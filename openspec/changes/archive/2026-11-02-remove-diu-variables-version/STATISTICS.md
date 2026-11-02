# Statistiques — remove-diu-variables-version

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `remove-diu-variables-version`, code de lot non attribué.
- Décision : retirer la déclaration dynamique `DIU_VARIABLES_VERSION`, sa
  ligne de résumé, ses tests et sa spécification canonique. `DIU_VERSION`
  reste la variable affichée pour la version du paquet.
- L’affectation historique `VERSION_VARIABLES` reste supprimée sans transfert;
  les expressions shell ambiguës bloquent le nettoyage.
- La suite complète de référence compte 1006 tests réussis, 2 ignorés et aucun
  échec avec `/home/devops/python/current/bin/python3`.
- Archivage réussi sous `2026-11-02-remove-diu-variables-version`;
  une exigence modifiée et deux retirées dans les spécifications canoniques.
- Publication réussie : paquet `2026.11.02.14.42`, commit `c93fac7`, tag
  `v2026.11.02.14.42`, release Forgejo 403.
- Le paquet a été transféré dans CISMP (LXC 100), SHA-256 vérifié
  (`17b500d967f5cd6f759e7be112490f273c70beb4a56f903e69a5f688d5f0c3d8`), puis
  sa version installée a été vérifiée avec `dpkg-query`.
- Relance de `/root/diu/root-install-debian.sh` dans CISMP : code de sortie 0;
  le résumé affiche `DIU_VERSION` uniquement et aucune erreur de variable ne
  survient.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : retrait de `modules/diu/variables/diu/diu_variables_version.sh`,
  mise à jour de `root-install-debian.sh` et
  `modules/system/variables-cleanup.sh`.
- Tests : retrait de `tests/test_diu_variables_version.py`, mise à jour de
  `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : retrait de `diu-variables-version`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  1006 tests réussis, 2 ignorés.
- Tests ciblés `tests.test_config_cleanup` : 95 tests réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `/home/devops/.local/npm/bin/openspec validate remove-diu-variables-version --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive remove-diu-variables-version --yes --json` :
  réussi; deux exigences retirées et une modifiée.
- `git diff --check` : réussi.
- `sudo -n -i zsh -lic 'rcicddiu'` : publication réussie; release Forgejo 403.
- `sudo -n -i zsh -lic 'ridu'` : mise à jour de l’hôte réussie.
- Installation CISMP par `lxc-attach` après contrôle SHA-256 : réussie.
- Relance `/root/diu/root-install-debian.sh` dans LXC 100 : code 0.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration et l’affichage de `DIU_VARIABLES_VERSION` ont été retirés du
code actif, des tests et de la spécification canonique. `DIU_VERSION` reste
pour afficher la version du paquet DIU installé. Les tests, ShellCheck,
syntaxe Bash et validation OpenSpec stricte passent. Publication et
installation CISMP ont réussi. Le script s’est achevé sans erreur de variable;
le résumé conserve `DIU_VERSION`.
