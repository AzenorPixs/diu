# ENV10 — Proposal

## Why

Le bloc d'installation OpenCode du DIU récupère actuellement la dernière release GitHub, mais exécute l'installateur V1 (`https://opencode.ai/install`). Il peut donc conserver ou réinstaller la version 1.19.4 alors que la release officielle V2 v2.2.0 est publiée.

## What Changes

- Détecter la dernière release stable OpenCode V2 depuis GitHub et comparer sa version numérique à celle installée.
- Installer par l'installateur officiel V2 uniquement si le binaire est absent ou plus ancien ; ne pas réinstaller une version égale ou plus récente.
- Préserver l'activation `OPENCODE=1`, le chemin d'installation DevOps, l'absence de modification automatique du PATH et le nettoyage existant.
- Couvrir les cas de version, réseau et installation par des tests isolés sans réseau ni installation réels.

## Capabilities

### New Capabilities

- `devops-opencode`: installation et mise à jour du binaire OpenCode V2 dans l'environnement DevOps.

### Modified Capabilities

Aucune.

## Impact

Le bloc OpenCode de `root-install-debian.sh`, un test dédié, une nouvelle spécification OpenSpec, `TECHNICAL.md` et `CHANGELOG.md` sont concernés. Aucun nouveau paquet, paramètre persistant, changement système ou comportement de `OPENCODE=0` n'est introduit. Si la version distante ne peut pas être déterminée, l'installation OpenCode échoue explicitement avant de lancer l'installateur.
