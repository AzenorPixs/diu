# Conception

Le module `software_apt_jsvc.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`JSVC=0|1`, sans évaluation shell et en donnant priorité à une valeur
`SOFTWARES_APT_JSVC` déjà présente dans `softwares.env`. Le point d’entrée
utilisera le nouveau nom et gardera l’installation APT conditionnelle.
