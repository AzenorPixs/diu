# Conception — SYSTEM_GRUB_CONFIG

## Déclaration et consommateur

Ajouter le fichier unitaire `modules/diu/variables/system/system_grub_config.sh`
avec les paramètres validés : `STATIC`, `ENABLE`, scope `system` et défaut
`0`. Remplacer la condition `GRUB_CONFIG` du point d’entrée par
`SYSTEM_GRUB_CONFIG`, en traitant une valeur absente comme désactivée.

## Migration historique

Étendre `config_cleanup` pour accepter uniquement une affectation littérale
`0` ou `1` de `GRUB_CONFIG`. Retenir la dernière valeur simple, vérifier si
`SYSTEM_GRUB_CONFIG` est déjà déclaré dans `system.env`, et ne persister la
valeur historique que si le nouveau nom n’y figure pas. Supprimer ensuite
l’affectation historique avec les autres noms pris en charge. Une expression
ou une valeur invalide produit une erreur sans modifier les fichiers.

## Validation

Tester les valeurs par défaut, l’export, l’idempotence, la migration des
valeurs 0/1, la priorité du nouveau nom, l’échec ambigu sans effet de bord,
ainsi que le nom utilisé par le consommateur.
