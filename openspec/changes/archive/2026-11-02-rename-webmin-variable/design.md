# Conception

Le module `software_apt_webmin.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`WEBMIN=0|1`, sans évaluation shell et en donnant priorité au nouveau nom déjà
persisté dans `softwares.env`. Le consommateur utilisera
`SOFTWARES_APT_WEBMIN`. `SYSTEM_APT_WEBMIN` restera le réglage système distinct
du dépôt APT.
