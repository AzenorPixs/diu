## 1. Spécification et réalisation

- [x] 1.1 Valider strictement le change approuvé avant les écritures de code et tests.
- [x] 1.2 Ajouter la préparation bornée aux sept chemins DevOps et les diagnostics.
- [x] 1.3 Ajouter les tests isolés des droits, liens, erreurs et invariants.
- [x] 1.4 Mettre à jour TECHNICAL.md, README.md et CHANGELOG.md.

## 2. Validation et livraison

- [x] 2.1 Vérifier syntaxe Bash, ShellCheck, compilation Python et tests applicables.
- [x] 2.2 Vérifier OpenSpec, encodage, périmètre et cohérence documentaire.

Les 113 tests passent. Bash, ShellCheck et compilation Python passent.
Le change est valide en mode strict. Le canon existant est valide en mode
ordinaire avec huit avertissements de longueur. Le contrôle global strict
échoue sur 22 éléments préexistants, hors périmètre ; ils ne sont pas corrigés.

## 3. Opérations de livraison après les validations préalables

Archiver ce seul change et synchroniser la spécification canonique, puis
produire et vérifier STATISTIQUES.md avec six sections et mesures traçables.
Ces opérations sont prouvées par le résultat d'archivage et le rapport ajouté
dans l'archive ; elles ne sont pas cochées par anticipation.
