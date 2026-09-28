# Design
Le module system expose system_drivers_install_displaylink et system_drivers_remove_displaylink. Le routeur exige trois arguments drivers install|remove displaylink. Les helpers contrôlent les paquets avec dpkg-query, le noyau courant avec uname, DKMS, le module et systemd. La configuration statique est écrite atomiquement avant export.

Linux 7.x exige EVDI >= 1.15.1. Le candidat des dépôts configurés est privilégié ; sinon le paquet officiel Debian 1.15.1+dfsg-1 est téléchargé en HTTPS avec SHA256 fixé et métadonnées vérifiées. Les headers correspondent exactement au noyau, avec noms Debian ou Proxmox. Une seule transaction APT installe les dépendances et EVDI, pour éviter de reconfigurer prématurément l'ancienne version cassée. Ce minimum ne garantit pas tous les futurs noyaux 7.x : compilation/chargement restent obligatoires.

Les tests remplacent les outils système et utilisent des répertoires temporaires dans le dépôt. Aucun pilote, service, configuration root ou dépôt APT réel n'est modifié pendant la session. L'affichage physique des écrans ne peut être validé par ces tests.
