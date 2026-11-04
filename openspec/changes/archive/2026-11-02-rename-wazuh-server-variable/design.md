# Conception

Le module `software_apt_wazuh_server.sh` déclarera l’interrupteur statique dans
le scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`WAZUH_SERVER=0|1` vers `softwares.env`, sans interprétation et en donnant
priorité au nouveau nom. Le consommateur du serveur et le repli de
`SYSTEM_APT_WAZUH` utiliseront `SOFTWARES_APT_WAZUH_SERVER`; le choix de branche
du dépôt restera conditionné par `WAZUH_SERVER_UPGRADE`.
