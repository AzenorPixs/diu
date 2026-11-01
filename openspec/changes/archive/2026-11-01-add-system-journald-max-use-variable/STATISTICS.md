# Statistiques — add-system-journald-max-use-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-journald-max-use-variable`, code de lot non
  attribué.
- Décision validée : `SYSTEM_JOURNALD_MAX_USE`, `STATIC`, `ENABLE`, scope
  `system`, défaut `500M`.
- Les valeurs acceptées sont un entier, suivi facultativement de `K`, `M`, `G`,
  `T`, `P` ou `E`. Une valeur historique simple et valide est migrée sans
  interprétation si le nouveau nom n’est pas déjà configuré.
- `SystemMaxUse` et `RuntimeMaxUse` utilisent la nouvelle variable.
  `JOURNALD_KEEP_FREE` reste distinct et hors de ce change.
- Archivage réussi sous `2026-11-01-add-system-journald-max-use-variable`; la
  spec canonique était déjà synchronisée.
- Suite complète DIU avec Python 3.14.10 : 745 tests réussis, 2 ignorés,
  aucun échec.
- Publication et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

15 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_journald_max_use.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_journald_max_use.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`.
- Specs canoniques : `openspec/specs/system-journald-max-use/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_journald_max_use test_config_cleanup` : 30 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 745 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_journald_max_use.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_journald_max_use.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_journald_max_use.py` : réussi.
- Validations strictes OpenSpec du change, de `system-journald-max-use` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 67/84 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-journald-max-use-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 118/130 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_JOURNALD_MAX_USE` est déclaré statique avec défaut `500M`; les valeurs
préconfigurées sont validées, et l’ancienne limite simple est migrée sans
exécution. Les deux paramètres journald utilisent le nouveau nom. Le change
est archivé; tests, contrôles shell et validations OpenSpec ciblées réussissent.
Publication et relance DIU dans CISMP restent à faire. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.
