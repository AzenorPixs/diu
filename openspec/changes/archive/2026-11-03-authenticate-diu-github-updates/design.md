## Conception

Le parcours GitHub réutilise le lecteur de jeton du projet et son contrôle de
permissions lorsque le fichier d'identifiant existe. Les requêtes d'API et
l'asset GitHub utilisent une configuration curl temporaire protégée, supprimée
à la fin du sous-shell. Le jeton n'est ni affiché ni transmis en argument ou à
une autre origine lors des redirections. Sans jeton, l'accès public anonyme
reste disponible ; un dépôt privé inaccessible reste une erreur explicite.

L'asset authentifié est demandé par son identifiant via l'URL d'API construite
à partir du dépôt configuré, avec `Accept: application/octet-stream`. Le nom,
la version et l'architecture restent vérifiés avant `dpkg`. Les tests utilisent
uniquement des identifiants factices et des transports simulés.
