# Statistiques — github-only-diu-update

## Statistiques générales et décisions

Session SCM directe du 2026-11-03, agent Codex. Change archivé après validation ; GitHub est la source unique de mise à jour du paquet DIU. Version inchangée et aucun commit, sur décision du développeur. Durée, tokens et coût : N/A, mesures non collectées.

## Types de messages et d’outils

Échanges de cadrage, validation explicite du périmètre, lectures, commandes, modifications et contrôles. Nombre exhaustif de messages et d’appels par outil : N/A, télémétrie non collectée. Aucun agent délégué.

## Fichiers modifiés

Moteur `modules/diu/update.sh`, aide `lib/rid-help.sh`, tests `test_diu_package_update.py` et `test_diu_http_compression.py`, `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`, canon `openspec/specs/diu-package-update/spec.md` et artefacts du présent change, y compris ce rapport. Nombre total des fichiers et lignes modifiées : N/A, inventaire Git non effectué.

## Commandes

Contrôles réussis : `bash -n` et ShellCheck pour les deux scripts ; compilation syntaxique des deux fichiers Python ; 9 tests ciblés de mise à jour, 3 tests de compression et 59 tests d’aide. Validation finale : 1 121 tests exécutés, dont 2 ignorés, sans échec ; les tests ciblés sont inclus dans la suite globale et ne sont pas additionnés. OpenSpec strict a réussi après correction d’une première validation stricte échouée (scénarios omis dans le delta) ; archivage réussi et canon synchronisé ; après deux validations strictes du canon en échec sur une longueur excessive, reformulation équivalente et validation stricte réussie. Première suite globale interrompue pour relancer avec un répertoire temporaire dans le projet ; elle ne constitue pas une validation finale. Comptage exhaustif des commandes : N/A.

## Accès web

Aucun appel à un outil web par l’agent. Les API et installations de mise à jour sont simulées dans les tests ; aucune vérification réelle du dépôt GitHub ou installation réelle n’est revendiquée.

## Synthèse globale

Les trois tâches du change sont validées selon `tasks.md`. Les comportements hors mise à jour DIU et la version du projet restent hors modification ; l’indisponibilité de GitHub bloque la mise à jour sans repli. Publication et déploiement : non effectués. Rapport global racine absent : maintenance non applicable ; mandater SGS pour sa création.
