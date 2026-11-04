## Tâches

- [x] 1. Spécifier les commandes système et le retrait des anciens chemins.
- [x] 2. Modifier les routeurs, les aides et la documentation.
- [x] 3. Vérifier les commandes, le refus des anciennes, les aides et les mises à jour existantes.
- [x] 4. Valider et archiver le change.

## Sous-lots normalisés

### move-hosts-commands-to-system — code non attribué — Routage réseau système

Tâches 1 à 4 : contrat et implémentation du même routage. Prérequis : périmètre validé. Critères : commandes et aides, refus des anciens chemins, tests isolés, ShellCheck et OpenSpec. État VALIDÉ au 2026-11-04 : 104 tests ciblés réussis (11 réseau, 61 aides, 15 APT, 17 informations), syntaxe Bash et Python, ShellCheck et validation OpenSpec stricte ; tests isolés sans modification système. Attribution définitive par ACL.
