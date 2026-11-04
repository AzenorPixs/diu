# Tâches

- [x] Retirer les appels de modification des mots de passe des trois comptes.
- [x] Vérifier les comptes existants et absents, la syntaxe et OpenSpec.
- [x] Examiner la documentation et la validation globale du change.

## Sous-lots normalisés

### stop-setting-technical-account-passwords — comptes techniques — code non attribué

- Tâches : les trois tâches ci-dessus, un seul comportement transversal.
- Périmètre : blocs de comptes, tests isolés et documentation associée.
- Dépendances : aucune pour les contrôles isolés ; publication hors mandat.
- Critères : six scénarios de compte, syntaxe, ShellCheck et OpenSpec strict.
- État au 2026-11-04 : VALIDÉ localement : six scénarios isolés réussis,
  bash -n, ShellCheck et OpenSpec strict réussis ; suite complète de 1 149
  tests exécutés, dont 2 ignorés. Attribution ultérieure par ACL.
