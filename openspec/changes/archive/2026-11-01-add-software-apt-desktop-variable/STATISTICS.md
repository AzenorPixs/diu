# Statistiques — add-software-apt-desktop-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-software-apt-desktop-variable`, code de lot non attribué.
- Décision appliquée : `SOFTWARES_APT_DESKTOP`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `DESKTOP=0|1` est transférée
  exactement vers `softwares.env` si le nouveau nom n'y est pas déjà configuré.
- Les deux consommateurs historiques utilisent le nouveau nom avec repli `0`;
  le comportement du profil de bureau activé est préservé.
- Archivage réussi sous `2026-11-01-add-software-apt-desktop-variable`, avec
  deux spécifications ajoutées et une modifiée.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 797 tests
  réussis, 2 ignorés, aucun échec.
- Le paquet DIU et le prochain essai CISMP restent à publier après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/softwares/infos.sh` et
  `modules/diu/variables/softwares/software_apt_desktop.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_module_infos.py` et
  `tests/test_software_apt_desktop.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `legacy-variable-cleanup`, `module-infos` et
  `software-apt-desktop`.
- Archive : proposition, design, tâches, deux deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  797 tests réussis, 2 ignorés.
- Tests ciblés de déclaration du bureau, migration et informations des
  modules : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/softwares/software_apt_desktop.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_software_apt_desktop.py
  tests/test_config_cleanup.py tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  add-software-apt-desktop-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  add-software-apt-desktop-variable --yes --json` : réussi; deux specs
  ajoutées, une modifiée.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le sélecteur historique `DESKTOP` est maintenant déclaré sous
`SOFTWARES_APT_DESKTOP`, avec un défaut désactivé et transfert exact des
valeurs `0|1`. Le change est archivé; tests, contrôles Bash et validation
OpenSpec stricte réussissent. La publication et la relance du DIU dans CISMP
restent à réaliser. Le rapport général `STATISTICS.md` à la racine est absent;
sa production relève du prompt SGS.
