# Statistiques — rename-env-ia-activation-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-env-ia-activation-variable`, code de lot non attribué.
- Contrat validé : `ENVIRONMENT_IA`, `STATIC`, `ENABLE`, scope
  `environnements`, défaut `0`.
- La dernière valeur historique littérale `ENV_IA=0|1` est transférée
  exactement vers `environnements.env`, sauf si `ENVIRONMENT_IA` y est déjà
  configurée; les variables suffixées `ENV_IA_USER`, `ENV_IA_GROUP` et
  `ENV_IA_PASSWORD` restent distinctes.
- Archivage réussi sous `2026-11-02-rename-env-ia-activation-variable`;
  trois spécifications ajoutées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 823 tests
  réussis, 2 ignorés, aucun échec.
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
  `modules/diu/variables/environnements/environment_ia.sh`,
  `modules/environments/infos.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_sudoers.py`,
  `tests/test_environment_ia.py`, `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `environment-ia`, `legacy-variable-cleanup`,
  `module-infos`.
- Archive : proposition, design, tâches, trois deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  823 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, génération sudoers et informations
  des modules : réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-env-ia-activation-variable --strict` : valide.
- `openspec archive rename-env-ia-activation-variable --yes --json` : réussi;
  trois spécifications ajoutées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le provisionnement IA utilise désormais `ENVIRONMENT_IA`, déclaré en
`STATIC/ENABLE` dans le scope `environnements`, avec un défaut `0`. La valeur
historique exacte `ENV_IA=0|1` est migrée, la nouvelle valeur configurée reste
prioritaire et les variables suffixées ne sont pas renommées. Les contrôles
OpenSpec, Bash, ShellCheck, compilation Python et 823 tests passent. La
publication et la relance dans CISMP restent à effectuer. Le rapport général
`STATISTICS.md` à la racine est absent; sa production relève du prompt SGS.
