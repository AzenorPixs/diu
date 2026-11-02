# Statistiques — rename-wazuh-server-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-wazuh-server-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_WAZUH_SERVER`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `WAZUH_SERVER=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Le repli d’initialisation de `SYSTEM_APT_WAZUH` utilise le nouveau contrôle
  logiciel avec `WAZUH_SERVER_UPGRADE`; cette variable de mise à niveau reste
  distincte.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  959 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-wazuh-server-variable`; quatre
  exigences ajoutées dans trois spécifications.
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
  `modules/diu/variables/softwares/software_apt_wazuh_server.sh`,
  `modules/diu/variables/system/system_apt_unofficial.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_wazuh_server.py`,
  `tests/test_system_apt_unofficial.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-wazuh-server`, mise à
  jour de `legacy-variable-cleanup` et `system-debian-apt`.
- Archive : proposition, conception, tâches, trois deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  959 tests réussis, 2 ignorés.
- Tests ciblés du contrôle Wazuh Server, de sa migration et du dépôt APT :
  104 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-wazuh-server-variable --strict` : valide.
- `openspec archive rename-wazuh-server-variable --yes --json` : réussi;
  trois spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Wazuh Server utilise désormais `SOFTWARES_APT_WAZUH_SERVER`,
déclaré `STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La
valeur historique exacte `WAZUH_SERVER=0|1` est migrée et le nouveau réglage
déjà configuré reste prioritaire. Le repli du dépôt `SYSTEM_APT_WAZUH` conserve
le rôle de `WAZUH_SERVER_UPGRADE`. La suite complète compte 959 tests réussis
et 2 ignorés; ShellCheck, syntaxe Bash, compilation Python et validation
OpenSpec stricte passent. Publication et relance dans CISMP restent à effectuer.
Le rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.
