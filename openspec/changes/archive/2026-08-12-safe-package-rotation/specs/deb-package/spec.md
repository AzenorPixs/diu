## MODIFIED Requirements

### Requirement: Emplacement de production du paquet

Le paquet Debian produit SHALL être généré dans le répertoire `dist/` à la
racine du projet. Le répertoire `dist/` ne SHALL pas lui-même être embarqué
dans le paquet.

Le nouveau paquet SHALL être construit dans un emplacement temporaire avant
d'être publié dans `dist/`. Les anciens paquets `diu_*_all.deb` SHALL être
supprimés de `dist/` uniquement après la publication réussie du nouveau paquet,
en excluant explicitement le nouveau paquet de cette suppression.

En cas d'échec de la construction ou de la publication, les anciens paquets
SHALL rester intacts dans `dist/`.

Le nettoyage SHALL cibler uniquement les artefacts Debian du DIU
(`diu_*_all.deb`) et ne SHALL pas supprimer les autres fichiers éventuellement
présents dans `dist/`.

#### Scenario: Génération dans dist/

WHEN la construction du paquet est terminée sans erreur
THEN le fichier `.deb` est présent dans `dist/`
AND le chemin du fichier est affiché sur la sortie standard

#### Scenario: dist/ non embarqué

WHEN le paquet est construit
THEN le répertoire `dist/` n'est pas inclus dans le paquet produit

#### Scenario: Rotation après succès

WHEN un build réussi suit un ou plusieurs builds précédents
THEN les anciens paquets `diu_*_all.deb` sont supprimés de `dist/`
AND le nouveau paquet est le seul paquet DIU présent dans `dist/`
AND les autres fichiers éventuellement présents dans `dist/` ne sont pas
  supprimés

#### Scenario: Préservation après échec

WHEN un build échoue avant ou pendant la publication du nouveau paquet
THEN les anciens paquets `diu_*_all.deb` restent intacts dans `dist/`
AND aucun nettoyage n'est effectué dans `dist/`

#### Scenario: Pas de fenêtre sans paquet

WHEN la construction du nouveau paquet est en cours
THEN les anciens paquets restent disponibles dans `dist/`
AND le nouveau paquet n'est publié dans `dist/` qu'après succès de
  `dpkg-deb`
