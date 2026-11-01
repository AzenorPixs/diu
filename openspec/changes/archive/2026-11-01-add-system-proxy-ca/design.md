## Context

`root-install-debian.sh` utilise actuellement `PROXY_CA` sous `set -Eeuo pipefail`. La configuration locale historique peut ne pas définir cette variable. Le gestionnaire modulaire découvre automatiquement les fichiers placés sous `modules/diu/variables/<scope>/`.

## Goals / Non-Goals

- Initialiser l’option avec `SYSTEM_PROXY_CA`, `STATIC`, `ENABLE`, scope `system` et défaut `0`.
- Préserver le comportement d’installation de la CA lorsque la nouvelle valeur vaut `1`.
- Retirer l’affectation historique avant de sourcer `variables.sh`.
- Ne pas modifier le chargeur, les certificats, les chemins ni le contenu de l’opération CA.

## Decisions

- Ajouter `modules/diu/variables/system/system_proxy_ca.sh` selon le contrat des déclarations statiques existantes.
- Utiliser `SYSTEM_PROXY_CA` dans le point d’entrée, avec `0` comme repli si la déclaration est désactivée.
- Étendre `config_cleanup` au seul nom historique `PROXY_CA`. Le nettoyage reste limité aux affectations simples, idempotent et sans affichage de leur valeur.
- Ne pas transférer `PROXY_CA` vers `SYSTEM_PROXY_CA`. La valeur initiale du nouveau réglage reste `0` et sa configuration persistante relève de `system.env`.
- Tester le comportement CA par inspection de son branchement et tester la déclaration avec des fichiers temporaires ; ne pas installer de certificat pendant les tests unitaires.

## Risks / Trade-offs

Une ancienne configuration `PROXY_CA=1` sera supprimée et ne sera pas transférée ; l’installation de la CA restera désactivée par défaut jusqu’à la définition de `SYSTEM_PROXY_CA=1`. Le premier lancement du DIU peut avoir appliqué d’autres étapes avant son arrêt sur la variable absente ; cette évolution ne revient pas sur ces effets.
