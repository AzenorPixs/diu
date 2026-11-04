# Tasks

## 1. Contrat

- [x] 1.1 Valider le change et ses exigences avec `openspec validate upgrade-devops-opencode-v2 --strict --no-interactive` avant toute écriture de code ou de test.

## 2. Implémentation et documentation

- [x] 2.1 Mettre à jour le bloc OpenCode de `root-install-debian.sh` et ajouter les tests isolés de sélection de release et comparaison de versions ; vérifier chaque cas avec `python3 -B tests/test_devops_opencode.py -v`.
- [x] 2.2 Documenter la détection et l'installation OpenCode V2 dans `TECHNICAL.md` et ajouter une entrée `Unreleased` dans `CHANGELOG.md` ; vérifier les sections et fins de ligne concernées.

## 3. Validation globale

- [x] 3.1 Exécuter les tests ciblés et applicables du monolithe, `bash -n`, ShellCheck et la validation OpenSpec stricte ; consigner chaque commande et résultat.
- [x] 3.2 Revoir les fichiers touchés, l'encodage UTF-8/LF, la cohérence documentaire et l'absence de changements hors périmètre ; ne cocher qu'avec preuves observées.

## Preuves de validation avant archivage

- `/home/devops/python/current/bin/python3 -B tests/test_devops_opencode.py -v` : exécutée et réussie, 9 tests.
- `/home/devops/python/current/bin/python3 -B tests/test_devops_nodejs.py -v` : exécutée et réussie, 5 tests.
- `/home/devops/python/current/bin/python3 -B tests/test_root_shellcheck.py -v` : exécutée et réussie, 9 tests.
- `bash -n root-install-debian.sh` et `shellcheck root-install-debian.sh` : exécutées et réussies.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_devops_opencode.py` : exécutée et réussie.
- `openspec validate upgrade-devops-opencode-v2 --strict --no-interactive` : exécutée et réussie après implémentation.
- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` : 628 tests exécutés, 2 ignorés, 7 échecs hors du périmètre modifié. Un test d'orchestration Git échoue faute de permission d'écriture à `/etc/gitconfig` ; six tests de mises à jour échouent car `system_update` est introuvable. Aucun fichier de ces composants n'a été modifié.
- `openspec validate --all --strict --no-interactive` : 47 éléments valides, 22 échecs sur 69. Les diagnostics touchent d'autres spécifications et deux changes Forgejo actifs qui omettent des scénarios ; le change courant reste valide. Aucun fichier de ces autres éléments n'a été modifié.
- UTF-8/LF vérifiés pour les huit fichiers de source, test, change et documentation concernés. Les cadrages et README non modifiés restent cohérents avec les responsabilités observées ; le relevé `DEVOPS.md` préexistant est préservé.

## Workflow follow-up

- Archiver uniquement ce change après achèvement et validation de toutes les tâches.
- Vérifier l'archive, produire puis vérifier `STATISTIQUES.md` conformément à `AGENTS.md`.
- Appliquer les étapes de commit et publications uniquement selon les conditions explicites du prompt SCM.
