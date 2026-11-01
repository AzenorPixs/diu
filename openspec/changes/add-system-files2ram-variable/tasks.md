# Tâches — Déclaration modulaire de SYSTEM_FILES2RAM

Code de lot : non attribué. Les repères ci-dessous restent provisoires ; la
normalisation définitive des sous-lots attend une attribution validée ACL.

## 1. Spécifier le contrat

- [x] 1.1 Décrire la déclaration et le consommateur dans le delta
      `system-files2ram`.
- [x] 1.2 Étendre le contrat de nettoyage historique pour `FILES2RAM`.

## 2. Implémenter et tester

- [x] 2.1 Déclarer `SYSTEM_FILES2RAM` et renommer le consommateur.
- [x] 2.2 Migrer les valeurs historiques littérales avec priorité à
      `SYSTEM_FILES2RAM` dans `system.env`.
- [x] 2.3 Tester la déclaration, le consommateur, la migration, l’ambiguïté
      et l’idempotence.

## 3. Documentation et validation globale

- [x] 3.1 Mettre à jour le changelog et le cadrage technique ; vérifier les
      autres documents concernés.
- [ ] 3.2 Exécuter les tests ciblés, la suite DIU applicable, les contrôles
      shell, OpenSpec et UTF-8/LF.

## Sous-lots normalisés

En attente d’un code de lot attesté. Les tâches 1.1–3.2 sont les repères
provisoires des unités ; aucune séquence `SL` définitive n’est attribuée.

## Validation finale

- [ ] 4.1 Vérifier l’intégration, la cohérence documentaire et les critères
      d’acceptation sur les dernières sources.
