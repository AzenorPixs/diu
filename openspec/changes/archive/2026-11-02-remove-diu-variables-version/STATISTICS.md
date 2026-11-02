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
- Publication du paquet, installation LXC et vérification du résultat restent
  à effectuer.

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

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration et l’affichage de `DIU_VARIABLES_VERSION` ont été retirés du
code actif, des tests et de la spécification canonique. `DIU_VERSION` reste
pour afficher la version du paquet DIU installé. Les tests, ShellCheck,
syntaxe Bash et validation OpenSpec stricte passent. Publication et
vérification CISMP restent à effectuer.
