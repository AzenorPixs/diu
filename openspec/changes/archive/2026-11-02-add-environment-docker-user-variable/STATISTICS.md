# Statistiques — add-environment-docker-user-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-environment-docker-user-variable`, code de lot non attribué.
- Contrat validé : `ENVIRONMENT_DOCKER_USER`, `STATIC`, `ENABLE`, scope
  `docker`, défaut `docker`.
- La valeur littérale historique `DOCKER_USER` est transférée exactement vers
  `docker.env`; une nouvelle valeur déjà configurée garde la priorité.
- Les consommateurs du propriétaire des stacks Docker utilisent le nouveau
  nom; `ENV_DOCKER_USER` reste distinct.
- Archivage réussi sous `2026-11-02-add-environment-docker-user-variable`,
  avec deux spécifications ajoutées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 817 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet et nouvel essai CISMP restent à effectuer après ce
  relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/docker/docker_user.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_sudoers.py`,
  `tests/test_docker_user_environment.py`, `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `docker-user` et `legacy-variable-cleanup`.
- Archive : proposition, design, tâches, deux deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  817 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, consommateurs Docker et Sudoers :
  réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/docker/docker_user.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_docker_user_environment.py
  tests/test_config_cleanup.py tests/test_devops_sudoers.py
  tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  add-environment-docker-user-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  add-environment-docker-user-variable --yes --json` : réussi; deux specs
  ajoutées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le propriétaire des stacks Docker est maintenant déclaré comme
`ENVIRONMENT_DOCKER_USER` dans le scope `docker`, avec défaut `docker`. L'ancien
`DOCKER_USER` est migré sans altérer sa valeur; les noms préfixés comme
`ENV_DOCKER_USER` restent distincts. Tests, contrôles Bash, validation OpenSpec
stricte et archivage réussissent. Publication et relance DIU dans CISMP restent
à effectuer. Le rapport général `STATISTICS.md` à la racine est absent; sa
production relève du prompt SGS.
