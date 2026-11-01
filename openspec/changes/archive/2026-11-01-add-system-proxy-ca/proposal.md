# Déclaration modulaire de SYSTEM_PROXY_CA

## Why

L’exécution normale du DIU sous Bash strict échoue lorsque `PROXY_CA` est absent. Cette option historique pilote l’installation de l’autorité de certification système, mais elle n’est pas initialisée par le nouveau gestionnaire de variables.

## What Changes

- Déclarer `SYSTEM_PROXY_CA` comme variable `STATIC`, `ENABLE`, scope `system`, avec la valeur par défaut `0`.
- Remplacer la consommation de `PROXY_CA` par `SYSTEM_PROXY_CA` dans le point d’entrée.
- Retirer l’affectation historique simple `PROXY_CA` avant le chargement de `variables.sh`, sans transférer sa valeur.
- Ajouter les tests de génération, persistance, nettoyage historique et consommation du nouveau nom.

## Capabilities

### New Capabilities

- `system-proxy-ca` : configuration déclarative de l’activation de l’autorité de certification système.

### Modified Capabilities

- `legacy-variable-cleanup` : retrait de l’affectation historique `PROXY_CA`.

## Impact

Le point d’entrée, la déclaration modulaire du scope `system`, le nettoyage historique, leurs tests et la documentation technique sont concernés. L’ancienne valeur n’est pas transférée ; si elle valait `1`, la nouvelle valeur initiale sera `0` jusqu’à ce que `SYSTEM_PROXY_CA=1` soit configurée dans `/root/diu/config/system.env`. Le traitement de la CA lui-même reste inchangé.

Code de lot : non attribué ; attribution réservée au processus ACL.
