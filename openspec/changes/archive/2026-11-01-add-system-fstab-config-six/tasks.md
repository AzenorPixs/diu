# Tâches — Ajout de SYSTEM_FSTAB_CONFIG6

Code de lot : non attribué. Les repères ci-dessous restent provisoires ; la
normalisation définitive des sous-lots attend une attribution validée ACL.

## 1. Spécifier le contrat

- [x] 1.1 Ajouter le contrat de la sixième entrée au delta `system-fstab`.
- [x] 1.2 Étendre le delta de nettoyage historique pour `FSTAB_CONFIG6`.

## 2. Implémenter et tester

- [x] 2.1 Déclarer `SYSTEM_FSTAB_CONFIG6` et l’ajouter après CONFIG5 dans le
      point d’entrée.
- [x] 2.2 Migrer les valeurs historiques littérales en respectant la priorité
      de `system.env`.
- [x] 2.3 Étendre les tests des déclarations, du consommateur et de la
      migration ambiguë/idempotente.

## 3. Documentation et validation globale

- [x] 3.1 Mettre à jour le cadrage technique et le changelog ; vérifier les
      autres documents concernés.
- [x] 3.2 Exécuter les tests ciblés, la suite DIU applicable, les contrôles
      shell, OpenSpec et UTF-8/LF.

## Sous-lots normalisés

En attente d’un code de lot attesté. Les tâches 1.1–3.2 sont les repères
provisoires des unités ; aucune séquence `SL` définitive n’est attribuée.

## Validation finale

- [x] 4.1 Vérifier l’intégration, la cohérence documentaire et les critères
      d’acceptation sur les dernières sources.
