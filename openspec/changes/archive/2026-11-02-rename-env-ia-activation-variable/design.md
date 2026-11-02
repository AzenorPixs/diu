# Design

Le module `environment_ia.sh` déclare `ENVIRONMENT_IA` en `STATIC`, `ENABLE`,
scope `environnements`, défaut `0`. `config_cleanup` transfère les valeurs
littérales `0` ou `1` de `ENV_IA` depuis `variables.sh` ou
`environnements.env`, conserve la priorité du nouveau nom, puis supprime
l'ancien export. Les paramètres suffixés `ENV_IA_USER`, `ENV_IA_GROUP` et
`ENV_IA_PASSWORD` restent inchangés. Le point d'entrée utilise le nouveau nom
avec repli désactivé.
