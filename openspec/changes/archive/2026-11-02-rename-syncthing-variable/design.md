# Conception

Le module `software_apt_syncthing.sh` déclarera l’interrupteur statique dans
le scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`SYNCTHING=0|1`, sans évaluation shell et en donnant priorité au nouveau nom
déjà persisté dans `softwares.env`. Les deux consommateurs du point d’entrée
utiliseront `SOFTWARES_APT_SYNCTHING`.
