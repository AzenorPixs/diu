# Statistiques — add-system-no-sleep-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-no-sleep-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_NO_SLEEP`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- La dernière valeur historique littérale `NO_SLEEP=0|1` est transférée
  exactement si `SYSTEM_NO_SLEEP` n’est pas déjà configurée. Une valeur `1`
  conserve les traitements de désactivation de veille; `0` n’efface pas un
  éventuel `nosleep.conf` existant.
- Archivage réussi sous `2026-11-01-add-system-no-sleep-variable`. La spec
  canonique existait déjà; aucune synchronisation additionnelle n’a été
  nécessaire.
- Suite complète DIU avec Python 3.14.10 : 761 tests réussis, 2 ignorés,
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
  `modules/diu/variables/system/system_no_sleep.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_no_sleep.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`.
- Specs canoniques : `openspec/specs/system-no-sleep/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_no_sleep test_config_cleanup` : 34 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 761 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_no_sleep.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_no_sleep.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_no_sleep.py` : réussi.
- Validations strictes OpenSpec du change, de `system-no-sleep` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 69/86 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-no-sleep-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 120/132 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_NO_SLEEP` est déclaré en `STATIC`, `ENABLE`, scope `system`, défaut
`0`. La migration conserve exactement l’ancienne valeur littérale et donne
priorité au nouveau nom. Le consommateur garde le comportement de
`nosleep.conf`; le défaut désactivé n’efface pas un fichier déjà présent. Le
change est archivé; tests, contrôles shell et validations OpenSpec ciblées
réussissent. Publication et relance DIU dans CISMP restent à faire. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.
