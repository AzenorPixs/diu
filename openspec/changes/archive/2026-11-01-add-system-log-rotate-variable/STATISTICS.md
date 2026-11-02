# Statistiques — add-system-log-rotate-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-log-rotate-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_LOG_ROTATE`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- Une ancienne valeur littérale `LOG_ROTATE=0|1` est migrée exactement si le
  nouveau nom n’est pas déjà configuré. Les formes ambiguës bloquent le
  nettoyage sans mutation ni affichage de leur contenu.
- Le consommateur logrotate utilise le nouveau nom. `LOG_ROTATE_DAILY` et le
  contenu du bloc logrotate restent hors de ce change.
- Archivage réussi sous
  `2026-11-01-add-system-log-rotate-variable`; une spec canonique a été
  modifiée par la synchronisation d’archive.
- Suite complète DIU avec Python 3.14.10 : 725 tests réussis, 2 ignorés,
  aucun échec.
- Publication du paquet et relance de DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

16 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_log_rotate.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_log_rotate.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `openspec/specs/system-log-rotate/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_log_rotate test_config_cleanup` : 28 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 725 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_log_rotate.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_log_rotate.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_log_rotate.py` : réussi.
- Validations strictes OpenSpec du change, de `system-log-rotate` et de `legacy-variable-cleanup` : réussies.
- Validation OpenSpec stricte globale avant archivage : 64/81 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-log-rotate-variable --yes --json` : réussi; une spec canonique modifiée.
- `openspec validate --archived --json --no-interactive` : 115/127 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_LOG_ROTATE` est déclaré en `STATIC`, `ENABLE`, scope `system`, défaut
`0`. La migration conserve exactement l’ancienne valeur littérale et donne la
priorité au nouveau nom. Le consommateur logrotate conserve son comportement
existant, tandis que `LOG_ROTATE_DAILY` reste une variable séparée. Le change
est archivé; tests, contrôles shell et validations OpenSpec ciblées réussissent.
La publication et la relance DIU dans CISMP restent à effectuer. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.
