# Design

Le module system devient l'unique point d'entrée des mises à jour APT. Le
contexte Debian appelle `software_deb update` après régénération des dépôts
officiels et active son affichage des cibles. Le contexte APT global appelle
successivement `apt-get update` et `apt-get dist-upgrade -y`; aucune autre
transaction de paquet n'est ajoutée par l'orchestrateur. `update_all` réutilise
ce contexte puis met à jour les composants DIU.
