## 1. Réalisation

- [x] 1.1 Comparer les versions distantes et protéger la publication de branche et de tag.
- [x] 1.2 Tester les trois fournisseurs, les versions supérieures, égales, inférieures, horodatées et les concurrences sur dépôts isolés.
- [x] 1.3 Aligner les aides, la documentation et les autres deltas OpenSpec concernés.

## 2. Validation

- [x] 2.1 Valider les tests ciblés et globaux, Bash, ShellCheck et OpenSpec.
- [x] 2.2 Vérifier la cohérence et les conditions d'archivage.

## Sous-lots

### enforce-provider-version-authority — code non attribué : autorité et protections

Tâches 1.1 à 1.3 ; dépendances : transport authentifié existant ; validation : fixtures Git sans réseau. État : validé le 2026-11-10 sur fixtures Git et identifiants fictifs ; contrôles ciblés réussis.

### enforce-provider-version-authority — code non attribué : validation

Tâches 2.1 et 2.2 ; dépendance : réalisation ; validation : contrôles ciblés et globaux. État : validé le 2026-11-10 : 1 236 tests dont 2 ignorés, Bash, ShellCheck et OpenSpec strict réussis ; archivage et CI/CD à effectuer.
