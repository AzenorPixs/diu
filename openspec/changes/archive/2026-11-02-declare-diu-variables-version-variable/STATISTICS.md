# Statistiques — declare-diu-variables-version-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `declare-diu-variables-version-variable`, code de lot non
  attribué.
- Contrat validé : `DIU_VARIABLES_VERSION`, `DYNAMIC`, `ENABLE`, scope `diu`;
  `variable_generator()` retourne la version du paquet Debian `diu` installé
  via `dpkg-query`, et échoue explicitement si elle est indisponible.
- L’ancienne valeur littérale `VERSION_VARIABLES` n’est pas transférée;
  `VERSION` demeure conservée.
- La suite complète de référence compte 1010 tests réussis, 2 ignorés et aucun
  échec avec `/home/devops/python/current/bin/python3`.
- Archivage réussi sous `2026-11-02-declare-diu-variables-version-variable`;
  trois exigences ajoutées et une modifiée dans deux spécifications.
- Publication réussie : paquet `2026.11.02.14.25`, commit `cb83983`, tag
  `v2026.11.02.14.25`, release Forgejo 401.
- Le paquet a été transféré dans CISMP (LXC 100), SHA-256 vérifié
  (`ee9ace47efe826927a119def4c44c2bce7bfc099fa3589846265dc7679c7e6dc`), puis
  la version installée a été vérifiée avec `dpkg-query`.
- Relance de `/root/diu/root-install-debian.sh` dans CISMP : code de sortie 0;
  les deux variables de version affichent `2026.11.02.14.25`, puis le script
  termine après la section réseau sans autre erreur de variable.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/diu/diu_variables_version.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_diu_variables_version.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`, `DEVOPS.md` régénéré par
  `ridu` après la publication précédente.
- Spécifications canoniques : ajout de `diu-variables-version`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  1010 tests réussis, 2 ignorés.
- Tests ciblés `tests.test_diu_variables_version` et
  `tests.test_config_cleanup` : 99 tests réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `/home/devops/.local/npm/bin/openspec validate declare-diu-variables-version-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive declare-diu-variables-version-variable --yes --json` :
  réussi; deux spécifications archivées.
- `git diff --check` : réussi.
- `sudo -n -i zsh -lic 'rcicddiu'` : publication réussie; release Forgejo 401.
- `sudo -n -i zsh -lic 'ridu'` : mise à jour de l’hôte réussie.
- Installation CISMP par `lxc-attach` après contrôle SHA-256 : réussie.
- Relance `/root/diu/root-install-debian.sh` dans LXC 100 : code 0.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le résumé DIU utilise désormais `DIU_VARIABLES_VERSION`, générée depuis la
version du paquet Debian installé. Le nettoyage retire sans évaluation
l’ancienne valeur littérale et bloque les expressions ambiguës. Les tests
ciblés, la suite complète de référence, ShellCheck, la syntaxe Bash et OpenSpec
stricte passent. Publication, installation LXC et nouveau cycle d’exécution
ont réussi. Le script d’installation a terminé sans autre erreur de variable.
