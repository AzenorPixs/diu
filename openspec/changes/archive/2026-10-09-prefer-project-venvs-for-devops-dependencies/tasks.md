## 1. Spécification

- [x] 1.1 Vérifier les artefacts UTF-8/LF et les scénarios préservés ; réussir la validation stricte avant code/test.

## 2. Correctif

- [x] 2.1 Implémenter découverte, priorité, sondes isolées, chemins réels, diagnostics et format 0.4.
- [x] 2.2 Réussir les tests de venv et les régressions des quatre suites de modèles.
- [x] 2.3 Réussir syntaxe Bash, ShellCheck et compilation Python.

## 3. Cohérence

- [x] 3.1 Mettre à jour TECHNICAL.md, README.md et CHANGELOG.md ; justifier les documents inchangés.
- [x] 3.2 Vérifier diff, périmètre, UTF-8/LF, nettoyage et validations OpenSpec finales ; distinguer les écarts préexistants.

## 4. Clôture après les prérequis

Après preuve des tâches, synchroniser le seul canon puis archiver ce change. Produire et vérifier STATISTIQUES.md, ses six sections, UTF-8/LF et totaux. Ne cocher aucune tâche sans preuve ni réarchiver si seul le rapport reste à corriger.

## Preuves avant archivage

- Change strict avant code et final : code 0, aucune issue.
- bash -n, ShellCheck, py_compile et compilation des deux programmes Python integres : codes 0.
- Tests finaux : 63 DevOps + 17 OpenSpec + 8 tous-modeles + 9 mise-a-jour generale = 97 reussis, aucun echec ni ignore.
- Reproduction synthetique Pixs : quatre distributions privilegiees dans .venv, interpreteur conserve et chemins installation observes.
- Priorite, sous-dossiers, repli, absence du Python DevOps, .pth/paquets non executes, erreurs, ambiguite, repertoire site-packages manquant et delais verifies.
- Source originale et courante comparees sans Git ; cinq fichiers preexistants modifies et cinq artefacts ajoutes seulement. UTF-8/LF verifies ; temporaires absents.
- Global strict : diagnostics preexistants identiques (3 ERROR, 53 WARNING, 1 INFO), code natif 1 conserve, non revendique comme succes global.
- Archivage et rapport seront prouves apres leur execution.
