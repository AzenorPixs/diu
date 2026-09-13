# Cadrage technique du DIUE

## Objet et périmètre

Ce document définit le cadre technique transversal du projet **DIUE**.

Le dépôt, le paquet Debian et les spécifications OpenSpec utilisent encore le
nom historique **DIU** et l'identifiant **`diu`**. Cette convention est
conservée dans les noms de fichiers, les fonctions, les variables, les
commandes et les chemins.

Ce document complète :

- `AGENTS.md`, qui définit les règles de travail, de sécurité et de
  compatibilité ;
- `PROJECT.md`, qui décrit les objectifs et les domaines fonctionnels ;
- `BUILD.md`, qui décrit exclusivement la construction du paquet Debian.

Il décrit les choix techniques communs, les interfaces entre modules, les
chemins d'exécution, la configuration, l'authentification, la gestion des
erreurs et les contrôles de validation. Les comportements fonctionnels précis
restent définis par les spécifications OpenSpec applicables.

## Références et autorité

L'ordre d'autorité technique et fonctionnelle est celui défini dans
`AGENTS.md`. Pour une évolution fonctionnelle, les fichiers suivants sont les
sources de vérité OpenSpec :

```text
openspec/config.yaml
openspec/changes/
openspec/specs/
```

La configuration OpenSpec utilise le schéma `spec-driven`. Les spécifications
existantes suivent principalement cette structure :

```text
# titre
## Purpose
## Requirements
### Requirement: exigence
#### Scenario: scénario comportemental
```

Les exigences utilisent des termes normatifs (`SHALL`, `MUST`, `DOIT`) et les
scénarios décrivent les cas d'usage sous forme comportementale. Ce document ne
remplace pas ces exigences : il en expose les mécanismes techniques communs.

Toute nouvelle capacité fonctionnelle doit donc être spécifiée et validée dans
OpenSpec avant son implémentation.

## Socle d'exécution

Le DIUE est une application Bash destinée aux versions stables de Debian
prises en charge par le projet.

Les scripts doivent respecter les contraintes suivantes :

- utiliser une ligne d'interpréteur compatible avec Debian ;
- être encodés en UTF-8 avec des fins de ligne Unix LF ;
- privilégier les commandes disponibles dans une installation Debian standard ;
- protéger les expansions de variables par des guillemets lorsque nécessaire ;
- valider les paramètres et les prérequis avant toute mutation ;
- propager tout échec par un code de retour non nul et un diagnostic utile ;
- préserver les comportements existants qui ne sont pas concernés par une
  évolution validée.

Le point d'entrée active le mode strict :

```bash
set -Eeuo pipefail
```

Un module sourcé s'exécute donc dans le même contexte strict. Les commandes
dont l'échec est attendu doivent être placées dans une condition explicite ;
aucune erreur ne doit être ignorée silencieusement.

## Contextes, utilisateurs et chemins

| Élément | Valeur ou convention | Rôle |
|---|---|---|
| Racine de développement | `/home/devops/datas/diu` | Sources, Git, OpenSpec et artefacts de développement |
| Installation de production | `/root/diu` | Application installée et configuration locale |
| Projet géré | `${DEVOPS_PROJECTS_ROOT}/<ID PROJECT>` | Répertoire d'un projet administré par le DIUE |
| Point d'entrée | `root-install-debian.sh` | Bootstrap, aide et dispatch |
| Configuration historique | `/root/diu/variables.sh` | Variables locales conservées pour compatibilité |
| Configuration par domaine | `/root/diu/config/<scope>.env` | Valeurs persistantes du nouveau mécanisme |
| Configuration d'un projet | `<projet>/project.env` | Métadonnées Git et paramètres des fournisseurs distants |

`root-install-debian.sh` calcule `BASH_SCRIPT_PATH` depuis son emplacement
réel. Les bibliothèques et les modules distribués avec l'application sont
ensuite chargés avec des chemins relatifs à cette racine.

Les opérations nécessitant un dépôt de projet ou Git sont normalement
exécutées sous `DEVOPS_USER`, avec `DEVOPS_GROUP` comme groupe associé. Le
script principal vérifie également que l'exécution globale dispose des droits
root lorsque l'opération modifie le système.

## Architecture du code

L'architecture fonctionnelle est organisée par domaines :

```text
root-install-debian.sh       bootstrap, aide et dispatch CLI
lib/                         fonctions génériques réutilisables
modules/diu/                 configuration et mises à jour du DIUE
modules/system/              Debian et dépôts APT
modules/softwares/           moteurs logiciels
modules/projects/            projets, Git, publications et paquet DIU
modules/ia/                  intégration de l'agent Hermès
```

La publication unifiée des artefacts est assurée par
`projects_forgejo_release <ID PROJECT>`. Elle complète au besoin les
variables générales du projet et les variables `REMOTE_FORGEJO_*`, puis
publie les artefacts activés par `PROJECT_DOCKERED` et
`PROJECT_DEBIAN_PACKAGE`.

Le dépôt reste en transition vers cette architecture. Une partie importante
des fonctions historiques est encore présente dans `root-install-debian.sh`.
Les répertoires `modules/desktop/` et `modules/environments/` existent dans
l'arborescence, mais ne fournissent pas actuellement de module spécialisé
chargé par le bootstrap principal. L'architecture cible décrite dans
`PROJECT.md` ne doit pas être interprétée comme l'existence d'implémentations
déjà séparées.

### Ordre de chargement actuel

Après l'aide précoce et le nettoyage de la configuration historique, le point
d'entrée charge `variables.sh`, puis les fonctions communes et les modules
dans l'ordre général suivant :

```text
modules/system/variables-cleanup.sh
/root/diu/variables.sh
lib/logging.sh
lib/docker.sh
lib/forgejo-auth.sh
lib/gitlab-auth.sh
lib/github-auth.sh
modules/ia/hermes.sh
modules/diu/config.sh
modules/diu/update.sh
modules/diu/update-all.sh
modules/system/apt.sh
modules/softwares/*.sh
modules/projects/*.sh
```

Le chargement d'un fichier Bash ne doit pas déclencher d'opération
fonctionnelle imprévisible. Les fichiers déclaratifs de variables constituent
l'exception prévue : leur sourcing initialise immédiatement leur variable.

Le dispatch public est assuré par des fonctions `manage_*_action` et par des
fonctions de domaine. Les commandes historiques `rid proj ...` restent
acceptées par compatibilité avec l'aide et les appels existants.

## Configuration et variables

### Coexistence des deux mécanismes

La migration des variables repose sur la coexistence contrôlée de l'ancien et
du nouveau mécanisme :

```text
/root/diu/variables.sh
        │ valeurs historiques locales
        ▼
/root/diu/config/<scope>.env
        │ valeurs persistées par domaine
        ▼
modules/diu/variables/<scope>/*.sh
        déclarations unitaires et valeurs initiales
```

`variables.sh` est une configuration locale de production. Il n'est pas
embarqué dans le paquet Debian et ne doit pas être remplacé par une mise à
jour applicative. Le détail de l'exclusion du paquet et du staging est défini
dans `BUILD.md`.

### Nettoyage de la variable historique

`modules/system/variables-cleanup.sh` fournit `config_cleanup`.

Le point d'entrée appelle cette fonction avant de sourcer
`/root/diu/variables.sh`. Elle supprime uniquement les affectations simples de
`DEBIAN_RELEASE`, avec `export` facultatif et espaces initiaux éventuels.
Elle conserve les autres variables, commentaires et noms voisins.

La fonction accepte un chemin de fichier optionnel, ce qui permet les tests
isolés. Elle est idempotente : l'absence du fichier ou l'absence de la ligne à
supprimer est un succès sans réécriture. Toute erreur de lecture ou d'écriture
bloque le chargement suivant.

Les consommateurs utilisent `SYSTEM_DEBIAN_RELEASE`. La valeur historique
n'est pas transférée automatiquement.

### Déclarations unitaires

Les fichiers de variables sont placés exactement deux niveaux sous :

```text
modules/diu/variables/<scope>/<variable>.sh
```

`config_generator` les découvre avec `find`, les trie, puis les source un par
un. L'ajout d'une variable ne nécessite donc pas de modifier une liste
centrale.

Une déclaration contient les attributs techniques suivants :

| Attribut | Valeurs | Signification |
|---|---|---|
| `config` | `STATIC`, `DYNAMIC` | Valeur persistante ou calculée |
| `state` | `ENABLE`, `DISABLE` | Variable active ou retirée |
| `scope` | nom en minuscules | Fichier de configuration associé |
| `default_value` | valeur de la variable | Valeur initiale ou de repli déclarée |
| `variable_config_file` | `/root/diu/config/<scope>.env` | Destination persistante |
| `variable_generator` | fonction Bash | Génération d'une valeur dynamique |

Pour une variable `STATIC` active et absente, la valeur par défaut est
exportée puis persistée. Une variable déjà définie, y compris avec une valeur
vide, est conservée.

Pour une variable `DYNAMIC` active et absente, le générateur est appelé et la
valeur est exportée sans persistance automatique. `SYSTEM_DEBIAN_RELEASE` est
le cas dynamique de référence : son générateur lit `VERSION_CODENAME` dans
`/etc/os-release`, normalise en minuscules et refuse une valeur vide ou
invalide.

Une déclaration désactivée retire la variable de l'environnement et supprime
uniquement sa ligne persistante exacte.

### Chargement, tri et mise à jour

`config_load` charge les scopes dans cet ordre :

```text
diu, desktop, devops, docker, environnements,
ia, projects, softwares, system
```

Chaque fichier `.env` est facultatif. Après le chargement des scopes,
`config_generator` initialise les variables absentes puis `config_sort` trie
et déduplique les lignes identiques de chaque fichier `.env`.

`config_update` réapplique le chargement et la génération. Les déclarations
statiques doivent donc rester idempotentes et ne pas écraser une valeur
existante. Une évolution du cycle de génération des variables dynamiques doit
être spécifiée avant modification.

Les fichiers de configuration produits doivent rester sourçables par Bash,
être limités au scope concerné et échouer explicitement si une persistance
requise est impossible.

### Conventions de nommage

- variables globales : majuscules et `_` ;
- variables locales : minuscules et `_` ;
- nouveaux identifiants techniques : anglais ;
- scopes et noms de fichiers de variables : minuscules ;
- fonctions : nom explicite cohérent avec le domaine.

Un identifiant existant suffisamment clair est conservé. Les renommages
purement esthétiques sont exclus du périmètre des évolutions.

## Dépôts Debian et APT

Le module `system` centralise la génération des dépôts officiels Debian et des
dépôts tiers gérés par le DIUE.

### Dépôts Debian officiels

Les cinq variables statiques du dépôt officiel sont dans le scope `system` :

| Variable | Valeur par défaut |
|---|---:|
| `SYSTEM_APT_DEBIAN_UPDATES` | `1` |
| `SYSTEM_APT_DEBIAN_BACKPORT` | `1` |
| `SYSTEM_APT_DEBIAN_CONTRIB` | `1` |
| `SYSTEM_APT_DEBIAN_NONFRFEE` | `1` |
| `SYSTEM_APT_DEBIAN_SOURCES` | `0` |

Le nom `SYSTEM_APT_DEBIAN_NONFRFEE` est conservé tel qu'il existe dans le
code et les spécifications.

`SYSTEM_DEBIAN_RELEASE` est déterminée dynamiquement depuis
`/etc/os-release`. La configuration correspondante utilise :

- le format deb822 dans `debian.sources` pour Debian Trixie et les versions
  ultérieures ;
- le format historique dans `/etc/apt/sources.list` pour Bookworm et les
  versions antérieures.

Les composants `main`, `contrib`, `non-free-firmware` et `non-free` ainsi que
les suites `updates`, `backports` et `security` sont activés selon les
variables du scope `system`. Le trousseau officiel Debian est référencé par
les entrées générées.

### Dépôts tiers

`system_apt_repository_engine` est le moteur commun des dépôts tiers. Il :

1. valide le nom, le type et l'état du dépôt ;
2. télécharge la clé GPG déclarée et la convertit dans
   `/usr/share/keyrings/` ;
3. écrit un fichier `.sources` ou `.list` selon la version Debian ;
4. supprime le format alternatif géré par le DIUE ;
5. retire les fichiers et le trousseau lorsque le dépôt est désactivé.

Les variables persistantes de dépôts tiers sont détectées depuis la
configuration APT existante au premier chargement. Elles couvrent notamment
CrowdSec, Docker, LemonLDAP, MongoDB, NodeSource, NVIDIA, Proxmox, VS Code,
Wazuh, Webmin et les dépôts OpenAI/ChatGPT.

Les fichiers tiers non gérés par le DIUE sont préservés. La régénération ne
doit pas introduire implicitement une source étrangère dans la résolution des
paquets Debian officiels.

### Mise à jour du système

`system_apt_update` régénère la configuration, actualise les index APT,
exécute la transaction globale de mise à niveau, puis effectue le nettoyage
APT prévu et installe les prérequis manquants.

Les prérequis obligatoires sont traités sans sortie s'ils sont déjà installés,
et dans l'ordre alphabétique lorsqu'ils manquent :

```text
aptitude apache2-utils apt-transport-https bash-completion
bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg gpg
inetutils-telnet iptables jq libsecret-tools lshw lsb-release man-db manpages-fr
net-tools netcat-traditional nicstat openssl pciutils python3-pytest ripgrep
shellcheck sudo tcpdump traceroute tree util-linux wget
```

Les fonctions publiques de gestion des dépôts valident leur identifiant,
persistent les variables du scope `system`, puis régénèrent la configuration.

## Moteurs logiciels

Le routage logiciel passe par `manage_software_action` pour les commandes
génériques et par `manage_softwares_action` pour les commandes modulaires.
Trois moteurs sont reconnus : `deb`, `apt` et `github`.

Les identifiants logiciels sont validés avant routage. Une recette doit être
déclarée explicitement par le moteur ; le nom fourni par l'utilisateur ne doit
jamais devenir directement un nom de fonction ou une commande shell.

### Moteur `deb`

`modules/softwares/deb.sh` gère les paquets Debian officiels.

Chaque opération :

- vérifie les commandes et le trousseau Debian requis ;
- construit un répertoire temporaire d'index ;
- extrait des métadonnées uniquement les origines Debian de la release
  installée, de `updates` et de `security` ;
- utilise des options APT isolées (`sourceparts=-`, listes et caches
  temporaires) ;
- actualise les index avec le trousseau officiel et refuse les sources
  non authentifiées ;
- simule la transaction et contrôle aussi les dépendances qu'elle ajoute ou
  retire avant toute mutation.

Les fichiers de configuration APT persistants ne sont pas modifiés par ce
moteur. Une version installée dont l'origine officielle ne peut pas être
vérifiée est refusée.

Les opérations globales ciblent uniquement les paquets Debian officiels
installés. Une mise à jour ciblée n'installe pas un paquet absent et une
opération répétée ne réinstalle pas inutilement un paquet déjà dans l'état
attendu.

### Moteur `apt`

Le moteur `apt` utilise une table de recettes explicite. La recette actuelle
est `chatgpt` :

- l'installation prépare d'abord le dépôt OpenAI/ChatGPT via le moteur
  `system` si nécessaire, puis installe le paquet ;
- la désinstallation retire le paquet, le dépôt associé et met à jour l'état
  persistant ;
- la mise à jour vérifie que le logiciel est installé ;
- la mise à jour globale combine l'actualisation APT et les recettes des
  logiciels tiers reconnus.

Un logiciel sans recette échoue explicitement sans appeler APT.

`SOFTWARES_APT_CHATGPT` représente l'état persistant de l'intégration dans le
scope `softwares`. Les anciennes variables de personnalisation de profil non
prévues par la spécification ne doivent pas être recréées.

### Moteur `github`

La recette actuelle est `codex-cli`. Elle :

- accepte uniquement Linux x86_64 ;
- interroge la dernière release du dépôt GitHub `openai/codex` ;
- vérifie le tag attendu, l'archive et son digest SHA-256 ;
- installe la version validée sous `/usr/local/lib/codex` par défaut ;
- expose le binaire via `/usr/local/bin/codex` par défaut ;
- conserve le profil utilisateur lors d'une désinstallation ;
- persiste son état dans `SOFTWARES_APT_CODEX_CLI` du scope `softwares`.

La recette ne modifie pas `HOME` pour simuler un profil différent. Toute
nouvelle recette doit suivre le même registre explicite et rester idempotente.

## Projets et configuration Git

### Métadonnées générales

Un projet géré est identifié par son répertoire sous
`${DEVOPS_PROJECTS_ROOT}` et par son fichier `project.env`.

Les variables générales obligatoires sont :

```text
PROJECT_ID
PROJECT_NAME
PROJECT_TYPE
PROJECT_DOCKERED
```

La configuration Git locale comprend la branche locale par défaut et
l'identité Git. `git_update` est responsable exclusivement de
`LOCAL_DEFAULT_BRANCH`, `GIT_USER_NAME` et `GIT_USER_EMAIL`. La configuration
générale du projet relève de `update_projects` ; les parcours de clonage
utilisent leur configuration interne dédiée.

Les configurations de fournisseurs sont différentielles. Chaque fonction
`<provider>_update` valide d'abord les variables générales, puis ne modifie que
son propre bloc dans `project.env`. L'écriture passe par un fichier temporaire
et un remplacement atomique ; le fichier final reste propriété de
`DEVOPS_USER:DEVOPS_GROUP` avec le mode `660`.

### Variables des fournisseurs distants

| Fournisseur | Variables principales | Défaut notable |
|---|---|---|
| Forgejo | `REMOTE_FORGEJO_BASE_URL`, `REMOTE_FORGEJO_OWNER`, `REMOTE_FORGEJO_REPOSITORY`, `REMOTE_FORGEJO_NAME`, `REMOTE_FORGEJO_BRANCH`, `REMOTE_FORGEJO_SSL_VERIFY` | dépôt = identifiant, remote = `origin`, branche = `main`, TLS = `No` |
| GitLab | `REMOTE_GITLAB_BASE_URL`, `REMOTE_GITLAB_OWNER`, `REMOTE_GITLAB_REPOSITORY`, `REMOTE_GITLAB_NAME`, `REMOTE_GITLAB_BRANCH`, `REMOTE_GITLAB_SSL_VERIFY` | dépôt = identifiant, remote = `origin`, branche = `main`, TLS = `No` |
| GitHub | `REMOTE_GITHUB_BASE_URL`, `REMOTE_GITHUB_OWNER`, `REMOTE_GITHUB_REPOSITORY`, `REMOTE_GITHUB_NAME`, `REMOTE_GITHUB_BRANCH` | dépôt = identifiant, remote = `origin`, branche = `main` |

Les URL configurées ne contiennent pas d'identifiants. Elles servent à
construire un remote HTTPS de la forme :

```text
https://<hôte>/<propriétaire>/<dépôt>.git
```

Avant un push, le remote demandé est vérifié ou créé par la fonction dédiée
au fournisseur. Un remote absent est ajouté ; un remote existant dont l'URL
ne correspond pas à `project.env` provoque un échec explicite et n'est pas
écrasé.

Le remote configuré pour GitLab ou GitHub peut donc être différent de
`origin`. Un push fournisseur ne doit pas modifier le remote d'un autre
fournisseur.

### TLS fournisseur

`REMOTE_FORGEJO_SSL_VERIFY` et `REMOTE_GITLAB_SSL_VERIFY` acceptent `Yes` ou
`No` après normalisation.

Une valeur `No` désactive la vérification TLS uniquement dans l'opération
authentifiée du fournisseur concerné, via un sous-shell ou une option locale.
Elle ne modifie pas la configuration TLS globale de Git ni celle des autres
fournisseurs. Toute autre valeur est refusée.

## Authentification distante

### Cœur Git authentifié

`git_with_token`, situé dans `modules/projects/git.sh`, est le cœur commun aux
fournisseurs. Il est agnostique de Forgejo, GitLab et GitHub.

Son mécanisme est le suivant :

1. valider le chemin, le nom d'utilisateur, le token et les arguments Git ;
2. créer un répertoire temporaire de mode `700` ;
3. créer un fichier credentials de mode `600` ;
4. fournir à Git un script `GIT_ASKPASS` temporaire ne contenant pas le token ;
5. exécuter Git sous `DEVOPS_USER` avec `GIT_TERMINAL_PROMPT=0` ;
6. supprimer systématiquement les ressources temporaires par `trap`.

Le token n'est ni placé dans les arguments de Git, ni exposé par une invite
interactive. Toute erreur d'authentification est bloquante : aucun fallback
silencieux vers une saisie Username/Password n'est autorisé.

### Fichiers d'identifiants

Les fournisseurs utilisent les fichiers locaux suivants dans le projet :

```text
<projet>/config/forgejo.username
<projet>/config/forgejo.token
<projet>/config/gitlab.username
<projet>/config/gitlab.token
<projet>/config/github.username
<projet>/config/github.token
```

Le répertoire de configuration est créé avec le mode `700` lorsque nécessaire.
Chaque fichier d'identifiant doit être non vide et avoir exactement le mode
`600`. Les fichiers sont créés via un fichier temporaire puis installés avec
les droits de `DEVOPS_USER:DEVOPS_GROUP`.

Les modules `lib/forgejo-auth.sh`, `lib/gitlab-auth.sh` et
`lib/github-auth.sh` résolvent le remote HTTPS, vérifient les identifiants et
délèguent les opérations Git au cœur commun. Le token ne doit apparaître ni
dans les journaux, ni dans les diagnostics, ni dans les URL.

Forgejo dispose en plus de fonctions API authentifiées pour les opérations de
release. Ces appels utilisent eux aussi une configuration `curl` temporaire,
protégée et supprimée après usage.

## Publication et mise à jour du DIUE

La publication de projets est routée par `git_push_provider` vers Forgejo,
GitLab ou GitHub. Les fonctions publiques restent dédiées :

```text
forgejo_push <PROJECT_ID>
gitlab_push  <PROJECT_ID>
github_push  <PROJECT_ID>
```

La publication vérifie le projet, `project.env`, le remote attendu, la branche
et les identifiants avant de pousser. Les aides CLI doivent rester cohérentes
avec les commandes `rid projects <provider> update|push`.

La release du paquet DIU vers Forgejo est un parcours distinct. Il vérifie le
paquet présent dans `dist/`, ses métadonnées et l'état Git, puis utilise l'API
Forgejo pour créer ou alimenter une release sans remplacer une release
existante. Les détails du build du paquet restent dans `BUILD.md`.

`update_diu` consulte publiquement la dernière release Forgejo du paquet DIU,
compare les versions Debian, télécharge l'artefact attendu, vérifie son nom et
sa version, puis l'installe avec `dpkg`. Ce parcours public n'utilise pas les
identifiants Forgejo/Git.

## Orchestration des mises à jour

`rid update` est routé par `manage_update_action` vers `update_all` lorsqu'il
n'a pas d'argument. `rid update diu` reste limité à la mise à jour du DIUE.
Une commande avec moteur explicite reste limitée à ce moteur.

L'orchestrateur global traite les participants explicitement déclarés :

```text
softwares/apt
softwares/github
ia/hermes si configuré et installé
modules sans sous-fonction applicable
diu
```

Les modules sans opération disponible sont signalés comme non applicables ;
ils ne sont pas présentés comme mis à jour. Une opération commune ne doit pas
être exécutée deux fois dans le même parcours.

Chaque participant est isolé dans un sous-shell strict lorsque cela est
nécessaire. Le résultat global est non nul dès qu'une opération requise échoue
ou reste bloquée. Le bilan final ne doit pas annoncer un succès global dans ce
cas.

La mise à jour du DIUE peut remplacer son processus par `dpkg --install`.
L'appel est confiné au sous-processus utilisé par `update_all` afin que
l'orchestrateur conserve la capacité de produire le bilan global.

## Journalisation et diagnostics

`lib/logging.sh` fournit les fonctions communes :

| Fonction | Sortie |
|---|---|
| `print_title` | séparateur, titre et lignes vides sur stdout |
| `print_info` | préfixe `ℹ️` et message sur stdout |
| `print_success` | préfixe `✅` et message sur stdout |
| `print_error` | préfixe `❌` et message sur stderr |

Les appelants historiques doivent conserver le même comportement après toute
évolution de cette bibliothèque. Les diagnostics doivent identifier l'étape,
le composant et la cause utile sans afficher de secret, de token ou de contenu
de fichier sensible.

## Sécurité et idempotence

Toute fonction qui écrit dans le système doit :

- limiter ses écritures à son domaine ;
- valider les entrées avant de construire un chemin ou une commande ;
- utiliser des fichiers temporaires protégés pour les données sensibles ;
- nettoyer les ressources temporaires en cas de succès comme d'échec ;
- éviter les mutations partielles lorsque cela est raisonnablement possible ;
- rendre une seconde exécution sans effet indésirable.

Les secrets restent dans les fichiers locaux exclus du versionnement. Ils ne
doivent être ni lus à des fins documentaires, ni inscrits dans les sources,
les spécifications ou les journaux.

Les opérations nécessitant root doivent rester explicites. Les opérations Git
sur les projets sont exécutées sous `DEVOPS_USER` afin de préserver le
propriétaire et l'environnement du dépôt.

## Validation technique

Les tests isolés actuellement présents couvrent :

```text
tests/test_config_cleanup.py
tests/test_software.py
tests/test_system_apt.py
tests/test_system_debian_release.py
```

Pour toute modification Bash, exécuter au minimum :

```bash
bash -n <fichier>
shellcheck <fichier>
```

Puis exécuter les tests concernés, par exemple :

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
```

Les vérifications doivent couvrir, lorsque pertinent :

- la syntaxe Bash et ShellCheck ;
- les chemins et utilisateurs attendus ;
- les cas d'échec et les codes de retour ;
- l'idempotence ;
- l'absence de mutation APT ou Git non autorisée ;
- la non-exposition des identifiants ;
- la conformité aux exigences OpenSpec ;
- l'absence de modification hors périmètre.

Les opérations OpenSpec du projet sont exécutées depuis la racine du projet,
sous l'utilisateur `DEVOPS_USER`. Les commandes de validation strictes
exposées par le DIUE sont notamment :

```bash
openspec validate <nom> --type change --strict
openspec validate <nom> --type spec --strict
```

Une vérification réussie ne doit être annoncée qu'après exécution effective
de la commande correspondante.

## Compatibilité et évolutions

La migration vers les modules spécialisés doit rester progressive. En
particulier :

- `root-install-debian.sh` reste le point d'entrée compatible ;
- `variables.sh` reste une configuration locale non embarquée ;
- `SYSTEM_DEBIAN_RELEASE` remplace progressivement `DEBIAN_RELEASE` ;
- les configurations Forgejo, GitLab et GitHub restent séparées dans
  `project.env` ;
- les remotes existants ne sont jamais écrasés lorsqu'ils sont incohérents ;
- une nouvelle recette logicielle doit être explicitement enregistrée et
  testée ;
- un déplacement, un renommage, une suppression ou une modification de
  convention nécessite l'autorisation prévue par `AGENTS.md`.

Toute évolution doit être minimale, réversible lorsque possible et limitée
aux fichiers nécessaires. Les fonctionnalités non documentées par une
spécification OpenSpec validée ne doivent pas être introduites par ce seul
document.
