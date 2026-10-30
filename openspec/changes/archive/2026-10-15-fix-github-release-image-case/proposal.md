# ART09 — Correction de la casse des références GHCR

## Why

La release GitHub construit le chemin Docker avec la casse native du compte
et du dépôt GitHub. Docker refuse notamment `ghcr.io/AzenorPixs/pkeycloak`.

## What Changes

- Normaliser en minuscules le propriétaire et le dépôt dans les références
  GHCR versionnée et `latest`, ainsi que dans le résumé CI/CD.
- Préserver les valeurs de configuration, l'identité GitHub, l'image locale,
  le tag de version, les identifiants et les autres fournisseurs.
- Vérifier ces invariants sur des fixtures sans publication réelle.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `implement-projects-github-release` : références GHCR compatibles avec
  les valeurs GitHub comportant des majuscules.

## Impact

Modification de `modules/projects/git.sh`, `tests/test_projects.py`,
`TECHNICAL.md`, `README.md`, `CHANGELOG.md` et de la spécification concernée.
Aucune nouvelle dépendance, migration ou modification de `project.env`.
Le repli consiste à rétablir les trois expressions de construction des
références ; aucune donnée persistante n'est transformée.

## Validation

Périmètre SCM validé le 15 octobre 2026 : spécification, correctif, tests,
documentation, synchronisation et archivage ciblés, avec rapport d'archive.
Syntaxe Bash/Python, ShellCheck, tests projets isolés et validation stricte
OpenSpec. La publication réelle et la mise à jour du DIU installé restent
hors périmètre.
