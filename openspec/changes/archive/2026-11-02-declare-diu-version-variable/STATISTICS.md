# Statistiques — declare-diu-version-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `declare-diu-version-variable`, code de lot non attribué.
- Contrat validé : `DIU_VERSION`, `DYNAMIC`, `ENABLE`, scope `diu`; sa
  fonction génératrice lit la version installée du paquet Debian `diu` avec
  `dpkg-query`.
- `VERSION_ALIAS` est retirée sans migration; `VERSION` et
  `VERSION_VARIABLES` sont conservées.
- La suite complète de référence compte 1005 tests réussis, 2 ignorés et aucun
  échec avec `/home/devops/python/current/bin/python3`.
- Archivage réussi sous `2026-11-02-declare-diu-version-variable`; trois
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
  `modules/diu/variables/diu/diu_version.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_diu_version.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `diu-version`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  1005 tests réussis, 2 ignorés.
- Tests ciblés `tests.test_diu_version` et `tests.test_config_cleanup` :
  97 tests réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `/home/devops/.local/npm/bin/openspec validate declare-diu-version-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive declare-diu-version-variable --yes --json` :
  réussi; deux spécifications archivées.
- `git diff --check` : réussi.
- `pytest -q` avec le Python système : 976 réussis, 2 ignorés, 26 échecs dans
  les tests de détection d’environnements virtuels de projet; l’interpréteur de
  référence `/home/devops/python/current/bin/python3` exécute toute la suite
  sans échec.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le résumé DIU utilise désormais `DIU_VERSION`, générée depuis la version du
paquet installé. L’ancienne affectation `VERSION_ALIAS` est supprimée sans
évaluation ni transfert, et les contrôles de syntaxe, ShellCheck, OpenSpec et
la suite complète de référence réussissent. La publication, l’installation
LXC et le nouveau cycle d’exécution restent à effectuer.
