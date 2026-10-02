# Design

`system_apt_repository_engine` reçoit `enable`, `name`, `url_gpg_key`, `type`,
`suites`, `architecture` et `uris`. Il installe la clé dans
`/usr/share/keyrings`, écrit un seul fichier géré au nom du dépôt et supprime
les variantes `.sources`, `.list` et la clé lorsque `enable=0`.

`system_apt_configure_unofficial` fournit localement les paramètres de chaque
dépôt et appelle le moteur pour chaque variable, y compris lorsqu'elle vaut
zéro, afin de garantir l'idempotence.

Avant `curl` et `gpg --dearmor`, le moteur vérifie que le trousseau géré est un
fichier lisible et non vide (`-f`, `-r`, `-s`). Dans ce cas, il préserve son
contenu sans téléchargement ni conversion, puis poursuit la génération des
sources APT. Sinon, le chemin d'installation existant reste appliqué, avec un
retour non nul et un diagnostic si le téléchargement ou la conversion échoue.
La vérification TLS, les formats APT et la désactivation du dépôt sont conservés.

Cette vérification porte sur la disponibilité du fichier ; la validation des
signatures reste assurée par APT. Elle ne déclenche aucun renouvellement
automatique des clés et ne recherche pas de trousseau sous un autre nom.
