## 1. Contrat et réalisation

- [x] 1.1 Spécifier et valider l'accès GitHub privé et public. Preuve : validation OpenSpec stricte réussie le 2026-11-03.
- [x] 1.2 Adapter la recherche et le téléchargement GitHub en réutilisant l'authentification existante. Preuve : cinq tests GitHub isolés, 2026-11-03.
- [x] 1.3 Tester l'accès privé, l'accès public et les échecs sans fuite d'identifiant. Preuve : cinq tests privés, trois tests de fournisseurs et contrôles Zstandard réussis, 2026-11-03.
- [x] 1.4 Actualiser la documentation et la version locale coordonnée. Preuve : README, TECHNICAL, CHANGELOG et PROJECT_VERSION=1.0.6, 2026-11-03.

## 2. Validation

- [x] 2.1 Exécuter les contrôles ciblés, syntaxiques et statiques. Preuves : 66 tests ciblés, bash -n, ShellCheck et compilation Python réussis, 2026-11-03.
- [x] 2.2 Exécuter la validation globale et vérifier la cohérence avant archivage. Preuves : 1 088 tests exécutés dont 2 ignorés, sans échec ; OpenSpec strict et UTF-8/LF validés le 2026-11-03.

## Sous-lots normalisés

### authenticate-diu-github-updates — code non attribué — Contrat et accès

Tâches : 1.1 et 1.2. Dépendance : contrat validé. Objectif : réutiliser
l'authentification GitHub pour releases et assets. Validation : OpenSpec et
tests isolés. État : VALIDÉ, 2026-11-03 ; preuves : tâches 1.1 et 1.2.

### authenticate-diu-github-updates — code non attribué — Tests et documentation

Tâches : 1.3 et 1.4. Dépendance : accès implémenté et version coordonnée.
Validation : tests de succès et d'échecs, relecture et version locale.
État : VALIDÉ, 2026-11-03 ; preuves : tâches 1.3 et 1.4.

### authenticate-diu-github-updates — code non attribué — Validation globale

Tâches : 2.1 et 2.2. Dépendance : réalisation et documentation. Validation :
tests ciblés et globaux, syntaxe, ShellCheck et OpenSpec. État : VALIDÉ,
2026-11-03 ; preuves : tâches 2.1 et 2.2.
