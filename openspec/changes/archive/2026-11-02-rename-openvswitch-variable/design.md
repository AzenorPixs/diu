# Conception

Le module `software_apt_openvswitch.sh` déclarera l’interrupteur statique dans
le scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`OPENVSWITCH=0|1`, sans évaluation shell et en donnant priorité au nouveau nom
déjà persisté dans `softwares.env`. Le point d’entrée utilisera
`SOFTWARES_APT_OPENVSWITCH` et gardera l’installation APT conditionnelle.
