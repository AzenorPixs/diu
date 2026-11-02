# Conception

Le module `software_apt_syslog_client.sh` déclarera l’interrupteur statique
dans le scope logiciels. `config_cleanup` migrera uniquement les valeurs
littérales `SYSLOG_CLIENT=0|1`, sans évaluation shell et en donnant priorité au
nouveau nom déjà persisté dans `softwares.env`. Le bloc rsyslog utilisera
`SOFTWARES_APT_SYSLOG_CLIENT`; `SYSLOG_CLIENT_SERVER` restera inchangée.
