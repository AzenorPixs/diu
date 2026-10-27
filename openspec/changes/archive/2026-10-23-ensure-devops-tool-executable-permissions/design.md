# Préparation limitée des exécutables

## Décision

Le rendu commun prépare `go/current/bin/go`, `node/current/bin/node`,
`node/current/bin/npm`, `.opencode/bin/opencode`, `.local/npm/bin/openspec`,
`python/current/bin/python3` et `python/current/bin/pip3` après la capture du
début du relevé et avant toute sonde ou inventaire de dépendances.

Une fonction dédiée résout le domicile et chaque cible avec `readlink -f`,
vérifie le confinement au domicile canonique et la nature de fichier
ordinaire, puis ajoute `ugo+x` uniquement si ces bits ne sont pas déjà tous
présents. Les binaires absents ne sont ni créés ni installés. Les objets
existants non ordinaires et les cibles externes sont refusés. Les chemins
`current` et les liens npm/OpenSpec internes restent pris en charge.

Les fichiers hôte et les autres fichiers du domicile ne sont pas parcourus.
La préparation s'exécute avec les droits de l'appelant déjà autorisé par le
générateur (root ou compte DevOps), sans élévation supplémentaire. Les sondes
conservent leur utilisateur, interpréteur, répertoire et borne de 15 secondes.

## Échecs et reprise

Une résolution impossible, un objet non ordinaire, une sortie de confinement,
une lecture de mode impossible ou un échec de chmod interrompt la préparation
avec un diagnostic limité au chemin relatif connu. Aucun nouveau DEVOPS.md
n'est publié. Les droits déjà corrigés persistent ; la réexécution reprend
sur l'état constaté et ne modifie pas un fichier possédant déjà tous les bits
d'exécution. Une sonde appelée directement distingue un fichier absent d'un
fichier non exécutable sans corriger ses droits elle-même.

## Validation

Les fixtures restent sous la racine du dépôt. Elles couvrent les sept outils
privés d'exécution, la préparation avant l'inventaire, les liens internes et
externes, les chemins non ordinaires, les échecs de chmod, l'idempotence et la
préservation des outils hôte, des autres fichiers et du document existant.
Les tests existants de génération individuelle, groupée et de création
vérifient la conservation des interfaces et du format documentaire 0.6.
