#!/usr/bin/env python3
"""cgpt-approval-bridge : controleur de validation persistant, relai OC <-> CGPT.

OC propose une ecriture ou action sensible -> PENDING persistant.
CGPT liste, approuve ou rejette -> decision persistante.
OC sonde le statut -> applique uniquement sur APPROVED explicite.

Protocole : MCP sur stdio (JSON-RPC 2.0, une reponse par ligne).
Dependances : stdlib uniquement.
Etat : fichier JSON atomique (tmp + replace), chemin via CGPT_APPROVAL_STORE.
"""
import json
import os
import sys
import uuid
from datetime import datetime, timezone
from urllib import error, parse, request


SERVER_NAME = "cgpt-approval-bridge"
SERVER_VERSION = "0.1.0"
MCP_PROTOCOL_VERSION = "2024-11-05"

DEFAULT_STORE = "/tmp/opencode/cgpt-approvals.json"
DEFAULT_TTL_SECONDS = 86400
DEFAULT_CONTROLLER_URL = "http://127.0.0.1:8788"

VALID_STATES = ("PENDING", "APPROVED", "REJECTED", "CANCELLED", "EXPIRED")
DECIDABLE = ("PENDING",)


def store_path():
    """Retourne le chemin du magasin persistant."""
    path = os.environ.get("CGPT_APPROVAL_STORE", DEFAULT_STORE)
    return path


def utc_now():
    """Horodatage UTC RFC 3339."""
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def ensure_parent(path):
    """Cree le repertoire parent si necessaire."""
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)


def load_store(path):
    """Charge le magasin, retourne dict avec cle 'approvals'."""
    try:
        with open(path, "r", encoding="utf-8") as handle:
            data = json.load(handle)
    except FileNotFoundError:
        return {"approvals": {}}
    except (json.JSONDecodeError, OSError) as exc:
        raise StoreError("magasin illisible: %s" % exc)
    if not isinstance(data, dict) or not isinstance(data.get("approvals"), dict):
        raise StoreError("magasin corrompu: structure inattendue")
    return data


def save_store(path, data):
    """Ecriture atomique du magasin."""
    ensure_parent(path)
    tmp_path = path + ".tmp.%s" % os.getpid()
    try:
        with open(tmp_path, "w", encoding="utf-8") as handle:
            json.dump(data, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
        os.replace(tmp_path, path)
    except OSError as exc:
        raise StoreError("ecriture magasin impossible: %s" % exc)
    finally:
        try:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
        except OSError:
            pass


def notify_controller(item):
    """Notifie le controleur local sans affecter la reponse MCP stdio."""
    controller_url = os.environ.get("CGPT_CONTROLLER_URL", DEFAULT_CONTROLLER_URL)
    payload = json.dumps(
        {"event": "validation.request", "approval": item},
        ensure_ascii=False,
    ).encode("utf-8")
    http_request = request.Request(
        controller_url.rstrip("/") + "/validation/request",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with request.urlopen(http_request, timeout=2) as response:
            return 200 <= response.status < 300
    except (error.URLError, OSError):
        return False


def controller_decision(approval_id):
    """Lit une decision unique du controleur pour le prochain sondage OC."""
    controller_url = os.environ.get("CGPT_CONTROLLER_URL", DEFAULT_CONTROLLER_URL)
    url = controller_url.rstrip("/") + "/decision/" + parse.quote(approval_id, safe="")
    try:
        with request.urlopen(url, timeout=2) as response:
            if response.status != 200:
                return None
            payload = json.loads(response.read().decode("utf-8"))
    except (error.URLError, error.HTTPError, OSError, ValueError):
        return None
    if payload.get("decision") not in ("approved", "rejected"):
        return None
    return payload


class StoreError(Exception):
    """Erreur explicite du magasin persistant."""


class ValidationError(Exception):
    """Erreur explicite de validation d'entree."""


def new_approval_id():
    """Identifiant stable inter-composants."""
    return "apr-" + uuid.uuid4().hex[:12]


def check_expired(item):
    """Bascule PENDING vers EXPIRED si echeance depassee."""
    if item.get("status") != "PENDING":
        return item
    expires_at = item.get("expires_at")
    if not expires_at:
        return item
    if expires_at <= utc_now():
        item["status"] = "EXPIRED"
    return item


def require_str(args, name, max_len=500):
    """Valide une chaine obligatoire non vide."""
    value = args.get(name)
    if not isinstance(value, str) or not value.strip():
        raise ValidationError("parametre '%s' obligatoire et non vide" % name)
    if len(value) > max_len:
        raise ValidationError("parametre '%s' trop long (max %d)" % (name, max_len))
    return value.strip()


def require_list_str(args, name, max_items=50):
    """Valide une liste de chaines."""
    value = args.get(name)
    if not isinstance(value, list) or not value:
        raise ValidationError("parametre '%s' : liste non vide obligatoire" % name)
    if len(value) > max_items:
        raise ValidationError("parametre '%s' : trop d elements" % name)
    cleaned = []
    for entry in value:
        if not isinstance(entry, str) or not entry.strip():
            raise ValidationError("parametre '%s' : entree vide interdite" % name)
        cleaned.append(entry.strip())
    return cleaned


def do_propose(args):
    """OC -> cree une demande PENDING persistante, idempotente sur approval_id."""
    change_id = require_str(args, "change_id", 200)
    title = require_str(args, "title", 300)
    files = require_list_str(args, "files")
    summary = args.get("summary", "")
    if summary is not None and not isinstance(summary, str):
        raise ValidationError("parametre 'summary' : chaine attendue")
    summary = (summary or "")[:2000]
    approval_id = args.get("approval_id", "")
    request_id = args.get("requestId", "")
    if approval_id is not None and approval_id != "" and not isinstance(approval_id, str):
        raise ValidationError("parametre 'approval_id' : chaine attendue")
    if request_id is not None and request_id != "" and not isinstance(request_id, str):
        raise ValidationError("parametre 'requestId' : chaine attendue")
    approval_id = approval_id.strip() if isinstance(approval_id, str) else ""
    request_id = request_id.strip() if isinstance(request_id, str) else ""
    if approval_id and request_id and approval_id != request_id:
        raise ValidationError("approval_id et requestId doivent etre identiques")
    if not approval_id:
        approval_id = request_id
    ttl = args.get("ttl_seconds", DEFAULT_TTL_SECONDS)
    if not isinstance(ttl, int) or ttl < 60 or ttl > 604800:
        raise ValidationError("parametre 'ttl_seconds' : entier entre 60 et 604800")
    path = store_path()
    data = load_store(path)
    approvals = data["approvals"]
    if approval_id and approval_id in approvals:
        existing = check_expired(approvals[approval_id])
        if (
            existing.get("change_id") == change_id
            and existing.get("title") == title
        ):
            save_store(path, data)
            return existing
        raise ValidationError("approval_id '%s' deja utilise avec un contenu different" % approval_id)
    if not approval_id:
        approval_id = new_approval_id()
        while approval_id in approvals:
            approval_id = new_approval_id()
    now = utc_now()
    item = {
        "approval_id": approval_id,
        "requestId": approval_id,
        "change_id": change_id,
        "title": title,
        "files": files,
        "summary": summary,
        "status": "PENDING",
        "requester": "OC",
        "reviewer": "",
        "comment": "",
        "created_at": now,
        "updated_at": now,
        "expires_at": datetime.now(timezone.utc).timestamp() + ttl,
    }
    # Stocke l echeance en ISO pour lisibilite.
    item["expires_at"] = datetime.fromtimestamp(
        item["expires_at"], tz=timezone.utc
    ).isoformat().replace("+00:00", "Z")
    approvals[approval_id] = item
    save_store(path, data)
    notify_controller(item)
    return item


def do_get(args):
    """OC/CGPT -> detail d une demande, avec bascule EXPIRED si besoin."""
    approval_id = require_str(args, "approval_id", 100)
    path = store_path()
    data = load_store(path)
    item = data["approvals"].get(approval_id)
    if item is None:
        raise ValidationError("approval_id '%s' inconnu" % approval_id)
    item = check_expired(item)
    if item.get("status") == "PENDING":
        decision = controller_decision(approval_id)
        if decision is not None:
            item["status"] = "APPROVED" if decision["decision"] == "approved" else "REJECTED"
            item["reviewer"] = decision.get("reviewer", "CGPT")
            item["comment"] = decision.get("comment", "")
            item["updated_at"] = utc_now()
    save_store(path, data)
    return item


def do_list(args):
    """CGPT -> liste les demandes, filtre optionnel par status."""
    status = args.get("status", "")
    if status and status not in VALID_STATES:
        raise ValidationError("status inconnu, attendu parmi %s" % ",".join(VALID_STATES))
    path = store_path()
    data = load_store(path)
    items = []
    changed = False
    for item in data["approvals"].values():
        before = item.get("status")
        item = check_expired(item)
        if item.get("status") != before:
            changed = True
        if not status or item.get("status") == status:
            items.append(item)
    if changed:
        save_store(path, data)
    items.sort(key=lambda x: x.get("created_at", ""))
    limit = args.get("limit", 50)
    if not isinstance(limit, int) or limit < 1 or limit > 200:
        raise ValidationError("parametre 'limit' : entier entre 1 et 200")
    return {"approvals": items[:limit], "count": len(items)}


def do_decide(args, decision):
    """CGPT -> APPROVED ou REJECTED, echec ferme hors PENDING."""
    approval_id = require_str(args, "approval_id", 100)
    reviewer = require_str(args, "reviewer", 100)
    comment = args.get("comment", "")
    if comment is not None and not isinstance(comment, str):
        raise ValidationError("parametre 'comment' : chaine attendue")
    comment = (comment or "")[:2000]
    path = store_path()
    data = load_store(path)
    item = data["approvals"].get(approval_id)
    if item is None:
        raise ValidationError("approval_id '%s' inconnu" % approval_id)
    item = check_expired(item)
    if item.get("status") not in DECIDABLE:
        raise ValidationError(
            "decision refusee : statut '%s' non decidable" % item.get("status")
        )
    item["status"] = decision
    item["reviewer"] = reviewer
    item["comment"] = comment
    item["updated_at"] = utc_now()
    save_store(path, data)
    return item


def do_cancel(args):
    """OC -> annule une demande PENDING."""
    approval_id = require_str(args, "approval_id", 100)
    path = store_path()
    data = load_store(path)
    item = data["approvals"].get(approval_id)
    if item is None:
        raise ValidationError("approval_id '%s' inconnu" % approval_id)
    item = check_expired(item)
    if item.get("status") not in DECIDABLE:
        raise ValidationError(
            "annulation refusee : statut '%s' non annulable" % item.get("status")
        )
    item["status"] = "CANCELLED"
    item["updated_at"] = utc_now()
    save_store(path, data)
    return item


TOOLS = [
    {
        "name": "propose_approval",
        "description": "OC propose une ecriture OpenSpec a CGPT, cree un PENDING persistant.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "change_id": {"type": "string"},
                "title": {"type": "string"},
                "files": {"type": "array", "items": {"type": "string"}},
                "summary": {"type": "string"},
                "approval_id": {"type": "string"},
                "requestId": {"type": "string"},
                "ttl_seconds": {"type": "integer"},
            },
            "required": ["change_id", "title", "files"],
        },
    },
    {
        "name": "poll_approval",
        "description": "OC sonde la decision CGPT pour un approval_id.",
        "inputSchema": {
            "type": "object",
            "properties": {"approval_id": {"type": "string"}},
            "required": ["approval_id"],
        },
    },
    {
        "name": "get_approval",
        "description": "Lit le detail d une demande.",
        "inputSchema": {
            "type": "object",
            "properties": {"approval_id": {"type": "string"}},
            "required": ["approval_id"],
        },
    },
    {
        "name": "list_pending",
        "description": "CGPT liste les demandes, filtre status et limite.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "status": {"type": "string"},
                "limit": {"type": "integer"},
            },
        },
    },
    {
        "name": "approve",
        "description": "CGPT approuve une demande PENDING.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "approval_id": {"type": "string"},
                "reviewer": {"type": "string"},
                "comment": {"type": "string"},
            },
            "required": ["approval_id", "reviewer"],
        },
    },
    {
        "name": "reject",
        "description": "CGPT rejette une demande PENDING.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "approval_id": {"type": "string"},
                "reviewer": {"type": "string"},
                "comment": {"type": "string"},
            },
            "required": ["approval_id", "reviewer"],
        },
    },
    {
        "name": "cancel_approval",
        "description": "OC annule une demande PENDING.",
        "inputSchema": {
            "type": "object",
            "properties": {"approval_id": {"type": "string"}},
            "required": ["approval_id"],
        },
    },
    {
        "name": "request_validation",
        "description": "OC demande une validation CGPT : cree un PENDING persistant et retourne l approval_id a sonder.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "change_id": {"type": "string"},
                "title": {"type": "string"},
                "files": {"type": "array", "items": {"type": "string"}},
                "summary": {"type": "string"},
                "approval_id": {"type": "string"},
                "requestId": {"type": "string"},
                "ttl_seconds": {"type": "integer"},
            },
            "required": ["change_id", "title", "files"],
        },
    },
]


def ok_result(request_id, result):
    """Enveloppe JSON-RPC de succes."""
    return {"jsonrpc": "2.0", "id": request_id, "result": result}


def ok_tools_call(payload):
    """Formate un resultat d outil MCP."""
    return {"content": [{"type": "text", "text": json.dumps(payload, ensure_ascii=False)}]}


def err_result(request_id, code, message):
    """Enveloppe JSON-RPC d erreur."""
    return {"jsonrpc": "2.0", "id": request_id, "error": {"code": code, "message": message}}


def handle_request(req):
    """Route une requete JSON-RPC vers le handler MCP."""
    if not isinstance(req, dict):
        return err_result(None, -32600, "requete invalide : objet attendu")
    request_id = req.get("id")
    method = req.get("method")
    params = req.get("params") or {}
    if not isinstance(params, dict):
        return err_result(request_id, -32602, "params : objet attendu")
    try:
        if method == "initialize":
            return ok_result(
                request_id,
                {
                    "protocolVersion": MCP_PROTOCOL_VERSION,
                    "capabilities": {"tools": {"listChanged": False}},
                    "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
                },
            )
        if method in ("notifications/initialized", "notifications/cancelled"):
            return None
        if method == "ping":
            return ok_result(request_id, {})
        if method == "tools/list":
            return ok_result(request_id, {"tools": TOOLS})
        if method == "tools/call":
            name = params.get("name", "")
            args = params.get("arguments") or {}
            if not isinstance(args, dict):
                return err_result(request_id, -32602, "arguments : objet attendu")
            if name == "propose_approval":
                return ok_result(request_id, ok_tools_call(do_propose(args)))
            if name in ("poll_approval", "get_approval"):
                return ok_result(request_id, ok_tools_call(do_get(args)))
            if name == "list_pending":
                return ok_result(request_id, ok_tools_call(do_list(args)))
            if name == "approve":
                return ok_result(request_id, ok_tools_call(do_decide(args, "APPROVED")))
            if name == "reject":
                return ok_result(request_id, ok_tools_call(do_decide(args, "REJECTED")))
            if name == "cancel_approval":
                return ok_result(request_id, ok_tools_call(do_cancel(args)))
            if name == "request_validation":
                item = do_propose(args)
                item["hint"] = "sonder via poll_approval jusqu a APPROVED explicite"
                return ok_result(request_id, ok_tools_call(item))
            return err_result(request_id, -32601, "outil inconnu : %s" % name)
        return err_result(request_id, -32601, "methode inconnue : %s" % method)
    except ValidationError as exc:
        return err_result(request_id, -32602, str(exc))
    except StoreError as exc:
        return err_result(request_id, -32000, str(exc))
    except Exception as exc:  # noqa: BLE001 - echec ferme explicite
        return err_result(request_id, -32603, "erreur interne : %s" % exc)


def main():
    """Boucle stdio : une requete JSON par ligne, une reponse par ligne."""
    stdin = sys.stdin
    stdout = sys.stdout
    for line in stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except json.JSONDecodeError:
            stdout.write(json.dumps(err_result(None, -32700, "JSON invalide")) + "\n")
            stdout.flush()
            continue
        resp = handle_request(req)
        if resp is None:
            continue
        stdout.write(json.dumps(resp, ensure_ascii=False) + "\n")
        stdout.flush()


if __name__ == "__main__":
    main()
