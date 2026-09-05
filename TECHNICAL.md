# Cadrage technique du DIU

## Objet

Ce document définit le cadre technique transversal du Debian Installer Unifié
(DIU).

Il complète :

- `PROJECTS.md`, qui décrit le projet et ses domaines fonctionnels ;
- `BUILD.md`, qui décrit la construction du paquet Debian du DIU.

Il couvre les conventions d'exécution, l'organisation du code Bash, le
chargement des composants, la configuration et la transition entre l'ancienne
et la nouvelle gestion des variables.

Les comportements fonctionnels détaillés restent définis par les
spécifications OpenSpec applicables.

## Socle technique

Le DIU est développé en Bash et s'exécute sur les versions stables de Debian
prises en charge par le projet.

Les scripts doivent :

- utiliser une ligne d'interpréteur compatible avec Debian ;
- conserver un encodage UTF-8 et des fins de ligne Unix LF ;
- privilégier les outils disponibles dans une installation Debian standard ;
- protéger les expansions de variables par des guillemets lorsque nécessaire ;
- traiter explicitement les erreurs attendues ;
- retourner un code non nul lorsqu'une opération demandée échoue ;
- rester compatibles avec les comportements existants qui ne sont pas
  concernés par une évolution validée.

Le script principal active actuellement :

```bash
set -Eeuo pipefail
```

Les modules sourcés s'exécutent donc dans un contexte strict. Une variable
absente, une commande en échec ou une erreur dans un pipeline doit être prise
en compte lors de toute évolution.

## Contextes et chemins

Le DIU distingue deux contextes principaux :

| Contexte | Chemin | Rôle |
|---|---|---|
| Développement | `/home/devops/datas/diu` | Sources, Git, OpenSpec et production des artefacts |
| Production | `/root/diu` | Application DIU installée et configuration locale |

Dans un conteneur OpenCode, la racine du projet est exposée sous
`/home/devops/datas/diu`.

`BASH_SCRIPT_PATH` est calculé depuis l'emplacement réel de
`root-install-debian.sh`. Il sert à charger les bibliothèques et les modules de
manière relative au script principal.

Les chemins absolus `/root/diu` restent utilisés pour la configuration de
production. Toute modification de cette convention doit être spécifiée et
validée, car elle affecte la compatibilité avec les installations existantes.

### Environnement OpenSpec

La commande `openspec` s'utilise dans l'environnement de l'utilisateur
`devops`, dont le répertoire personnel est `/home/devops`, depuis la racine
du projet `/home/devops/datas/diu`.

Les exécutables sont installés aux emplacements suivants :

- OpenSpec : `/home/devops/.local/npm/bin/openspec` ;
- Node.js : `/home/devops/node/current/bin/node`.

Si la session de l'agent n'hérite pas du `PATH` de `devops`, utiliser ces
exécutables en complétant le `PATH` pour la commande concernée :

```bash
PATH="/home/devops/node/current/bin:/home/devops/.local/npm/bin:$PATH" openspec --version
```

Le même préfixe s'applique aux commandes de validation et de gestion des
évolutions OpenSpec. Une commande absente du `PATH` de la session ne signifie
pas qu'OpenSpec est absent de l'environnement de `devops`.

## Point d'entrée et chargement du code

`root-install-debian.sh` est le point d'entrée principal du DIU.

Son initialisation suit actuellement cet ordre général :

```text
root-install-debian.sh
        │
        ├── active le mode Bash strict
        ├── calcule BASH_SCRIPT_PATH
        ├── charge modules/system/variables-cleanup.sh et exécute config_cleanup
        ├── charge variables.sh
        ├── charge les bibliothèques de lib/
        ├── charge les modules fonctionnels
        ├── crée config/ et deb/ si nécessaire
        ├── appelle config_load
        └── poursuit le dispatch ou l'installation Debian
```

Les fichiers présents sous `lib/` fournissent des fonctions génériques et
réutilisables. Les fichiers présents sous `modules/` portent les fonctions
propres aux domaines fonctionnels décrits dans `PROJECTS.md`.

Un fichier Bash destiné à être sourcé doit uniquement définir ou initialiser
ce qui est nécessaire à son rôle. Il ne doit pas déclencher d'opération
fonctionnelle imprévisible au seul chargement, à l'exception des fichiers
déclaratifs de variables dont l'exécution constitue explicitement leur
mécanisme d'initialisation.

## Organisation modulaire

L'organisation technique cible sépare :

```text
lib/                         fonctions génériques partagées
modules/diu/                 moteur et configuration du DIU
modules/system/              système Debian
modules/desktop/             environnements graphiques
modules/environments/        environnements utilisateurs
modules/softwares/           cycle de vie des logiciels
modules/projects/            projets de développement
```

La migration reste progressive. Le dépôt peut donc contenir temporairement
des structures intermédiaires ou des fonctions encore présentes dans le
script principal.

L'arborescence actuelle contient notamment `modules/environment/` au
singulier, tandis que l'architecture fonctionnelle cible utilise
`modules/environments/`. Cet état est constaté comme une transition ; ce
document n'autorise pas à lui seul un renommage ou un déplacement.

## Gestion de la configuration

La gestion de la configuration appartient au module `diu`.

Elle repose sur trois niveaux qui coexistent pendant la migration :

```text
variables.sh
    │
    │ ancienne configuration centralisée
    ▼
config/<scope>.env
    │
    │ valeurs persistées par domaine
    ▼
modules/diu/variables/<scope>/*.sh
      déclarations unitaires et valeurs par défaut
```

Le fichier central du nouveau mécanisme est :

```text
modules/diu/config.sh
```

Il expose les fonctions `config_load`, `config_generator`, `config_sort` et
`config_update`.

## Ancienne gestion des variables

L'ancienne méthode regroupe les variables globales dans :

```text
/root/diu/variables.sh
```

Le script principal charge `modules/system/variables-cleanup.sh` et exécute
`config_cleanup` avant de sourcer ce fichier, puis charge les autres bibliothèques
et modules. Le nettoyage retire les affectations simples de `DEBIAN_RELEASE`
(avec `export` optionnel), sans réécriture si elles sont absentes. Une erreur
interrompt le démarrage. Les consommateurs utilisent `SYSTEM_DEBIAN_RELEASE`,
sans reprise de la valeur historique.
Les variables deviennent ainsi disponibles dans l'environnement d'exécution
du DIU.

Cette méthode présente une configuration centralisée dans un seul fichier.
Elle reste nécessaire pendant la migration afin de préserver les
installations existantes et les variables qui n'ont pas encore de déclaration
unitaire.

`variables.sh` est une configuration locale de production :

- il reste situé à la racine de l'installation DIU ;
- il n'est pas embarqué dans le paquet Debian ;
- il ne doit pas être remplacé lors d'une mise à jour ;
- il est progressivement relayé par la configuration gérée dans le module
  `diu`.

L'abandon de cette méthode doit rester progressif. Une variable ne peut être
retirée de `variables.sh` qu'après validation de son remplacement, de sa
persistance et de sa compatibilité avec une configuration existante.

## Nouvelle gestion des variables

La nouvelle méthode place chaque déclaration de variable dans un fichier Bash
unitaire :

```text
modules/diu/variables/<scope>/<nom_de_variable>.sh
```

Les déclarations sont découvertes automatiquement. `config_generator`
recherche les fichiers `*.sh` exactement deux niveaux sous
`modules/diu/variables/`, les trie, puis les source un par un.

Cette découverte permet d'ajouter une variable à un domaine sans modifier la
liste interne de `config_generator`.

### Attributs d'une déclaration

Une déclaration unitaire définit actuellement les éléments suivants :

| Attribut | Valeurs attendues | Rôle |
|---|---|---|
| `config` | `STATIC` ou `DYNAMIC` | Mode d'obtention de la valeur |
| `state` | `ENABLE` ou `DISABLE` | Activation de la variable |
| `scope` | Nom du domaine en minuscules | Fichier de persistance associé |
| `default_value` | Valeur propre à la variable | Valeur initiale ou de repli |
| `variable_config_file` | `/root/diu/config/<scope>.env` | Destination persistante |
| `variable_generator` | Fonction Bash | Génération d'une valeur dynamique |

Le nom de la variable globale est actuellement porté directement par le code
de son fichier déclaratif. Il n'existe pas encore d'attribut générique séparé
pour ce nom.

### Scopes

Les scopes fonctionnels prévus sont :

```text
desktop
devops
diu
docker
environnements
ia
projects
softwares
system
```

Chaque scope dispose d'un fichier de configuration persistant correspondant :

```text
/root/diu/config/<scope>.env
```

Le nom `environnements.env` est actuellement employé par `config_load`.
Cette convention doit rester cohérente entre le chargeur, les déclarations et
les fichiers présents sur les installations existantes.

### Variable `STATIC`

Une variable `STATIC` représente une valeur persistante.

Son comportement est :

```text
state = ENABLE
        │
        ├── variable déjà définie
        │       └── conserver sa valeur
        │
        └── variable absente
                ├── exporter default_value
                └── écrire son export dans config/<scope>.env
```

Une valeur existante ne doit pas être remplacée par la valeur par défaut. La
création automatique sert à compléter une ancienne configuration lorsqu'une
nouvelle variable apparaît dans une version plus récente du DIU.

### Variable `DYNAMIC`

Une variable `DYNAMIC` représente une valeur calculée au moment de
l'exécution.

Lorsqu'elle est active et absente, sa valeur est obtenue par
`variable_generator`. Le modèle prévoit l'usage de `default_value` comme
valeur de repli si la génération ne peut pas fournir de résultat exploitable.

`SYSTEM_DEBIAN_RELEASE` est une déclaration `DYNAMIC`, `ENABLE`, de scope
`system`. Son générateur lit `VERSION_CODENAME` dans `/etc/os-release` et
retourne le nom de code en minuscules. Une valeur déjà définie est conservée.
Aucune valeur dynamique n'est persistée. Si la détection échoue, cette
déclaration signale une erreur et laisse la variable absente, sans valeur de
repli inventée. Ce comportement est défini par la spécification OpenSpec
`system-debian-release`.

### Variable désactivée

Lorsque `state` vaut `DISABLE`, la déclaration :

- retire la variable de l'environnement courant avec `unset` ;
- supprime sa ligne persistante du fichier `config/<scope>.env` si ce fichier
  existe.

La suppression doit cibler uniquement la déclaration exacte de la variable
concernée.

## Cycle de chargement de la configuration

`config_load` exécute les opérations suivantes :

```text
config_load
    │
    ├── charge config/diu.env
    ├── charge config/desktop.env
    ├── charge config/devops.env
    ├── charge config/docker.env
    ├── charge config/environnements.env
    ├── charge config/ia.env
    ├── charge config/projects.env
    ├── charge config/softwares.env
    ├── charge config/system.env
    ├── exécute config_generator
    └── exécute config_sort
```

Chaque fichier `.env` est facultatif. Son absence ne doit pas interrompre le
chargement.

Compte tenu de l'ordre d'initialisation complet :

1. `variables.sh` fournit encore les valeurs historiques ;
2. les fichiers `config/*.env` chargent les valeurs persistées par scope ;
3. les déclarations unitaires créent uniquement les variables toujours
   absentes ;
4. les fichiers `.env` sont triés et dédupliqués.

Les valeurs persistées dans `config/*.env` peuvent donc prendre le relais des
valeurs historiques avant l'application des valeurs par défaut unitaires.

## Tri et persistance

`config_sort` découvre les fichiers `*.env` directement présents sous
`/root/diu/config`, puis applique :

```bash
sort -u <fichier> -o <fichier>
```

Cette opération garantit un ordre déterministe et supprime les lignes
strictement identiques. Elle ne résout pas plusieurs lignes différentes qui
déclareraient le même nom de variable. Les déclarations unitaires doivent donc
éviter de produire des doublons contradictoires.

Les écritures de configuration doivent :

- cibler uniquement le fichier du scope concerné ;
- préserver les valeurs existantes ;
- produire une syntaxe Bash valide pouvant être sourcée ;
- ne jamais inscrire de secret dans les journaux ;
- échouer explicitement si une persistance requise ne peut pas être réalisée.

## Mise à jour de la configuration

`config_update` fournit un point d'entrée pour réappliquer le mécanisme de
configuration pendant l'exécution du DIU.

Dans l'implémentation actuelle, `config_update` appelle `config_load`, puis
`config_generator`, alors que `config_load` appelle déjà `config_generator`.
Le générateur peut donc être exécuté deux fois lors d'un `config_update`.

Les déclarations `STATIC` actuelles évitent une seconde écriture parce qu'elles
ne créent leur variable que lorsqu'elle est absente. Le comportement doit
rester idempotent. Une évolution future de `config_update`, en particulier
avec des variables `DYNAMIC`, devra clarifier cet ordre dans une spécification
validée.

## Conventions de nommage

Les conventions suivantes s'appliquent au nouveau code :

- variables globales : lettres majuscules et séparateur `_` ;
- variables locales : lettres minuscules et séparateur `_` ;
- nouveaux identifiants techniques : anglais ;
- fichiers de variables unitaires : nom explicite en minuscules avec suffixe
  `.sh` ;
- scopes : noms de domaine en minuscules ;
- fonctions : noms explicites cohérents avec le domaine existant.

Un nom existant suffisamment clair doit être conservé. Un renommage purement
esthétique n'est pas autorisé.

## Gestion des erreurs et idempotence

Une fonction du DIU doit :

- vérifier ses paramètres et prérequis avant toute modification ;
- limiter ses écritures au domaine qu'elle gère ;
- afficher un message permettant d'identifier l'échec ;
- propager un code de retour non nul ;
- éviter de laisser un état partiellement modifié lorsque cela est
  raisonnablement possible ;
- supporter une nouvelle exécution sans dupliquer ni dégrader la
  configuration.

Les commandes dont l'échec est attendu doivent être placées dans une condition
explicite. Une erreur ne doit jamais être ignorée silencieusement.

## Sécurité et données sensibles

Les secrets ne doivent pas être inscrits directement dans les sources, les
spécifications, les journaux ou les messages de diagnostic.

Les fichiers de configuration pouvant contenir des identifiants restent des
données locales. Ils ne doivent pas être embarqués dans les artefacts ni
utilisés comme documentation technique.

Les scripts doivent appliquer le principe du moindre privilège. Une opération
ne doit pas demander les droits root si l'outil utilisé peut accomplir son
travail sans élévation.

Les entrées provenant de l'utilisateur, de fichiers de configuration ou de
services distants doivent être validées avant d'être utilisées dans un chemin,
une commande ou une écriture système.

## Dépendances

Une dépendance Debian standard déjà disponible doit être privilégiée. Toute
nouvelle dépendance nécessite une justification, une validation explicite et
une documentation adaptée.

Une fonction qui dépend d'une commande non garantie doit vérifier sa présence
avec `command -v` avant de l'utiliser et fournir une erreur compréhensible si
elle est absente.

## Validation technique

Toute modification d'un script Bash doit au minimum être vérifiée avec :

```bash
bash -n <fichier>
shellcheck <fichier>
```

Les tests applicables doivent ensuite vérifier le comportement modifié, les
cas d'échec attendus, l'idempotence lorsque pertinente et l'absence de
régression sur les commandes existantes.

Avant de déclarer une évolution valide, il faut également vérifier :

- la conformité aux spécifications OpenSpec applicables ;
- la cohérence entre le point d'entrée, les bibliothèques et les modules ;
- l'absence de modification hors périmètre ;
- l'absence de secret ajouté aux sources ;
- la compatibilité avec les installations Debian existantes.
