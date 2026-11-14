## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version `0.8` et l'ordre documentaire défini ici. Pour template, le titre SHALL être `DEVOPS.md — Template`. Matériel SHALL suivre immédiatement Système d'exploitation. Chaque rubrique logicielle SHALL placer le chemin après la version ; PostgreSQL Serveur SHALL placer l'adresse après la version. Tests navigateurs extérieurs en mode headless SHALL terminer le document.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.8 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH` si activé, OpenSSH & SSHPASS, Docker-Compose, Git, Go, Node, NPM, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Python - Outils de compilation si Cython ou Nuitka est déclaré dans [build-system].requires, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** les métadonnées de traçabilité, la section de configuration locale et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox
- **AND THEN** le document ne contient ni rubrique OpenCode, ni chemin `/home/${ENV_DEVOPS_USER}/.opencode`, ni puce `OPENCODE_PASSWORD`

#### Scenario: Configuration locale et sécurité

- **WHEN** un document DevOps est généré
- **THEN** le texte de configuration locale validé apparaît une seule fois avant la légende des sondes et rappelle les restrictions de consultation de project.env par les agents
- **AND THEN** les mentions d'authentification dans ce texte ne citent que SSH et PostgreSQL

### Requirement: Distinction entre hôte et environnement DevOps

DIU SHALL relever le système d'exploitation hôte et les versions des outils hôte Docker-Compose, Git, OpenSSL et PostgreSQL Client. Docker SHALL être relevé uniquement si ENV_DEVOPS_TESTS_DOCKER vaut exactement `1`. DIU SHALL relever Go, Node, NPM, OpenSpec, Python et pip depuis les binaires situés dans `/home/${ENV_DEVOPS_USER}`, sous cet utilisateur. OpenCode SHALL NOT être sondé comme outil DevOps. DIU SHALL NOT remplacer un outil DevOps manquant par un outil hôte.

#### Scenario: Versions hôte différentes

- **WHEN** le PATH hôte contient un Node et un Python différents de ceux du domicile DevOps
- **THEN** les rubriques DevOps indiquent les versions et chemins du domicile DevOps

#### Scenario: Outil manquant ou défaillant

- **WHEN** un outil DevOps restant est absent ou sa sonde échoue
- **THEN** sa rubrique indique que sa version est indisponible et le chemin attendu ou l'absence de binaire
- **AND THEN** aucune installation n'est réalisée

#### Scenario: Répertoire de l'appelant inaccessible à DevOps

- **WHEN** la génération est lancée depuis un dossier inaccessible à l'utilisateur DevOps, par exemple /root
- **THEN** les sondes, notamment go version, sont exécutées depuis son domicile accessible
- **AND THEN** la version Go disponible est relevée et le répertoire courant de l'appelant est préservé

### Requirement: Sélection des manifestes JavaScript utiles

DIU SHALL retenir les manifestes `package.json` racine présents, ceux déclarant des dépendances, ainsi que les organisateurs et membres de workspaces déclarés. Les motifs de workspaces SHALL rester relatifs et confinés au projet. Les autres manifestes vides SHALL être comptés comme non retenus. `.opencode/package.json` SHALL NOT être découvert explicitement ni recevoir une rubrique particulière dans DEVOPS.md.

#### Scenario: Workspace sans dépendance

- **WHEN** un membre découvert correspond à un motif de workspace déclaré et n'a aucune dépendance
- **THEN** il est retenu tandis que les autres manifestes vides sont comptés comme non retenus

### Requirement: Collecte JavaScript passive

La collecte SHALL utiliser sous le compte DevOps un Python existant, isolé et sans site automatique, avec la bibliothèque standard. Elle SHALL NOT lancer npm, Bun, un script, un import applicatif, une installation ou une requête réseau. Elle SHALL NOT lire `.npmrc`, les fichiers env ni les secrets. L'absence de Node SHALL NOT bloquer une analyse passive disponible.

#### Scenario: Code à effet de bord

- **WHEN** un manifeste contient des scripts et un paquet contient du code exécutable
- **THEN** la collecte ne les exécute pas et ne modifie aucun fichier du projet

### Requirement: Restitution JavaScript dans les rubriques existantes

NPM SHALL recevoir la sous-section Dépendances JavaScript du projet pour les composants applicatifs retenus. Chaque dépendance SHALL distinguer déclaration, version verrouillée npm et observation locale, avec chemin d'installation vérifié. DEVOPS.md SHALL NOT produire de sous-section Dépendances OpenCode du projet.

#### Scenario: Deux usages Pixs

- **WHEN** frontend/package.json et .opencode/package.json déclarent des paquets
- **THEN** le manifeste frontend apparaît une seule fois dans la rubrique NPM
- **AND** le manifeste `.opencode/package.json` n'est pas publié dans DEVOPS.md

### Requirement: Cohérence des rendus JavaScript

Les sous-sections sans manifeste ni diagnostic SHALL être omises. Les versions des binaires Node et NPM SHALL rester distinctes des paquets. Les parcours individuel, groupé et de création SHALL utiliser le même rendu, avec ordre principal et section finale des navigateurs conservés.

#### Scenario: Parcours existants

- **WHEN** un rendu individuel, groupé ou final de création est produit
- **THEN** les sous-sections sont identiques à observations égales et n'ajoutent aucun doublon

### Requirement: Préparation des exécutables DevOps connus

Avant les inventaires et sondes du rendu commun, DIU SHALL préparer uniquement ces chemins sous `/home/${ENV_DEVOPS_USER}` : `go/current/bin/go`, `node/current/bin/node`, `node/current/bin/npm`, `.local/npm/bin/openspec`, `python/current/bin/python3` et `python/current/bin/pip3`. Les outils absents SHALL rester indisponibles sans création ni installation. La version documentaire, les commandes et le contexte des sondes SHALL rester inchangés.

#### Scenario: Sept outils présents sans droit d'exécution

- **WHEN** les sept fichiers historiques existent sans bits d'exécution
- **THEN** DIU ajoute les bits ugo+x des six outils DevOps encore gérés avant les inventaires et les sondes
- **AND** DIU n'inspecte ni ne modifie `.opencode/bin/opencode`
- **AND THEN** les versions et inventaires disponibles sont relevés normalement
- **AND THEN** propriétaires, droits de lecture et d'écriture, outils hôte et autres fichiers restent inchangés

#### Scenario: OpenCode absent des outils DevOps

- **WHEN** le rendu prépare les exécutables DevOps connus
- **THEN** DIU ne recherche ni ne prépare `/home/${ENV_DEVOPS_USER}/.opencode/bin/opencode`

## REMOVED Requirements

### Requirement: Exception ciblée du manifeste OpenCode

**Reason**: DEVOPS.md ne présente plus les dépendances OpenCode du projet.
**Migration**: Les configurations `.opencode` restent des ressources de projet, hors de l'inventaire DevOps.

### Requirement: Source documentaire du mot de passe API OpenCode

**Reason**: DEVOPS.md ne contient plus de rubrique OpenCode ni d'indication de son mot de passe API.
**Migration**: Aucune donnée d'authentification OpenCode n'est restituée dans l'inventaire DevOps.
