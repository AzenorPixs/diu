# Statistiques — rename-bunkerweb-upgrade-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-bunkerweb-upgrade-variable`, code de lot non attribué.
- Contrat validé : `DOCKER_STACK_BUNKERWEB_UPDATE`, `STATIC`, `ENABLE`, scope
  `docker`, défaut `0`.
- La dernière valeur historique littérale
  `DOCKER_STACK_BUNKERWEB_UPGRADE=0|1` est transférée exactement vers
  `docker.env`, sauf si le nouveau nom y est déjà configuré.
- Les réglages `DOCKER_STACK_BUNKERWEB_AUTO_UPDATE` et
  `DOCKER_STACK_BUNKERWEB_VERSION` restent distincts.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  991 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-bunkerweb-upgrade-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/docker/docker_stack_bunkerweb_update.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_docker_stack_bunkerweb_update.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `docker-stack-bunkerweb-update`, mise
  à jour de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  991 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration BunkerWeb : 96 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-bunkerweb-upgrade-variable --strict` : valide.
- `openspec archive rename-bunkerweb-upgrade-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le réglage de mise à jour BunkerWeb utilise désormais
`DOCKER_STACK_BUNKERWEB_UPDATE`, déclaré `STATIC/ENABLE` dans le scope `docker`,
avec un défaut `0`. La valeur historique littérale est migrée; le nouveau
réglage déjà configuré reste prioritaire. Les sélecteurs d’auto-update et de
version restent indépendants. La suite complète compte 991 tests réussis et 2
ignorés; ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec
stricte passent. Publication et relance dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.
