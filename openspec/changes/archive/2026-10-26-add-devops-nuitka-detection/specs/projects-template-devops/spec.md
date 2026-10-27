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
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH` si activé, OpenSSH & SSHPASS, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Python - Outils de compilation si Cython ou Nuitka est déclaré dans [build-system].requires, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

### Requirement: Provenance et portée informative du relevé

Avant la première rubrique, DIU SHALL distinguer sondes système, outils DevOps et dépendances. La légende SHALL expliquer priorité des venv et repli DevOps, sources [project].dependencies et [build-system].requires pour Cython et Nuitka, manifestes JavaScript par composant, déclaration/verrou/observation et absence de qualification fonctionnelle ou preuve de tests. Les trois parcours SHALL partager cette présentation sans doublon.

#### Scenario: Parcours de génération existants

- **WHEN** une génération individuelle, groupée ou finale de création réussit
- **THEN** le document contient une seule provenance DIU, un début du relevé UTC, une classification et la légende
- **AND THEN** aucun résultat de test ou de qualification n'est inventé

### Requirement: Déclaration préalable de Cython pour la compilation

DIU SHALL reconnaître le nom de distribution Cython, sans distinction de casse, uniquement dans la liste [build-system].requires du TOML. DIU SHALL émettre « Python - Outils de compilation » après pip et avant Prompts si Cython ou Nuitka est déclaré, avec une entrée Cython seulement s’il est déclaré. Sans déclaration confirmée, DIU MUST NOT découvrir ou sonder des venv pour Cython. Une analyse invalide ou impossible SHALL produire un diagnostic fixe hors de cette rubrique.

#### Scenario: Cython déclaré pour la construction

- **WHEN** [build-system].requires contient Cython, cython ou une exigence Cython avec contrainte ou marqueur
- **THEN** la rubrique de compilation apparaît une seule fois après pip et avant Prompts, avec la déclaration et sa source
- **AND** les contraintes et marqueurs restent déclaratifs sans résolution, et les références directes restent masquées
- **AND** les dépendances d’exécution restent inchangées

#### Scenario: Cython non déclaré pour la construction

- **WHEN** le manifeste est absent, sans [build-system].requires, ou déclare Cython uniquement dans une autre table, un commentaire ou un nom de distribution différent
- **THEN** l’entrée Cython est omise et aucune sonde Cython n’est exécutée ; la rubrique et la découverte sont omises si Nuitka n’est pas déclaré non plus
- **AND** un manifeste absent reste signalé par l’inventaire d’exécution existant

#### Scenario: Déclaration non vérifiable

- **WHEN** le manifeste est illisible, invalide, possède un requires mal typé ou l’analyseur est indisponible
- **THEN** le diagnostic explique que la déclaration n’est pas vérifiable sans émettre la rubrique de compilation ni conclure à une absence d’installation

## ADDED Requirements

### Requirement: Déclaration préalable de Nuitka pour la compilation

DIU SHALL reconnaître uniquement Nuitka, sans distinction de casse, dans [build-system].requires, avec ses contraintes, marqueurs ou extras. DIU SHALL afficher une entrée Nuitka uniquement après déclaration confirmée. Sans cette déclaration, DIU MUST NOT sonder Nuitka. Les références directes SHALL être masquées ; les marqueurs et contraintes SHALL rester déclaratifs, sans résolution. Une autre table ou un commentaire MUST NOT déclencher cette détection.

#### Scenario: Déclarations Nuitka acceptées

- **WHEN** requires contient Nuitka, nuitka, NUITKA>=2 ou Nuitka[build-wheel]
- **THEN** l’entrée Nuitka est affichée avec sa déclaration et sa source, après sondage conditionnel

#### Scenario: Nuitka non déclaré pour la construction

- **WHEN** Nuitka est absent de requires, seulement dans une autre table, un commentaire ou un nom tel que nuitka-tools
- **THEN** aucune entrée ni sonde Nuitka n’est produite, même si Nuitka est installé localement

### Requirement: États Nuitka indépendants et provenance locale

DIU SHALL appliquer à Nuitka les sondes isolées et bornées des venv du projet, sans import, .pth, installation, compilation, modification de manifeste ni repli global. L’entrée SHALL indiquer la version et les chemins observés, non installé avec les venv vérifiés si l’absence est établie, ou installation non vérifiable sinon, notamment sans venv. L’état de Nuitka SHALL rester indépendant de celui de Cython.

#### Scenario: Version locale et environnement observés

- **WHEN** le premier venv valide selon la priorité fournit Nuitka
- **THEN** sa version, son interpréteur, son environnement et son installation sont indiqués, sans conformité de version ni usage effectif déduits
- **AND** la présence de Nuitka dans le Python global ne remplace jamais une absence locale

#### Scenario: Absence et impossibilité de vérification

- **WHEN** tous les venv découverts sont sondés avec succès sans Nuitka
- **THEN** Nuitka est indiqué non installé avec les environnements vérifiés
- **AND** aucun venv, une découverte incomplète, un échec, une expiration ou des métadonnées Nuitka ambiguës donnent installation non vérifiable si aucune installation valide n’est observée

#### Scenario: Deux outils et états distincts

- **WHEN** Cython est installé et Nuitka absent ou non vérifiable, ou inversement
- **THEN** chaque outil garde son propre état et sa provenance, y compris dans des venv différents

### Requirement: Rubrique commune des compilateurs déclarés

DIU SHALL produire une seule rubrique Python - Outils de compilation après pip et avant Prompts si Cython ou Nuitka est déclaré. Elle SHALL contenir seulement les outils déclarés, dans l’ordre Cython puis Nuitka. Sans les deux déclarations, aucune rubrique ni découverte ou sonde de compilation SHALL être produite. Les trois parcours SHALL partager ce rendu au format 0.7, avec une découverte commune et les bornes existantes.

#### Scenario: Quatre combinaisons de déclaration

- **WHEN** le manifeste déclare Cython seul, Nuitka seul, les deux ou aucun
- **THEN** la rubrique contient respectivement Cython, Nuitka, Cython puis Nuitka, ou est omise
- **AND** aucun outil non déclaré n’est sondé ni présenté, sans rubrique dupliquée

#### Scenario: Tous les parcours et limites communes

- **WHEN** une génération individuelle, groupée ou finale de création traite un projet déclarant un ou deux outils
- **THEN** les observations égales produisent le même inventaire, avec une seule découverte et les sondes nécessaires aux noms encore recherchés
- **AND** les bornes de 3 secondes par sonde et 12 secondes de recherche/sondes, les diagnostics sans sortie rejetée et les dépendances d’exécution restent conservés
