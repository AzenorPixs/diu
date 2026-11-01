# Conception — SYSTEM_LOG_ROTATE

## Déclaration et consommateur

Ajouter `modules/diu/variables/system/system_log_rotate.sh` avec `STATIC`,
`ENABLE`, scope `system` et défaut `0`. Remplacer la condition du point
d’entrée par `SYSTEM_LOG_ROTATE`, sans changer les traitements logrotate
existants.

## Migration historique

Étendre `config_cleanup` pour accepter uniquement une affectation littérale
`0` ou `1` de `LOG_ROTATE`. Retenir la dernière valeur simple, vérifier si
`SYSTEM_LOG_ROTATE` est déjà déclarée dans `system.env`, et ne persister
l’ancienne valeur que si le nouveau nom n’y figure pas. Retirer ensuite les
lignes historiques. Toute forme nécessitant une interprétation shell bloque
avant écriture.

## Validation

Tester le défaut, les valeurs existantes, l’invalidation d’une valeur
préconfigurée, les erreurs de persistance, le nettoyage DISABLE, la migration
de `0` et `1`, la priorité, l’ambiguïté et le consommateur.
