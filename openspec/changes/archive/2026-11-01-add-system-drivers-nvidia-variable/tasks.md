# Tâches — Déclaration modulaire de SYSTEM_DRIVERS_NVIDIA

Code de lot : non attribué. Les repères ci-dessous restent provisoires ; la
normalisation définitive des sous-lots attend une attribution validée ACL.

## 1. Spécifier le contrat

- [x] 1.1 Décrire la déclaration et ses consommateurs dans le delta
      `system-drivers-nvidia`.
- [x] 1.2 Étendre le nettoyage historique pour `DRIVERS_NVIDIA`.

## 2. Implémenter la déclaration et ses consommateurs

- [x] 2.1 Déclarer `SYSTEM_DRIVERS_NVIDIA` et remplacer les six usages exacts
      de l’ancienne variable.
- [x] 2.2 Migrer les affectations historiques littérales avec priorité à la
      configuration `SYSTEM_DRIVERS_NVIDIA` déjà présente.
- [x] 2.3 Tester la déclaration, les consommateurs, la migration, les formes
      ambiguës et l’idempotence.

## 3. Documentation et validation globale

- [x] 3.1 Mettre à jour le changelog et le cadrage technique ; vérifier les
      autres documents concernés.
- [x] 3.2 Exécuter les tests ciblés, la suite DIU applicable, les contrôles
      shell, OpenSpec et UTF-8/LF.

## Sous-lots normalisés

En attente d’un code de lot attesté. Les tâches 1.1–3.2 sont les repères
provisoires des unités ; aucune séquence `SL` définitive n’est attribuée.

## Validation finale

- [x] 4.1 Vérifier l’intégration, la cohérence documentaire et les critères
      d’acceptation sur les dernières sources.
