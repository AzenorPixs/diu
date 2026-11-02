# Conception

Le module `system_rc_local.sh` déclarera le contrôle statique dans le scope
système. `config_cleanup` migrera uniquement les valeurs littérales
`RCLOCAL=0|1`, sans interprétation shell et en donnant priorité au nouveau nom
déjà persisté dans `system.env`. Le point d’entrée utilisera
`SYSTEM_RC_LOCAL` et conservera le bloc actuel de génération de `/etc/rc.local`.
