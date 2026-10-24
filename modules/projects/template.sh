#!/usr/bin/env bash

projects_template_openspec() {
    local project_id="${1:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-/home/${ENV_DEVOPS_USER:-}/datas}"
    local project_path="${projects_root}/${project_id}"
    local openspec_command="" command=""
    local opencode="${OPENCODE:-}"

    if [[ "$#" -ne 1 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ||
        -z "${project_id}" || "${project_id}" == */* || "${project_id}" == . ||
        "${project_id}" == .. || "${project_id}" =~ [[:cntrl:]] ]]; then
        print_error 'Usage : rid projects template openspec <ID PROJECT> (identifiant sans chemin et utilisateur DevOps valide).'
        return 1
    fi
    if [[ -L "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Le dossier du projet est absent ou symbolique : ${project_path}"
        return 1
    fi
    if [[ -L "${project_path}/openspec" ||
        ( -e "${project_path}/openspec" && ! -d "${project_path}/openspec" ) ]]; then
        print_error 'La cible openspec doit être un répertoire ordinaire.'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi

    if [[ -d "${project_path}/openspec" ]]; then
        openspec_command='openspec update'
    else
        if [[ ! -d "${project_path}/.opencode" ]]; then
            opencode=0
        fi
        case "${opencode}" in
            1) openspec_command='openspec init --tools opencode --profile custom' ;;
            0) openspec_command='openspec init --profile custom' ;;
            *) print_error 'OPENCODE doit valoir 0 ou 1 pour initialiser OpenSpec.'; return 1 ;;
        esac
    fi

    # Un chemin absolu et des apostrophes échappées préservent le chemin dans le shell de connexion.
    if ! project_path="$(cd -- "${project_path}" && pwd -P)"; then
        print_error 'Impossible de résoudre le répertoire du projet.'
        return 1
    fi
    command="cd '${project_path//\'/\'\\\'\'}' && ${openspec_command}"
    if ! su - "${ENV_DEVOPS_USER}" -c "${command}"; then
        print_error "Initialisation ou mise à jour OpenSpec échouée : ${project_path}"
        return 1
    fi
    print_success "OpenSpec préparé : ${project_path}"
}

# Les outils hôte ne doivent pas être résolus dans le PATH DevOps.
projects_template_devops_host_binary() {
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin type -P -- "$1"
}

projects_template_devops_user_run() {
    local devops_home="$1"
    shift
    local user_path="${devops_home}/node/current/bin:${devops_home}/python/current/bin:${devops_home}/go/current/bin:/usr/local/bin:/usr/bin:/bin"

    if [[ "$(id -un)" == "${ENV_DEVOPS_USER}" ]]; then
        (
            cd -- "${devops_home}" || return 1
            PATH="${user_path}" GOTOOLCHAIN=local /usr/bin/timeout 15s "$@"
        )
    else
        # Expansion des arguments dans le shell enfant, après changement d'utilisateur.
        # shellcheck disable=SC2016
        runuser -u "${ENV_DEVOPS_USER}" -- env PATH="${user_path}" GOTOOLCHAIN=local \
            bash -c 'cd -- "$1" || exit 1; shift; exec /usr/bin/timeout 15s "$@"' \
            bash "${devops_home}" "$@"
    fi
}

projects_template_devops_prepare_executables() {
    local devops_home="$1" canonical_home="" relative="" target="" mode=""

    if ! canonical_home="$(readlink -f -- "${devops_home}" 2>/dev/null)" ||
        [[ ! -d "${canonical_home}" ]]; then
        print_error 'Impossible de résoudre le domicile DevOps pour préparer les exécutables.'
        return 1
    fi
    for relative in go/current/bin/go node/current/bin/node node/current/bin/npm \
        .opencode/bin/opencode .local/npm/bin/openspec \
        python/current/bin/python3 python/current/bin/pip3; do
        if [[ ! -e "${devops_home}/${relative}" && ! -L "${devops_home}/${relative}" ]]; then
            continue
        fi
        if ! target="$(readlink -f -- "${devops_home}/${relative}" 2>/dev/null)" ||
            [[ "${target}" != "${canonical_home}/"* ]]; then
            print_error "Cible DevOps non résolue ou hors du domicile : ${relative}."
            return 1
        fi
        if [[ ! -e "${target}" ]]; then
            continue
        fi
        if [[ ! -f "${target}" ]]; then
            print_error "Le binaire DevOps doit être un fichier ordinaire : ${relative}."
            return 1
        fi
        if ! mode="$(stat -c '%a' -- "${target}" 2>/dev/null)" ||
            [[ ! "${mode}" =~ ^[0-7]{3,4}$ ]]; then
            print_error "Impossible de lire les droits du binaire DevOps : ${relative}."
            return 1
        fi
        if (( (8#${mode} & 8#111) != 8#111 )); then
            if ! chmod ugo+x -- "${target}" 2>/dev/null; then
                print_error "Impossible de rendre le binaire DevOps exécutable : ${relative}."
                return 1
            fi
        fi
    done
}

projects_template_devops_version() {
    local context="$1" devops_home="$2" binary="$3"
    local output=""
    shift 3

    if [[ -z "${binary}" || ! -e "${binary}" ]]; then
        printf '%s\n' 'indisponible (binaire absent)'
        return 0
    fi
    if [[ ! -f "${binary}" || ! -x "${binary}" ]]; then
        printf '%s\n' 'indisponible (binaire non exécutable)'
        return 0
    fi

    if [[ "${context}" == node && ! -x "${devops_home}/node/current/bin/node" ]]; then
        printf '%s\n' 'indisponible (Node DevOps absent)'
        return 0
    fi
    if [[ "${context}" == python && ! -x "${devops_home}/python/current/bin/python3" ]]; then
        printf '%s\n' 'indisponible (Python DevOps absent)'
        return 0
    fi

    if [[ "${context}" == host ]]; then
        if ! output="$(/usr/bin/timeout 15s "${binary}" "$@" 2>/dev/null)"; then
            printf '%s\n' 'indisponible (sonde échouée)'
            return 0
        fi
    else
        case "${context}" in
            node)
                if ! output="$(projects_template_devops_user_run "${devops_home}" \
                    "${devops_home}/node/current/bin/node" "${binary}" "$@" 2>/dev/null)"; then
                    printf '%s\n' 'indisponible (sonde échouée)'
                    return 0
                fi
                ;;
            python)
                if ! output="$(projects_template_devops_user_run "${devops_home}" \
                    "${devops_home}/python/current/bin/python3" -I -B "${binary}" "$@" 2>/dev/null)"; then
                    printf '%s\n' 'indisponible (sonde échouée)'
                    return 0
                fi
                ;;
            *)
                if ! output="$(projects_template_devops_user_run "${devops_home}" "${binary}" "$@" 2>/dev/null)"; then
                    printf '%s\n' 'indisponible (sonde échouée)'
                    return 0
                fi
                ;;
        esac
    fi

    if [[ "${output}" =~ [0-9]+(\.[0-9]+){1,3}[[:alnum:].+-]* ]]; then
        printf '%s\n' "${BASH_REMATCH[0]}"
    else
        printf '%s\n' 'indisponible (version non reconnue)'
    fi
}

projects_template_devops_section() {
    local title="$1" version="$2" binary="$3"
    if [[ "${title}" == Docker ]]; then
        printf '# Conteneur %s, pour tests nécessitant des droits root\n\n  * %s\n  * %s\n  * /var/run/docker.sock\n  * debian:stable-slim\n\n\n' \
            "${title}" "${version}" "${binary:-binaire introuvable}"
    else
        printf '# %s\n\n  * %s\n  * %s\n\n\n' \
            "${title}" "${version}" "${binary:-binaire introuvable}"
    fi
}

projects_template_devops_tpm_device() {
    local device_root="$1" candidate=""
    local LC_ALL=C
    for candidate in "${device_root}"/tpmrm[0-9]* "${device_root}"/tpm[0-9]*; do
        if [[ -c "${candidate}" && "${candidate##*/}" =~ ^tpm(rm)?[0-9]+$ ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done
    return 1
}

projects_template_devops_tpm_property() {
    local output="$1" property="$2" field="$3" pattern="$4"
    local line="" current="" value="" blocks=0 values=0
    while IFS= read -r line; do
        if [[ "${line}" =~ ^([A-Z0-9_]+):[[:space:]]*$ ]]; then
            current="${BASH_REMATCH[1]}"
            if [[ "${current}" == "${property}" ]]; then
                blocks=$((blocks + 1))
            fi
        elif [[ "${current}" == "${property}" &&
            "${line}" =~ ^[[:space:]]+(raw|value):[[:space:]]*(.*)$ &&
            "${BASH_REMATCH[1]}" == "${field}" ]]; then
            value="${BASH_REMATCH[2]}"
            values=$((values + 1))
        fi
    done <<< "${output}"
    if [[ "${value}" == \"*\" ]]; then
        value="${value:1:${#value}-2}"
    fi
    if [[ "${blocks}" -ne 1 || "${values}" -ne 1 || ! "${value}" =~ ${pattern} ]]; then
        return 1
    fi
    printf '%s\n' "${value}"
}

projects_template_devops_tpm_pcrs() {
    local output="$1" line="" bank="" selection="" value="" result="" banks=',' seen=""
    local header=0
    local pattern='^[[:space:]]*-[[:space:]]+([a-z][a-z0-9_]{0,31}):[[:space:]]*\[([^]]*)\][[:space:]]*$'
    local indices_pattern='^[[:space:]]*([0-9]{1,3}([[:space:]]*,[[:space:]]*[0-9]{1,3})*)?[[:space:]]*$'
    local -a indices=()
    while IFS= read -r line; do
        if [[ "${line}" == 'selected-pcrs:' && "${header}" -eq 0 ]]; then
            header=1
        elif [[ "${line}" =~ ^[[:space:]]*$ ]]; then
            continue
        elif [[ "${header}" -eq 1 && "${line}" =~ ${pattern} ]]; then
            bank="${BASH_REMATCH[1]}"
            selection="${BASH_REMATCH[2]}"
            if [[ "${banks}" == *",${bank},"* || ! "${selection}" =~ ${indices_pattern} ]]; then
                return 1
            fi
            banks+="${bank},"
            IFS=',' read -r -a indices <<< "${selection}"
            selection='' seen=','
            for value in "${indices[@]}"; do
                value="${value//[[:space:]]/}"
                [[ -n "${value}" ]] || continue
                value="$((10#${value}))"
                if [[ "${value}" -gt 255 || "${seen}" == *",${value},"* ]]; then
                    return 1
                fi
                seen+="${value},"
                selection+="${selection:+, }${value}"
            done
            result+="${result:+ ; }${bank}: [${selection}]"
        else
            return 1
        fi
    done <<< "${output}"
    [[ -n "${result}" ]] || return 1
    printf '%s\n' "${result}"
}

projects_template_devops_tpm() {
    local device_root="${1:-/dev}" sysfs_root="${2:-/sys/class/tpm}"
    local device="" index="" major="" binary="" output="" status=0
    local version='non vérifiable' manufacturer='non vérifiable'
    local vendor='non vérifiable' revision='non vérifiable' pcrs='non vérifiable'
    local diagnostic='indisponible (aucun périphérique TPM visible)'

    if device="$(projects_template_devops_tpm_device "${device_root}")"; then
        index="${device##*/tpm}"
        index="${index#rm}"
        if [[ -r "${sysfs_root}/tpm${index}/tpm_version_major" ]] &&
            IFS= read -r major < "${sysfs_root}/tpm${index}/tpm_version_major"; then
            case "${major}" in
                1) version=1.2 ;;
                2) version=2.0 ;;
            esac
        fi
        if [[ "${version}" == 1.2 ]]; then
            diagnostic='non vérifiable (sonde réservée au TPM 2)'
        elif [[ ! -r "${device}" || ! -w "${device}" ]]; then
            diagnostic='non vérifiable (accès au périphérique refusé)'
        elif ! binary="$(projects_template_devops_host_binary tpm2_getcap)" || [[ ! -x "${binary}" ]]; then
            diagnostic='non vérifiable (tpm2_getcap absent)'
        else
            diagnostic=''
            if output="$(/usr/bin/timeout --kill-after=1s 5s "${binary}" -T "device:${device}" properties-fixed 2>/dev/null)"; then
                if [[ "${#output}" -le 65536 ]]; then
                    if [[ "${version}" == 'non vérifiable' ]]; then
                        version="$(projects_template_devops_tpm_property "${output}" TPM2_PT_FAMILY_INDICATOR value '^2[.]0$')" || version='non vérifiable'
                    fi
                    manufacturer="$(projects_template_devops_tpm_property "${output}" TPM2_PT_MANUFACTURER value '^[A-Za-z0-9][A-Za-z0-9 ._-]{0,31}$')" || manufacturer='non vérifiable'
                    vendor="$(projects_template_devops_tpm_property "${output}" TPM2_PT_MANUFACTURER raw '^0[xX][0-9A-Fa-f]{1,8}$')" || vendor='non vérifiable'
                    revision="$(projects_template_devops_tpm_property "${output}" TPM2_PT_REVISION value '^[0-9]{1,3}[.][0-9]{2}$')" || revision='non vérifiable'
                fi
            else
                status=$?
                manufacturer='non vérifiable (sonde échouée)'
                if [[ "${status}" -eq 124 || "${status}" -eq 137 ]]; then
                    manufacturer='non vérifiable (sonde expirée)'
                fi
                vendor="${manufacturer}" revision="${manufacturer}"
            fi
            if output="$(/usr/bin/timeout --kill-after=1s 5s "${binary}" -T "device:${device}" pcrs 2>/dev/null)"; then
                if [[ "${#output}" -le 65536 ]]; then
                    pcrs="$(projects_template_devops_tpm_pcrs "${output}")" || pcrs='non vérifiable'
                fi
            else
                status=$?
                pcrs='non vérifiable (sonde échouée)'
                if [[ "${status}" -eq 124 || "${status}" -eq 137 ]]; then
                    pcrs='non vérifiable (sonde expirée)'
                fi
            fi
        fi
    else
        device="${diagnostic}"
        version="${diagnostic}"
    fi
    if [[ -n "${diagnostic}" ]]; then
        manufacturer="${diagnostic}" vendor="${diagnostic}" revision="${diagnostic}" pcrs="${diagnostic}"
    fi
    printf '# Matériel\n\n## TPM\n\n  * Chemin : %s\n  * Version : %s\n  * Fabricant : %s\n  * Identifiant fournisseur : %s\n  * Révision de spécification : %s\n  * Registres PCR : %s\n\n\n' \
        "${device}" "${version}" "${manufacturer}" "${vendor}" "${revision}" "${pcrs}"
}

projects_template_devops_postgresql() {
    local project_env="$1" psql_binary="$2"
    if [[ ! -x /usr/bin/python3 ]]; then
        printf '  * indisponible (Python système absent pour la lecture de configuration)\n  * adresse non vérifiée\n'
        return 0
    fi

    # Le parseur ne restitue jamais les identifiants, les valeurs du fichier ou
    # les erreurs brutes de psql, et ne peut pas exécuter une expression shell.
    /usr/bin/python3 -I -B - "${project_env}" "${psql_binary}" <<'PY'
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys

config_path, psql = sys.argv[1:]
keys = {'PG_HOST', 'PG_SERVER', 'PG_PORT', 'PG_DATABASE', 'PG_USERNAME',
        'PG_USER', 'PG_PASSWORD', 'PG_SSLMODE'}
values = {}
version = 'indisponible (configuration absente ou invalide)'
address = 'adresse non configurée'
diagnostic = 'fichier project.env absent ou illisible'
try:
    lines = Path(config_path).read_text(encoding='utf-8').splitlines()
    for line in lines:
        match = re.match(r'^\s*(?:export\s+)?([A-Z_]+)\s*=\s*(.*)$', line)
        if not match or match[1] not in keys:
            continue
        literal = match[2].strip()
        diagnostic = f'affectation non littérale pour {match[1]}'
        # shlex retire les guillemets sans développer variables ou commandes.
        # Les caractères spéciaux d'un mot de passe restent donc littéraux.
        parsed = shlex.split(literal, comments=True)
        if len(parsed) > 1:
            raise ValueError('affectation non littérale')
        values[match[1]] = parsed[0] if parsed else ''
    host = values.get('PG_HOST') or values.get('PG_SERVER', '')
    port = values.get('PG_PORT', '')
    if not values.get('PG_HOST') and host.count(':') == 1:
        host, server_port = host.split(':')
        port = port or server_port
    port = port or '5432'
    diagnostic = 'PG_HOST ou PG_SERVER absent' if not host else 'adresse invalide'
    if not re.fullmatch(r'[A-Za-z0-9_./:-]+', host):
        raise ValueError('adresse invalide')
    diagnostic = 'PG_PORT invalide'
    if not port.isascii() or not port.isdigit() or not 0 < int(port) < 65536:
        raise ValueError('port invalide')
    address = f'[{host}]:{port}' if ':' in host else f'{host}:{port}'
    version = 'indisponible (client PostgreSQL absent)'
    if psql and os.access(psql, os.X_OK):
        # Éviter tout paramètre PostgreSQL hérité du shell appelant.
        environment = {key: value for key, value in os.environ.items() if not key.startswith('PG')}
        environment.update(PGHOST=host, PGPORT=port,
                           PGDATABASE=values.get('PG_DATABASE', 'postgres'),
                           PGUSER=values.get('PG_USERNAME') or values.get('PG_USER', ''),
                           PGPASSWORD=values.get('PG_PASSWORD', ''),
                           PGCONNECT_TIMEOUT='5', PGOPTIONS='-c statement_timeout=5000')
        sslmode = values.get('PG_SSLMODE', 'prefer')
        if sslmode not in {'disable', 'allow', 'prefer', 'require', 'verify-ca', 'verify-full'}:
            raise ValueError('sslmode invalide')
        environment['PGSSLMODE'] = sslmode
        result = subprocess.run([psql, '-X', '-w', '-A', '-t', '-q', '-c', 'SHOW server_version;'],
                                env=environment, capture_output=True, text=True, timeout=10, check=False)
        observed = re.match(r'^\s*([0-9]+(?:\.[0-9]+){0,2})(?:\s|$)', result.stdout)
        version = observed[1] if result.returncode == 0 and observed else 'indisponible (serveur inaccessible ou version non vérifiable)'
except (OSError, ValueError, UnicodeError, subprocess.TimeoutExpired):
    if address != 'adresse non configurée':
        version = 'indisponible (connexion ou configuration non vérifiable)'
    else:
        version = f'indisponible (configuration absente ou invalide : {diagnostic})'
print(f'  * {version}\n  * {address}')
PY
}

projects_template_devops_python_manifest() {
    local devops_home="$1" project_path="$2" project_id="$3"
    if [[ -e "${project_path}/pyproject.toml" || -L "${project_path}/pyproject.toml" ]]; then
        return 0
    fi
    if [[ ! -x /usr/bin/python3 ]]; then
        print_error 'Impossible de vérifier PROJECT_TYPE : Python système absent.'
        return 1
    fi

    projects_template_devops_user_run "${devops_home}" /usr/bin/python3 -I -B - \
        "${project_path}" "${project_id}" <<'PY'
from pathlib import Path
import re
import shlex
import sys

project_path = Path(sys.argv[1])
try:
    lines = (project_path / 'project.env').read_text(encoding='utf-8').splitlines()
except FileNotFoundError:
    sys.exit(0)
except (OSError, UnicodeError):
    print('Impossible de lire PROJECT_TYPE dans project.env.', file=sys.stderr)
    sys.exit(1)
project_type = ''
try:
    for line in lines:
        match = re.match(r'^\s*(?:export\s+)?PROJECT_TYPE\s*=\s*(.*)$', line)
        if match:
            values = shlex.split(match[1], comments=True)
            if len(values) > 1:
                raise ValueError('affectation non littérale')
            project_type = values[0] if values else ''
except ValueError:
    print('PROJECT_TYPE doit être une affectation littérale.', file=sys.stderr)
    sys.exit(1)
if project_type == 'PYTHON':
    name = re.sub(r'[^A-Za-z0-9._-]', '-', sys.argv[2]).strip('._-') or 'project'
    try:
        # Création exclusive : un manifeste apparu entre-temps reste conservé.
        with (project_path / 'pyproject.toml').open('x', encoding='utf-8', newline='\n') as stream:
            stream.write(f'[project]\nname = "{name}"\nversion = "0.0.0"\ndependencies = []\n')
    except FileExistsError:
        pass
    except OSError:
        print('Impossible de créer pyproject.toml pour le projet Python.', file=sys.stderr)
        sys.exit(1)
PY
}

projects_template_devops_dependencies() {
    local devops_home="$1" template_path="$2" python_binary="$3"
    local analyzer="${python_binary}" analysis_is_devops=1
    local manifest="${template_path}/pyproject.toml"
    if [[ ! -f "${manifest}" ]]; then
        printf '  * pyproject.toml absent : dépendances non déclarées dans le projet\n'
        return 0
    fi
    if [[ "${manifest}" != /* ]]; then
        manifest="${PWD}/${manifest}"
    fi
    if [[ ! -x "${analyzer}" ]]; then
        analyzer=/usr/bin/python3
        analysis_is_devops=0
    fi
    if [[ ! -x "${analyzer}" ]]; then
        printf "  * Dépendances non vérifiables : Python d'analyse absent\n"
        return 0
    fi

    projects_template_devops_user_run "${devops_home}" "${analyzer}" -I -B - \
        "${manifest}" "${python_binary}" "${analysis_is_devops}" <<'PY'
from importlib import metadata
from pathlib import Path
import json
import os
import re
import signal
import subprocess
import sys
import time

SEARCH_BUDGET = 12.0
PROBE_TIMEOUT = 3.0
IGNORED_DIRECTORIES = {
    ".git", ".hg", ".svn", ".cache", ".pytest_cache", ".mypy_cache",
    ".ruff_cache", ".npm", ".idea", ".vscode", ".stfolder", "node_modules",
    "__pycache__", "logs", "tmp", "output", "reports", "dist", "build",
    "PROMPTS", ".opencode", ".agents", "openspec", ".generated", ".history",
    ".output", ".tmp", "secrets", "credentials",
}
PROBE_PROGRAM = r'''
from importlib import metadata
from pathlib import Path
import json
import re
import site
import sys

root = Path(sys.argv[1])
wanted = set(json.loads(sys.argv[2]))
paths = sorted({str(Path(p).resolve()) for p in site.getsitepackages([str(root)])
                if Path(p).is_dir()})
if not paths:
    sys.exit(3)
found = {}
try:
    for distribution in metadata.distributions(path=paths):
        name = re.sub(r"[-_.]+", "-", distribution.metadata.get("Name", "")).lower()
        if name in wanted:
            if name in found:
                found[name] = None
            else:
                found[name] = {
                    "version": distribution.version,
                    "location": str(Path(distribution.locate_file("")).resolve()),
                }
except (OSError, UnicodeError, ValueError):
    sys.exit(3)
print(json.dumps(found, sort_keys=True))
'''


def safe_text(value):
    return (isinstance(value, str) and 0 < len(value) <= 4096
            and not any(ord(char) < 32 or ord(char) == 127 for char in value))


def valid_observation(value):
    return (isinstance(value, dict) and set(value) == {"version", "location"}
            and isinstance(value["version"], str)
            and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9.!+_-]{0,199}", value["version"]) is not None
            and safe_text(value["location"]) and Path(value["location"]).is_absolute())


def discover_environments(project_root, deadline):
    environments = []
    incomplete = False

    def on_error(_error):
        nonlocal incomplete
        incomplete = True

    for directory, directories, files in os.walk(project_root, followlinks=False, onerror=on_error):
        if time.monotonic() >= deadline:
            incomplete = True
            break
        path = Path(directory)
        if any(not safe_text(name) for name in directories):
            incomplete = True
        directories[:] = sorted(name for name in directories
                                if name not in IGNORED_DIRECTORIES
                                and safe_text(name) and not (path / name).is_symlink())
        if "pyvenv.cfg" in files:
            directories[:] = []
            marker = path / "pyvenv.cfg"
            if marker.is_file() and not marker.is_symlink():
                if safe_text(str(path)):
                    environments.append(path)
                else:
                    incomplete = True
            else:
                incomplete = True

    priority = {".venv": 0, "venv": 1, "env": 2}
    environments.sort(key=lambda p: (priority.get(str(p.relative_to(project_root)), 3),
                                     str(p.relative_to(project_root))))
    return environments, incomplete


def probe_environment(environment, names, deadline):
    remaining = deadline - time.monotonic()
    if remaining <= 0:
        return None
    interpreter = next((environment / "bin" / name for name in ("python3", "python")
                        if (environment / "bin" / name).is_file()
                        and os.access(environment / "bin" / name, os.X_OK)), None)
    if interpreter is None:
        return None
    try:
        with subprocess.Popen(
                [str(interpreter), "-I", "-B", "-S", "-", str(environment), json.dumps(sorted(names))],
                stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                text=True, start_new_session=True) as process:
            try:
                output, _errors = process.communicate(PROBE_PROGRAM, timeout=min(PROBE_TIMEOUT, remaining))
            except subprocess.TimeoutExpired:
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.communicate()
                return None
        if process.returncode != 0 or len(output) > 65536:
            return None
        result = json.loads(output)
        if not isinstance(result, dict) or not set(result).issubset(names):
            return None
        if any(value is not None and not valid_observation(value) for value in result.values()):
            return None
    except (OSError, UnicodeError, ValueError, subprocess.TimeoutExpired):
        return None
    return interpreter, result


def emit(label, version, interpreter, environment, location):
    print(f"  * {label} : {version} --> {interpreter}")
    print(f"    * Environnement : {environment}")
    print(f"    * Installation : {location}")


def main():
    try:
        import tomllib
    except ImportError:
        print("  * Lecture non disponible : module tomllib absent du Python d'analyse")
        return
    try:
        manifest = Path(sys.argv[1])
        project_root = manifest.parent.resolve()
        project = tomllib.loads(manifest.read_text(encoding="utf-8")).get("project", {})
        if not isinstance(project, dict):
            raise ValueError("projet invalide")
        dependencies = project.get("dependencies", [])
        dynamic = project.get("dynamic", [])
        if (not isinstance(dependencies, list) or not all(isinstance(item, str) for item in dependencies)
                or not isinstance(dynamic, list) or not all(isinstance(item, str) for item in dynamic)):
            raise ValueError("dependances invalides")
        declarations = []
        for dependency in dependencies:
            match = re.match(r"^([A-Za-z0-9][A-Za-z0-9._-]*)", dependency)
            if not match or not safe_text(dependency):
                raise ValueError("dependance invalide")
            constraint = dependency[match.end():].strip()
            if "@" in constraint:
                constraint = "(référence directe déclarée dans pyproject.toml)"
            name = match[1]
            declarations.append((re.sub(r"[-_.]+", "-", name).lower(),
                                 (name + " " + constraint).strip()))
    except (OSError, ValueError, UnicodeError):
        print("  * pyproject.toml illisible ou invalide : dépendances non vérifiables")
        return

    if "dependencies" in dynamic:
        print("  * Dépendances dynamiques : versions non vérifiables depuis pyproject.toml")
    elif not declarations:
        print("  * Aucune dépendance déclarée dans [project].dependencies")
    if not declarations:
        return

    wanted = {name for name, _label in declarations}
    selected = {}
    uncertain = set()
    deadline = time.monotonic() + SEARCH_BUDGET
    environments, incomplete = discover_environments(project_root, deadline)
    for environment in environments:
        missing = wanted - selected.keys()
        if not missing:
            break
        if time.monotonic() >= deadline:
            incomplete = True
            break
        observation = probe_environment(environment, missing, deadline)
        if observation is None:
            uncertain.update(missing)
            continue
        interpreter, values = observation
        for name, value in values.items():
            if value is None:
                uncertain.add(name)
            else:
                selected[name] = (str(interpreter), str(environment), value)

    if incomplete or uncertain:
        print("  * Recherche ou sonde des venv du projet non vérifiable : inventaire partiel.")
    global_binary = sys.argv[2]
    global_available = sys.argv[3] == "1"
    for name, label in declarations:
        if name in selected:
            interpreter, environment, value = selected[name]
            emit(label, value["version"], interpreter, environment, value["location"])
            continue
        if not global_available:
            emit(label, "non vérifiable (Python DevOps absent)", "indisponible",
                 "repli Python DevOps indisponible", "non observée")
            continue
        try:
            distribution = metadata.distribution(name)
            value = {"version": distribution.version,
                     "location": str(Path(distribution.locate_file("")).resolve())}
            if not valid_observation(value):
                raise ValueError("metadonnee invalide")
        except metadata.PackageNotFoundError:
            version = "non vérifiable" if incomplete or name in uncertain else "non installé"
            emit(label, version, global_binary, "Python DevOps (repli)", "non observée")
        except (OSError, UnicodeError, ValueError):
            emit(label, "non vérifiable", global_binary, "Python DevOps (repli)", "non observée")
        else:
            emit(label, value["version"], global_binary, "Python DevOps (repli)", value["location"])


main()
PY
}

projects_template_devops_timestamp() {
    local date_binary="" timestamp="" year month day last_day=31
    local utc_pattern='^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$'

    if ! date_binary="$(projects_template_devops_host_binary date)" ||
        ! timestamp="$(/usr/bin/timeout 15s "${date_binary}" -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" ||
        [[ ! "${timestamp}" =~ ${utc_pattern} ]]; then
        printf '%s\n' 'Horodatage UTC du relevé indisponible.' >&2
        return 1
    fi
    year=$((10#${timestamp:0:4}))
    month=$((10#${timestamp:5:2}))
    day=$((10#${timestamp:8:2}))
    if (( month == 2 )); then
        last_day=28
        if (( year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) )); then
            last_day=29
        fi
    elif (( month == 4 || month == 6 || month == 9 || month == 11 )); then
        last_day=30
    fi
    if (( year == 0 || day > last_day )); then
        printf '%s\n' 'Horodatage UTC du relevé indisponible.' >&2
        return 1
    fi
    printf '%s\n' "${timestamp}"
}

projects_template_devops_javascript() {
    local devops_home="$1" project_path="$2"
    local analyzer="${devops_home}/python/current/bin/python3"
    if [[ ! -x "${analyzer}" ]]; then
        analyzer=/usr/bin/python3
    fi
    if [[ ! -x "${analyzer}" ]]; then
        printf '## Dépendances JavaScript du projet\n\n  * Inventaire non vérifiable : analyseur absent\n\n\034'
        return 0
    fi
    if [[ "${project_path}" != /* ]]; then
        project_path="${PWD}/${project_path}"
    fi
    projects_template_devops_user_run "${devops_home}" "${analyzer}" -I -B -S - \
        "${project_path}" <<'PY_JS'
import fnmatch
from functools import lru_cache
import html
import json
import os
from pathlib import Path, PurePosixPath
import re
import stat
import sys
import time

JS_SEARCH_BUDGET = 12.0
MAX_ENTRIES = 10000
MAX_MANIFESTS = 128
MAX_DEPENDENCIES = 1024
JSON_LIMIT = 1024 * 1024
LOCK_LIMIT = 8 * 1024 * 1024
TOTAL_LIMIT = 32 * 1024 * 1024
GROUPS = ("dependencies", "devDependencies", "peerDependencies", "optionalDependencies")
LOCK_NAMES = ("npm-shrinkwrap.json", "package-lock.json", "pnpm-lock.yaml",
              "yarn.lock", "bun.lock", "bun.lockb")
IGNORED = {
    ".git", ".hg", ".svn", ".cache", ".npm", ".pytest_cache", ".mypy_cache",
    ".ruff_cache", ".idea", ".vscode", ".stfolder", ".agents", ".opencode",
    "node_modules", "__pycache__", ".venv", "venv", "env", "logs", "tmp",
    "output", "reports", "dist", "build", "PROMPTS", "openspec", "secrets",
    "credentials", ".generated", ".history", ".output", ".tmp",
}
NAME = re.compile(r"(?:@[A-Za-z0-9._-]+/)?[A-Za-z0-9][A-Za-z0-9._-]{0,213}\Z")
VERSION = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+(?:-[A-Za-z0-9.-]+)?(?:\+[A-Za-z0-9.-]+)?\Z")
CONSTRAINT = re.compile(r"[A-Za-z0-9.*+^~<>=| -]{1,200}\Z")
root = Path(sys.argv[1]).resolve()
deadline = time.monotonic() + JS_SEARCH_BUDGET
state = {"entries": 0, "bytes": 0, "dependencies": 0, "limits": set()}
root_fd = os.open(root, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)


class InventoryError(Exception):
    pass


def time_check():
    if time.monotonic() >= deadline:
        state["limits"].add("délai de collecte dépassé")
        raise InventoryError("délai de collecte dépassé")


def safe_path(path):
    return len(str(path)) <= 4096 and not any(ord(c) < 32 or ord(c) == 127 for c in str(path))


def markdown(value):
    value = html.escape("".join(c if ord(c) >= 32 and ord(c) != 127 else "?"
                              for c in str(value)), quote=False)
    for character in ("\\", "*", "_", "[", "]", chr(96), "#", "|"):
        value = value.replace(character, "\\" + character)
    return value


def valid_name(value):
    return (type(value) is str and len(value) <= 214 and NAME.fullmatch(value)
            and all(part not in (".", "..") for part in value.split("/")))


def directory_fd(relative):
    if not safe_path(relative):
        raise InventoryError("chemin non restituable")
    current = os.dup(root_fd)
    try:
        for part in relative.parts:
            if part in ("", "."):
                continue
            if part == "..":
                raise InventoryError("chemin hors périmètre")
            following = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                                dir_fd=current)
            os.close(current)
            current = following
        return current
    except (OSError, InventoryError):
        os.close(current)
        raise


def file_status(relative):
    try:
        parent = directory_fd(relative.parent)
        try:
            return os.stat(relative.name, dir_fd=parent, follow_symlinks=False)
        finally:
            os.close(parent)
    except FileNotFoundError:
        return None
    except OSError:
        raise InventoryError("chemin inaccessible ou symbolique") from None


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("clés JSON dupliquées")
        result[key] = value
    return result


def read_json(relative, limit):
    time_check()
    descriptor = None
    parent = None
    try:
        parent = directory_fd(relative.parent)
        descriptor = os.open(relative.name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK,
                             dir_fd=parent)
        observed = os.fstat(descriptor)
        if not stat.S_ISREG(observed.st_mode):
            raise InventoryError("fichier non ordinaire")
        if observed.st_size > limit:
            state["limits"].add("limite de taille JSON atteinte")
            raise InventoryError("fichier JSON trop volumineux")
        if state["bytes"] + observed.st_size > TOTAL_LIMIT:
            state["limits"].add("budget de lectures JSON atteint")
            raise InventoryError("budget de lectures JSON atteint")
        with os.fdopen(descriptor, "rb") as handle:
            descriptor = None
            raw = handle.read(limit + 1)
        state["bytes"] += len(raw)
        if len(raw) > limit or state["bytes"] > TOTAL_LIMIT:
            state["limits"].add("budget de lectures JSON atteint")
            raise InventoryError("budget de lectures JSON atteint")
        time_check()
        result = json.loads(raw.decode("utf-8-sig"), object_pairs_hook=unique_object)
        if type(result) is not dict:
            raise InventoryError("objet JSON attendu")
        return result
    except (OSError, UnicodeError, ValueError, RecursionError):
        raise InventoryError("JSON invalide, illisible ou symbolique") from None
    finally:
        if descriptor is not None:
            os.close(descriptor)
        if parent is not None:
            os.close(parent)


def discover():
    found = set()
    diagnostics = set()
    pending = [Path(".")]
    try:
        while pending:
            time_check()
            relative = pending.pop()
            if not safe_path(relative):
                diagnostics.add("chemin de découverte non restituable")
                continue
            descriptor = None
            try:
                descriptor = directory_fd(relative)
                if relative != Path("."):
                    try:
                        marker = os.stat("pyvenv.cfg", dir_fd=descriptor, follow_symlinks=False)
                    except FileNotFoundError:
                        marker = None
                    if marker is not None:
                        continue
                children = []
                with os.scandir(descriptor) as entries:
                    for entry in entries:
                        time_check()
                        state["entries"] += 1
                        if state["entries"] > MAX_ENTRIES:
                            state["limits"].add("limite d'entrées de découverte atteinte")
                            raise InventoryError("limite d'entrées de découverte atteinte")
                        child = relative / entry.name
                        if entry.name == "package.json":
                            found.add(child)
                            if len(found) > MAX_MANIFESTS:
                                state["limits"].add("limite de manifestes atteinte")
                                raise InventoryError("limite de manifestes atteinte")
                        elif entry.name not in IGNORED and entry.is_dir(follow_symlinks=False):
                            children.append(child)
                pending.extend(sorted(children, key=lambda p: p.as_posix(), reverse=True))
            except OSError:
                diagnostics.add("sous-dossier inaccessible ou modifié pendant la découverte")
            finally:
                if descriptor is not None:
                    os.close(descriptor)
    except InventoryError as error:
        diagnostics.add(str(error))
        # Un sous-ensemble dépendant de readdir ne doit pas devenir un inventaire stable.
        found.clear()
    for explicit in (Path("package.json"), Path(".opencode/package.json")):
        try:
            if file_status(explicit) is not None:
                found.add(explicit)
        except InventoryError:
            found.add(explicit)
    if len(found) > MAX_MANIFESTS:
        state["limits"].add("limite de manifestes atteinte")
        found.intersection_update((Path("package.json"), Path(".opencode/package.json")))
    return sorted(found, key=lambda p: p.as_posix()), diagnostics


def workspace_patterns(data, errors):
    value = data.get("workspaces", [])
    if type(value) is dict:
        value = value.get("packages")
    if type(value) is not list or len(value) > 128:
        errors.append("workspaces non vérifiables")
        return []
    patterns = []
    for pattern in value:
        if (type(pattern) is not str or not pattern or len(pattern) > 200
                or not safe_path(pattern) or pattern.startswith(("/", "!"))
                or ".." in PurePosixPath(pattern).parts):
            errors.append("motif de workspace non vérifiable")
            continue
        parts = tuple(p for p in pattern.split("/") if p not in ("", "."))
        if len(parts) > 32:
            errors.append("motif de workspace non vérifiable")
        elif parts:
            patterns.append(parts)
    return patterns


@lru_cache(maxsize=4096)
def glob_match(parts, pattern):
    time_check()
    if not pattern:
        return not parts
    if pattern[0] == "**":
        return glob_match(parts, pattern[1:]) or bool(parts and glob_match(parts[1:], pattern))
    return bool(parts and fnmatch.fnmatchcase(parts[0], pattern[0])
                and glob_match(parts[1:], pattern[1:]))


def declared(value):
    if type(value) is not str:
        return "non vérifiable (contrainte invalide)", None, False
    if CONSTRAINT.fullmatch(value):
        return value, None, True
    if value.startswith("workspace:") and CONSTRAINT.fullmatch(value[10:]):
        return value, None, True
    if value.startswith("npm:"):
        alias = value[4:]
        separator = alias.rfind("@")
        target, constraint = (alias[:separator], alias[separator + 1:]) if separator > 0 else (alias, "*")
        if valid_name(target) and CONSTRAINT.fullmatch(constraint):
            return "alias npm " + target + " " + constraint, target, True
    return "référence externe ou locale masquée", None, False


def source_manifest(relative):
    item = {"path": relative, "data": {}, "groups": {}, "errors": [], "patterns": []}
    try:
        if not safe_path(relative):
            raise InventoryError("chemin de manifeste non restituable")
        item["data"] = read_json(relative, JSON_LIMIT)
        for group in GROUPS:
            value = item["data"].get(group, {})
            if type(value) is not dict:
                item["errors"].append(group + " non vérifiables")
                value = {}
            item["groups"][group] = value
        item["patterns"] = workspace_patterns(item["data"], item["errors"])
    except InventoryError as error:
        item["errors"].append("manifeste non vérifiable : " + str(error))
    return item


lock_cache = {}


def local_lock(folder):
    if folder in lock_cache:
        return lock_cache[folder]
    result = {"folder": folder, "sources": [], "data": None, "error": "", "chosen": None,
              "inaccessible": False}
    for name in LOCK_NAMES:
        relative = folder / name
        try:
            present = file_status(relative) is not None
        except InventoryError:
            result["inaccessible"] = True
            present = False
        if present:
            result["sources"].append(relative)
    npm_sources = [p for p in result["sources"] if p.name in LOCK_NAMES[:2]]
    if npm_sources:
        result["chosen"] = npm_sources[0]
        try:
            data = read_json(result["chosen"], LOCK_LIMIT)
            if type(data.get("lockfileVersion")) is not int or data["lockfileVersion"] not in (2, 3):
                result["error"] = "format npm non analysé (formats 2 et 3 seulement)"
            elif type(data.get("packages")) is not dict:
                result["error"] = "verrou npm invalide"
            else:
                result["data"] = data
        except InventoryError as error:
            result["error"] = "verrou non vérifiable : " + str(error)
    elif result["sources"]:
        result["error"] = "format de verrou non analysé"
    elif result["inaccessible"]:
        result["error"] = "emplacement du verrou non vérifiable"
    else:
        result["error"] = "verrou absent"
    lock_cache[folder] = result
    return result


def choose_lock(item, owners):
    result = local_lock(item["path"].parent)
    if not result["sources"] and not result["inaccessible"]:
        for owner in owners:
            inherited = local_lock(owner["path"].parent)
            if inherited["sources"] or inherited["inaccessible"]:
                return inherited
    return result


def lock_version(lock, item, name):
    if lock["data"] is None:
        return "non vérifiable (" + lock["error"] + ")", None
    packages = lock["data"]["packages"]
    folder = item["path"].parent
    while True:
        relative = folder.relative_to(lock["folder"])
        key = (relative / "node_modules" / name).as_posix()
        entry = packages.get(key)
        if entry is not None:
            seen = set()
            for _ in range(8):
                if type(entry) is not dict:
                    break
                if entry.get("link") is not True:
                    value = entry.get("version")
                    if type(value) is str and len(value) <= 200 and VERSION.fullmatch(value):
                        return value, value
                    break
                target = entry.get("resolved")
                if (type(target) is not str or not safe_path(target)
                        or target.startswith("/") or ".." in PurePosixPath(target).parts
                        or target in seen):
                    break
                seen.add(target)
                entry = packages.get(PurePosixPath(target).as_posix())
            return "non vérifiable (entrée de verrou invalide)", None
        if folder == lock["folder"]:
            break
        folder = folder.parent
    return "non renseignée dans le verrou", None


def allowed_installation(path):
    try:
        relative = path.relative_to(root)
    except ValueError:
        return False
    if not safe_path(relative):
        return False
    denied = IGNORED - {"node_modules", ".opencode"}
    if any(part in denied for part in relative.parts):
        return False
    if ".opencode" in relative.parts:
        index = relative.parts.index(".opencode")
        if relative.parts[index + 1:index + 2] != ("node_modules",):
            return False
    return True


def installed(item, name, expected):
    folder = item["path"].parent
    while True:
        time_check()
        candidate = root / folder / "node_modules" / name
        try:
            resolved = candidate.resolve()
            if not allowed_installation(resolved):
                return "non vérifiable (cible hors périmètre)", None, None
            try:
                observed = candidate.lstat()
            except FileNotFoundError:
                observed = None
            if observed is not None:
                if not resolved.is_dir():
                    return "non vérifiable (installation incomplète)", None, None
                metadata = read_json(resolved.relative_to(root) / "package.json", JSON_LIMIT)
                actual_name = metadata.get("name")
                version = metadata.get("version")
                if (not valid_name(actual_name) or (expected and actual_name != expected)
                        or type(version) is not str or len(version) > 200
                        or not VERSION.fullmatch(version)):
                    return "non vérifiable (métadonnées incohérentes)", None, None
                return version, str(resolved), version
        except (OSError, RuntimeError, InventoryError):
            return "non vérifiable (métadonnées inaccessibles)", None, None
        if folder == Path("."):
            return "non observée localement", None, None
        folder = folder.parent


def render_manifest(item, owners):
    relative = item["path"]
    if not safe_path(relative) or not safe_path(root):
        return "### Manifeste au chemin non restituable\n\n  * Manifeste non vérifiable\n"
    lines = ["### " + markdown(relative.as_posix()), "",
             "  * Manifeste : " + markdown(root / relative)]
    data = item["data"]
    errors = list(item["errors"])
    manager = data.get("packageManager")
    if manager is not None:
        if (type(manager) is str and re.fullmatch(r"(?:npm|pnpm|yarn|bun)@[A-Za-z0-9.+_-]{1,200}", manager)):
            lines.append("  * Gestionnaire déclaré : " + markdown(manager))
        else:
            errors.append("packageManager non vérifiable")
    engines = data.get("engines", {})
    if type(engines) is not dict:
        errors.append("engines non vérifiables")
    else:
        for name in sorted(engines):
            if valid_name(name):
                value, _target, valid = declared(engines[name])
                lines.append("  * engines." + markdown(name) + " : "
                             + markdown(value if valid else "non vérifiable"))
            else:
                errors.append("nom engines non vérifiable")
    lock = choose_lock(item, owners)
    if lock["sources"]:
        lines.append("  * Verrous présents : " + ", ".join(markdown(root / p) for p in lock["sources"]))
    if lock["chosen"]:
        lines.append("  * Verrou npm retenu : " + markdown(root / lock["chosen"]))
    unsupported = [p for p in lock["sources"] if p.name not in LOCK_NAMES[:2]]
    if unsupported:
        lines.append("  * Autres verrous non analysés : " + ", ".join(markdown(root / p) for p in unsupported))
    if lock["error"]:
        lines.append("  * " + markdown(lock["error"]))
    if lock["data"] is not None:
        key = relative.parent.relative_to(lock["folder"]).as_posix()
        key = "" if key == "." else key
        entry = lock["data"]["packages"].get(key)
        if type(entry) is not dict or any(
                entry.get(group, {}) != values for group, values in item["groups"].items()):
            errors.append("déclarations différentes ou absentes dans le verrou")
    for error in sorted(set(errors)):
        lines.append("  * " + markdown(error))
    any_dependency = False
    for group in GROUPS:
        dependencies = item["groups"].get(group, {})
        if not dependencies:
            continue
        any_dependency = True
        lines.extend(["", "#### " + group, ""])
        for name in sorted(dependencies):
            time_check()
            if state["dependencies"] >= MAX_DEPENDENCIES:
                state["limits"].add("limite de dépendances restituées atteinte")
                return "\n".join(lines) + "\n"
            state["dependencies"] += 1
            if not valid_name(name):
                lines.append("  * Dépendance non vérifiable : nom invalide")
                continue
            value, target, _regular = declared(dependencies[name])
            locked, locked_version = lock_version(lock, item, name)
            observation, location, observed_version = installed(item, name, target or name)
            lines.append("  * " + markdown(name) + " : déclarée " + markdown(value)
                         + " ; verrouillée (npm) " + markdown(locked)
                         + " ; observée " + markdown(observation))
            lines.append("    * Installation : " + (markdown(location) if location else "non observée"))
            if locked_version and observed_version and locked_version != observed_version:
                lines.append("    * Écart entre version verrouillée et version observée")
    if not any_dependency and not errors:
        lines.append("  * Aucune dépendance directement déclarée")
    return "\n".join(lines) + "\n"


def collect():
    paths, diagnostics = discover()
    manifests = []
    for path in paths:
        time_check()
        manifests.append(source_manifest(path))
    owner_map = {}
    for item in manifests:
        owners = []
        for possible in manifests:
            if possible is item or not possible["patterns"]:
                continue
            try:
                relative = item["path"].parent.relative_to(possible["path"].parent)
            except ValueError:
                continue
            if relative != Path(".") and any(glob_match(relative.parts, p) for p in possible["patterns"]):
                owners.append(possible)
        owner_map[item["path"]] = sorted(owners, key=lambda x: len(x["path"].parts), reverse=True)
    general = []
    opencode = []
    skipped = 0
    for item in manifests:
        owners = owner_map[item["path"]]
        if (item["path"] not in (Path("package.json"), Path(".opencode/package.json"))
                and not item["errors"] and not item["patterns"] and not owners
                and not any(item["groups"].values())):
            skipped += 1
            continue
        target = opencode if item["path"] == Path(".opencode/package.json") else general
        try:
            target.append(render_manifest(item, owners))
        except InventoryError:
            diagnostics.add("collecte interrompue avant restitution complète")
            break
    diagnostics.update(state["limits"])
    if skipped:
        general.insert(0, "  * Manifestes sans dépendance non retenus : " + str(skipped) + "\n")
    if diagnostics:
        general.insert(0, "\n".join("  * Inventaire incomplet : " + markdown(d) for d in sorted(diagnostics)) + "\n")
    first = "## Dépendances JavaScript du projet\n\n" + "\n".join(general) + "\n" if general else ""
    second = "## Dépendances OpenCode du projet\n\n" + "\n".join(opencode) + "\n" if opencode else ""
    return first, second


try:
    try:
        general, opencode = collect()
    except InventoryError:
        general = "## Dépendances JavaScript du projet\n\n  * Inventaire incomplet : délai ou limite de collecte\n\n"
        opencode = ""
    sys.stdout.write(general + chr(28) + opencode)
finally:
    os.close(root_fd)
PY_JS
}

projects_template_devops_hostname() {
    local binary="" output=""
    local LC_ALL=C

    if ! binary="$(projects_template_devops_host_binary hostname)" || [[ ! -x "${binary}" ]]; then
        printf '%s\n' 'indisponible (commande hostname absente)'
        return 0
    fi
    if ! output="$(/usr/bin/timeout 15s "${binary}" -f 2>/dev/null)"; then
        printf '%s\n' "indisponible (nom d'hôte non vérifiable)"
        return 0
    fi
    if [[ ! "${output}" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]{0,252}$ ]]; then
        printf '%s\n' "indisponible (nom d'hôte invalide)"
        return 0
    fi
    printf '%s\n' "${output}"
}

projects_template_devops_render() {
    local devops_home="$1" template_path="$2"
    local project_title="${3:-${template_path##*/}}"
    local name="" binary="" version="" context="" operating_system=""
    local hostname=""
    local psql_binary="" compose_binary="" python_binary="${devops_home}/python/current/bin/python3"
    local venv_status='indisponible'
    local started_at="" environment_type=UNSET
    local javascript_report="" javascript_dependencies="" opencode_dependencies=""
    local -a version_arguments=()

    started_at="$(projects_template_devops_timestamp)" || return 1
    projects_template_devops_prepare_executables "${devops_home}" || return 1
    case "${SYSTEM_DEBIAN_ENVIRONNEMENT:-UNSET}" in
        DOCKER|LXC|PHYSICAL|PROXMOX|VM|UNSET)
            environment_type="${SYSTEM_DEBIAN_ENVIRONNEMENT:-UNSET}" ;;
    esac
    if [[ -r /etc/os-release ]]; then
        operating_system="$(
            # shellcheck source=/dev/null
            . /etc/os-release
            printf '%s' "${PRETTY_NAME:-système non identifié}"
        )" || return 1
    else
        operating_system='indisponible (/etc/os-release absent)'
    fi
    if [[ "${project_title}" == template ]]; then
        project_title=Template
    fi
    printf '# DEVOPS.md — %s\n\nVersion : 0.7\n\nGénéré automatiquement par Debian Installeur Unifié (DIU).\nDébut du relevé (UTC) : %s\nEnvironnement d\047exécution DIU : %s\n\n' \
        "${project_title}" "${started_at}" "${environment_type}" || return 1
    printf '%s\n' \
        "Les sondes système concernent le contexte d'exécution DIU." \
        'Les outils DevOps sont interrogés avec les binaires indiqués dans leurs rubriques.' \
        'Les dépendances Python sont recherchées en priorité dans les venv du projet, puis dans le Python DevOps en repli explicite.' \
        "Dans l’inventaire Python, la flèche indique le Python sondé ; Installation indique le chemin observé dans les métadonnées." \
        'Les dépendances Python attendues proviennent de [project].dependencies dans pyproject.toml.' \
        'Les dépendances JavaScript sont regroupées par manifeste et catégorie sous NPM et OpenCode.' \
        'Leurs déclarations, versions verrouillées npm et métadonnées locales sont distinctes ; un verrou ne prouve pas une installation.' \
        'Les contraintes JavaScript ne sont pas résolues et cet inventaire ne prouve pas le chargement de plugins OpenCode.' \
        'Un inventaire multi-environnements ne valide pas un environnement Python unique.' \
        'Cet inventaire ne constitue pas une qualification fonctionnelle ni une preuve de réussite des tests du projet.' \
        '' || return 1
    hostname="$(projects_template_devops_hostname)" || return 1
    printf '# Système d\047exploitation\n\n  * %s\n  * %s\n\n\n' "${operating_system}" "${hostname}" || return 1
    projects_template_devops_tpm /dev /sys/class/tpm || return 1

    if ! javascript_report="$(projects_template_devops_javascript "${devops_home}" "${template_path}" 2>/dev/null)" ||
        [[ "${javascript_report}" != *$'\034'* ]]; then
        javascript_report=$'## Dépendances JavaScript du projet\n\n  * Inventaire non vérifiable : analyse échouée\n\n\034'
    fi
    javascript_dependencies="${javascript_report%%$'\034'*}"
    opencode_dependencies="${javascript_report#*$'\034'}"

    for name in Docker LXC Docker-Compose Git Go Node NPM OpenCode OpenSpec OpenSSL 'PostgreSQL Client'; do
        case "${name}" in
            Docker) [[ "${ENV_DEVOPS_TESTS_DOCKER:-0}" == 1 ]] || continue ;;
            LXC)
                if [[ "${ENV_DEVOPS_TESTS_LXC:-0}" == 1 ]]; then
                    printf '# Conteneur LXC, pour tests nécessitant des droits root\n\n  * Variables d\047accès disponible dans project.env\n  * Debian 13\n  * Accès TPM OK\n\n\n' || return 1
                fi
                continue
                ;;
        esac
        context=host
        version_arguments=(--version)
        case "${name}" in
            Docker) binary="$(projects_template_devops_host_binary docker)" || binary='' ;;
            Docker-Compose)
                binary="$(projects_template_devops_host_binary docker-compose)" || binary=''
                if [[ -z "${binary}" ]]; then
                    for compose_binary in \
                        /usr/local/lib/docker/cli-plugins/docker-compose \
                        /usr/local/libexec/docker/cli-plugins/docker-compose \
                        /usr/lib/docker/cli-plugins/docker-compose \
                        /usr/libexec/docker/cli-plugins/docker-compose; do
                        if [[ -x "${compose_binary}" ]]; then
                            binary="${compose_binary}"
                            break
                        fi
                    done
                fi
                ;;
            Git) binary="$(projects_template_devops_host_binary git)" || binary='' ;;
            Go) context=user; binary="${devops_home}/go/current/bin/go"; version_arguments=(version) ;;
            Node) context=user; binary="${devops_home}/node/current/bin/node" ;;
            NPM) context=node; binary="${devops_home}/node/current/bin/npm" ;;
            OpenCode) context=user; binary="${devops_home}/.opencode/bin/opencode" ;;
            OpenSpec) context=node; binary="${devops_home}/.local/npm/bin/openspec" ;;
            OpenSSL) binary="$(projects_template_devops_host_binary openssl)" || binary=''; version_arguments=(version) ;;
            'PostgreSQL Client') binary="$(projects_template_devops_host_binary psql)" || binary=''; psql_binary="${binary}" ;;
        esac
        version="$(projects_template_devops_version "${context}" "${devops_home}" "${binary}" "${version_arguments[@]}")" || return 1
        projects_template_devops_section "${name}" "${version}" "${binary}" || return 1
        case "${name}" in
            NPM) printf '%s' "${javascript_dependencies}" || return 1 ;;
            OpenCode)
                if [[ -n "${opencode_dependencies}" ]]; then
                    printf '%s\n\n' "${opencode_dependencies}" || return 1
                fi
                ;;
        esac
    done

    printf '# PostgreSQL Serveur\n\n' || return 1
    projects_template_devops_postgresql "${template_path}/project.env" "${psql_binary}" || return 1
    printf '  * Les variables PostgreSQL sont chargées depuis project.env\n  * PG_HOST PG_PORT PG_DATABASE PG_USERNAME PG_PASSWORD\n\n\n' || return 1

    version="$(projects_template_devops_version user "${devops_home}" "${python_binary}" --version)" || return 1
    if [[ -x "${python_binary}" ]] && projects_template_devops_user_run \
        "${devops_home}" "${python_binary}" -I -B -c 'import venv, ensurepip; ensurepip.version()' >/dev/null 2>&1; then
        venv_status=disponible
    fi
    printf '# Python\n\n  * %s\n  * %s\n  * venv: %s\n\n\n' "${version}" "${python_binary}" "${venv_status}" || return 1
    # Les accents graves font partie du titre Markdown, sans expansion shell.
    # shellcheck disable=SC2016
    printf '# Python - Dépendances du projet - Source de vérité `pyproject.toml`\n\n' || return 1
    if ! projects_template_devops_dependencies "${devops_home}" "${template_path}" "${python_binary}" 2>/dev/null; then
        printf '  * Versions des dépendances non vérifiables : sonde Python échouée\n' || return 1
    fi
    printf '\n\n' || return 1
    binary="${devops_home}/python/current/bin/pip3"
    version="$(projects_template_devops_version python "${devops_home}" "${binary}" --version)" || return 1
    projects_template_devops_section 'Python - Gestionnaire de paquets' "${version}" "${binary}" || return 1

    printf '# Prompts\n\n  * Dossier des prompts : %s/datas/prompts\n  * Index des prompts : %s/datas/prompts/INDEX.md\n\n\n' \
        "${devops_home}" "${devops_home}" || return 1

    printf '# Tests navigateurs extérieurs en mode headless\n\nLa détection ne vérifie pas le fonctionnement du mode headless.\n\n' || return 1
    for name in Chromium Firefox; do
        case "${name}" in
            Chromium)
                binary="$(projects_template_devops_host_binary chromium)" ||
                    binary="$(projects_template_devops_host_binary chromium-browser)" || binary=''
                ;;
            Firefox)
                binary="$(projects_template_devops_host_binary firefox)" ||
                    binary="$(projects_template_devops_host_binary firefox-esr)" || binary=''
                ;;
        esac
        version="$(projects_template_devops_version host "${devops_home}" "${binary}" --version)" || return 1
        printf '## %s\n\n  * %s\n  * %s\n  * Mode headless : --headless\n\n\n' \
            "${name}" "${version}" "${binary:-binaire introuvable}" || return 1
    done
}

projects_template_devops() {
    local devops_home="/home/${ENV_DEVOPS_USER:-}"
    local project_id="${1:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-${devops_home}/datas}"
    local template_path="${projects_root}/${project_id}"
    local document="${template_path}/DEVOPS.md" temporary_document="" content=""
    local devops_group=""

    if [[ "$#" -ne 1 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ||
        -z "${project_id}" || "${project_id}" == */* || "${project_id}" == . ||
        "${project_id}" == .. || "${project_id}" =~ [[:cntrl:]] ]]; then
        print_error 'Usage : rid projects template devops <ID PROJECT> (identifiant sans chemin et utilisateur DevOps valide).'
        return 1
    fi
    if [[ -L "${template_path}" ]]; then
        print_error 'Le dossier du projet doit être un chemin ordinaire.'
        return 1
    fi
    if [[ ! -d "${template_path}" ]]; then
        print_info "Dossier du projet absent : ${template_path}. Aucune action effectuée."
        return 0
    fi
    if [[ -L "${template_path}" || -L "${document}" || ( -e "${document}" && ! -f "${document}" ) ]]; then
        print_error 'Le projet et son fichier DEVOPS.md doivent être des chemins ordinaires.'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ "${EUID}" -ne 0 && "$(id -un)" != "${ENV_DEVOPS_USER}" ]]; then
        print_error "Exécuter cette génération en root ou sous ${ENV_DEVOPS_USER}."
        return 1
    fi
    if ! projects_template_devops_python_manifest "${devops_home}" "${template_path}" "${project_id}"; then
        print_error 'Impossible de préparer le manifeste Python ; DEVOPS.md est conservé.'
        return 1
    fi
    if ! content="$(projects_template_devops_render "${devops_home}" "${template_path}" "${project_id}")"; then
        print_error 'Impossible de préparer DEVOPS.md ; le document existant est conservé.'
        return 1
    fi
    if ! temporary_document="$(mktemp "${template_path}/.DEVOPS.md.XXXXXX")"; then
        print_error 'Impossible de créer le fichier temporaire DEVOPS.md.'
        return 1
    fi
    if ! printf '%s\n' "${content}" > "${temporary_document}"; then
        if ! rm -f -- "${temporary_document}"; then
            print_error 'Impossible de supprimer le document temporaire.'
        fi
        print_error "Impossible d'écrire DEVOPS.md ; le document existant est conservé."
        return 1
    fi
    if [[ -f "${document}" ]]; then
        if ! chmod --reference="${document}" "${temporary_document}" ||
            ! chown --reference="${document}" "${temporary_document}"; then
            if ! rm -f -- "${temporary_document}"; then
                print_error 'Impossible de supprimer le document temporaire.'
            fi
            print_error 'Impossible de conserver les droits de DEVOPS.md.'
            return 1
        fi
    else
        if ! devops_group="$(id -gn "${ENV_DEVOPS_USER}")" ||
            ! chmod 644 "${temporary_document}" ||
            ! chown "${ENV_DEVOPS_USER}:${devops_group}" "${temporary_document}"; then
            if ! rm -f -- "${temporary_document}"; then
                print_error 'Impossible de supprimer le document temporaire.'
            fi
            print_error 'Impossible de définir les droits de DEVOPS.md.'
            return 1
        fi
    fi
    if ! mv -f -- "${temporary_document}" "${document}"; then
        if ! rm -f -- "${temporary_document}"; then
            print_error 'Impossible de supprimer le document temporaire.'
        fi
        print_error 'Impossible de remplacer DEVOPS.md ; le document existant est conservé.'
        return 1
    fi
    print_success "DEVOPS.md généré ou actualisé : ${document}. Les versions indisponibles sont indiquées dans le document."
}

projects_template_devops_project_is_configured() {
    local project_env="$1" project_id="$2"

    /usr/bin/timeout 15s /usr/bin/python3 -I -B - "${project_env}" "${project_id}" <<'PY'
from pathlib import Path
import re
import shlex
import sys

required = {'PROJECT_ID', 'PROJECT_NAME', 'PROJECT_TYPE',
            'PROJECT_DOCKERED', 'PROJECT_DEBIAN_PACKAGE'}
values = {}
try:
    for line in Path(sys.argv[1]).read_text(encoding='utf-8').splitlines():
        match = re.match(r'^\s*(?:export\s+)?([A-Z_]+)\s*=\s*(.*)$', line)
        if not match or match[1] not in required:
            continue
        parsed = shlex.split(match[2], comments=True)
        if len(parsed) > 1:
            raise ValueError('affectation non littérale')
        values[match[1]] = parsed[0] if parsed else ''
except (OSError, ValueError, UnicodeError):
    sys.exit(1)
valid = all(values.get(key, '').strip() for key in required)
sys.exit(0 if valid and values['PROJECT_ID'] == sys.argv[2] else 1)
PY
}

projects_template_all_all() {
    local devops_home="/home/${ENV_DEVOPS_USER:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-${devops_home}/datas}"
    local project_path="" project_id=""
    local selected=0 succeeded=0 ignored=0 failed=0

    if [[ "$#" -ne 0 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ]]; then
        print_error 'Usage : rid projects template all all (utilisateur DevOps valide).'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ "${EUID}" -ne 0 && "$(id -un)" != "${ENV_DEVOPS_USER}" ]]; then
        print_error "Exécuter cette préparation en root ou sous ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ ! -d "${projects_root}" ]]; then
        print_error "Répertoire des projets introuvable : ${projects_root}"
        return 1
    fi
    if [[ ! -x /usr/bin/python3 ]]; then
        print_error 'Impossible de sélectionner les projets : Python système absent.'
        return 1
    fi

    # Même sélection que les modèles groupés, sans modifier les options du shell.
    for project_path in "${projects_root}"/* "${projects_root}"/.[!.]* "${projects_root}"/..?*; do
        if [[ ! -d "${project_path}" && ! -L "${project_path}" ]]; then
            continue
        fi
        project_id="${project_path##*/}"
        if [[ "${project_id}" =~ [[:cntrl:]] ]]; then
            ignored=$((ignored + 1))
            print_info 'Projet ignoré : identifiant invalide.'
            continue
        fi
        if [[ -L "${project_path}" || -L "${project_path}/project.env" ||
            ! -f "${project_path}/project.env" ]] ||
            ! projects_template_devops_project_is_configured "${project_path}/project.env" "${project_id}"; then
            ignored=$((ignored + 1))
            print_info "Projet ignoré : ${project_id} (chemin symbolique ou configuration absente, incomplète, illisible ou invalide)."
            continue
        fi

        selected=$((selected + 1))
        if ! projects_template_openspec "${project_id}"; then
            failed=$((failed + 1))
            print_error "OpenSpec échoué pour le projet : ${project_id}. DevOps non exécuté pour ce projet."
            continue
        fi
        # DevOps dépend des autres modèles et reste toujours l'étape finale du projet.
        if projects_template_devops "${project_id}"; then
            succeeded=$((succeeded + 1))
        else
            failed=$((failed + 1))
            print_error "Génération DevOps échouée pour le projet : ${project_id}."
        fi
    done

    if [[ "${selected}" -eq 0 ]]; then
        print_info "Aucun projet éligible au traitement de tous les modèles dans ${projects_root}."
    fi
    print_info "Bilan modèles : ${selected} sélectionné(s), ${succeeded} réussi(s), ${ignored} ignoré(s), ${failed} échoué(s)."
    if [[ "${failed}" -gt 0 ]]; then
        return 1
    fi
    return 0
}

projects_template_openspec_all() {
    local devops_home="/home/${ENV_DEVOPS_USER:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-${devops_home}/datas}"
    local project_path="" project_id=""
    local selected=0 succeeded=0 ignored=0 failed=0

    if [[ "$#" -ne 0 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ]]; then
        print_error 'Usage : rid projects template openspec all (utilisateur DevOps valide).'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ "${EUID}" -ne 0 && "$(id -un)" != "${ENV_DEVOPS_USER}" ]]; then
        print_error "Exécuter cette préparation en root ou sous ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ ! -d "${projects_root}" ]]; then
        print_error "Répertoire des projets introuvable : ${projects_root}"
        return 1
    fi
    if [[ ! -x /usr/bin/python3 ]]; then
        print_error 'Impossible de sélectionner les projets : Python système absent.'
        return 1
    fi

    # Les mêmes motifs que DevOps incluent les dossiers cachés sans modifier le shell appelant.
    for project_path in "${projects_root}"/* "${projects_root}"/.[!.]* "${projects_root}"/..?*; do
        if [[ ! -d "${project_path}" && ! -L "${project_path}" ]]; then
            continue
        fi
        project_id="${project_path##*/}"
        if [[ "${project_id}" =~ [[:cntrl:]] ]]; then
            ignored=$((ignored + 1))
            print_info 'Projet ignoré : identifiant invalide.'
            continue
        fi
        if [[ -L "${project_path}" || -L "${project_path}/project.env" ||
            ! -f "${project_path}/project.env" ]] ||
            ! projects_template_devops_project_is_configured "${project_path}/project.env" "${project_id}"; then
            ignored=$((ignored + 1))
            print_info "Projet ignoré : ${project_id} (chemin symbolique ou configuration absente, incomplète, illisible ou invalide)."
            continue
        fi

        selected=$((selected + 1))
        if projects_template_openspec "${project_id}"; then
            succeeded=$((succeeded + 1))
        else
            failed=$((failed + 1))
            print_error "Initialisation ou mise à jour OpenSpec échouée pour le projet : ${project_id}."
        fi
    done

    if [[ "${selected}" -eq 0 ]]; then
        print_info "Aucun projet éligible à la préparation OpenSpec dans ${projects_root}."
    fi
    print_info "Bilan OpenSpec : ${selected} sélectionné(s), ${succeeded} réussi(s), ${ignored} ignoré(s), ${failed} échoué(s)."
    if [[ "${failed}" -gt 0 ]]; then
        return 1
    fi
    return 0
}

projects_template_devops_all() {
    local devops_home="/home/${ENV_DEVOPS_USER:-}"
    local projects_root="${DEVOPS_PROJECTS_ROOT:-${devops_home}/datas}"
    local project_path="" project_id=""
    local selected=0 succeeded=0 ignored=0 failed=0

    if [[ "$#" -ne 0 || ! "${ENV_DEVOPS_USER:-}" =~ ^[a-z_][a-z0-9_-]*\$?$ ]]; then
        print_error 'Usage : rid projects template devops all (utilisateur DevOps valide).'
        return 1
    fi
    if ! id -u "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error "Utilisateur DevOps introuvable : ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ "${EUID}" -ne 0 && "$(id -un)" != "${ENV_DEVOPS_USER}" ]]; then
        print_error "Exécuter cette génération en root ou sous ${ENV_DEVOPS_USER}."
        return 1
    fi
    if [[ ! -d "${projects_root}" ]]; then
        print_error "Répertoire des projets introuvable : ${projects_root}"
        return 1
    fi
    if [[ ! -x /usr/bin/python3 ]]; then
        print_error 'Impossible de sélectionner les projets : Python système absent.'
        return 1
    fi

    # Les trois motifs disjoints incluent les dossiers cachés sans modifier
    # les options de glob du shell appelant ni suivre les liens symboliques.
    for project_path in "${projects_root}"/* "${projects_root}"/.[!.]* "${projects_root}"/..?*; do
        if [[ ! -d "${project_path}" && ! -L "${project_path}" ]]; then
            continue
        fi
        project_id="${project_path##*/}"
        if [[ "${project_id}" =~ [[:cntrl:]] ]]; then
            ignored=$((ignored + 1))
            print_info 'Projet ignoré : identifiant invalide.'
            continue
        fi
        if [[ -L "${project_path}" || -L "${project_path}/project.env" ||
            ! -f "${project_path}/project.env" ]] ||
            ! projects_template_devops_project_is_configured "${project_path}/project.env" "${project_id}"; then
            ignored=$((ignored + 1))
            print_info "Projet ignoré : ${project_id} (chemin symbolique ou configuration absente, incomplète, illisible ou invalide)."
            continue
        fi

        selected=$((selected + 1))
        if projects_template_devops "${project_id}"; then
            succeeded=$((succeeded + 1))
        else
            failed=$((failed + 1))
            print_error "Génération DevOps échouée pour le projet : ${project_id}."
        fi
    done

    if [[ "${selected}" -eq 0 ]]; then
        print_info "Aucun projet éligible à la génération DevOps dans ${projects_root}."
    fi
    print_info "Bilan DevOps : ${selected} sélectionné(s), ${succeeded} réussi(s), ${ignored} ignoré(s), ${failed} échoué(s)."
    if [[ "${failed}" -gt 0 ]]; then
        return 1
    fi
    return 0
}
