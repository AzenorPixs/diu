# Paquet Debian du DIU

## Purpose

Construire un paquet Debian de production contenant les fichiers nécessaires au
fonctionnement du DIU, préparant une installation déployant le contenu sous
`/root/diu` sur la machine cible.

## Requirements

### Requirement: Nom du paquet

Le paquet Debian produit SHALL porter le nom `diu`.

#### Scenario: Nommage du paquet

WHEN la construction du paquet est déclenchée
THEN le paquet généré porte le nom `diu` dans son en-tête

### Requirement: Version du paquet

PROJECT_VERSION, lorsqu’elle est déclarée et valide, SHALL déterminer la version du paquet. Sans cette clé, la version SHALL suivre les tags de HEAD en privilégiant les versions stables sur les horodatages, puis l’horodatage local sans Git ou tag ; ambiguïtés et erreurs Git SHALL rester bloquantes.

#### Scenario: Version générée
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** aucun tag de HEAD n'est disponible
- **THEN** le champ Version et le nom du paquet utilisent le même horodatage local YYYY.MM.DD.HH.MM
- **AND** la version est affichée lors de la construction

#### Scenario: Version issue du tag
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** HEAD possède v1.2.3 ou 1.2.3 comme unique version valide
- **THEN** le paquet utilise 1.2.3 ; des variantes équivalentes ne créent pas d’ambiguïté

#### Scenario: Versions de tags ambiguës
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** HEAD possède plusieurs versions distinctes après application de la priorité stable ou un tag inexploitable
- **THEN** le build échoue avant publication et préserve dist/

#### Scenario: Tag stable et horodaté
- **WHEN** HEAD porte une seule version stable et un ou plusieurs tags horodatés
- **THEN** le constructeur retient la version stable

### Requirement: Déploiement sous /root/diu

Lorsque le paquet Debian est installé, le contenu de production du DIU SHALL
être déployé sous `/root/diu` sur la machine cible.

#### Scenario: Installation du paquet

WHEN le paquet est installé sur la machine cible
THEN le répertoire `/root/diu` existe
AND `/root/diu` contient `root-install-debian.sh`
AND `/root/diu/lib/` contient les fonctions génériques
AND `/root/diu/modules/` contient les modules fonctionnels

### Requirement: Contenu de production du paquet

Le paquet Debian produit SHALL contenir uniquement les fichiers de production
du DIU. Le contenu est défini par une liste blanche.

Les éléments inclus dans le paquet sont :

- `root-install-debian.sh`
- `lib/` (ensemble des fichiers)
- `modules/` (ensemble des fichiers)

#### Scenario: Éléments inclus

WHEN le paquet est construit
THEN seuls les éléments listés ci-dessus sont présents dans le paquet

#### Scenario: Éléments exclus

WHEN le paquet est construit
THEN les éléments suivants ne sont pas inclus dans le paquet :

- `deb/`
- `dist/`
- `.git/`
- `.opencode/`
- `openspec/`
- `config/`
- les caches, journaux, secrets et fichiers temporaires
- `variables.sh`

#### Scenario: variables.sh non embarqué

WHEN le paquet est construit
THEN `variables.sh` n'est pas inclus dans le paquet

#### Scenario: Préservation de variables.sh existant

WHEN le paquet est installé ou mis à jour sur une machine cible
THEN un éventuel `/root/diu/variables.sh` déjà présent n'est pas remplacé

### Requirement: Emplacement de production du paquet

Le paquet Debian SHALL être produit dans dist/ sans embarquer ce répertoire. La construction temporaire, la publication et la rotation SHALL préserver le dernier paquet valide et les fichiers étrangers au DIU.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

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

#### Scenario: Production et rotation sûres des paquets

- **WHEN** un paquet Debian du DIU est construit ou publié, avec succès ou échec
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

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

### Requirement: Rôle du répertoire deb/

Le répertoire `deb/` SHALL être un répertoire runtime servant de cache aux paquets
Debian externes téléchargés et consommés par le DIU. Il est recréable et ne
constitue pas un élément de distribution du DIU.

#### Scenario: Non-embarquement de deb/

WHEN le paquet est construit
THEN `deb/` n'est pas embarqué dans le paquet Debian du DIU

#### Scenario: Non-lecture de deb/ pendant la construction

WHEN la construction du paquet est en cours
THEN le contenu de `deb/` n'est pas lu ni copié

#### Scenario: deb/ non utilisé comme destination

WHEN le paquet est produit
THEN `deb/` n'est pas utilisé comme destination du paquet produit

#### Scenario: Indépendance vis-à-vis de deb/

WHEN le contenu éventuellement présent dans `deb/` dans le projet de
développement varie
THEN le contenu du paquet produit n'est pas influencé

### Requirement: Vérification des prérequis

Le DIU SHALL vérifier la disponibilité des outils nécessaires à la
construction du paquet avant de procéder.

#### Scenario: Prérequis satisfaits

WHEN les outils requis sont disponibles
THEN la construction du paquet est déclenchée

#### Scenario: Prérequis manquant

WHEN un outil requis est absent
THEN un message d'erreur identifie l'outil manquant
AND la construction n'est pas déclenchée
AND aucun paquet n'est produit
AND le DIU se termine avec le code 1

### Requirement: Validation du projet cible

Le DIU SHALL valider que le projet cible possède les éléments nécessaires
au packaging du DIU avant de procéder à la construction.

Les éléments requis dans le projet cible sont :

- `root-install-debian.sh`
- `lib/`
- `modules/`

#### Scenario: Projet cible valide

WHEN le projet cible contient les éléments requis
THEN la construction du paquet est déclenchée

#### Scenario: Projet cible invalide

WHEN le projet cible ne contient pas un ou plusieurs éléments requis
THEN un message d'erreur identifie les éléments manquants
AND la construction n'est pas déclenchée
AND aucun paquet n'est produit
AND le DIU se termine avec le code 1

### Requirement: Commande rid proj deb

DIU SHALL accepter rid proj deb <project_id> et rid projects deb [project_id]. Sans identifiant, projects SHALL cibler diu. L'identifiant SHALL sélectionner un enfant direct de DEVOPS_PROJECTS_ROOT contenant les sources DIU requises, sans chemin ni lien symbolique. Le paquet SHALL rester nommé diu. Les arguments supplémentaires SHALL être refusés.

#### Scenario: Construction depuis la commande rid

WHEN l'utilisateur exécute `rid proj deb monprojet`
THEN le DIU valide que le projet `$DEVOPS_PROJECTS_ROOT/monprojet` existe
AND le DIU valide que le projet contient les éléments requis pour le packaging
AND le DIU vérifie les prérequis de construction
AND le DIU construit le paquet Debian dans `dist/` du projet

#### Scenario: Projet inexistant

WHEN l'utilisateur exécute `rid proj deb projetinexistant`
THEN un message d'erreur indique que le projet n'existe pas
AND le DIU se termine avec le code 1
#### Scenario: Projet par défaut

- **WHEN** rid projects deb est demandé
- **THEN** le projet diu est construit sans modifier cicddiu

#### Scenario: Cache deb absent

- **WHEN** le projet contient le script principal, lib/ et modules/ mais pas deb/
- **THEN** la construction est permise sans lire ni créer ce cache

#### Scenario: Identifiant ou chemin invalide

- **WHEN** l'identifiant est vide, un chemin, un lien symbolique ou sort de la racine
- **THEN** la commande échoue sans écriture ni construction
