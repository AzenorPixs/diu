# Conception

Les variables résident dans le scope system. La valeur APT par défaut est 1. Pour GitHub, l'état initial reflète la présence des outils nécessaires. Flatpak reprend la valeur existante `SYSTEM_FLATPAK` si la nouvelle est absente, sinon détecte le paquet. La migration ne supprime pas la valeur historique sans vérification.

Les commandes d'activation assurent les dépendances avant de persister 1. Les commandes de désactivation ne retirent aucun paquet et persistent 0. Une variable invalide ou une dépendance impossible à satisfaire produit une erreur explicite. Les moteurs désactivés sont ignorés dans une mise à jour globale et refusés pour les actions explicites. Le fonctionnement système APT indépendant des moteurs logiciels reste intact.

Les dépendances GitHub sont curl, jq, tar, gzip et sha256sum. Les dépendances APT sont apt, apt-transport-https, apt-utils et dpkg-query. Flatpak conserve sa configuration Flathub lorsqu'il est activé. Les anciens chemins install/remove Flatpak sont remplacés ; system update flatpak reste inchangé.
