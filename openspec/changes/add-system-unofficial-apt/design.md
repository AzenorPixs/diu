# Design

`system_apt_repository_engine` reçoit `enable`, `name`, `url_gpg_key`, `type`,
`suites`, `architecture` et `uris`. Il installe la clé dans
`/usr/share/keyrings`, écrit un seul fichier géré au nom du dépôt et supprime
les variantes `.sources`, `.list` et la clé lorsque `enable=0`.

`system_apt_configure_unofficial` fournit localement les paramètres de chaque
dépôt et appelle le moteur pour chaque variable, y compris lorsqu'elle vaut
zéro, afin de garantir l'idempotence.
