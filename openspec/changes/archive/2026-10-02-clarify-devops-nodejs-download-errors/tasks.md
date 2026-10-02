## 1. Spécification
- [x] 1.1 Valider le change et ses exigences avant toute écriture de code ou test.

## 2. Implémentation et documentation
- [x] 2.1 Séparer le téléchargement de l'index Node.js et contextualiser son échec.
- [x] 2.2 Ajouter les tests isolés du diagnostic et de la sélection de version.
- [x] 2.3 Documenter le comportement dans TECHNICAL.md.

## 3. Validation et finalisation
- [x] 3.1 Exécuter bash -n, ShellCheck, les tests ciblés et les tests du monolithe.
- [x] 3.2 Contrôler les fichiers touchés, UTF-8/LF et la cohérence des cadrages.
- [x] 3.3 Valider le change en vue de sa synchronisation et de son archivage.

## Preuves de validation

- `bash -n root-install-debian.sh` : exécutée et réussie.
- `shellcheck root-install-debian.sh` : exécutée et réussie, sans diagnostic.
- `python3 -B tests/test_devops_nodejs.py -v` : exécutée et réussie, 5 tests,
  dont 8 cas d'échec curl (codes 60, 6, 22 et 28, avec ou sans contenu partiel).
- `python3 -B tests/test_root_shellcheck.py -v` : exécutée et réussie, 9 tests.
- Syntaxe Python via `ast.parse`, UTF-8/LF et revue du bloc : exécutées et réussies.
- Le nouveau diagnostic conserve l'échec et TLS ; seul TECHNICAL.md nécessite
  une mise à jour. AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et README.md
  restent cohérents dans le périmètre examiné. Aucune inspection ni opération
  Git n'a été effectuée ; aucune configuration locale du DIU n'a été lue ou modifiée.
- `openspec validate clarify-devops-nodejs-download-errors --strict --no-interactive`
  via le chemin DEVOPS.md : exécutée et réussie avant et après implémentation.

La synchronisation et l'archivage sont l'opération terminale, après validation
de toutes les tâches d'implémentation et de contrôle ci-dessus.

## Finalisation observée

- L'appel d'archivage `--json` seul a demandé la confirmation de synchronisation,
  sans archiver. L'appel autorisé `--json --yes` a ensuite réussi : 3 exigences
  ajoutées, aucune exigence existante modifiée, supprimée ou renommée.
- Change archivé sous `2026-10-02-clarify-devops-nodejs-download-errors`.
- La validation stricte de la spécification principale a initialement échoué
  sur le Purpose provisoire généré par OpenSpec. Le Purpose a été renseigné
  dans la spécification principale et le delta archivé.
- `openspec validate devops-nodejs-download --strict --no-interactive` via le
  chemin DEVOPS.md : exécutée et réussie après correction. Le seul diagnostic
  restant est informatif : longueur de l'exigence de diagnostic supérieure
  à 500 caractères ; aucune erreur ni avertissement ne subsiste.
