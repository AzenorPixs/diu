# Conception

Le module `software_apt_omada.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`OMADA=0|1`, sans évaluer leur contenu et en donnant priorité au nouveau nom
persisté dans `softwares.env`. Le point d’entrée emploiera
`SOFTWARES_APT_OMADA` pour l’installation et les règles firewall. Les valeurs
`OMADA_VERSION` et `SYSLOG_SERVER_SKIL_OMADA` resteront inchangées.
