# Statistiques — add-software-apt-apache2-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-software-apt-apache2-variable`, code de lot non attribué.
- Décision validée : `SOFTWARES_APT_APACHE2`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière ancienne valeur littérale `APACHE2=0|1` est transférée exactement
  vers `softwares.env` si `SOFTWARES_APT_APACHE2` n’y est pas déjà configurée.
  Une valeur ambiguë bloque avant toute mutation.
- Archivage réussi sous
  `2026-11-01-add-software-apt-apache2-variable`. La spec canonique existait
  déjà au moment de l’archivage; aucune synchronisation additionnelle n’a été
  nécessaire.
- Suite complète DIU avec Python 3.14.10 : 769 tests réussis, 2 ignorés,
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
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_apache2.sh`.
- Tests : `tests/test_software_apt_apache2.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Specs canoniques : `openspec/specs/software-apt-apache2/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_software_apt_apache2 test_config_cleanup` : 36 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 769 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/softwares/software_apt_apache2.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/softwares/software_apt_apache2.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_software_apt_apache2.py` : réussi.
- Validations strictes OpenSpec du change, de `software-apt-apache2` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 70/87 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-software-apt-apache2-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 121/133 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SOFTWARES_APT_APACHE2` est déclaré en `STATIC`, `ENABLE`, scope `softwares`,
défaut `0`. Le nettoyage migre l’ancienne valeur littérale vers le bon fichier
de scope, sans l’exécuter, et préserve une valeur nouvelle déjà configurée. Le
change est archivé; tests, contrôles shell et validations OpenSpec ciblées
réussissent. Publication et relance DIU dans CISMP restent à effectuer. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.
