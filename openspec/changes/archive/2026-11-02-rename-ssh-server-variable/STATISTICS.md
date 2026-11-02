# Statistiques — rename-ssh-server-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-ssh-server-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_SSH_SERVER`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `SSH=0|1` est transférée exactement
  vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Les deux consommateurs utilisent la nouvelle variable; les valeurs
  `KEY_SSH_ADMIN` et `KEY_SSH_ACME` restent distinctes.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  927 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-ssh-server-variable`; trois
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
  `modules/diu/variables/softwares/software_apt_ssh_server.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_ssh_server.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-ssh-server`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  927 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration OpenSSH : 80 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-ssh-server-variable --strict` : valide.
- `openspec archive rename-ssh-server-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle OpenSSH utilise désormais `SOFTWARES_APT_SSH_SERVER`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `SSH=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. Les clés `KEY_SSH_ADMIN` et `KEY_SSH_ACME` restent séparées.
La suite complète compte 927 tests réussis et 2 ignorés; ShellCheck, syntaxe
Bash, compilation Python et validation OpenSpec stricte passent. Publication et
relance dans CISMP restent à effectuer. Le rapport général `STATISTICS.md` à
la racine est absent; sa production relève du prompt SGS.
