# Conception — SYSTEM_JOURNALD_MAX_USE

## Déclaration et consommateurs

Ajouter `modules/diu/variables/system/system_journald_max_use.sh` avec
`STATIC`, `ENABLE`, scope `system` et défaut `500M`. Valider les valeurs selon
le format de taille journald : un entier suivi facultativement de `K`, `M`,
`G`, `T`, `P` ou `E`. Le consommateur injecte la valeur dans
`SystemMaxUse` et `RuntimeMaxUse` sans autre changement.

## Migration historique

Étendre `config_cleanup` pour accepter une affectation littérale simple de
`JOURNALD_MAX_USE`, éventuellement entourée de guillemets simples ou doubles.
Retenir la dernière valeur acceptée, persister sa valeur telle quelle sous
`SYSTEM_JOURNALD_MAX_USE` uniquement si ce nouveau nom n’est pas déjà déclaré,
puis retirer les anciennes lignes. Toute forme exigeant une interprétation
shell bloque avant écriture.

## Validation

Tester le défaut, les tailles valides, l’invalidation des formats non pris en
charge, les erreurs de persistance, la migration des littéraux quotés et non
quotés, la priorité, l’ambiguïté et les deux consommateurs journald.
