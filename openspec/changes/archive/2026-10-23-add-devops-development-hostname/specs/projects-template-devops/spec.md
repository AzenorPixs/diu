## ADDED Requirements

### Requirement: Nom d'hôte dans la rubrique système

DIU SHALL ajouter en deuxième puce de Système d'exploitation le résultat
de `hostname -f`, après le nom de l'OS. La sonde SHALL utiliser le binaire
système du contexte d'exécution DIU, sans modifier le nom ni le réseau.
Sa durée SHALL être bornée à 15 secondes. Sa sortie SHALL être une seule
ligne de 1 à 253 caractères ASCII alphanumériques, points ou tirets,
commençant par un caractère alphanumérique. Une impossibilité SHALL être
rendue explicitement sans bloquer la génération.

#### Scenario: Nom d'hôte disponible

- **WHEN** hostname -f réussit avec hvp1.pixs.fr
- **THEN** la rubrique contient le nom de l'OS puis hvp1.pixs.fr en deuxième puce
- **AND THEN** hostname est appelé une seule fois avec le seul argument -f
- **AND THEN** la rubrique Matériel et les rubriques suivantes gardent leur ordre

#### Scenario: Valeur actualisée dans tous les parcours

- **WHEN** le nom retourné change entre deux générations individuelles, groupées ou à la création
- **THEN** chaque document utilise la valeur actuellement retournée sans nom codé en dur
- **AND THEN** le document porte la version 0.7

#### Scenario: Commande indisponible, échouée ou expirée

- **WHEN** hostname est absent, échoue ou dépasse la durée autorisée
- **THEN** la deuxième puce indique explicitement une indisponibilité
- **AND THEN** la génération se poursuit sans nom inventé ni erreur brute

#### Scenario: Sortie invalide

- **WHEN** hostname retourne une sortie vide, multiligne, trop longue ou contenant des caractères non admis
- **THEN** la deuxième puce indique un nom d'hôte invalide sans publier la sortie rejetée
- **AND THEN** aucune valeur ancienne ni aucun repli sur hostname sans -f n'est utilisé

## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version
`0.7` et l'ordre du scénario « Rubriques documentaires conservées ».
Pour template, le titre SHALL être `DEVOPS.md — Template`.
Matériel SHALL suivre immédiatement Système d'exploitation.
Chaque rubrique logicielle SHALL placer le chemin après la version ;
PostgreSQL Serveur SHALL placer l'adresse après la version.
Tests navigateurs extérieurs en mode headless SHALL terminer le document.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.7 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Docker, pour tests nécessitant des droits root`, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox


