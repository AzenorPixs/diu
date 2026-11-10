## 1. Spécification
- [x] 1.1 Définir le refus et préserver les parcours APT existants.

## 2. Implémentation et validation
- [x] 2.1 Retirer le routage et les entrées d'aide, adapter les tests et le changelog.
- [x] 2.2 Vérifier les tests ciblés, la syntaxe, ShellCheck et la validation globale.

## Sous-lots normalisés

### remove-softwares-apt-update — code non attribué : contrat, implémentation et validation
- Tâches : 1.1, 2.1, 2.2 ; périmètre : spécification, routage, aide, tests et documentation.
- Dépendance : validation du périmètre et change OpenSpec ; critères : refus sans effet, comportements préservés et contrôles réussis.
- État : VALIDÉ au 2026-11-06 ; OpenSpec strict, 34 tests logiciels, 63 tests aide, bash -n et ShellCheck réussis ; validation globale réussie : 1 220 tests dont 2 ignorés avec Python DevOps. Attribution définitive des sous-lots en attente d'ACL.
