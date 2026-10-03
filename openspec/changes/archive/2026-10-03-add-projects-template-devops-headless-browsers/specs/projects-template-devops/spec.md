## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver un titre `DEVOPS.md — <ID PROJECT>` adapté à l'identifiant, la version
documentaire `0.2`, et les rubriques Système d'exploitation, Docker,
Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL
Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source
de vérité `pyproject.toml`, Python - Gestionnaire de paquets, dans cet ordre.
La rubrique Tests navigateurs extérieurs en mode headless SHALL suivre ces
rubriques et terminer le document, avec les sous-rubriques Chromium puis Firefox.
Pour l'identifiant template, le titre SHALL rester `DEVOPS.md — Template`.
Chaque rubrique logicielle SHALL placer le chemin du binaire après sa version.
Le serveur PostgreSQL SHALL indiquer son adresse après sa version.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire reste 0.2 et les rubriques existantes conservent leur ordre
- **AND THEN** une seule section Tests navigateurs extérieurs en mode headless termine le document

## ADDED Requirements

### Requirement: Navigateurs externes hôte pour le mode headless

DIU SHALL détecter Chromium et Firefox sur l'hôte de génération à partir du
PATH système fixe utilisé par projects_template_devops_host_binary, sans utiliser
le PATH DevOps ni des caches de frameworks de test. La recherche SHALL retenir
le premier exécutable disponible parmi chromium puis chromium-browser pour
Chromium, et firefox puis firefox-esr pour Firefox.

Chaque sous-rubrique SHALL indiquer la version relevée avec --version, puis
le chemin de l'exécutable détecté et la ligne « Mode headless : --headless ».
La section SHALL préciser que la détection de version ne vérifie pas le
fonctionnement du mode headless. Les sondes SHALL être limitées à 15 secondes
et SHALL conserver les arguments et les chemins contenant des espaces.

Un navigateur absent SHALL être indiqué par « indisponible (binaire absent) »
et « binaire introuvable ». Une sonde échouée ou sans version reconnue SHALL
être indiquée explicitement avec le chemin détecté, sans afficher les erreurs
brutes ni conserver une ancienne version. DIU SHALL NOT sélectionner une
autre variante après l'échec de la sonde du premier exécutable détecté.
Ces indisponibilités SHALL NOT empêcher la génération du document.
La détection SHALL NOT installer de logiciel ni démarrer un test de navigation.

#### Scenario: Navigateurs hôte disponibles

- **WHEN** chromium et firefox sont présents sur le PATH système hôte et leurs sondes réussissent
- **THEN** la section finale indique leurs versions, leurs chemins et l'option --headless
- **AND THEN** elle précise que le fonctionnement headless n'est pas vérifié

#### Scenario: Variantes de noms

- **WHEN** seuls chromium-browser et firefox-esr sont présents
- **THEN** leurs versions et chemins sont affichés sous Chromium et Firefox

#### Scenario: Plusieurs variantes disponibles

- **WHEN** les noms canoniques et les variantes sont tous présents
- **THEN** chromium et firefox sont retenus avant chromium-browser et firefox-esr

#### Scenario: Navigateurs absents

- **WHEN** aucun exécutable d'une famille n'est trouvé sur le PATH système hôte
- **THEN** sa sous-rubrique indique la version indisponible et le binaire introuvable
- **AND THEN** la génération peut réussir sans installation

#### Scenario: Sonde défaillante ou version non reconnue

- **WHEN** un exécutable détecté échoue, dépasse le délai ou ne produit pas de version reconnue
- **THEN** sa sous-rubrique indique explicitement la sonde échouée ou la version non reconnue et conserve son chemin
- **AND THEN** aucune variante alternative ni ancienne version ne remplace ce résultat

#### Scenario: Réexécution et appels existants

- **WHEN** une génération individuelle, groupée ou finale de création appelle projects_template_devops
- **THEN** le document produit inclut la même section finale actualisée sans doublon
- **AND THEN** les garanties existantes d'idempotence, de droits et de préservation du document en cas d'échec d'écriture restent applicables
