# Conception

Le module `software_apt_lemonldap.sh` déclarera l’interrupteur statique dans
le scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`LEMONLDAP=0|1`, sans évaluer leur contenu et en donnant priorité à une valeur
`SOFTWARES_APT_LEMONLDAP` déjà persistée dans `softwares.env`. Le bloc
d’installation APT et le repli historique de `SYSTEM_APT_LEMONLDAP` utiliseront
le nouveau nom; le réglage explicite du dépôt restera dans `system.env` et
gardera la priorité lorsqu’il est déjà défini.
