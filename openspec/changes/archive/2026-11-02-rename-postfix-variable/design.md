# Conception

Le module `software_apt_postfix.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`POSTFIX=0|1`, sans interprétation shell et en donnant priorité au nouveau nom
persisté dans `softwares.env`. Le point d’entrée utilisera
`SOFTWARES_APT_POSTFIX`; la valeur distincte `POSTFIX_RELAY_HOST` restera
inchangée et continuera à configurer `relayhost`.
