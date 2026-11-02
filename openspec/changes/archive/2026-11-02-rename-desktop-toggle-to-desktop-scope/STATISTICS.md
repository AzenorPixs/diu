# Statistiques — rename-desktop-toggle-to-desktop-scope

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-desktop-toggle-to-desktop-scope`, code de lot non attribué.
- Contrat : variable `DESKTOP`, `STATIC`, `ENABLE`, scope `desktop`, défaut `0`.
- La valeur existante `SOFTWARES_APT_DESKTOP=0|1` dans `softwares.env` est
  transférée exactement vers `DESKTOP` dans `desktop.env`, sauf si un `DESKTOP`
  est déjà déclaré dans `desktop.env`.
- Une ancienne affectation `DESKTOP=0|1` de `variables.sh` est aussi migrée.
  La valeur persistée sous `SOFTWARES_APT_DESKTOP` prévaut sur cette valeur
  historique lorsqu'aucun `DESKTOP` nouveau n'existe.
- Archivage réussi sous `2026-11-02-rename-desktop-toggle-to-desktop-scope`,
  avec une spécification ajoutée et trois modifiées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 798 tests
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
  `modules/system/variables-cleanup.sh`, `modules/desktop/infos.sh`,
  `modules/softwares/infos.sh`, ajout de
  `modules/diu/variables/desktop/desktop.sh` et retrait de l'ancienne
  déclaration logicielle.
- Tests : `tests/test_config_cleanup.py`, `tests/test_module_infos.py` et
  `tests/test_software_apt_desktop.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `legacy-variable-cleanup`, `module-infos` et
  `software-apt-desktop`.
- Archive : proposition, design, tâches, trois deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  798 tests réussis, 2 ignorés.
- Tests ciblés de déclaration `DESKTOP`, migration et informations des modules
  : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/desktop/desktop.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_software_apt_desktop.py
  tests/test_config_cleanup.py tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  rename-desktop-toggle-to-desktop-scope --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  rename-desktop-toggle-to-desktop-scope --yes --json` : réussi; une spec
  ajoutée, trois modifiées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`DESKTOP` réside désormais dans le scope `desktop`. `config_cleanup` préserve
les valeurs déjà persistées sous `SOFTWARES_APT_DESKTOP` et respecte la priorité
de `desktop.env`. Les tests, contrôles Bash, validation stricte et archivage
réussissent. Publication et relance DIU dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève du
prompt SGS.
