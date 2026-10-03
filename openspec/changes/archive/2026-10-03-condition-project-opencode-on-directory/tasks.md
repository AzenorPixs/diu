## 1. Spécification préalable

- [x] 1.1 Formaliser et valider strictement le delta OpenSpec dans le périmètre approuvé avant toute écriture de code ou de test.

## 2. Implémentation et documentation

- [x] 2.1 Ajouter la valeur effective locale à projects_template_openspec et conserver les branches et prérequis existants.
- [x] 2.2 Actualiser l'aide et TECHNICAL.md pour la condition de présence du dossier.
- [x] 2.3 Adapter les fixtures existantes et couvrir la matrice de valeurs, le fichier non répertoire, les projets mixtes et la conservation de OPENCODE.

## 3. Validation et clôture

- [x] 3.1 Exécuter bash -n, ShellCheck, la compilation Python et les tests ciblés et de non-régression des appelants.
- [x] 3.2 Contrôler les aides help et ?, la cohérence documentaire, les changements du périmètre, UTF-8 et LF, et valider strictement le change.
- [x] 3.3 Établir l'éligibilité à la synchronisation et à l'archivage du seul change ciblé : critères satisfaits, tâches d'implémentation et de validation terminées, documentation cohérente.

## Preuves de validation

- `bash -n modules/projects/template.sh` et `bash -n lib/rid-help.sh` : succès.
- `shellcheck modules/projects/template.sh lib/rid-help.sh` : succès.
- Compilation des trois fichiers Python modifiés via `py_compile` avec
  l'interpréteur `/home/devops/python/current/bin/python3` : succès,
  fichiers compilés temporaires nettoyés.
- Tests avec ce même interpréteur et `-B` :
  `test_projects_template_openspec.py` (17), `test_projects_template_all.py` (8),
  `test_rid_help.py` (56), `test_projects.py` (25),
  `test_projects_general_update.py` (9), `test_devops_openspec.py` (9) :
  124 tests réussis. Su et OpenSpec sont simulés dans les tests fonctionnels.
- `openspec validate condition-project-opencode-on-directory --strict` : succès.
- Revue des modifications par comparaison aux contenus initiaux conservés
  en mémoire, sans inspection Git ; UTF-8 et LF vérifiés.
- Matrice de cohérence : code, aide et TECHNICAL.md alignés sur le delta ;
  AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et README.md n'exigent aucune
  modification pour cette condition locale. Aucun écart bloquant observé
  dans le périmètre concerné.

La synchronisation, l'archivage et la validation stricte de la spécification
finale interviennent après ces contrôles d'éligibilité.
