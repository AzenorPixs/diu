# Statistiques — rename-env-devops-activation-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-env-devops-activation-variable`, code de lot non attribué.
- Contrat : `ENVIRONMENTS_DEVOPS`, `STATIC`, `ENABLE`, scope
  `environnements`, défaut `0`.
- L'ancienne valeur littérale `ENV_DEVOPS=0|1` est transférée exactement vers
  `environnements.env`; les valeurs `ENVIRONMENTS_DEVOPS` déjà configurées
  restent prioritaires.
- Les affectations historiques `ENV_DEVOPS` sont supprimées après migration,
  sans toucher aux noms voisins comme `ENV_DEVOPS_USER`.
- Archivage réussi sous `2026-11-02-rename-env-devops-activation-variable`,
  avec trois spécifications ajoutées et deux modifiées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 805 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet et nouvel essai dans CISMP restent à effectuer après
  ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`, `modules/environments/infos.sh` et
  `modules/diu/variables/environnements/env_devops.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_python.py`,
  `tests/test_devops_sudoers.py`, `tests/test_environment_devops.py` et
  `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `devops-environment`, `legacy-variable-cleanup`,
  `module-infos`, `devops-python` et `devops-sudoers`.
- Archive : proposition, design, tâches, cinq deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  805 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, Python, Sudoers et informations des
  modules : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/environnements/env_devops.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_environment_devops.py
  tests/test_config_cleanup.py tests/test_devops_sudoers.py
  tests/test_devops_python.py tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  rename-env-devops-activation-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  rename-env-devops-activation-variable --yes --json` : réussi; trois specs
  ajoutées, deux modifiées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle d'activation du profil DevOps est déclaré comme
`ENVIRONMENTS_DEVOPS` dans le scope `environnements`. Les valeurs historiques
`ENV_DEVOPS=0|1` sont migrées sans modification et les valeurs déjà configurées
gardent la priorité. Tests, contrôles Bash, validation stricte et archivage
réussissent. Publication et relance DIU dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève du
prompt SGS.
