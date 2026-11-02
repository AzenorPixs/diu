# Conception

Le module `software_apt_syslog_server.sh` déclarera l’interrupteur statique
dans le scope logiciels. `config_cleanup` migrera uniquement les valeurs
littérales `SYSLOG_SERVER=0|1`, sans interprétation shell et en donnant
priorité au nouveau nom déjà persisté dans `softwares.env`. Le point d’entrée
utilisera `SOFTWARES_APT_SYSLOG_SERVER`; les options de catégories
`SYSLOG_SERVER_SKIL_*` resteront inchangées.
