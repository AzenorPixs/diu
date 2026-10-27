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
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH` si activé, OpenSSH & SSHPASS, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Python - Outils de compilation si Cython est déclaré dans [build-system].requires, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

### Requirement: Python et dépendances déclarées

La rubrique Python SHALL indiquer venv et ensurepip en troisième ligne ; la rubrique pip SHALL conserver sa version et son chemin DevOps. Les dépendances d’exécution de cette rubrique SHALL provenir uniquement de [project].dependencies et être recherchées dans les venv du projet avant le repli Python DevOps. Le document SHALL conserver les contraintes et signaler manifeste absent, invalide, dynamique ou paquet introuvable/non vérifiable, sans inventer ni installer de dépendance.

#### Scenario: Manifeste absent

- **WHEN** pyproject.toml est absent
- **THEN** le document indique cette absence sans ajouter implicitement psycopg

#### Scenario: Dépendances présentes

- **WHEN** pyproject.toml déclare des dépendances
- **THEN** chaque dépendance déclarée est documentée avec sa contrainte et sa version installée ou son indisponibilité

### Requirement: Provenance et portée informative du relevé

Avant la première rubrique, DIU SHALL distinguer sondes système, outils DevOps et dépendances. La légende SHALL expliquer priorité des venv et repli DevOps, sources [project].dependencies et [build-system].requires pour Cython, manifestes JavaScript par composant, déclaration/verrou/observation et absence de qualification fonctionnelle ou preuve de tests. Les trois parcours SHALL partager cette présentation sans doublon.

#### Scenario: Parcours de génération existants

- **WHEN** une génération individuelle, groupée ou finale de création réussit
- **THEN** le document contient une seule provenance DIU, un début du relevé UTC, une classification et la légende
- **AND THEN** aucun résultat de test ou de qualification n'est inventé

## ADDED Requirements

### Requirement: Déclaration préalable de Cython pour la compilation

DIU SHALL reconnaître le nom de distribution Cython, sans distinction de casse, uniquement dans la liste [build-system].requires du TOML. DIU SHALL émettre « Python - Outils de compilation » après pip et avant Prompts seulement si Cython est déclaré. Sans déclaration confirmée, DIU MUST NOT découvrir ou sonder des venv pour Cython. Une analyse invalide ou impossible SHALL produire un diagnostic fixe hors de cette rubrique.

#### Scenario: Cython déclaré pour la construction

- **WHEN** [build-system].requires contient Cython, cython ou une exigence Cython avec contrainte ou marqueur
- **THEN** la rubrique de compilation apparaît une seule fois après pip et avant Prompts, avec la déclaration et sa source
- **AND** les contraintes et marqueurs restent déclaratifs sans résolution, et les références directes restent masquées
- **AND** les dépendances d’exécution et autres outils de compilation restent inchangés

#### Scenario: Cython non déclaré pour la construction

- **WHEN** le manifeste est absent, sans [build-system].requires, ou déclare Cython uniquement dans une autre table, un commentaire ou un nom de distribution différent
- **THEN** la rubrique est omise et aucune découverte ni sonde Cython n’est exécutée
- **AND** un manifeste absent reste signalé par l’inventaire d’exécution existant

#### Scenario: Déclaration non vérifiable

- **WHEN** le manifeste est illisible, invalide, possède un requires mal typé ou l’analyseur est indisponible
- **THEN** le diagnostic explique que la déclaration n’est pas vérifiable sans émettre la rubrique de compilation ni conclure à une absence d’installation

### Requirement: Installation de Cython observée dans les venv du projet

Après déclaration confirmée, DIU SHALL rechercher Cython uniquement dans les venv du projet, dans l’ordre .venv, venv, env puis autres chemins triés. Les résultats SHALL distinguer version observée, « Cython : non installé » avec environnements vérifiés et « Cython : installation non vérifiable ». L’absence de venv ou une recherche ou sonde incomplète SHALL NOT prouver une absence. DIU MUST NOT utiliser de paquet global en repli.

#### Scenario: Cython installé dans un venv

- **WHEN** un venv du projet fournit des métadonnées Cython valides
- **THEN** le premier environnement selon la priorité fournit la version et les chemins observés, sans déduire un usage fonctionnel ni une conformité de version

#### Scenario: Absence vérifiée de Cython

- **WHEN** la découverte est achevée et tous les venv trouvés ont été sondés avec succès sans métadonnées Cython
- **THEN** le document indique non installé et les environnements vérifiés, même si le Python DevOps possède Cython

#### Scenario: Installation non vérifiable

- **WHEN** aucun venv n’est trouvé, ou une recherche ou sonde échoue, expire, dépasse son budget ou fournit des métadonnées ambiguës sans installation valide observée
- **THEN** le document indique installation non vérifiable avec un diagnostic fixe sans sortie rejetée

#### Scenario: Rendu et isolation communs

- **WHEN** un rendu individuel, groupé ou final de création traite un projet déclarant Cython
- **THEN** la rubrique conditionnelle est identique à observations égales, avec chemins du projet, sans import de paquet ni chargement de .pth, installation ou modification du manifeste

### Requirement: Sondes Cython isolées et rendu commun

DIU SHALL sonder les métadonnées avec -I -B -S, dans les bornes existantes de 3 secondes par sonde et 12 secondes de recherche/sondes. DIU MUST NOT importer Cython, charger de .pth, installer, compiler ni modifier le manifeste. Les trois parcours SHALL partager ce rendu au format 0.7. Les chemins observés SHALL provenir des environnements du projet ; aucune sortie rejetée SHALL être publiée.

#### Scenario: Sonde passive et bornée

- **WHEN** un environnement contient Cython, un fichier .pth à effet de bord ou un interpréteur qui expire
- **THEN** aucun paquet ni fichier .pth n’est exécuté, et toute expiration termine la sonde et ses descendants sans exposer de sortie brute
- **AND** les contraintes déclarées ne sont pas résolues et aucun fichier de manifeste n’est modifié
