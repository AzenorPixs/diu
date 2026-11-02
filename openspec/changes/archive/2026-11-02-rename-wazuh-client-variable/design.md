# Conception

Le module `software_apt_wazuh_agent.sh` déclarera l’interrupteur statique dans
le scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`WAZUH_CLIENT=0|1`, sans interprétation shell et en donnant priorité au nouveau
nom déjà persisté dans `softwares.env`. Le point d’entrée utilisera
`SOFTWARES_APT_WAZUH_AGENT`; `WAZUH_CLIENT_VERSION` restera inchangée.
