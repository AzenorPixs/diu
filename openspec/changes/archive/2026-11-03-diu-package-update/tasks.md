## 1. Spécification et réalisation

- [x] 1.1 Définir et valider les contrats de sélection et de mise à jour universelle. Preuve : `openspec validate diu-package-update --strict`, réussi le 2026-11-03.
- [x] 1.2 Implémenter la recherche des releases et l'installation contrôlée du paquet DIU. Preuve : trois tests de sélection, pagination et refus réussis le 2026-11-03.
- [x] 1.3 Adapter le routage, l'ordre global et les aides en conservant l'alias. Preuve : 11 tests de routage et orchestration et 59 tests d'aide réussis le 2026-11-03.
- [x] 1.4 Adapter la documentation et incrémenter la version du projet. Preuve : README, TECHNICAL et CHANGELOG relus ; PROJECT_VERSION portée à 1.0.4 le 2026-11-03.

## 2. Validation

- [x] 2.1 Exécuter les tests ciblés et les vérifications syntaxiques et statiques. Preuve : Tests ciblés (3 + 11 + 59 + 44), Bash, ShellCheck et compilation Python réussis le 2026-11-03.
- [x] 2.2 Exécuter la validation globale et vérifier les contrats et la documentation avant archivage. Preuves : 1 080 tests exécutés dont 2 ignorés avec Python DevOps ; OpenSpec strict, syntaxe, ShellCheck et UTF-8/LF réussis le 2026-11-03.

## Sous-lots normalisés

### diu-package-update — code non attribué — Contrats et sélection

Tâches : 1.1 et 1.2. Objectif : spécifier puis réaliser la sélection et l'installation. Dépendances : contrat validé avant code. Validation : OpenSpec, tests de sélection, erreurs et paquet. État : VALIDÉ, 2026-11-03 ; preuves : tâches 1.1 et 1.2 ci-dessus.

### diu-package-update — code non attribué — Interface et documentation

Tâches : 1.3 et 1.4. Objectif : exposer la commande et documenter son comportement. Dépendance : contrat de sélection. Validation : tests de routage, aides et relecture documentaire. État : VALIDÉ, 2026-11-03 ; preuves : tâches 1.3 et 1.4 ci-dessus.

### diu-package-update — code non attribué — Validation globale

Tâches : 2.1 et 2.2. Objectif : valider les unités et leurs interactions. Dépendances : réalisation et documentation. Validation : contrôles ciblés, suite applicable, OpenSpec et cohérence finale. État : VALIDÉ, 2026-11-03 ; preuves : tâches 2.1 et 2.2 ci-dessus.
