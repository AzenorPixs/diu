# Tâches — Déclaration modulaire de SYSTEM_PROXY

Code de lot : non attribué. Les repères ci-dessous restent provisoires ; la
normalisation définitive des sous-lots attend une attribution validée ACL.

## 1. Spécifier le contrat

- [x] 1.1 Décrire la déclaration statique, les consommateurs et la migration
      dans le delta `system-proxy`.
- [x] 1.2 Étendre le contrat de nettoyage historique pour `PROXY`.

## 2. Implémenter et tester la migration

- [x] 2.1 Déclarer `SYSTEM_PROXY` et remplacer les consommateurs exacts de
      `PROXY`.
- [x] 2.2 Migrer les affectations historiques littérales avec priorité à la
      configuration `SYSTEM_PROXY` existante.
- [x] 2.3 Ajouter ou mettre à jour les tests de déclaration, consommateurs,
      erreurs ambiguës et idempotence.

## 3. Documentation et validation globale

- [x] 3.1 Mettre à jour le changelog et vérifier les cadrages/documentations
      concernés.
- [x] 3.2 Exécuter les tests ciblés, la suite DIU applicable, les contrôles
      shell et OpenSpec ; vérifier UTF-8/LF et le périmètre.

## Sous-lots normalisés

En attente d’un code de lot attesté. Les tâches 1.1–3.2 sont les repères
provisoires des unités ; aucune séquence `SL` définitive n’est attribuée.

## Validation finale

- [x] 4.1 Vérifier l’intégration complète, la cohérence documentaire et les
      critères d’acceptation sur les dernières sources.
