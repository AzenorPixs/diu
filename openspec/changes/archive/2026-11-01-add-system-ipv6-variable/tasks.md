# Tâches — Déclaration modulaire de SYSTEM_IPV6

Code de lot : non attribué. Les repères restent provisoires jusqu’à une
attribution validée.

## 1. Spécifier le contrat

- [x] 1.1 Décrire la déclaration statique et la détection initiale par sysctl.
- [x] 1.2 Décrire la migration littérale et la priorité du nouveau nom.
- [x] 1.3 Réviser le contrat `root-shellcheck` sans défaut IPv6 littéral.

## 2. Implémenter et tester

- [x] 2.1 Ajouter la déclaration et renommer le consommateur.
- [x] 2.2 Migrer la dernière valeur historique `IPv6=0|1`.
- [x] 2.3 Tester la sonde, la persistance, la priorité et les erreurs.

## 3. Documentation et validation

- [x] 3.1 Mettre à jour les specs canoniques, `TECHNICAL.md` et `CHANGELOG.md`.
- [x] 3.2 Exécuter les tests ciblés et validations shell/OpenSpec applicables.
- [x] 3.3 Examiner les changements du mandat.

## Validation finale

- [x] 4.1 Archiver le change et produire ses statistiques.
