# Conception

Le module `software_apt_mongodb.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`MONGODB=0|1` vers `softwares.env`, sans interprétation, priorité au nouveau
nom, et sans toucher à `MONGODB_VERSION`. Le point d’entrée et le repli du
dépôt `SYSTEM_APT_MONGODB` utiliseront `SOFTWARES_APT_MONGODB`; le choix de
version historique restera piloté par `MONGODB_VERSION`, et une valeur système
du dépôt déjà configurée gardera sa priorité.
