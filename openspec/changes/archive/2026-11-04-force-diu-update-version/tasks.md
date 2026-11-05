## 1. Livraison

- [x] 1.1 Définir et valider le contrat OpenSpec.
- [x] 1.2 Adapter le routage, le moteur et les tests de sélection et installation.
- [x] 1.3 Adapter l’aide, les tests d’aide et la documentation.
- [x] 1.4 Exécuter les contrôles ciblés et la validation globale.

## Sous-lots normalisés

### force-diu-update-version — version explicite — code non attribué

- Tâches : 1.1 à 1.4 ; périmètre : OpenSpec, routage, moteur, aide, tests et documentation.
- Objectif : sélectionner et réinstaller une version GitHub exacte en préservant le mode automatique.
- Dépendances : contrat OpenSpec validé avant implémentation.
- Critères : tests ciblés, contrôles Bash et ShellCheck, OpenSpec strict et suite globale.
- État au 2026-11-04 : RÉALISÉ À VALIDER ; OpenSpec strict, 14 tests de mise à jour, 60 tests d’aide, 11 tests de routage, Bash et ShellCheck réussis ; suite globale : 1 152 tests dont 2 ignorés, avec Python DevOps. Attribution du code : ACL.
