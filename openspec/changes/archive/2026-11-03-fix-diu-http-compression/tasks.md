## 1. Contrat et correction

- [x] 1.1 Définir et valider le contrat de décodage HTTP. Preuve : validation OpenSpec stricte réussie le 2026-11-03.
- [x] 1.2 Corriger les deux appels et vérifier le succès et l'échec de décodage avec des données contrôlées. Preuves : trois tests HTTP locaux Zstandard réussis le 2026-11-03, installation simulée.
- [x] 1.3 Actualiser la documentation et la version dans le périmètre coordonné. Preuves : README, TECHNICAL, CHANGELOG et PROJECT_VERSION=1.0.5, 2026-11-03.

## 2. Validation

- [x] 2.1 Exécuter les tests ciblés et les contrôles de syntaxe et d'analyse applicables. Preuves : 3 tests Zstandard, 58 tests de régression, bash -n, ShellCheck et py_compile réussis le 2026-11-03.
- [x] 2.2 Exécuter la validation globale et vérifier la cohérence avant archivage. Preuves : 1 083 tests exécutés, dont 2 ignorés, sans échec ; validation stricte OpenSpec et UTF-8/LF réussies le 2026-11-03.

## Sous-lots normalisés

### fix-diu-http-compression — code non attribué — Contrat et décodage

Tâches : 1.1 et 1.2. Objectif : décoder les réponses HTTP avant traitement.
Dépendance : contrat validé avant code. Validation : OpenSpec et tests HTTP
locaux avec succès et échec. État : VALIDÉ, 2026-11-03 ; preuves : tâches 1.1 et 1.2.

### fix-diu-http-compression — code non attribué — Documentation et version

Tâche : 1.3. Objectif : actualiser les descriptions et la version du projet.
Dépendance : correction validée et coordination de la version. Validation :
relecture des documents et extraction filtrée de la version. État : VALIDÉ, 2026-11-03 ; preuve : tâche 1.3.

### fix-diu-http-compression — code non attribué — Validation globale

Tâches : 2.1 et 2.2. Objectif : vérifier la correction et les interactions.
Dépendance : unités précédentes. Validation : tests ciblés et globaux, syntaxe,
ShellCheck, OpenSpec et cohérence documentaire. État : VALIDÉ, 2026-11-03 ; preuves : tâches 2.1 et 2.2.
