# Inventaire ciblé — 2026-11-11

Variables Debian : SYSTEM_APT_DEBIAN_CONTRIB, NONFRFEE, NONFRFEE_FIRMWARE (nouvelle), SOURCES, UPDATES, BACKPORT. Le moteur a actuellement des replis actifs ; ils seront ramenés à zéro pour les éléments optionnels absents.

Variables tierces : SYSTEM_APT_DOCKER, LEMONLDAP, MONGODB, NODEJS, NVIDIA, PROXMOX, VSCODE, WAZUH, WEBMIN, CGPT ; SOFTWARE_APT_CROWDSEC ; DIU_APT_REPOSITORY_FD. Les recettes Docker, DevOps et IA ne sont pas déplacées, seule l’initialisation de leurs variables de dépôt est revue sur demande explicite.

23 logiciels : apache2, chatgpt, crowdsec-agent, crowdsec-bouncer, fastfetch, jsvc, lemonldap, mongodb, omada, openjdk, openvswitch, postfix, postgresql, qemu-guest-agent, ssh-server, syncthing, syslog-client, syslog-server, wazuh-agent, wazuh-server, webmin, zoom, zsh. Les identifiants et logiciels associés restent pris en charge. Omada et Wazuh agent conservent leur version explicite ; Zoom résout son paquet latest.

Blocs monolithiques : conditions SOFTWARES_APT_* obsolètes ; contrôles firewall SOFTWARE_APT_OMADA et SOFTWARE_APT_CROWDSEC_BOUNCER conservés. Le bloc SSH inclus dans la préparation Docker demeure hors périmètre conformément à l’exclusion utilisateur ; il est déjà désactivé par l’ancienne variable.

État Git initial : DEVOPS.md modifié avant travaux ; préservé et inclus dans la CICD SCM. Aucun code de lot attribué ; ACL recommandé ultérieurement.

Adaptateur bureau autorisé après constat : intel-media-va-driver-non-free est dans la section Debian non-free/video (métadonnées APT locales). Un helper SYSTEM prépare ce composant avant la transaction existante. Les blocs DevOps/Docker/IA restent inchangés.

Validation finale : 1 347 tests dont 2 ignorés, aucun échec ; 48 scripts Bash et 13 fichiers Python contrôlés. Les branches non représentables MongoDB/Wazuh sont refusées ; l’activation du composant firmware séparé est refusée sur Bullseye avant persistance.
