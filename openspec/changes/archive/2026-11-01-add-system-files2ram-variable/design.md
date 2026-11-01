# Conception — SYSTEM_FILES2RAM

## Décisions

- Ajouter `modules/diu/variables/system/system_files2ram.sh` avec `STATIC`,
  `ENABLE`, scope `system` et défaut `0`.
- Remplacer l’unique consommation du nom exact `FILES2RAM` par
  `SYSTEM_FILES2RAM`, avec repli désactivé lorsque la variable est absente.
- Étendre `config_cleanup` pour migrer `FILES2RAM=0|1` vers `SYSTEM_FILES2RAM`
  avant de supprimer l’affectation historique, sauf si le nouveau nom est
  déjà déclaré dans `system.env`.
- Une valeur historique ambiguë bloque avant toute mutation, sans affichage.

## Effets et repli

La migration d’une ancienne valeur `1` préserve les effets existants : lorsque
`/etc/tmpfiles.d/var2log.conf` est absent, le bloc peut supprimer le contenu de
`/var/log/*`, puis écrire sa configuration tmpfiles et FSTAB. La migration
est réversible en restaurant l’affectation `FILES2RAM` ou en modifiant la
valeur persistée dans `system.env`.
