## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version `0.5` et l'ordre des rubriques du scénario « Rubriques documentaires conservées ». Pour template, le titre SHALL être `DEVOPS.md — Template`. Chaque rubrique logicielle SHALL placer le chemin après la version ; PostgreSQL Serveur SHALL placer l'adresse après la version. Tests navigateurs extérieurs en mode headless SHALL terminer le document, avec Chromium puis Firefox.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.5 et les rubriques existantes conservent leur ordre
- **AND THEN** une seule section Tests navigateurs extérieurs en mode headless termine le document

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Docker, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire

### Requirement: Provenance et portée informative du relevé

Avant la première rubrique, le document SHALL identifier DIU et distinguer sondes système, outils DevOps et dépendances du projet. La légende SHALL expliquer priorité des venv, repli DevOps, source [project].dependencies pour Python, manifestes JavaScript par composant, distinction déclaration/verrou/observation et absence de qualification fonctionnelle ou de preuve de tests. Les parcours individuel, groupé et de création SHALL conserver cette présentation sans doublon.

#### Scenario: Parcours de génération existants

- **WHEN** une génération individuelle, groupée ou finale de création réussit
- **THEN** le document contient une seule provenance DIU, un début du relevé UTC, une classification et la légende
- **AND THEN** aucun résultat de test ou de qualification n'est inventé

## ADDED Requirements

### Requirement: Découverte des manifestes JavaScript du projet

DIU SHALL rechercher les package.json ordinaires à la racine et dans les sous-dossiers ordinaires du projet, sans suivre les liens de dossiers. Les chemins relatifs SHALL être triés. La découverte SHALL être réalisée une seule fois par rendu.

#### Scenario: Projet sans manifeste racine

- **WHEN** frontend/package.json et .opencode/package.json existent sans package.json racine
- **THEN** les deux sources peuvent être retenues et sont traitées une seule fois

### Requirement: Exclusions de découverte JavaScript

La recherche SHALL exclure node_modules, les venv détectés par pyvenv.cfg, les caches, Git, les sorties dist/build/output/reports, journaux, PROMPTS, openspec et ressources d'outillage.

#### Scenario: Manifestes tiers et générés

- **WHEN** node_modules, un venv ou une sortie contient package.json
- **THEN** ces manifestes ne sont pas découverts

### Requirement: Exception ciblée du manifeste OpenCode

La découverte SHALL traiter .opencode/package.json explicitement avec ses verrous racine associés. Elle SHALL NOT parcourir les configurations, états, commandes ou skills OpenCode.

#### Scenario: Outillage OpenCode du projet

- **WHEN** le dossier .opencode contient un manifeste et des ressources internes
- **THEN** seuls le manifeste racine et ses verrous associés servent à la déclaration

### Requirement: Sélection des manifestes JavaScript utiles

DIU SHALL retenir les manifestes racine et OpenCode présents, ceux déclarant des dépendances, ainsi que les organisateurs et membres de workspaces déclarés. Les motifs de workspaces SHALL rester relatifs et confinés au projet. Les autres manifestes vides SHALL être comptés comme non retenus.

#### Scenario: Workspace sans dépendance

- **WHEN** un membre découvert correspond à un motif de workspace déclaré et n'a aucune dépendance
- **THEN** il est retenu tandis que les autres manifestes vides sont comptés comme non retenus

### Requirement: Sources JavaScript invalides et découverte incomplète

Un manifeste invalide, illisible ou symbolique SHALL recevoir un diagnostic fixe sans exposer son contenu. Une découverte incomplète SHALL être explicite et SHALL NOT valoir absence certaine de manifeste.

#### Scenario: Manifeste impossible à lire

- **WHEN** la découverte rencontre un manifeste illisible ou une limite
- **THEN** le relevé indique cette limite sans reproduire l'erreur brute ni annoncer une absence certaine

### Requirement: Déclarations JavaScript par catégorie

Chaque inventaire SHALL identifier son manifeste et conserver séparément dependencies, devDependencies, peerDependencies et optionalDependencies, y compris lorsqu'un nom apparaît dans plusieurs groupes. Les champs engines et packageManager renseignés SHALL être rapportés comme déclarations sans déduire le gestionnaire effectif d'un verrou.

#### Scenario: Frontend et outils

- **WHEN** React relève de dependencies et Vite de devDependencies
- **THEN** les deux groupes et leurs contraintes restent distincts avec leur source

### Requirement: Références JavaScript et types sûrs

Les types incohérents SHALL être signalés. Les références URL, Git ou locales SHALL être masquées ou catégorisées sans publier de valeur sensible. Les alias npm et références workspace sûrs MAY être identifiés sans exécution. Les valeurs et chemins publiés SHALL être validés ou échappés pour préserver le Markdown.

#### Scenario: Référence privée

- **WHEN** une dépendance contient une URL ou un chemin privé
- **THEN** seule une catégorie fixe est publiée sans divulgation ni exécution

### Requirement: Versions verrouillées npm distinctes de l'installation

DIU SHALL lire les versions verrouillées depuis npm-shrinkwrap.json ou package-lock.json aux formats 2 et 3, avec priorité de npm-shrinkwrap.json. Les entrées SHALL être résolues selon leur chemin dans packages, y compris les liens internes au verrou. Un verrou SHALL NOT servir de preuve d'installation.

#### Scenario: Verrou sans paquet local

- **WHEN** le verrou indique une version mais aucune installation locale n'est observée
- **THEN** les deux informations restent distinctes

### Requirement: Verrou local et héritage de workspace

Le verrou local SHALL primer. Un membre de workspace sans verrou local MAY utiliser le verrou de son organisateur déclaré. L'inventaire SHALL citer le fichier effectivement consulté pour ce membre.

#### Scenario: Verrou partagé

- **WHEN** un workspace déclaré utilise le verrou npm de son organisateur
- **THEN** l'entrée packages pertinente est sélectionnée et la source du verrou est affichée

### Requirement: Verrous non analysés et incohérences

Les autres formats de verrou SHALL être identifiés comme non analysés. Un verrou absent, invalide, incomplet ou désynchronisé SHALL être signalé sans inventer de version. Des formats concurrents SHALL être explicites sans déduire le gestionnaire réellement utilisé.

#### Scenario: Formats concurrents

- **WHEN** des verrous npm, Yarn, pnpm ou Bun coexistent
- **THEN** les sources sont identifiées, la priorité npm est respectée et les formats non pris en charge ne fournissent pas de version

### Requirement: Recherche des installations JavaScript locales

DIU SHALL lire seulement le package.json d'installation correspondant à chaque dépendance, dans node_modules au plus près du manifeste puis dans les parents jusqu'à la racine du projet. La première installation présente SHALL primer, sans masquer une métadonnée invalide par un parent. Aucun paquet npm global ni cache extérieur SHALL être utilisé comme repli.

#### Scenario: Installation proche et partagée

- **WHEN** un paquet existe près du manifeste et à la racine
- **THEN** l'installation proche est retenue avec son chemin réel

### Requirement: Identité et confinement des paquets JavaScript

DIU SHALL rapporter version observée et chemin réel d'installation et vérifier l'identité du paquet ou de l'alias connu. Les liens de dossiers MAY être résolus uniquement dans les ressources autorisées du projet, notamment pour les workspaces et pnpm. Un fichier de métadonnées symbolique ou une cible extérieure ou protégée SHALL rester non vérifiable sans être lu.

#### Scenario: Liens d'installation

- **WHEN** un lien vise un composant interne autorisé et un autre vise un dossier extérieur
- **THEN** la cible interne peut être observée et la cible extérieure n'est pas lue

### Requirement: Absence locale et métadonnées JavaScript inconnues

Une erreur de lecture, une métadonnée invalide ou une identité incohérente SHALL être non vérifiable. Une absence complète dans les emplacements locaux pertinents SHALL être libellée non observée localement, sans conclure à l'absence globale du paquet ni au chargement d'un plugin.

#### Scenario: Métadonnée invalide

- **WHEN** le paquet proche est présent mais ses métadonnées sont illisibles
- **THEN** l'état reste non vérifiable sans utiliser un paquet global ou une installation plus haute

### Requirement: Écart entre verrou et observation JavaScript

Lorsque les versions verrouillée et observée sont connues et différentes, DIU SHALL signaler cet écart. Le relevé SHALL NOT prétendre résoudre les contraintes SemVer, qualifier le graphe ou prouver un chargement de plugin.

#### Scenario: Versions différentes

- **WHEN** le verrou indique 1.0.0 et les métadonnées locales 2.0.0
- **THEN** l'écart est affiché sans conclusion automatique de compatibilité

### Requirement: Collecte JavaScript passive

La collecte SHALL utiliser sous le compte DevOps un Python existant, isolé et sans site automatique, avec la bibliothèque standard. Elle SHALL NOT lancer npm, Bun, OpenCode, un script, un import applicatif, une installation ou une requête réseau. Elle SHALL NOT lire .npmrc, les configurations OpenCode, les fichiers env ni les secrets. L'absence de Node SHALL NOT bloquer une analyse passive disponible.

#### Scenario: Code à effet de bord

- **WHEN** un manifeste contient des scripts et un paquet contient du code exécutable
- **THEN** la collecte ne les exécute pas et ne modifie aucun fichier du projet

### Requirement: Limites de collecte JavaScript

La collecte SHALL être bornée à 12 secondes sous la borne utilisateur de 15 secondes, 10 000 entrées de découverte, 128 manifestes, 1 024 dépendances restituées, 1 Mio par manifeste ou métadonnée, 8 Mio par verrou et 32 Mio de lectures JSON cumulées.

#### Scenario: Collecte trop grande

- **WHEN** une borne de temps, de taille ou de nombre est atteinte
- **THEN** le relevé explicite son caractère incomplet

### Requirement: Analyseur JavaScript indisponible ou échoué

Une limite atteinte SHALL être explicite. Un analyseur absent ou échoué SHALL produire un diagnostic fixe sans publier sa sortie brute ni une absence certaine. La collecte SHALL utiliser le Python DevOps disponible, sinon un Python système existant pour cette seule analyse.

#### Scenario: Analyseur absent

- **WHEN** aucun analyseur utilisable n'est disponible
- **THEN** un diagnostic fixe remplace l'inventaire sans installation ni conservation de données anciennes

### Requirement: Restitution JavaScript dans les rubriques existantes

NPM SHALL recevoir la sous-section Dépendances JavaScript du projet pour les composants applicatifs retenus. OpenCode SHALL recevoir Dépendances OpenCode du projet pour .opencode/package.json. Chaque dépendance SHALL distinguer déclaration, version verrouillée npm et observation locale, avec chemin d'installation vérifié.

#### Scenario: Deux usages Pixs

- **WHEN** frontend/package.json et .opencode/package.json déclarent des paquets
- **THEN** chaque manifeste apparaît une seule fois dans sa rubrique respective

### Requirement: Cohérence des rendus JavaScript

Les sous-sections sans manifeste ni diagnostic SHALL être omises. Les versions des binaires Node, NPM et OpenCode SHALL rester distinctes des paquets. Les parcours individuel, groupé et de création SHALL utiliser le même rendu, avec ordre principal et section finale des navigateurs conservés.

#### Scenario: Parcours existants

- **WHEN** un rendu individuel, groupé ou final de création est produit
- **THEN** les sous-sections sont identiques à observations égales et n'ajoutent aucun doublon
