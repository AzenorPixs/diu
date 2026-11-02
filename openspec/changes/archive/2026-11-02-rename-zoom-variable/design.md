# Conception

Le module `software_apt_zoom.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`ZOOM=0|1`, sans évaluation shell et en donnant priorité au nouveau nom déjà
persisté dans `softwares.env`. Le point d’entrée utilisera
`SOFTWARES_APT_ZOOM` et conservera le parcours actuel du paquet Debian.
