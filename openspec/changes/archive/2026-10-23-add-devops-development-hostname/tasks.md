## 1. Spécification et réalisation

- [x] 1.1 Valider strictement le change avant toute écriture de code et de tests.
- [x] 1.2 Ajouter la sonde hostname -f et la deuxième puce sous l'OS.
- [x] 1.3 Passer le rendu et les attentes documentaires à 0.7.
- [x] 1.4 Ajouter les tests isolés et mettre à jour la documentation.

## 2. Validation

- [x] 2.1 Exécuter syntaxe Bash, ShellCheck, compilation Python et tests applicables.
- [x] 2.2 Vérifier OpenSpec, encodage, périmètre et cohérence documentaire.

Les 119 méthodes de test passent sans échec, erreur ou test ignoré.
Bash, ShellCheck et compilation Python passent. Le change est valide en mode
strict. Le contrôle global strict retrouve 22 éléments préexistants en échec,
dont les huit avertissements de longueur du canon ciblé. Ils restent hors périmètre.

## 3. Livraison après validation

Archiver uniquement ce change et synchroniser le canon, puis produire et
vérifier STATISTIQUES.md à six sections dans l'archive. Les résultats sont
prouvés après exécution, sans cocher ces opérations par anticipation.

