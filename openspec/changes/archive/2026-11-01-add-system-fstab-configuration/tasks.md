# Tâches — Déclaration modulaire de FSTAB

Code de lot : non attribué. Les repères ci-dessous restent provisoires ; la
normalisation définitive des sous-lots attend une attribution validée ACL.

## 1. Spécifier le contrat

- [x] 1.1 Décrire les six déclarations, consommateurs et migration dans le
      delta `system-fstab`.
- [x] 1.2 Étendre le contrat de nettoyage historique pour les six anciens noms.

## 2. Implémenter les déclarations et migrations

- [x] 2.1 Déclarer `SYSTEM_FSTAB` et `SYSTEM_FSTAB_CONFIG1` à
      `SYSTEM_FSTAB_CONFIG5`, puis renommer les consommateurs.
- [x] 2.2 Migrer les valeurs historiques littérales avec priorité à chaque
      nouvelle valeur déjà présente dans `system.env`.
- [x] 2.3 Tester les six déclarations, consommateurs, valeurs littérales,
      priorités, ambiguïtés et idempotence.

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
