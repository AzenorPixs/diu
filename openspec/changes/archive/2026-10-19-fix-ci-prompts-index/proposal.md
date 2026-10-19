# Corriger le chemin de l'alias ci

## Why

La configuration Zsh générée pour root définit encore `ci` avec le chemin
`/home/devops/datas/template/PROMPTS/INDEX.md`. Le dossier commun des prompts
est désormais `/home/devops/datas/prompts`, comme indiqué dans `DEVOPS.md`.

## What Changes

- Générer exactement `alias ci='cat /home/devops/datas/prompts/INDEX.md'`.
- Actualiser l'empreinte du contenu Zsh attendu après comparaison ciblée.
- Documenter la correction dans `CHANGELOG.md` et les exigences OpenSpec.

## Capabilities

### New Capabilities

- `system-shell-aliases` : chemin de l'index des prompts dans l'alias `ci`
  généré pour root.

### Modified Capabilities

Aucune.

## Impact

La correction concerne une ligne de `root-install-debian.sh`, l'empreinte
correspondante dans `tests/test_root_shellcheck.py` et le changelog.
Les autres lignes générées, commandes, variables et mécanismes d'installation
restent inchangés. Aucun ajout de dépendance, migration ou effet système
n'est prévu pendant cette session. Les configurations déjà installées ne
sont pas modifiées par l'édition des sources.

Le cycle couvre la validation, la synchronisation et l'archivage de ce seul
change, avec un rapport `STATISTIQUES.md`. Les autres changes restent hors
périmètre. Aucun commit ni inspection de l'état Git n'est prévu.
