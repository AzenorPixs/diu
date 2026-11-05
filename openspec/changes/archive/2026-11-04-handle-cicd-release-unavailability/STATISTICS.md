# Statistiques — handle-cicd-release-unavailability

## Statistiques générales et décisions

Change exécuté en session SCM directe, archivé le 2026-11-04. Les indisponibilités reconnues en release CI/CD sont non bloquantes, avec publication potentiellement partielle signalée. Les autres erreurs et les releases directes conservent leur contrat. Code de lot non attribué ; attribution ultérieure par ACL.

## Types de messages et d'outils

Agent de codage : Codex. Nombre de messages et appels d'outils : N/A, comptage exhaustif indisponible. Aucune télémétrie de pilotage requise ou déclenchée.

## Fichiers modifiés

Code : `modules/projects/git.sh`, `modules/projects/diu-release.sh`, `lib/github-auth.sh`. Tests : `tests/test_projects.py`, `tests/test_projects_cicd_debian.py`, `tests/test_projects_cicd_replay.py`, `tests/test_projects_forgejo_debian_idempotence.py`, `tests/test_projects_github_debian_release.py`. Documentation : `README.md`, `BUILD.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`. Synchronisation de `openspec/specs/projects-cicd/spec.md` et archivage du change. Des fichiers partagés contenaient également des modifications d'autres sessions, préservées.

## Commandes

Validation globale Python DevOps : 1 171 tests exécutés, dont 2 ignorés, résultat OK. Tests ciblés CI/CD, rejeu, GitHub, Forgejo et GitLab réussis. Syntaxe Bash, ShellCheck avec exclusion SC1091 pour imports dynamiques existants, OpenSpec strict et validation de la spécification synchronisée réussis. La première suite globale, avec `/usr/bin/python3`, a échoué avec 26 erreurs de fixtures venv ; la suite globale avec le Python DevOps documenté a réussi.

## Accès web

Aucun accès web utilisé pour cette correction. Les tests de publication utilisent des transports simulés ; aucune release réelle n'a été déclenchée.

## Synthèse globale

Implémentation et change archivés ; validation locale réussie dans les limites des transports simulés. Durée, nombre total de commandes et volumes de télémétrie : N/A, données exhaustives indisponibles. Aucun numéro de version ou code de lot n'a été créé par cette session.
