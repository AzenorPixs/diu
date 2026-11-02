# Conception

Le module `software_apt_postgresql.sh` déclarera l’interrupteur statique dans
le scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`POSTGRESQL=0|1`, sans évaluation shell et en donnant priorité au nouveau nom
déjà persisté dans `softwares.env`. Le point d’entrée utilisera
`SOFTWARES_APT_POSTGRESQL` et gardera l’installation APT conditionnelle du
serveur PostgreSQL.
