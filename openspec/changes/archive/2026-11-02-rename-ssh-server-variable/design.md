# Conception

Le module `software_apt_ssh_server.sh` déclarera l’interrupteur statique dans
le scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`SSH=0|1`, sans évaluation shell et en donnant priorité au nouveau nom déjà
persisté dans `softwares.env`. Les deux blocs consommateurs utiliseront
`SOFTWARES_APT_SSH_SERVER`; les clés `KEY_SSH_ADMIN` et `KEY_SSH_ACME` restent
inchangées.
