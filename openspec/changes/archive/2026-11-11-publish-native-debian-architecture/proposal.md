# Publication Debian selon l’architecture déclarée

## Why
La publication CAB3.0.0 amd64 échoue après commit/tag et construction : les
contrôles Forgejo/GitHub imposent encore all. Le développeur autorise toutes
les adaptations DIU nécessaires au paquet CAB.

## What Changes
Lire Architecture dans les métadonnées du paquet et vérifier le nom exact
<projet>_<version>_<architecture>.deb, sans accepter de renommage trompeur.
Les contrôles de version/tag/commit, unicité et idempotence restent conservés.

## Impact
Deux validateurs de publication et leurs tests ; aucun changement aux travaux
CODING_RULES de l’autre session. Livraison DIU coordonnée à sa barrière, puis
reprise idempotente du même CAB3.0.0. Code de lot non attribué.
