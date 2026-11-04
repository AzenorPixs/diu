## 1. Implémentation

- [x] 1.1 Définir la spécification et les décisions.
- [x] 1.2 Implémenter le nettoyage et migrer les consommateurs.
- [x] 1.3 Documenter le cycle et ajouter les tests.

## 2. Validation

- [x] 2.1 Exécuter syntaxe, ShellCheck et tests applicables.
- [x] 2.2 Vérifier le périmètre et valider OpenSpec.
- [x] 2.3 Synchroniser et archiver l’évolution.

## Résultats

- Syntaxe Bash : succès pour le nouveau module et le script principal.
- ShellCheck : succès pour modules/system/variables-cleanup.sh. Le script principal conserve ses 599 diagnostics antérieurs et ajoute un SC1091 de résolution du nouveau fichier sourcé, vérifié séparément (600 diagnostics au total ; contrôle global non passant avant cette évolution).
- Tests : 4 tests de nettoyage, 4 tests de déclaration système et 23 tests logiciels réussis.
- git diff --check : succès.
- OpenSpec : validation stricte de cette évolution réussie avant archivage.
- Les usages de l’ancien identifiant dans les sources autorisées sont limités au nettoyage, à ses tests et à sa documentation. Les configurations locales sensibles ne sont pas consultées : le nettoyage de variables.sh sera effectué au démarrage du DIU.
- Les modifications préexistantes du dépôt sont conservées. Aucun commit ni push effectué.

- Spécification synchronisée et évolution archivée le 2026-09-05. Purpose généré par OpenSpec complété après archivage.
