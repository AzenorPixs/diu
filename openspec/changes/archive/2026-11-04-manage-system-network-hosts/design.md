## Conception

Le module `modules/system/network.sh` fournit `system_network_hosts` et `system_network_update`. La première fonction reconstruit `/etc/hosts` selon les données déjà détectées ; la seconde l'appelle. Le routeur système expose les deux commandes et `system_update` appelle la mise à jour réseau. L'installation appelle la nouvelle fonction en remplacement de `config_host`. La mise à jour globale passe par `system_update`.

Les essais isolent le chemin hosts dans une copie temporaire de la fonction et remplacent les opérations extérieures par des doubles. Aucun test ne modifie le système réel. La suppression des anciennes entrées Docker est volontaire ; il n'y a pas de migration de ces entrées.
