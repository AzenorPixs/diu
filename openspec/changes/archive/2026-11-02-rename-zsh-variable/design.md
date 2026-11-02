# Conception

Le module `software_apt_zsh.sh` déclarera l’interrupteur statique dans le
scope logiciels. `config_cleanup` migrera uniquement les valeurs littérales
`ZSH=0|1`, sans évaluation shell et en donnant priorité au nouveau nom déjà
persisté dans `softwares.env`. Le consommateur utilisera
`SOFTWARES_APT_ZSH`; le comportement d’installation de Zsh/Fish et de
configuration des shells restera inchangé.
