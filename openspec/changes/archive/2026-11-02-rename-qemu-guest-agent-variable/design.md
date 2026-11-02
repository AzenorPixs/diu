# Conception

Le module `software_apt_qemu_guest_agent.sh` déclarera l’interrupteur statique
dans le scope logiciels. `config_cleanup` migrera uniquement les valeurs
littérales `QEMU_GUEST_AGENT=0|1`, sans interprétation shell et en donnant
priorité au nouveau nom déjà persisté dans `softwares.env`. Le point d’entrée
utilisera `SOFTWARES_APT_QEMU_GUEST_AGENT` et conservera l’installation APT
conditionnelle de `qemu-guest-agent`.
