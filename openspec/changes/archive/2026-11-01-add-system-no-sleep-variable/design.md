# Conception — SYSTEM_NO_SLEEP

Ajouter `modules/diu/variables/system/system_no_sleep.sh` avec `STATIC`,
`ENABLE`, scope `system` et défaut `0`. Remplacer le contrôle `NO_SLEEP` par
`SYSTEM_NO_SLEEP`, sans modifier la création de `nosleep.conf` lorsque la
valeur vaut `1`.

Étendre `config_cleanup` pour accepter uniquement une affectation littérale
`0` ou `1` de `NO_SLEEP`. Retenir la dernière valeur, migrer vers
`SYSTEM_NO_SLEEP` seulement si le nouveau nom n’est pas déjà déclaré, puis
retirer l’ancienne ligne. Toute syntaxe nécessitant une interprétation shell
bloque avant écriture.

Tester défaut, persistance, valeurs existantes, priorité, valeur invalide,
erreurs de persistance, migration 0/1, ambiguïté et consommateur.
