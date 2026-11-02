# Statistiques — rename-env-docker-activation-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-env-docker-activation-variable`, code de lot non attribué.
- Contrat validé : `ENVIRONMENT_DOCKER`, `STATIC`, `ENABLE`, scope
  `environnements`, défaut `0`.
- La dernière valeur littérale `ENV_DOCKER=0|1` est transférée exactement vers
  `environnements.env`; les valeurs `ENVIRONMENT_DOCKER` déjà configurées
  gardent la priorité.
- Les anciens exports `ENV_DOCKER` sont supprimés après migration, sans
  toucher aux noms voisins comme `ENV_DOCKER_USER` et `ENV_DOCKER_GROUP`.
- Archivage réussi sous `2026-11-02-rename-env-docker-activation-variable`,
  avec trois spécifications ajoutées et une modifiée.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 811 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet et prochain essai CISMP restent à effectuer après ce
  relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/environnements/environment_docker.sh`,
  `modules/environments/infos.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_sudoers.py`,
  `tests/test_environment_docker.py`, `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `docker-environment`, `legacy-variable-cleanup`,
  `module-infos`, `docker-sudoers`.
- Archive : proposition, design, tâches, trois deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  811 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, Sudoers Docker et informations des
  modules : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/environnements/environment_docker.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_environment_docker.py
  tests/test_config_cleanup.py tests/test_devops_sudoers.py
  tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  rename-env-docker-activation-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  rename-env-docker-activation-variable --yes --json` : réussi; trois specs
  ajoutées, une modifiée.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle de provisionnement Docker est déclaré comme `ENVIRONMENT_DOCKER`
dans le scope `environnements`. La valeur historique `ENV_DOCKER=0|1` est
migrée exactement, la priorité de la nouvelle variable est respectée et les
variables suffixées restent intactes. Tests, ShellCheck, syntaxe et validation
OpenSpec stricte réussissent. Publication et relance DIU dans CISMP restent à
effectuer. Le rapport général `STATISTICS.md` à la racine est absent; sa
production relève du prompt SGS.
