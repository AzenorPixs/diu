# Conception — SOFTWARES_APT_APACHE2

## Déclaration et consommateur

Ajouter `modules/diu/variables/softwares/software_apt_apache2.sh` avec
`STATIC`, `ENABLE`, scope `softwares` et défaut `0`. Remplacer le consommateur
`APACHE2` par `SOFTWARES_APT_APACHE2`, sans modifier les paquets ni les
traitements APT existants.

## Migration historique

Étendre `config_cleanup` avec une destination logiciels distincte
`/root/diu/config/softwares.env`. Accepter uniquement les littéraux `0` ou `1`
de `APACHE2`, vérifier si `SOFTWARES_APT_APACHE2` est déjà déclaré, migrer la
dernière valeur si nécessaire, puis retirer l’ancienne ligne. Toute valeur
ambiguë ou erreur de lecture/écriture bloque sans suppression.

## Validation

Tester défaut, valeurs préconfigurées, invalidation, erreurs de persistance,
migration/priorité, valeur ambiguë sans exécution et nouveau consommateur.
