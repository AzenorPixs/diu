# Conception

Le module `software_apt_openjdk.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`OPENJDK=0|1`, sans évaluer leur contenu et en donnant priorité au nouveau nom
déjà persisté dans `softwares.env`. Le point d’entrée utilisera
`SOFTWARES_APT_OPENJDK`; les branches d’installation Java 17/21 et la
configuration proxy existantes resteront inchangées.
