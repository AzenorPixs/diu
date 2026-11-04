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

Dans le bloc Node.js DevOps, le téléchargement de l'index officiel des versions
est séparé de leur sélection. Curl conserve la vérification TLS et utilise
`--connect-timeout 10 --max-time 60`. Un échec conserve le diagnostic curl,
affiche sur stderr un seul diagnostic DIU avec Node.js, l'URL et le code curl,
puis quitte avec ce code avant toute mutation du bloc Node.js. Il ne déclenche
pas de rapport ERR générique supplémentaire et n'annule pas les étapes
antérieures. La sélection de la dernière version de `NODEJS_SERIES` et le
diagnostic de série absente sont conservés. La spécification de référence est
`openspec/specs/devops-nodejs-download/spec.md`.

Lorsque `OPENCODE=1`, le bloc DevOps recherche sur les pages des releases
GitHub la dernière version stable OpenCode V2. Les tags préliminaires et les
autres versions majeures sont exclus. Curl conserve TLS et est borné à 10
secondes de connexion et 60 secondes de transfert. Une version installée
valide est comparée numériquement ; l'installateur officiel
`https://opencode.ai/v2/install` reçoit la version exacte avec `--version` et
`--no-modify-path` uniquement si le binaire est absent ou plus ancien. Une
version égale ou supérieure est conservée. Une erreur réseau, une release V2
absente ou une version locale illisible bloque l'installation avec un
diagnostic explicite. La référence est
`openspec/specs/devops-opencode/spec.md`.

## Contextes, utilisateurs et chemins

| Élément | Valeur ou convention | Rôle |
|---|---|---|
| Racine de développement | `/home/devops/datas/diu` | Sources, Git, OpenSpec et artefacts de développement |
| Installation de production | `/root/diu` | Application installée et configuration locale |
| Projet géré | `${ENV_DEVOPS_PROJECTS_ROOT}/<ID PROJECT>` | Répertoire d'un projet administré par le DIUE |
| Point d'entrée | `root-install-debian.sh` | Bootstrap, aide et dispatch |
| Configuration historique | `/root/diu/variables.sh` | Variables locales conservées pour compatibilité |
| Configuration par domaine | `/root/diu/config/<scope>.env` | Valeurs persistantes du nouveau mécanisme |
| Configuration d'un projet | `<projet>/project.env` | Métadonnées Git et paramètres des fournisseurs distants |

`root-install-debian.sh` calcule `BASH_SCRIPT_PATH` depuis son emplacement
réel. Les bibliothèques et les modules distribués avec l'application sont
ensuite chargés avec des chemins relatifs à cette racine. Le constructeur historique fournit un script de configuration qui crée
`/usr/local/bin/diu` vers le point d'entrée installé si le nom est libre ; le
constructeur générique ne le fournit pas. Le script installé vérifie ce nom à chaque démarrage en root, avant l’aide, et
crée le lien si le nom est libre. Après chargement de la configuration et vérification des droits, DIU crée
`/usr/local/bin/diut` vers `${ENV_DEVOPS_PROJECTS_ROOT}/diu/root-install-debian.sh`
si ce fichier existe et si le nom est libre. Toute entrée existante, même un
lien pendant, est conservée ; une erreur de création est signalée. Les alias
`rid` et `ridt` restent disponibles pendant la transition.

Les opérations nécessitant un dépôt de projet ou Git sont normalement
exécutées sous `ENV_DEVOPS_USER`, avec `DEVOPS_GROUP` comme groupe associé. Le
script principal vérifie également que l'exécution globale dispose des droits
root lorsque l'opération modifie le système.

Le provisionnement des comptes techniques DevOps, Docker et IA ne définit
pas de mot de passe et conserve celui des comptes existants. Les commandes
exécutées par root sous ces identités ne nécessitent pas leur mot de passe.

### Accès sudo sans mot de passe au compte DevOps

À la fin du bloc `ENVIRONMENTS_DEVOPS=1`, `configure_devops_sudoers` génère
`/etc/sudoers.d/99-diu-devops` si `ENV_DEVOPS_USER` existe. Chaque compte humain
retenu reçoit `compte ALL=(ENV_DEVOPS_USER) NOPASSWD: ALL`, avec les noms réels,
pour utiliser `sudo -u` ou `sudo -iu` sans mot de passe.

La sélection repose sur les comptes locaux de `/etc/passwd`, dans la plage
`UID_MIN`–`UID_MAX` de `/etc/login.defs`, avec un shell existant et exécutable.
Elle exclut `root`, les shells vides, `nologin` et `false`, ainsi que les
comptes configurés `ENV_DEVOPS_USER`, `ENV_DOCKER_USER` et `ENV_IA_USER`.
C'est une convention : un autre compte technique doté d'un UID ordinaire et
d'un shell de connexion peut satisfaire ces critères.

Le candidat caché est contrôlé avec `visudo -cf`, reçoit `root:root` et `0440`,
puis remplace atomiquement le fragment géré. Un échec préalable préserve le
fragment précédent et provoque un diagnostic et un retour non nul. Une
sélection vide produit un fichier commenté sans règle ; les réexécutions ne
créent aucun doublon. Les autres fragments sudoers et PAM ne sont pas modifiés.
Un bloc désactivé ou un compte DevOps absent ne révoque pas de règles existantes.
Une règle sudoers ultérieure contradictoire peut influer sur l'accès effectif.
Les noms contenant des caractères de syntaxe sudoers, tels que virgules ou
espaces, provoquent une erreur sans remplacement : la génération accepte des
noms commençant par un caractère alphanumérique ou underscore, puis composés de
caractères alphanumériques, underscores, points ou tirets, avec dollar final
facultatif.

Après publication réussie, le compte rendu affiche les comptes réellement
autorisés, séparés par un espace, par exemple
`Sudoers DevOps configuré pour alice bob.`. Une sélection vide affiche
`Sudoers DevOps : aucun compte humain retenu.` après publication du fragment
commenté. Un échec ou un compte cible absent ne produit aucun message de succès.

### Accès sudo sans mot de passe au compte Docker

À la fin de la branche active du bloc `ENVIRONMENT_DOCKER=1`, avant son `else` de
désactivation, `configure_docker_sudoers` génère
`/etc/sudoers.d/99-diu-docker` si `ENV_DOCKER_USER` existe. Chaque compte humain
retenu reçoit `compte ALL=(ENV_DOCKER_USER) NOPASSWD: ALL`, avec les noms réels.
La sélection UID/shell, les exclusions et les contrôles de publication sont
identiques à ceux décrits pour DevOps, y compris l'exclusion des comptes
configurés DevOps, Docker et IA. Un bloc désactivé ou un compte absent ne
révoque pas de règles déjà installées.

Le propriétaire des stacks Docker est déclaré dans le scope `docker` sous le
nom `ENVIRONMENT_DOCKER_USER`, en `STATIC`, `ENABLE`, défaut `docker`.
L'ancienne valeur littérale `DOCKER_USER` est migrée exactement vers
`docker.env`; une valeur nouvelle existante garde la priorité. Les références
aux chemins et données des stacks utilisent le nouveau nom.

Les deux fonctions utilisent `configure_environment_sudoers`, limité aux
scopes fixes `devops` et `docker`. Chaque scope possède son candidat caché et
son fragment indépendant ; une génération ne remplace pas celui de l'autre
environnement. Le fragment Docker reçoit `root:root` et `0440` après validation
`visudo -cf`, puis publication atomique. Les autres fragments et PAM restent
inchangés ; la politique globale peut influer sur les accès effectifs.
Le compte rendu suit le même format : `Sudoers Docker configuré pour alice bob.`
ou `Sudoers Docker : aucun compte humain retenu.` en cas de sélection vide.

### Dépendance Python DevOps

Psycopg relève des dépendances des projets, déclarées notamment dans leur
`pyproject.toml`. Sa gestion par le DIU est temporairement désactivée : le
bloc `ENVIRONMENTS_DEVOPS=1` et `PYTHON=1` conserve en commentaires l'installation,
la mise à jour, la lecture de version, le contrôle d'import et les messages
Psycopg. La préparation de Python, pip, leurs liens, le profil Python et la
gestion des droits DevOps restent inchangés. L'absence de Psycopg ou un import
inutilisable ne bloque plus ce bloc.

Le lancement OpenCode en écriture (`launch_ocrw`) conserve aussi l'ancienne
commande d'installation Psycopg en commentaire, hors de la chaîne exécutée.
Les autres outils du conteneur, les montages et le lancement par `setpriv`
restent inchangés. Chaque projet doit fournir Psycopg lorsqu'il en a besoin.
Le DIU ne désinstalle aucun paquet Psycopg déjà présent ; il n'effectue plus
de mise à jour spécifique à ce paquet. Le mécanisme existant de remplacement
du préfixe Python reste applicable. La spécification de référence est
`openspec/specs/devops-python/spec.md`.

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
Les répertoires `modules/desktop/` et `modules/environments/` fournissent
leurs points d’entrée d’information ; `environments` fournit également son
module de mise à jour. L'architecture cible décrite dans
`PROJECT.md` ne doit pas être interprétée comme l'existence d'implémentations
déjà séparées.

### Commandes OpenSpec du domicile DevOps

À la fin du bloc `OPENSPEC=1`, après la vérification du binaire, le monolithe
prépare OpenSpec dans `/home/${ENV_DEVOPS_USER}` via
`su - "$ENV_DEVOPS_USER" -c`. Le shell de connexion rejoint ce domicile et
ajoute les chemins Node et npm DevOps à PATH. Si le dossier `openspec/` existe,
il exécute `openspec update`, indépendamment de `OPENCODE`. Sinon, il exécute
`openspec init --tools opencode --profile custom` pour `OPENCODE=1` ou
`openspec init --profile custom` pour `OPENCODE=0`.

Une valeur OpenCode absente ou invalide empêche l'initialisation. Un échec de
changement de répertoire, de su ou d'OpenSpec provoque un diagnostic et un
arrêt non nul avant la suite du DIU, sans message de réussite de cette étape
ni suppression des écritures partielles. Un bloc désactivé ne prépare pas
le domicile. Ce traitement est indépendant des templates de projets.
La spécification de référence est
`openspec/specs/devops-home-openspec/spec.md`.

### Template OpenSpec des projets

`rid projects template openspec <ID PROJECT>` prépare OpenSpec dans
`${ENV_DEVOPS_PROJECTS_ROOT}/<ID PROJECT>` (à défaut,
`/home/${ENV_DEVOPS_USER}/datas/<ID PROJECT>`). La fonction
`projects_template_openspec`, dans `modules/projects/template.sh`, utilise
`su - "$ENV_DEVOPS_USER" -c` et le shell de connexion pour exécuter :

- `openspec init --tools opencode --profile custom` si le dossier `openspec/`
  est absent, le dossier `.opencode/` est présent et `OPENCODE=1` ;
- `openspec init --profile custom` si `openspec/` est absent et `OPENCODE=0`,
  ou si le dossier `.opencode/` est absent, quelle que soit `OPENCODE` ;
- `openspec update` si le dossier `openspec/` existe, y compris après copie du modèle.

La valeur OpenCode effective est locale au projet : sans dossier `.opencode/`,
elle vaut 0 sans modifier la variable configurée pour les projets suivants.
Un fichier ordinaire nommé `.opencode` ne compte pas comme dossier.

`rid projects template openspec all` appelle `projects_template_openspec_all`
pour tous les projets configurés, avec la même sélection que DevOps all :
dossiers directs et cachés dont `project.env` ordinaire contient les cinq
affectations littérales non vides `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`,
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE`, avec un identifiant conforme au
nom du dossier. La sélection réutilise le contrôle DevOps sans exécuter le
fichier ni afficher ses valeurs ; les chemins symboliques et configurations
invalides sont ignorés. La fonction traite chaque projet via la fonction
individuelle, poursuit après échec et affiche les nombres sélectionnés,
réussis, ignorés et échoués. Elle rend un code non nul si une opération échoue,
et un succès avec bilan si aucun projet n'est éligible. `all` est désormais
réservé à ce traitement dans la CLI ; un dossier nommé `all` reste éligible
et est traité directement par la boucle, sans récursion.

L'ancienne syntaxe `rid projects template <ID PROJECT> openspec` est rejetée
lorsqu'elle ne correspond pas déjà à une commande valide avec sélecteur
`openspec` ou `devops`.
Le sélecteur `openspec` après `template` est prioritaire :
`rid projects template openspec devops` vise OpenSpec pour le projet `devops`.
La génération DevOps utilise `rid projects template devops <ID PROJECT>` ou
`rid projects template devops all` pour tous les projets configurés. Les anciens
ordres sont rejetés lorsqu'ils ne correspondent pas déjà à une commande valide.
Les chemins invalides, les dossiers symboliques, les utilisateurs absents et les valeurs
OPENCODE autres que 0 ou 1 lors d'une initialisation avec un dossier `.opencode/`
provoquent un échec.
La fonction individuelle ne lit pas `project.env`. Un outil absent ou en échec est signalé
avec un code non nul ; ses éventuelles écritures partielles sont conservées.

`rid projects create <ID PROJECT>` appelle cette préparation après la copie,
la personnalisation et l'attribution des droits, puis génère `DEVOPS.md`.
Un échec OpenSpec empêche la génération DevOps et le message de succès, en
conservant le projet préparé. La capacité de référence est
`openspec/specs/projects-template-openspec/spec.md`.

### Traçabilité du document DevOps

Avant les inventaires de dépendances et les sondes, le rendu commun prépare
les sept exécutables du domicile `/home/${ENV_DEVOPS_USER}` : Go, Node, npm,
OpenCode, OpenSpec, Python et pip. Seuls les chemins connus de ces outils sont
traités, sans parcours récursif. Les cibles ordinaires, y compris celles
atteintes par les liens internes `current`, npm ou OpenSpec, sont résolues
et confinées au domicile canonique. Les seuls bits `ugo+x` manquants sont
ajoutés ; propriétaire et droits de lecture et d'écriture sont conservés.
Les fichiers déjà dotés des trois bits d'exécution restent inchangés.

Un outil absent reste indisponible sans installation. Une cible externe ou
non ordinaire, une résolution impossible ou un échec de préparation des
droits bloque le rendu et conserve le `DEVOPS.md` existant. Les droits déjà
corrigés restent appliqués si une étape suivante échoue ; une réexécution
reprend sur l'état constaté. Les outils hôte et les autres fichiers du
domicile ne sont pas modifiés. Les sondes directes distinguent un binaire
absent d'un binaire présent non exécutable sans modifier elles-mêmes ses
droits. Les sondes restent exécutées sous le compte et avec les interpréteurs
déjà prévus, avec leur borne de 15 secondes. Cette préparation s'applique aux
parcours individuel, groupé et final de création.

`projects_template_devops_render` produit la version documentaire `0.7`.
La rubrique OpenCode ajoute immédiatement après le chemin du binaire la puce
« La variable OPENCODE_PASSWORD pour l'API est chargée depuis project.env »,
avant les dépendances OpenCode éventuelles. Cette indication est statique :
elle ne lit pas la variable ni le fichier pour cet ajout et ne prouve pas
que le mot de passe est défini ou que l'API est accessible. Les parcours
individuel, groupé et de création partagent ce rendu ; les documents existants
l'adoptent à leur prochaine génération normale.

Après le titre et la version, le document identifie DIU comme générateur,
indique le début du relevé en UTC au format `YYYY-MM-DDTHH:MM:SSZ` et publie
la classification fournie par `SYSTEM_DEBIAN_ENVIRONNEMENT`.

La rubrique « Système d'exploitation » contient le nom de l'OS puis, en
deuxième puce, le résultat de `hostname -f` dans le contexte d'exécution DIU.
Cette commande système est appelée une seule fois par rendu, avec une borne
de 15 secondes. Le helper accepte une ligne de 1 à 253 caractères ASCII
alphanumériques, points ou tirets, commençant par un caractère alphanumérique ;
un nom court retourné par la commande reste inchangé, sans suffixe inventé.
Une commande absente, échouée ou expirée, ou une sortie invalide, produit un
diagnostic explicite en deuxième puce et n'empêche pas les autres rubriques.
Ni la sortie rejetée ni stderr ne sont publiés. Aucun nom de machine n'est
codé en dur et aucune configuration du nom d'hôte ou du réseau n'est modifiée.

La capture utilise une seule fois le binaire `date` hôte, avant les sondes,
avec `-u` et une borne de 15 secondes. Une commande absente, échouée, expirée
ou une sortie mal formée bloque la préparation et conserve le document
existant. Ce début ne certifie ni la synchronisation de l'horloge ni la
simultanéité des observations. Le comportement du manifeste Python
conditionnel déjà préparé reste inchangé.

Les classifications admises sont `DOCKER`, `LXC`, `PHYSICAL`, `PROXMOX`, `VM`
et `UNSET`. Une variable absente, vide ou inconnue est rendue comme `UNSET`
sans reproduire sa valeur. La génération réutilise la classification de DIU
sans relancer son détecteur ni interpréter `PROJECT_DOCKERED`.

La légende distingue les sondes système, l'outillage du compte DevOps et les
déclarations et observations des dépendances Python et JavaScript. Les
dépendances Python d’exécution proviennent uniquement de
`[project].dependencies` dans `pyproject.toml` et sont recherchées d'abord
dans les venv du projet, puis avec le Python DevOps en repli explicite.
L'inventaire ne vaut ni qualification fonctionnelle, ni validation d'un
environnement Python unique, ni preuve de réussite des tests du projet.

Les parcours individuel, groupé et final de création produisent cet en-tête
une seule fois. Le titre, l'ordre relatif des rubriques existantes, les sondes,
les droits et le propriétaire sont conservés. À observations identiques, le contenu technique
reste identique hors horodatage. Les anciens documents prennent le format
`0.7` lors de leur prochaine génération normale ; aucune migration ni retouche
manuelle n'est nécessaire. La référence est
`openspec/specs/projects-template-devops/spec.md`.

La rubrique « Conteneur Docker, pour tests nécessitant des droits root » est
générée uniquement si `ENV_DEVOPS_TESTS_DOCKER` vaut exactement `1`. Elle contient,
dans cet ordre, la version détectée, le chemin du binaire,
`/var/run/docker.sock` et `debian:stable-slim`. Ces deux références sont
des références documentaires fixes, conservées même lorsque Docker est
indisponible ; les diagnostics de version et de binaire restent explicites.
Un indicateur absent, vide ou différent de `1` omet la rubrique et sa sonde Docker.
Le générateur ne vérifie ni la présence ni l'accès au socket ou à l'image,
ne télécharge ni ne lance de conteneur et ne modifie aucune permission.
Le tag `debian:stable-slim` suit Debian stable sans figer une version ou un
digest. La puce fixe Accès TPM OK suit l'image et précède l'autorisation
commune ; elle décrit le contexte de test configuré, sans détection dynamique
ni qualification d'un autre hôte. Docker-Compose et les autres rubriques et
sondes restent indépendants.

La rubrique « Conteneur LXC, pour tests nécessitant des droits root accessible en SSH » est générée
uniquement si `ENV_DEVOPS_TESTS_LXC` vaut exactement `1`, indépendamment de Docker.
Elle suit Docker lorsqu'il est présent, sinon Matériel, et précède OpenSSH & SSHPASS, puis Docker-Compose.
Ses trois premières puces sont fixes : « Variables d'accès disponible dans project.env pour l'accès SSH »,
« Debian 13 », « Accès TPM OK ». Ces mentions sont déclaratives : le générateur
ne lit pas d'identifiants LXC, ne se connecte pas au conteneur et ne qualifie pas
son TPM. Une valeur absente, vide ou différente de `1` omet cette rubrique.
Les trois parcours de génération partagent ce rendu au format `0.7`.

Chaque rubrique de conteneur activée contient la même puce d'autorisation :
« Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests. »
Docker contient six puces et LXC cinq. L’autorisation est la dernière pour
Docker et la quatrième pour LXC. LXC se termine par la puce exacte :
« Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests. »
La fonction commune `projects_template_devops_test_authorization` émet l’autorisation.
Un échec d’écriture de l’autorisation ou de la dernière puce LXC est propagé
et conserve le document existant. Aucune autorisation
orpheline n'est émise pour une rubrique omise. Cette génération reste documentaire :
elle ne modifie pas les contrôles de permissions imposés par les outils ou
plateformes et ne lance aucune opération réelle dans les conteneurs.

La rubrique permanente « OpenSSH & SSHPASS » suit LXC lorsqu’il est présent,
sinon le dernier bloc précédent, et précède Docker-Compose. Ses quatre puces
indiquent la version OpenSSH, le chemin hôte de `ssh`, la version sshpass et
le chemin hôte de `sshpass`. Les versions proviennent de `ssh -V` (y compris
sa sortie sur stderr) et `sshpass -V`, avec une borne de 15 secondes par outil.
Seul le numéro de version est publié ; absences, échecs, expirations et sorties
non reconnues sont signalés explicitement. Aucune connexion, lecture
d’identifiants, installation ou modification des droits de ces outils n’est
réalisée. Cette rubrique est indépendante des indicateurs Docker/LXC et
commune aux trois parcours, au format documentaire `0.7`. Les documents existants
l’adoptent à leur prochaine génération normale.

La rubrique « Prompts », après le gestionnaire de paquets Python et l’éventuelle
rubrique « Python - Outils de compilation », et avant les
tests navigateurs, indique le dossier `/home/${ENV_DEVOPS_USER}/datas/prompts`
et son index `/home/${ENV_DEVOPS_USER}/datas/prompts/INDEX.md`. Ces chemins
réutilisent le domicile DevOps construit depuis `ENV_DEVOPS_USER`, indépendamment
de `ENV_DEVOPS_PROJECTS_ROOT`. La rubrique ne lit, ne sonde ni ne crée ces ressources ;
leur absence n'empêche pas la génération.

### Matériel TPM dans le document DevOps

Après « Système d'exploitation », chaque rendu ajoute « Matériel », puis
« TPM ». Ses six puces sont Chemin, Version, Fabricant, Identifiant
fournisseur, Révision de spécification et Registres PCR, dans cet ordre.
La version documentaire reste `0.7`. Le relevé concerne uniquement le
matériel visible dans le contexte d'exécution DIU.

Le premier périphérique caractère `/dev/tpmrmN` est préféré aux `/dev/tpmN`,
avec ordre lexical C dans chaque famille et `/dev/tpmrm0` prioritaire.
Le même indice désigne `/sys/class/tpm/tpmN/tpm_version_major` : 1 donne
TPM 1.2 et 2 donne TPM 2.0. Un TPM 1.2 conserve chemin et version ; les
autres champs explicitent la limite de la sonde TPM 2.

Si le périphérique est accessible et `tpm2_getcap` déjà présent, deux requêtes
locales utilisent explicitement `-T device:<chemin>` : `properties-fixed`
et `pcrs`. Chacune a une borne de 5 secondes, avec terminaison forcée après
une seconde supplémentaire. La famille peut compléter une version sysfs
indisponible. Fabricant reprend le code ASCII de `TPM2_PT_MANUFACTURER` et
Identifiant fournisseur son code hexadécimal, sans correspondance commerciale
inventée ; Révision reprend `TPM2_PT_REVISION`, distincte du firmware.
Registres PCR indique les banques et indices alloués, sans lire les valeurs
de registres ni modifier leur allocation.

Une absence, un accès refusé, un outil manquant ou une sonde échouée/expirée
reste explicite et non bloquant. Les propriétés absentes, invalides ou
dupliquées restent non vérifiables ; les sorties non reconnues et stderr ne
sont pas publiées. Une réponse dépassant 64 Kio n'est pas analysée.
Aucun outil n'est installé, aucun droit n'est modifié et aucun transport
réseau implicite n'est utilisé. Aucun autre TPM n'est sondé en repli après
un échec. Les parcours individuel, groupé et de création partagent ce rendu.
Les documents existants l'adoptent à leur prochaine génération normale.
La référence est `openspec/specs/projects-template-devops/spec.md`.

### Dépendances Python des environnements du projet

`projects_template_devops_dependencies` recherche les dossiers ordinaires
portant un `pyvenv.cfg` ordinaire dans le projet. La recherche ignore les
liens de dossiers, les caches, `.git`, `node_modules`, les sorties, journaux
et ressources d'outillage, et ne descend pas à l'intérieur d'un venv.
La priorité est `.venv`, `venv`, `env` à la racine, puis les autres chemins
relatifs triés, y compris les environnements sous un dossier du projet.

Chaque environnement utilise `bin/python3`, sinon `bin/python`, sous le
compte DevOps. Le chemin d'entrée du venv est conservé même s'il pointe vers
un Python de base. La sonde utilise `-I -B -S` et les répertoires
`site-packages` de ce préfixe explicite : aucun script d'activation, fichier
`.pth` ou paquet applicatif n'est chargé. Chaque sonde est bornée à 3 secondes,
dans un budget de recherche/sondes de 12 secondes sous la borne utilisateur
existante de 15 secondes. Les processus de sonde et leurs descendants sont
terminés en cas de dépassement.

Pour chaque dépendance, le premier venv fournissant des métadonnées valides
est retenu. À défaut, le Python DevOps est consulté comme repli explicite.
La flèche indique l'interpréteur sondé ; les lignes `Environnement` et
`Installation` donnent la provenance et le chemin d'installation retourné
par les métadonnées, sans déduire un nom de module depuis la distribution.
Plusieurs dépendances peuvent provenir d'environnements différents. Les
versions et contraintes sont rapportées sans résolution ni installation.

Le Python système existant peut lire le manifeste si le Python DevOps est
absent ; ses paquets ne deviennent pas une source de repli. Une recherche
incomplète, un venv brisé, une sonde en échec ou des métadonnées contradictoires
sont signalés sans sortie brute. Une absence non prouvée est indiquée comme
`non vérifiable`, avec les limites de l'inventaire. Les diagnostics de
manifeste, références directes et dépendances dynamiques sont conservés.
La référence reste `openspec/specs/projects-template-devops/spec.md`.

### Outils de compilation Python : Cython et Nuitka déclarés

Le rendu lit d’abord `[build-system].requires` dans `pyproject.toml`. Les noms
de distribution `Cython` et `Nuitka`, sans distinction de casse et avec leurs
éventuels extras, contraintes ou marqueurs déclaratifs, déclenchent la rubrique
unique « Python - Outils de compilation », après le gestionnaire de paquets et
avant Prompts. Elle contient uniquement les outils déclarés, Cython puis Nuitka.
Un commentaire ou une autre table ne constitue pas cette déclaration. Sans aucun
des deux outils déclarés, la rubrique et la découverte des venv de compilation
sont omises ; un outil non déclaré n’est jamais demandé aux sondes. Un manifeste
invalide ou une analyse impossible produit un diagnostic commun de déclaration
non vérifiable sans rubrique ; un manifeste absent reste signalé par l’inventaire
d’exécution existant.

Le mode `compilation` de `projects_template_devops_dependencies` (alias interne
`cython` conservé) réutilise une découverte ordonnée commune et les sondes isolées
ci-dessus, avec les mêmes bornes, uniquement dans les venv du projet. Les sondes
ne demandent que les noms déclarés encore recherchés. Aucun paquet global ne sert
de repli. Chaque outil garde son état et sa provenance : version, interpréteur,
environnement et installation observés, « non installé » avec les environnements
vérifiés si son absence est établie, ou « installation non vérifiable » sinon,
notamment sans venv. Une métadonnée ambiguë pour un outil ne rend pas inconnue
l’observation valide de l’autre. Les références directes sont masquées, les
contraintes ne sont pas résolues et aucune conformité de version ni utilisation
effective pour compiler n’est déduite de cet inventaire.

Les trois parcours partagent ce rendu au format `0.7`, sans activation shell,
import de Cython ou Nuitka, chargement de `.pth`, installation, compilation ni modification
du manifeste. Les documents existants l’adoptent à leur prochaine génération
normale. La référence reste `openspec/specs/projects-template-devops/spec.md`.

### Dépendances JavaScript et OpenCode du projet

`projects_template_devops_javascript` collecte une seule fois les métadonnées
JavaScript par rendu. La sous-section « Dépendances JavaScript du projet »
figure sous NPM ; « Dépendances OpenCode du projet » figure sous OpenCode pour
`.opencode/package.json`. Elles sont omises lorsqu'aucun manifeste ni diagnostic
ne les concerne. Les versions des binaires restent distinctes des paquets.

La découverte parcourt les dossiers ordinaires du projet sans suivre les liens,
en excluant les paquets tiers `node_modules`, venv, caches, Git, sorties,
journaux, `PROMPTS`, `openspec` et ressources d'outillage. L'exception OpenCode
se limite à son manifeste et ses verrous racine ; ses configurations et états
ne sont pas parcourus. Les manifestes racine, OpenCode, déclarant des dépendances
ou organisant/appartenant à des workspaces sont retenus et triés par chemin.
Les autres manifestes vides sont comptés comme non retenus. Les motifs de
workspaces restent relatifs au projet ; les formes impossibles sont signalées.

Chaque manifeste conserve séparément `dependencies`, `devDependencies`,
`peerDependencies` et `optionalDependencies`, ainsi que les déclarations
`engines` et `packageManager` renseignées. Une référence privée URL/Git/locale
est catégorisée sans publication de sa valeur. Les alias npm sûrs et références
workspace sont identifiés sans résolution de contraintes ni exécution.

Le verrou npm local prime ; `npm-shrinkwrap.json` prime sur `package-lock.json`.
Seuls les formats 2 et 3 sont analysés. Un workspace déclaré sans verrou local
peut utiliser celui de son organisateur, avec les entrées `packages` pertinentes
et les liens internes au verrou. Les autres formats et sources concurrentes
sont explicites sans déduction du gestionnaire réellement utilisé. Un verrou
absent, invalide, incomplet ou désynchronisé ne fournit aucune preuve d'installation.

Pour chaque dépendance directe, les métadonnées sont recherchées dans
`node_modules` au plus près du manifeste puis dans ses parents jusqu'à la
racine. La première installation présente prime ; une métadonnée invalide
reste non vérifiable sans être masquée par une installation supérieure. Les
liens d'installation internes au projet, notamment workspaces et pnpm, sont
admis avec chemin réel ; les fichiers symboliques et cibles extérieures ou
protégées sont refusés. Les JSON sont ouverts depuis un descripteur racine,
sans suivre les liens intermédiaires. Aucun paquet global ou cache extérieur
OpenCode ne devient un repli. L'absence locale est libellée « non observée
localement » ; les échecs restent « non vérifiable ». Un écart entre verrou et
version observée est signalé sans conclusion SemVer ni preuve de plugin chargé.

L'analyseur est le Python DevOps existant, sinon `/usr/bin/python3`, avec
`-I -B -S` et uniquement la bibliothèque standard. Il ne lance ni npm, Bun,
OpenCode, script ou import applicatif, ni installation ou requête réseau, et
ne lit aucun `.npmrc`, fichier env ou secret. La collecte est bornée à
12 secondes sous la borne utilisateur de 15 secondes, 10 000 entrées de
découverte, 128 manifestes et 1 024 dépendances restituées. Les lectures sont
limitées à 1 Mio par manifeste/métadonnée, 8 Mio par verrou et 32 Mio au total.
Les limites et les diagnostics fixes rendent les données inconnues explicites ;
les sorties brutes ne sont pas publiées. La référence reste
`openspec/specs/projects-template-devops/spec.md`.

### Navigateurs hôte dans le document DevOps

La génération DevOps termine `DEVOPS.md` par « Tests navigateurs extérieurs
en mode headless », avec Chromium puis Firefox : version, chemin hôte et
option `--headless`. La détection utilise le PATH système fixe du générateur,
recherche `chromium` puis `chromium-browser`, et `firefox` puis `firefox-esr`.
Les sondes `--version` sont limitées à 15 secondes. Un navigateur absent ou
une version non vérifiable est indiqué explicitement, sans empêcher la
génération. Aucune installation ni test de navigation n'est réalisé ; une
version détectée ne prouve pas le fonctionnement du mode headless.
Cette section est aussi produite par les appels groupés et en fin de création.
La référence est `openspec/specs/projects-template-devops/spec.md`.

### Tous les modèles pour tous les projets

`rid projects template all all` appelle `projects_template_all_all`. Le premier
`all` désigne tous les modèles disponibles, actuellement OpenSpec et DevOps ;
le second désigne les projets configurés selon la même sélection `project.env`
que `openspec all` et `devops all` : cinq variables littérales non vides et
`PROJECT_ID` correspondant au dossier, sans exécuter la configuration.

Le traitement est réalisé par projet : OpenSpec puis DevOps, avant de passer
au suivant. DevOps reste toujours l'étape finale car il dépend des autres
modèles. Un échec OpenSpec empêche DevOps pour ce projet ; un échec DevOps
signale également ce projet comme échoué. Dans les deux cas, les autres projets
sont traités et les fichiers existants ou partiellement écrits sont conservés.
Le bilan compte les projets sélectionnés, réussis, ignorés et échoués ; un
projet n'est réussi que si tous ses modèles réussissent. Un échec produit un
code non nul ; aucun projet éligible produit un bilan et un succès.

La nouvelle commande exige exactement `all all`, sans cible individuelle après
le premier `all`. Les aides `projects template all help` et
`projects template all all help`, ainsi que leurs variantes `?`, expliquent
la sélection et l'ordre sans charger de configuration ni lancer de modèle.
La capacité de référence est `openspec/specs/projects-template-all/spec.md`.
Les commandes existantes et le parcours de création sont conservés.

### Mise à jour générale des projets

`rid projects update` sans identifiant appelle `projects_update`, qui délègue
une seule fois à `projects_template_all_all`. La sélection selon `project.env`,
OpenSpec puis DevOps en dernier pour chaque projet, la poursuite après échec,
la conservation des écritures et le bilan sont ceux de
`rid projects template all all`. Le code de retour est transmis à l'appelant.
Aucune synchronisation du modèle local ni configuration Git ou fournisseur
n'est ajoutée à cette mise à jour.

`rid projects update <ID PROJECT>` conserve son rôle de mise à jour interactive
des variables générales via `update_projects`. Dans cet usage, `all` reste
le nom d'un projet ciblé. Un identifiant explicitement vide ou des arguments
supplémentaires provoquent une erreur avant traitement. Les aides `help` et
`?` distinguent les deux usages avant tout chargement de configuration.
La capacité de référence est `openspec/specs/projects-general-update/spec.md`.

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
fonctions de domaine. Le filtre initial du point d'entrée accepte la classe
`projects` et rejette la classe historique `proj`. Les références OpenSpec à
`rid proj deb <project_id>` et `rid proj rel <project_id>` restent à réconcilier
avec ce routage ; cette description ne modifie pas leur contrat.

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
`DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE`, `PROXY_CA`,
`PROXY`, `DRIVERS_NVIDIA`, `FSTAB`, `FILES2RAM`, `GRUB_CONFIG`, `IPv6`,
`LOG_ROTATE`, `JOURNALD_MAX_USE`, `JOURNALD_KEEP_FREE`, `NO_SLEEP`, `DESKTOP`,
`CROWDSEC_AGENT`, `SYSTEM_CROWDSEC_AGENT`, `CROWDSEC_BOUNCER`,
`CROWDSEC_BOUNCER_API_KEY`, `SYSTEM_APT_CROWDSEC`, `APACHE2` et
`FSTAB_CONFIG1` à `FSTAB_CONFIG6`,
avec `export` facultatif et espaces initiaux éventuels.
Elle conserve les autres variables, commentaires et noms voisins.

Pour `PROXY`, `DRIVERS_NVIDIA`, `FSTAB`, `FILES2RAM`, `GRUB_CONFIG`, `IPv6` et
`LOG_ROTATE`, le nettoyage transfère la dernière valeur littérale `0` ou `1`
vers leur nouveau nom système dans `system.env`. Pour `JOURNALD_MAX_USE` et
`JOURNALD_KEEP_FREE`, il transfère la dernière taille littérale journald
simple, sans l’évaluer. `NO_SLEEP` suit également la migration littérale
`0|1` sans évaluation.
`APACHE2` est migrée séparément vers `SOFTWARES_APT_APACHE2` dans
`softwares.env`, avec validation littérale et priorité au nouveau nom.
Les réglages `CROWDSEC_AGENT`, `SYSTEM_CROWDSEC_AGENT`,
`CROWDSEC_BOUNCER`, `SYSTEM_APT_CROWDSEC` et `CROWDSEC_BOUNCER_API_KEY` sont
migrés vers les noms logiciels dédiés dans `softwares.env`. Les valeurs 0/1
sont transférées littéralement; la clé API est copiée sans affichage ni
évaluation et le fichier reçoit le mode `0600`.
Pour `FSTAB_CONFIG1` à `FSTAB_CONFIG6`, il transfère la dernière valeur
littérale simple, y compris une valeur entre guillemets. Une déclaration
nouvelle déjà présente prévaut ; toute syntaxe exigeant une interprétation
shell bloque le chargement sans modifier les fichiers.

La fonction accepte un chemin de fichier optionnel, ce qui permet les tests
isolés. Elle est idempotente : l'absence du fichier ou des affectations
historiques est un succès sans réécriture. Une migration valide persiste
`SYSTEM_PROXY` avant de supprimer `PROXY`. Toute erreur de lecture ou
d'écriture bloque le chargement suivant.

Les consommateurs utilisent `SYSTEM_DEBIAN_RELEASE`,
`SYSTEM_DEBIAN_ENVIRONNEMENT`, `SYSTEM_DRIVERS_DISPLAY_LINK`,
`SYSTEM_TIME_ZONE`, `SYSTEM_PROXY_CA`, `SYSTEM_PROXY`,
`SYSTEM_DRIVERS_NVIDIA`, `SYSTEM_FSTAB`, `SYSTEM_FILES2RAM`,
`SYSTEM_GRUB_CONFIG`, `SYSTEM_IPV6`, `SYSTEM_LOG_ROTATE`,
`SYSTEM_JOURNALD_MAX_USE`, `SYSTEM_JOURNALD_KEEP_FREE`, `SYSTEM_NO_SLEEP` et
`SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG6`. À l’exception des migrations littérales documentées
ci-dessus, les valeurs historiques ne sont pas transférées. Le nettoyage
intervient à la prochaine exécution du DIU, sans sauvegarde automatique des
autres anciennes affectations supprimées.

La racine des projets est `ENV_DEVOPS_PROJECTS_ROOT`, déclarée dans le scope
`environnements` en `STATIC` et `ENABLE`. Une valeur nouvelle configurée
prévaut; sinon l'ancienne valeur littérale `DEVOPS_PROJECTS_ROOT` est migrée.
À défaut, le chemin `/home/${ENV_DEVOPS_USER}/datas` est développé puis persisté
comme littéral; l'indisponibilité de `ENV_DEVOPS_USER` après son initialisation
est signalée. Si un ancien
fichier persiste une expression dépendant de cet utilisateur, le chargeur
prépare sa déclaration littérale avant de sourcer le fichier, quel que soit
l'ordre des lignes. La déclaration unitaire `env_devops_user.sh` est chargée
une fois avant `env_devops_projects_root.sh`. Elle est `STATIC/ENABLE`, scope
`environnements`, avec `root` comme défaut; une valeur existante est conservée.
Sans utilisateur ni racine déjà définis, le chemin devient `/home/root/datas`.
Si seul l'ancien `DEVOPS_USER` est défini, sa valeur est reprise pour
`ENV_DEVOPS_USER`; les consommateurs du code utilisent le nouveau nom.
Une racine historique utilisant `${DEVOPS_USER}` est conservée jusqu'à ce que
sa valeur issue du chargement habituel soit persistée sous le nouveau nom,
puis son ancienne affectation est retirée au passage suivant. Les substitutions
de commande et autres expressions ambiguës restent refusées.

Le résumé de mise à jour affiche `DIU_VERSION`, déclarée dynamiquement dans le
scope `diu` depuis la version retournée par `dpkg-query` pour le paquet `diu`.
L’ancienne valeur `VERSION_ALIAS` n’est pas transférée.

Le contrôle d’installation Apache2 utilise `SOFTWARES_APT_APACHE2`, déclaré
dans le scope `softwares`; l’ancienne valeur `APACHE2` est migrée vers
`softwares.env`.
Le contrôle d’installation de Fastfetch utilise `SOFTWARES_APT_FASTFETCH`,
déclaré dans le scope `softwares`; l’ancienne valeur `FASTFETCH` est migrée
vers `softwares.env`.
Le contrôle d’installation jsvc utilise `SOFTWARES_APT_JSVC`, déclaré dans le
scope `softwares`; l’ancienne valeur `JSVC` est migrée vers `softwares.env`.
Le contrôle d’installation LemonLDAP-NG utilise `SOFTWARES_APT_LEMONLDAP` dans
`softwares.env`; sa valeur initialise `SYSTEM_APT_LEMONLDAP` uniquement si le
réglage du dépôt système n’existe pas déjà.
Le contrôle d’installation MongoDB utilise `SOFTWARES_APT_MONGODB` dans
`softwares.env`; `MONGODB_VERSION` reste séparé pour sélectionner la branche
du dépôt `SYSTEM_APT_MONGODB`.
Le contrôle OpenJDK utilise `SOFTWARES_APT_OPENJDK` dans `softwares.env`; le
point d’entrée conserve la sélection Java selon la version Debian.
Le contrôle Omada utilise `SOFTWARES_APT_OMADA` dans `softwares.env` pour
l’installation et le firewall; `OMADA_VERSION` et `SYSLOG_SERVER_SKIL_OMADA`
restent séparés.
Le contrôle Open vSwitch utilise `SOFTWARES_APT_OPENVSWITCH` dans
`softwares.env`; l’ancienne valeur `OPENVSWITCH` y est migrée.
Le contrôle du serveur PostgreSQL utilise `SOFTWARES_APT_POSTGRESQL` dans
`softwares.env`; l’ancienne valeur `POSTGRESQL` y est migrée.
Le contrôle Postfix utilise `SOFTWARES_APT_POSTFIX` dans `softwares.env`; la
valeur distincte `POSTFIX_RELAY_HOST` continue à configurer le relais.
Le contrôle de `qemu-guest-agent` utilise `SOFTWARES_APT_QEMU_GUEST_AGENT` dans
`softwares.env`; le paquet reste désactivé par défaut.
Le contrôle Syncthing utilise `SOFTWARES_APT_SYNCTHING` dans `softwares.env`
pour l’installation du paquet ; le DIU ne crée ni ne modifie `.stignore`.
Le contrôle Webmin utilise `SOFTWARES_APT_WEBMIN` dans `softwares.env`; son
dépôt APT reste contrôlé séparément par `SYSTEM_APT_WEBMIN`.
Le contrôle de l’agent Wazuh utilise `SOFTWARES_APT_WAZUH_AGENT` dans
`softwares.env`; `WAZUH_CLIENT_VERSION` reste le sélecteur de version séparé.
Le contrôle Wazuh Server utilise `SOFTWARES_APT_WAZUH_SERVER` dans
`softwares.env`; son repli vers `SYSTEM_APT_WAZUH` respecte
`WAZUH_SERVER_UPGRADE`.
Le contrôle Zoom utilise `SOFTWARES_APT_ZOOM` dans `softwares.env` pour le
parcours de téléchargement et d’installation du paquet Debian.
Le contrôle Zsh utilise `SOFTWARES_APT_ZSH` dans `softwares.env` pour
l’installation et la configuration de Zsh/Fish.
Le contrôle de `/etc/rc.local` utilise `SYSTEM_RC_LOCAL` dans `system.env`;
l’ancienne valeur `RCLOCAL=0|1` y est migrée.
Le client rsyslog utilise `SOFTWARES_APT_SYSLOG_CLIENT` dans `softwares.env`;
`SYSLOG_CLIENT_SERVER` conserve l’adresse distante.
Le serveur rsyslog utilise `SOFTWARES_APT_SYSLOG_SERVER` dans `softwares.env`;
les options `SYSLOG_SERVER_SKIL_*` continuent à sélectionner les catégories de
journaux.
Le serveur OpenSSH utilise `SOFTWARES_APT_SSH_SERVER` dans `softwares.env`;
les clés `KEY_SSH_ADMIN` et `KEY_SSH_ACME` ne sont pas renommées.

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

### Option proxy système

`modules/diu/variables/system/system_proxy.sh` déclare `SYSTEM_PROXY` avec
`STATIC`, `ENABLE`, scope `system` et valeur initiale `0`. Une valeur absente
est persistée dans `/root/diu/config/system.env`, puis exportée ; une valeur
existante, même vide, est conservée. Le point d’entrée exécute les traitements
proxy système et Java existants seulement lorsque `SYSTEM_PROXY` vaut `1`.
La migration de `PROXY` vers `SYSTEM_PROXY` est effectuée par le nettoyage
historique. Les variables `PROXY_HTTP` et `PROXY_HTTP_HOST` gardent leur rôle.

### Option proxy CA système

`modules/diu/variables/system/system_proxy_ca.sh` déclare
`SYSTEM_PROXY_CA` avec `STATIC`, `ENABLE`, scope `system` et valeur initiale
`0`. Une valeur absente est persistée dans `/root/diu/config/system.env`, puis
exportée ; une valeur existante, même vide, est conservée. Le point d’entrée
exécute le traitement CA existant seulement lorsque `SYSTEM_PROXY_CA` vaut
`1`. L’ancienne affectation `PROXY_CA` est supprimée avant le chargement de
`variables.sh`, sans transfert ; une ancienne activation doit être reportée
explicitement à `SYSTEM_PROXY_CA=1` dans `system.env`.

### Option pilote NVIDIA système

`modules/diu/variables/system/system_drivers_nvidia.sh` déclare
`SYSTEM_DRIVERS_NVIDIA` avec `STATIC`, `ENABLE`, scope `system` et valeur
initiale `0`. Une valeur absente est persistée dans
`/root/diu/config/system.env`, puis exportée ; une valeur existante est
conservée. Le point d’entrée exécute les traitements NVIDIA existants
uniquement lorsque `SYSTEM_DRIVERS_NVIDIA` vaut `1`. Ces traitements peuvent
installer des prérequis, configurer DKMS et les modules noyau, et activer le
runtime NVIDIA de Docker. Une ancienne affectation simple `DRIVERS_NVIDIA=0`
ou `1` est migrée par le nettoyage historique ; une forme ambiguë bloque le
chargement sans afficher son contenu.

### Options FSTAB système

`modules/diu/variables/system/system_fstab.sh` déclare `SYSTEM_FSTAB` avec
`STATIC`, `ENABLE`, scope `system` et valeur initiale `0`. Les six fichiers
`system_fstab_config1.sh` à `system_fstab_config6.sh` déclarent
`SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG6` avec `STATIC`, `ENABLE`, scope
`system` et valeur initiale `NONE`. Les valeurs absentes sont persistées dans
`/root/diu/config/system.env`, puis exportées; les valeurs existantes sont
préservées. `SYSTEM_FSTAB=1` active les écritures FSTAB explicites existantes;
`SYSTEM_FSTAB_CONFIG6` suit `SYSTEM_FSTAB_CONFIG5`, et `SYSTEM_FSTAB_CONFIG1`
reste aussi consommée par FILES2RAM. La migration des
anciennes affectations littérales est effectuée avant de sourcer
`variables.sh`; les syntaxes nécessitant une interprétation shell bloquent le
nettoyage.

### Option FILES2RAM système

`modules/diu/variables/system/system_files2ram.sh` déclare
`SYSTEM_FILES2RAM` avec `STATIC`, `ENABLE`, scope `system` et valeur initiale
`0`. Une valeur absente est persistée dans `/root/diu/config/system.env`, puis
exportée; une valeur existante est préservée. Le point d’entrée exécute le
traitement FILES2RAM existant seulement lorsque `SYSTEM_FILES2RAM` vaut `1`.
Celui-ci peut supprimer `/var/log/*` lors de sa première activation si
`/etc/tmpfiles.d/var2log.conf` n’existe pas; l’ancienne valeur littérale est
migrée avant l’exécution et une syntaxe ambiguë bloque le nettoyage.

### Configuration GRUB système

`modules/diu/variables/system/system_grub_config.sh` déclare
`SYSTEM_GRUB_CONFIG` avec `STATIC`, `ENABLE`, scope `system` et valeur initiale
`0`. Une valeur absente est persistée dans `/root/diu/config/system.env`, puis
exportée; une valeur existante est préservée. Le point d’entrée exécute le
bloc GRUB existant seulement lorsque cette variable vaut `1`. La dernière
valeur littérale `GRUB_CONFIG=0|1` est migrée lors du nettoyage historique si
`SYSTEM_GRUB_CONFIG` n’est pas déjà déclarée; une valeur `1` reste `1`, tandis
qu’une affectation ambiguë bloque le nettoyage.

### Contrôle IPv6 système

`modules/diu/variables/system/system_ipv6.sh` déclare `SYSTEM_IPV6` en
`STATIC`, `ENABLE`, scope `system`. Si elle n’est pas définie, le DIU lit
`net.ipv6.conf.all.disable_ipv6` avec sysctl : `0` produit `SYSTEM_IPV6=1`,
`1` produit `SYSTEM_IPV6=0`. La valeur est persistée dans
`/root/diu/config/system.env`; une erreur ou valeur sysctl invalide bloque la
génération sans export. Une valeur historique littérale `IPv6=0|1` est
migrée sans altération et prévaut sur la détection; toute valeur nouvelle
déjà définie garde la priorité. Le point d’entrée conserve les traitements
sysctl IPv6 existants sous le nouveau nom.

### Contrôle logrotate système

`modules/diu/variables/system/system_log_rotate.sh` déclare
`SYSTEM_LOG_ROTATE` en `STATIC`, `ENABLE`, scope `system`, défaut `0`. Une
valeur préconfigurée `0` ou `1` est conservée; toute autre valeur est refusée.
L’ancienne valeur littérale `LOG_ROTATE=0|1` est migrée exactement si aucune
valeur nouvelle n’est déjà présente. Le point d’entrée ne modifie le fichier
`/etc/logrotate.conf` que lorsque `SYSTEM_LOG_ROTATE=1`; dans ce cas il
continue d’utiliser `LOG_ROTATE_DAILY` pour le compte de rotations.

### Limite de taille journald

`modules/diu/variables/system/system_journald_max_use.sh` déclare
`SYSTEM_JOURNALD_MAX_USE` en `STATIC`, `ENABLE`, scope `system`, défaut
`500M`. Les valeurs acceptées sont un entier, suivi facultativement de `K`,
`M`, `G`, `T`, `P` ou `E`. Une valeur historique simple
`JOURNALD_MAX_USE` est migrée sans l’évaluer; une valeur nouvelle déjà
configurée est prioritaire. Le point d’entrée utilise cette limite pour les
journaux systemd persistants et volatils. `JOURNALD_KEEP_FREE` reste distinct.

### Espace libre journald

`modules/diu/variables/system/system_journald_keep_free.sh` déclare
`SYSTEM_JOURNALD_KEEP_FREE` en `STATIC`, `ENABLE`, scope `system`, défaut
`1G`. Les valeurs acceptées sont un entier, suivi facultativement de `K`,
`M`, `G`, `T`, `P` ou `E`. Une valeur historique simple
`JOURNALD_KEEP_FREE` est migrée sans l’évaluer; une valeur nouvelle déjà
configurée est prioritaire. Le point d’entrée utilise cette réserve pour les
journaux systemd persistants et volatils.

### Contrôle de veille systemd

`modules/diu/variables/system/system_no_sleep.sh` déclare `SYSTEM_NO_SLEEP` en
`STATIC`, `ENABLE`, scope `system`, défaut `0`. Une valeur historique simple
`NO_SLEEP=0|1` est migrée exactement; une valeur nouvelle déjà configurée est
prioritaire. `SYSTEM_NO_SLEEP=1` crée `nosleep.conf` avec les paramètres
existants qui désactivent suspend et hibernation. Une valeur `0` ignore ce
bloc et ne supprime pas un fichier `nosleep.conf` déjà présent.

### CrowdSec dans le scope logiciels

Les interrupteurs `SOFTWARES_APT_CROWDSEC`,
`SOFTWARES_APT_CROWDSEC_AGENT` et `SOFTWARES_APT_CROWDSEC_BOUNCER` sont
déclarés dans le scope `softwares`. Le dépôt CrowdSec est configuré par APT;
les paquets `crowdsec` et `crowdsec-firewall-bouncer-iptables` sont installés
par APT. La clé `SOFTWARES_CROWDSEC_BOUNCER_API_KEY` est aussi stockée dans
`softwares.env`, qui est protégé en mode `0600` dès qu'il contient la clé.
L’application à la configuration YAML ne transmet pas la valeur dans les
arguments d’un processus enfant ni dans la sortie.

Le profil de bureau utilise `DESKTOP`, déclaré en `STATIC`, `ENABLE`, scope
`desktop`, défaut `0`. La valeur historique `DESKTOP=0|1` est déplacée de
`variables.sh` vers `desktop.env`; l'ancienne valeur plus récente
`SOFTWARES_APT_DESKTOP=0|1` de `softwares.env` est également migrée exactement
si `DESKTOP` n'est pas déjà déclaré dans `desktop.env`. Les deux consommateurs
du point d'entrée utilisent ce contrôle.

### Contrôle de la stack Docker Traefik / Dockhand

`modules/diu/variables/docker/docker_stack_traefik_dockhand.sh` déclare
`DOCKER_STACK_TRAEFIK_DOCKHAND` en `STATIC`, `ENABLE`, scope `docker`, défaut
`0`. Une valeur existante `0` ou `1` est conservée; une valeur absente est
persistée dans `/root/diu/config/docker.env` avec le défaut `0`. Les
consommateurs existants de la stack gardent ce nom; `1` active la stack.
La génération système de `/etc/hosts` ne crée plus les entrées de cette stack.
Le réglage de mise à jour est `DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE`, déclaré
en `STATIC`, `ENABLE`, scope `docker`, défaut `0`; l’ancienne valeur
`DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE=0|1` est migrée vers `docker.env`.

### Contrôle de la stack Docker DevOps

`modules/diu/variables/docker/docker_stack_devops.sh` déclare
`DOCKER_STACK_DEVOPS` en `STATIC`, `ENABLE`, scope `docker`, défaut `0`. Une
valeur existante `0` ou `1` est conservée; une valeur absente est persistée
dans `/root/diu/config/docker.env` avec le défaut `0`. Le consommateur
existant conserve le même nom. La génération système de `/etc/hosts`
ne crée plus les noms d’hôtes DevOps.

### Mise à jour de la stack Docker BunkerWeb

`modules/diu/variables/docker/docker_stack_bunkerweb_update.sh` déclare
`DOCKER_STACK_BUNKERWEB_UPDATE` en `STATIC`, `ENABLE`, scope `docker`, défaut
`0`. L’ancienne valeur littérale `DOCKER_STACK_BUNKERWEB_UPGRADE=0|1` est
migrée exactement vers `docker.env` si le nouveau nom n’y est pas déjà défini.
`DOCKER_STACK_BUNKERWEB_AUTO_UPDATE` et `DOCKER_STACK_BUNKERWEB_VERSION`
restent des réglages distincts.

### Indicateurs de tests DevOps

`modules/diu/variables/environnements/env_devops_tests_docker.sh` et
`env_devops_tests_lxc.sh` déclarent respectivement `ENV_DEVOPS_TESTS_DOCKER`
et `ENV_DEVOPS_TESTS_LXC` : `STATIC`, `ENABLE`, scope `environnements`,
valeur initiale `0`. Après chargement de la configuration, chaque variable
absente est persistée dans `/root/diu/config/environnements.env`, puis exportée.
Les nouvelles lignes de ces deux indicateurs commencent par huit espaces avant
`export`, comme les lignes du fichier de configuration présentées par le
développeur. Une désactivation reconnaît également les déclarations anciennes
sans retrait ou précédées de tabulations ; les lignes existantes ne sont pas
reformatées lors de la génération.

`modules/diu/variables/environnements/env_devops.sh` déclare
`ENVIRONMENTS_DEVOPS` en `STATIC`, `ENABLE`, scope `environnements`, défaut `0`.
L'ancienne valeur littérale `ENV_DEVOPS=0|1` est migrée exactement vers
`environnements.env`; le bloc de création du compte et de préparation du profil
DevOps utilise le nouveau nom.

`modules/diu/variables/environnements/environment_docker.sh` déclare
`ENVIRONMENT_DOCKER` en `STATIC`, `ENABLE`, scope `environnements`, défaut `0`.
L'ancienne valeur littérale `ENV_DOCKER=0|1` est migrée exactement vers
`environnements.env`; les paramètres voisins `ENV_DOCKER_USER` et
`ENV_DOCKER_GROUP` restent distincts.

`modules/diu/variables/environnements/environment_ia.sh` déclare
`ENVIRONMENT_IA` en `STATIC`, `ENABLE`, scope `environnements`, défaut `0`.
L'ancienne valeur littérale `ENV_IA=0|1` est migrée exactement vers
`environnements.env`; le bloc de création du compte et de préparation du profil
IA utilise le nouveau nom.
Le répertoire est créé si nécessaire. Une erreur de création ou de persistance
produit un diagnostic stderr et un statut non nul, sans définir la variable
absente concernée.

Les valeurs déjà définies, même vides, sont conservées et exportées sans
réécriture. Le chargement normal suivi de la génération ne crée aucun doublon ;
les autres lignes et scopes sont conservés. Le générateur DevOps consomme ces
indicateurs uniquement pour afficher les rubriques documentaires Docker et LXC
décrites dans « Traçabilité du document DevOps ». Aucun lancement de test
Docker/LXC ni changement d'infrastructure n'est ajouté. La configuration réelle
adopte ces valeurs à la prochaine exécution normale du DIU mis à jour.
Le contrat est défini dans
`openspec/specs/devops-tests-environment-flags/spec.md` et vérifié en isolation
par `tests/test_env_devops_tests.py`.

### Fuseau horaire système

`modules/diu/variables/system/system_time_zone.sh` déclare `SYSTEM_TIME_ZONE`,
`STATIC`, `ENABLE`, scope `system`, avec le repli `Europe/Paris`.
À la première initialisation, `variable_generator` appelle
`timedatectl show --property=Timezone --value`. Une commande absente, un échec
ou une réponse vide utilise le repli avec un diagnostic stderr.
La valeur est persistée avec échappement Bash dans `/root/diu/config/system.env`
puis exportée. Un échec de persistance est bloquant. Une valeur déjà définie,
même vide, est conservée sans détection ni écriture.

Le nettoyage retire `TIME_ZONE` avant le chargement de `variables.sh`, sans
transfert ni sauvegarde automatique de sa valeur. Le parcours historique
utilise `SYSTEM_TIME_ZONE` pour configurer le fuseau. `rid system infos debian`
l'affiche immédiatement après `SYSTEM_DEBIAN_RELEASE` dans SYSTEM DEBIAN.

### Environnement Debian

`modules/diu/variables/system/system_debian_environnement.sh` déclare
`SYSTEM_DEBIAN_ENVIRONNEMENT` : `DYNAMIC`, `ENABLE`, scope `system`, repli `UNSET`.
La valeur est générée et exportée seulement si la variable est absente, sans
persistance automatique, conformément au cycle dynamique existant.

Son `variable_generator` utilise `systemd-detect-virt --container`, puis `--vm` :

| Résultat détecté | Valeur |
|---|---|
| Conteneur Docker courant | `DOCKER` |
| Conteneur LXC ou LXC-libvirt courant | `LXC` |
| Hyperviseur reconnu, dont KVM/Proxmox et Hyper-V | `VM` |
| Machine physique avec `pve-manager` confirmé installé | `PROXMOX` |
| Machine physique sans `pve-manager` installé | `PHYSICAL` |
| Outil absent, erreur, résultat incohérent ou environnement inconnu | `UNSET` |

Le conteneur prime sur son hôte ; Proxmox VE dans une VM reste `VM`.
Un dépôt Proxmox ou un nom de noyau ne suffit pas. Les conteneurs autres que
Docker et LXC restent `UNSET`. Ce résultat émet un diagnostic sur stderr sans
bloquer l'initialisation. La détection dépend des informations exposées par
l'environnement et ne garantit pas l'identification d'un hyperviseur masqué.
Les consommateurs historiques conservent leurs branches LXC, PHYSICAL, VM et
PROXMOX ; aucune branche d'installation DOCKER ou UNSET n'est ajoutée.

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
2. réutilise le trousseau `/usr/share/keyrings/<name>-archive-keyring.gpg`
   s'il est présent, lisible et non vide ; sinon, télécharge la clé GPG
   déclarée et la convertit à cet emplacement, avec un échec bloquant si
   l'installation échoue et sans désactiver la vérification TLS ;
3. écrit un fichier `.sources` ou `.list` selon la version Debian ;
4. supprime le format alternatif géré par le DIUE ;
5. retire les fichiers et le trousseau lorsque le dépôt est désactivé.

Les variables persistantes de dépôts tiers sont détectées depuis la
configuration APT existante au premier chargement. Elles couvrent notamment
CrowdSec, Docker, LemonLDAP, MongoDB, NodeSource, NVIDIA, Proxmox, VS Code,
Wazuh, Webmin et les dépôts OpenAI/ChatGPT.

Une valeur `SYSTEM_APT_*` déjà initialisée est prioritaire. Si aucune source
APT n'est détectée lors de l'initialisation, les activations historiques
CrowdSec, LemonLDAP, MongoDB et Wazuh restent prises en compte. MongoDB 4
utilise la version historique 4.4 ; sa suite reste Bullseye pour Bullseye et
Bookworm pour les versions suivantes. L'installation sans branche explicite
conserve une branche configurée de 4 à 8, ou choisit 8 si aucune n'est définie.
Wazuh accepte 4 et l'activation historique 1, traduites en activation 1 pour
le moteur ; 0 le désactive. Le trousseau CrowdSec historique sous le nom
`crowdsec-crowdsec-archive-keyring.gpg` peut être copié vers le nom géré sans
téléchargement lorsqu'il est lisible et non vide.

Le bloc APT du monolithe délègue ces dépôts au moteur commun. Ses branches
Bookworm et Bullseye conservent les traitements système indépendants et la
recette FusionDirectory, contrôlée par `DIU_APT_REPOSITORY_FD`. Les exigences
de référence sont dans `openspec/specs/system-debian-apt/spec.md`.

Les fichiers tiers non gérés par le DIUE sont préservés. La régénération ne
doit pas introduire implicitement une source étrangère dans la résolution des
paquets Debian officiels.

### Mise à jour du système

`system_apt_update` régénère la configuration, actualise les index APT,
exécute la transaction globale de mise à niveau, puis effectue le nettoyage
APT prévu et installe les prérequis manquants.

`system_install_prerequisites` vérifie chaque paquet individuellement, sans
sortie s'il est déjà installé. Les paquets manquants sont annoncés et installés
un par un dans l'ordre alphabétique, après déduplication. Un échec APT est
signalé et interrompt la fonction. Le socle commun est :

```text
aptitude apache2-utils apt-transport-https bash-completion
bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg gpg
inetutils-telnet iptables jq libpq5 libsecret-tools lshw lsb-release man-db manpages-fr
net-tools netcat-traditional nicstat openssl pciutils postgresql-client python3-pytest ripgrep
shellcheck sudo tcpdump traceroute tree util-linux wget
```

La fonction complète ce socle selon `SYSTEM_DEBIAN_ENVIRONNEMENT` :

| Famille | Paquets ajoutés au socle |
|---|---|
| LXC, PHYSICAL, VM, DOCKER | `acl` |
| PROXMOX | `acl`, `conntrack`, `glances`, `rsync` |
| Absente, vide, UNSET ou inconnue | Aucun |

DOCKER et VM utilisent exactement la même liste. Le parcours historique sans
argument appelle également cette fonction, à la place de ses anciennes listes,
avant sa configuration APT. La présence d'`aptitude` ne dispense plus de
vérifier les autres prérequis. DisplayLink ne fait pas partie de la fonction
commune et son ancien bloc automatique est supprimé : seules les commandes
explicites `rid system drivers` gèrent ce pilote.

Les fonctions publiques de gestion des dépôts valident leur identifiant,
persistent les variables du scope `system`, puis régénèrent la configuration.

## Moteurs logiciels

Le routage logiciel passe par `manage_software_action` pour les commandes
génériques et par `manage_softwares_action` pour les commandes modulaires.
Les commandes génériques reconnaissent trois moteurs : `deb`, `apt` et
`github`. Les commandes modulaires ajoutent le moteur d'applications `flatpak`
pour l'installation, la suppression et la mise à jour des applications système.
La préparation du client et du remote Flatpak relève séparément du module
`system`, selon `software-flatpak` et `system-flatpak`.

Les identifiants logiciels sont validés avant routage. Une recette doit être
déclarée explicitement par le moteur ; le nom fourni par l'utilisateur ne doit
jamais devenir directement un nom de fonction ou une commande shell.

### Apache2 via APT

`modules/diu/variables/softwares/software_apt_apache2.sh` déclare
`SOFTWARES_APT_APACHE2` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
Une valeur existante `0` ou `1` est conservée; une valeur absente est
persistée dans `/root/diu/config/softwares.env`. L’ancienne valeur littérale
`APACHE2=0|1` est migrée exactement vers ce scope si aucune nouvelle valeur
n’est déjà définie. Une valeur `1` garde l’installation Apache2 et de ses
dépendances existantes selon la version Debian détectée.

### Fastfetch par APT

`modules/diu/variables/softwares/software_apt_fastfetch.sh` déclare
`SOFTWARES_APT_FASTFETCH` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `FASTFETCH=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie. Le point
d’entrée conserve les installations APT existantes selon la version Debian.

### jsvc par APT

`modules/diu/variables/softwares/software_apt_jsvc.sh` déclare
`SOFTWARES_APT_JSVC` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `JSVC=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie. Le point
d’entrée conserve l’installation APT conditionnelle de jsvc.

### LemonLDAP-NG par APT

`modules/diu/variables/softwares/software_apt_lemonldap.sh` déclare
`SOFTWARES_APT_LEMONLDAP` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `LEMONLDAP=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie. Elle sert
aussi de repli à l’initialisation du dépôt `SYSTEM_APT_LEMONLDAP`; une valeur
système déjà configurée reste prioritaire.

### MongoDB par APT

`modules/diu/variables/softwares/software_apt_mongodb.sh` déclare
`SOFTWARES_APT_MONGODB` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `MONGODB=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie.
`MONGODB_VERSION` reste inchangée et sélectionne la branche utilisée pour
initialiser `SYSTEM_APT_MONGODB`; une valeur déjà configurée de ce réglage
système reste prioritaire.

### OpenJDK par APT

`modules/diu/variables/softwares/software_apt_openjdk.sh` déclare
`SOFTWARES_APT_OPENJDK` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `OPENJDK=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie. Le point
d’entrée garde OpenJDK 17 sur Bullseye/Bookworm et OpenJDK 21 sur Trixie.

### Omada

`modules/diu/variables/softwares/software_apt_omada.sh` déclare
`SOFTWARES_APT_OMADA` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `OMADA=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie. L’installation
du paquet et les règles firewall suivent ce réglage; `OMADA_VERSION` et
`SYSLOG_SERVER_SKIL_OMADA` ne sont pas migrées.

### Open vSwitch par APT

`modules/diu/variables/softwares/software_apt_openvswitch.sh` déclare
`SOFTWARES_APT_OPENVSWITCH` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `OPENVSWITCH=0|1` est transférée exactement
vers `softwares.env` si la nouvelle variable n’y est pas déjà définie. Le
point d’entrée conserve l’installation APT conditionnelle de
`openvswitch-switch`.

### Serveur PostgreSQL par APT

`modules/diu/variables/softwares/software_apt_postgresql.sh` déclare
`SOFTWARES_APT_POSTGRESQL` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `POSTGRESQL=0|1` est transférée exactement
vers `softwares.env` si la nouvelle variable n’y est pas déjà définie. Le
point d’entrée conserve l’installation APT conditionnelle du serveur
PostgreSQL.

### Postfix par APT

`modules/diu/variables/softwares/software_apt_postfix.sh` déclare
`SOFTWARES_APT_POSTFIX` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `POSTFIX=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie.
`POSTFIX_RELAY_HOST` reste distinct et configure `relayhost` lorsque Postfix
est activé.

### qemu-guest-agent par APT

`modules/diu/variables/softwares/software_apt_qemu_guest_agent.sh` déclare
`SOFTWARES_APT_QEMU_GUEST_AGENT` en `STATIC`, `ENABLE`, scope `softwares`,
défaut `0`. L’ancienne valeur littérale `QEMU_GUEST_AGENT=0|1` est transférée
exactement vers `softwares.env` si la nouvelle variable n’y est pas déjà
définie. Le point d’entrée conserve l’installation APT conditionnelle du
paquet `qemu-guest-agent`.

### Client syslog par APT

`modules/diu/variables/softwares/software_apt_syslog_client.sh` déclare
`SOFTWARES_APT_SYSLOG_CLIENT` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `SYSLOG_CLIENT=0|1` est transférée exactement
vers `softwares.env` si la nouvelle variable n’y est pas déjà définie.
`SYSLOG_CLIENT_SERVER` reste distincte et indique la destination des journaux.

### Serveur syslog par APT

`modules/diu/variables/softwares/software_apt_syslog_server.sh` déclare
`SOFTWARES_APT_SYSLOG_SERVER` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `SYSLOG_SERVER=0|1` est transférée exactement
vers `softwares.env` si la nouvelle variable n’y est pas déjà définie. Les
variables `SYSLOG_SERVER_SKIL_*` restent distinctes pour configurer les
catégories de journaux.

### Serveur OpenSSH par APT

`modules/diu/variables/softwares/software_apt_ssh_server.sh` déclare
`SOFTWARES_APT_SSH_SERVER` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `SSH=0|1` est transférée exactement vers
`softwares.env` si la nouvelle variable n’y est pas déjà définie. Les blocs
existants d’installation et de préparation des clés restent pilotés par cette
variable; les valeurs `KEY_SSH_*` restent distinctes.

### Syncthing par APT

`modules/diu/variables/softwares/software_apt_syncthing.sh` déclare
`SOFTWARES_APT_SYNCTHING` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `SYNCTHING=0|1` est transférée exactement
vers `softwares.env` si la nouvelle variable n’y est pas déjà définie. Le
point d’entrée conserve l’installation APT sans créer ni modifier `.stignore`.

### Webmin par APT

`modules/diu/variables/softwares/software_apt_webmin.sh` déclare
`SOFTWARES_APT_WEBMIN` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `WEBMIN=0|1` est transférée exactement vers
`softwares.env` si le nouveau nom n’y est pas déjà défini.
`SYSTEM_APT_WEBMIN` reste le réglage distinct du dépôt tiers.

### Agent Wazuh par paquet Debian

`modules/diu/variables/softwares/software_apt_wazuh_agent.sh` déclare
`SOFTWARES_APT_WAZUH_AGENT` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `WAZUH_CLIENT=0|1` est transférée exactement
vers `softwares.env` si le nouveau nom n’y est pas déjà défini.
`WAZUH_CLIENT_VERSION` reste inchangée et sélectionne la version du paquet.

### Wazuh Server

`modules/diu/variables/softwares/software_apt_wazuh_server.sh` déclare
`SOFTWARES_APT_WAZUH_SERVER` en `STATIC`, `ENABLE`, scope `softwares`, défaut
`0`. L’ancienne valeur littérale `WAZUH_SERVER=0|1` est transférée exactement
vers `softwares.env` si la nouvelle variable n’y est pas déjà définie.
`WAZUH_SERVER_UPGRADE` reste distincte et détermine le repli initial du dépôt
`SYSTEM_APT_WAZUH`.

### Zoom par paquet Debian

`modules/diu/variables/softwares/software_apt_zoom.sh` déclare
`SOFTWARES_APT_ZOOM` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `ZOOM=0|1` est transférée exactement vers
`softwares.env` si le nouveau nom n’y est pas déjà défini. Le consommateur
conserve le téléchargement, l’installation et la mise à jour du paquet Debian.

### Contrôle système de RC.local

`modules/diu/variables/system/system_rc_local.sh` déclare
`SYSTEM_RC_LOCAL` en `STATIC`, `ENABLE`, scope `system`, défaut `0`. L’ancienne
valeur littérale `RCLOCAL=0|1` est transférée exactement vers `system.env` si
la nouvelle variable n’y est pas déjà définie; `/etc/rc.local` reste généré
conditionnellement.

### Zsh et Fish par APT

`modules/diu/variables/softwares/software_apt_zsh.sh` déclare
`SOFTWARES_APT_ZSH` en `STATIC`, `ENABLE`, scope `softwares`, défaut `0`.
L’ancienne valeur littérale `ZSH=0|1` est transférée exactement vers
`softwares.env` si le nouveau nom n’y est pas déjà défini. Le point d’entrée
conserve l’installation APT et la configuration de Zsh, Fish et des outils
associés.

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

### Version prioritaire du projet

`lib/project-version.sh` lit uniquement `PROJECT_VERSION` dans `project.env`,
sans exécution de configuration ni réutilisation d'une valeur du projet précédent.
Le format est une version stable `x.y.z`, sans préfixe v et sans zéro initial
sur chacun des entiers sauf 0 ; les valeurs présentes invalides sont bloquantes.
Une clé absente conserve la sélection historique de chaque fonction.
Le contrat transversal est `openspec/specs/project-version/spec.md`.
Les règles de packaging sont détaillées dans BUILD.md.
Les paramètres automatiques de commit utilisent VERSION et le tag v<VERSION> ;
une description explicite est conservée. Une version `PROJECT_VERSION` déjà attribuée déclenche
un rejeu isolé du commit marqué, sans remplacer le tag local ni inclure les changements
locaux en attente. Un arbre inchangé ne crée pas de commit vide ; si le tag est absent des
dépôts vérifiés, il peut être créé sur HEAD.
Les pushes individuels et groupés sélectionnent le tag déclaré et vérifient
qu'il désigne HEAD avant tout transport ; les branches et protections restent
inchangées (leases Forgejo/GitHub, push normal GitLab).
Le build Docker produit latest et le tag VERSION. Une publication versionnée
utilise cette image locale précise et le tag Git attendu ; une image absente
ou un paquet de version différente bloque la publication. Les autres tags de
HEAD ne déterminent pas la version lorsque PROJECT_VERSION est présente.
Les aides décrivent ces règles avant bootstrap. La clé est relue pour chaque
projet, sans réutilisation de la variable shell éventuellement chargée avant.
L'argument facultatif de `rid projects cicd <ID PROJECT> [VERSION]` valide et
met à jour la seule affectation PROJECT_VERSION sans interpréter le fichier.
Les sélecteurs DIU privilégient les versions stables sur les horodatages ;
les comparaisons natives dpkg/APT conservent leur ordre et aucun epoch n'est ajouté.


### CI/CD générique et artefacts indépendants

`cicd_project` suit six étapes affichées : 1 commit/tag, 2 pushes Git,
3 build Docker, 4 build Debian, 5 publications, 6 bilan. Le build Docker
conserve l'activation exacte `PROJECT_DOCKERED=Yes`. Le build Debian utilise
`projects_build_deb`, moteur de `rid projects build debian <ID PROJECT>`,
uniquement pour `PROJECT_DEBIAN_PACKAGE=Yes`, `YES` ou `1`. Les clés absentes,
vides ou différentes n'appellent pas le builder Debian ; le bilan l'indique.
Les deux activations sont indépendantes, sans fuite vers le projet suivant.

Les sorties de publication Debian utilisent des libellés de projet alignés.
Chaque fournisseur annonce uniquement les contrôles effectivement réalisés ;
le tag figure dans les messages de release et de paquet déjà présent. Le
répertoire temporaire du rejeu est explicitement identifié comme isolé.

Lors d'un rejeu, le clone temporaire privé est nettoyé à la fin du flux. Le
contexte Docker provient des fichiers suivis du commit et ne contient ni `.git`,
ni configuration locale, ni identifiants de forge ; le build lit la configuration
nécessaire hors de ce contexte. Le paquet Debian est conservé dans
`dist/replay/<TAG>/<SHA256>/` sans écraser un fichier existant. Les historiques
divergents sont fusionnés dans une copie isolée, avec priorité aux fichiers
versionnés locaux en conflit et protection par SHA attendu lors du push. Un tag
distant divergent est remplacé sous lease sans sauvegarde ; les artefacts de cette
forge ne sont pas publiés durant cette exécution et leur cohérence doit être vérifiée.
Les releases Debian peuvent cibler un commit marqué ancêtre de la branche distante ; leurs assets
existants restent intacts. DIU ne vérifie pas l'immutabilité des tags Docker
distants : leur publication est donc ignorée lors d'un rejeu ; ce choix ne bloque
pas la publication Debian.
L'image Docker locale du rejeu utilise un tag temporaire dédié `replay-*` et
ne remplace ni le tag local versionné ni `latest`.

Sans Docker, Debian peut être construit puis publié sur Forgejo/GitLab/GitHub par
les fonctions Debian. Les conditions de complétude des fournisseurs,
dont le registre GitLab, sont conservées. GitHub publie Docker, Debian ou les
deux selon leur activation. Un échec de build empêche toutes les releases et retourne
un code non nul avec bilan partiel ; les pushes déjà réalisés restent publiés.
Une indisponibilité reconnue pendant le push permet les builds locaux et ignore
les publications du fournisseur concerné. Pendant une release, elle laisse
poursuivre les autres fournisseurs et signale une publication non confirmée,
potentiellement partielle. Aucune invocation récursive du bootstrap.
Le bilan conserve ses onze premiers paramètres et reçoit le statut du build
Debian dans un douzième paramètre facultatif.
Les contrats sont `projects-cicd`, `projects-debian-build` et `rid-help`.

### Publications GitHub Docker et Debian

`projects_github_release` sélectionne les artefacts pour la commande directe
`rid projects github release <ID PROJECT>`. Les deux indicateurs acceptent
Yes/YES/1. Le corps GHCR historique est conservé dans
`projects_github_release_docker`. Debian utilise
`projects_github_release_debian` dans `modules/projects/github-release.sh`,
sans dépendance à Docker ni construction. En parcours mixte, la présence du
paquet est vérifiée avant Docker, puis les deux publications sont exécutées.
La CI/CD conserve son activation Docker exacte Yes et appelle Debian seul
sans appeler Docker lorsque celui-ci n'est pas activé dans le flux.

Les contrôles de paquet, version, branche synchronisée, tag et release déjà
existante suivent Forgejo ; BUILD.md décrit le détail et les échecs partiels.
`_github_api_request` reste le transport JSON. `_github_upload_release_asset`
réalise l'upload binaire après validation de upload_url ; les tokens sont dans
une configuration curl temporaire 0600, hors arguments et journaux, nettoyée
en erreur et interruption. Les réponses HTTP/JSON et l'asset sont vérifiés.
Le contrat est `openspec/specs/projects-github-debian-release/spec.md`.

### Construction Debian déclarative

`projects_build_deb` dans `modules/projects/debian-build.sh` implémente
`rid projects build debian <ID PROJECT>`. La recette publique JSON et la lecture
littérale isolée de `PROJECT_DEBIAN_PACKAGE` évitent toute exécution de
configuration. `jq` valide les données ; `dpkg-deb --root-owner-group` assemble
le staging. Le format, les refus, la version, la rotation et les limites sont
définis dans [BUILD.md](BUILD.md). La recette DIU reste hors du paquet.
Les anciens parcours `projects deb` et `cicddiu` restent indépendants.
La référence est `openspec/specs/projects-debian-build/spec.md`.

### Métadonnées générales

Un projet géré est identifié par son répertoire sous
`${ENV_DEVOPS_PROJECTS_ROOT}` et par son fichier `project.env`.

Les variables générales obligatoires sont :

```text
PROJECT_ID
PROJECT_NAME
PROJECT_TYPE
PROJECT_DOCKERED
PROJECT_DEBIAN_PACKAGE
```

`update_projects` renseigne ces cinq variables. Elles sont également requises
pour la sélection des projets par les modèles groupés et pour la vérification
de la configuration générale avant une release Forgejo.

La configuration Git locale comprend la branche locale par défaut et
l'identité Git. `git_update_local` est responsable exclusivement de
`LOCAL_DEFAULT_BRANCH`, `GIT_USER_NAME` et `GIT_USER_EMAIL`. Le point d'entrée
public `git_update` enregistre ensuite l'exception de confiance système du
projet. La configuration générale du projet relève de `update_projects` ;
les parcours de clonage utilisent leur configuration interne dédiée.

`rid projects git init <ID PROJECT>` et `rid projects git update <ID PROJECT>`
enregistrent le chemin absolu canonique du projet dans `safe.directory` avec
`git config --system --add`. Cet enregistrement nécessite les droits
d'écriture sur la configuration Git système (normalement `/etc/gitconfig`).
Il couvre les comptes qui partagent le projet sans modifier son propriétaire.
Il est silencieux, idempotent, préserve les autres entrées et n'ajoute aucun
joker. Une entrée vide réinitialise les valeurs antérieures ; une entrée
exacte n'est considérée présente qu'après la dernière réinitialisation.
Les chemins finissant par `/*` ou contenant un saut de ligne sont refusés.
Les includes système sont lus dans leur ordre. Si un include neutralise
l'entrée du fichier principal, la commande échoue explicitement, sans
réordonner les règles administrateur ni accumuler de doublons à la relance.

L'initialisation vérifie l'exception après ses prérequis, avant le contrôle
d'un dépôt existant ; une réexécution sur un dépôt existant la met donc aussi
en place. La mise à jour ne l'enregistre qu'après le succès des variables
locales. Une erreur de lecture ou d'écriture provoque un diagnostic et un
retour non nul ; les écritures déjà effectuées ne sont pas annulées.

`rid projects git status <ID PROJECTS>` affiche `safe.directory : présente`
ou `absente`, avec la mention `système, entrée exacte` et le chemin canonique,
avant les opérations sur le dépôt. Ses replis de configuration utilisent
`git_update_local` sans ajouter d'exception. Une erreur de lecture n'est pas
assimilée à une absence. Ce diagnostic décrit l'entrée système exacte,
pas la confiance effective de tous les comptes : une configuration globale
prioritaire peut en changer l'effet. Une règle large déjà présente n'est
ni modifiée ni présentée comme l'entrée exacte du projet.

La session de validation utilise uniquement des configurations Git temporaires
isolées. Aucun dépôt n'est migré automatiquement. Un retour aux sources
précédentes laisse les exceptions déjà installées en place ; leur révocation
éventuelle est une opération distincte limitée à l'entrée du projet concerné.

`PROJECT_ORCHESTRATED_CODING` déclare le mode de développement : `No` pour
un agent de codage autonome, `Yes` pour un agent piloté par un orchestrateur.
La variable est facultative pour les projets existants ; son absence ou une
valeur littérale vide vaut `No`. `rid projects create <ID PROJECT>` et
`rid projects update <ID PROJECT>` la demandent avec la valeur enregistrée,
sinon `No`. Une entrée vide conserve le défaut, une autre réponse que `Yes`
ou `No` est redemandée ; une fin d'entrée empêche l'enregistrement.

`project_orchestrated_coding_get <fichier>` fournit cette valeur aux fonctions
qui en ont besoin, indépendamment des variables du shell et des projets
précédents. Il lit l'affectation littérale sans exécuter le fichier ; les
guillemets simples/doubles et le préfixe `export` sont acceptés. Une valeur
non vide invalide ou un fichier présent illisible ou non ordinaire provoque
un diagnostic sans contenu de configuration et un retour non nul. Un fichier
absent renvoie `No` sans écriture. `project_orchestrated_coding_prompt`
partage le questionnaire entre `update_projects` et `git_update_legacy`.
Le parcours historique conserve le mode dans son résumé et sa réécriture ;
la configuration Git locale et le clonage local le préservent.

La création et la mise à jour utilisent le même questionnaire : le type
propose BASH, GO, JAVASCRIPT, PERL et PYTHON sans interdire les autres valeurs ;
les options Docker et paquet Debian acceptent `Yes` ou `No`. La version
`PROJECT_VERSION` est obligatoire et conforme au format `x.y.z` sans zéro
initial ; une version existante est proposée par défaut. Une saisie invalide
est redemandée et une fin d'entrée interrompt la configuration avant écriture.
La création et la synchronisation ne copient pas `ORCHESTRATED_CODING.md` et
la synchronisation conserve les documents déjà présents. Le lecteur du mode
continue à valider la configuration avant copie.

`rid projects sync` synchronise `AGENTS.md`, `.gitignore`
et copie également
`DEVELOPMENT_MAP.md` depuis le modèle seulement si aucune entrée de ce nom
n'existe à la racine du projet, indépendamment du mode de pilotage. Cette
nouvelle copie est personnalisée et reçoit le propriétaire prévu. Une entrée
existante, même un répertoire ou un lien symbolique pendant, reste intacte
(contenu, droits, propriétaire et date de modification). La source n'est
exigée comme fichier régulier que si une copie est nécessaire ; sinon,
son absence est sans effet. Une source requise absente ou non régulière
provoque un échec avant toute copie dans ce projet. `sync all` applique cette
décision par projet et poursuit après les échecs avec un code global non nul.
En mode unitaire ou groupé,
`PROMPTS/` n'est plus exigé dans le modèle et reste exclu de la synchronisation :
une destination existante est préservée, y compris ses droits et son propriétaire,
et une destination absente n'est pas créée. Les ressources
OpenCode et CAB du projet (`.opencode/{commands,config,skills,broker}`) et le
broker global `/home/${ENV_DEVOPS_USER}/.opencode/broker` restent intacts : contenu,
droits, propriétaire et caches `__pycache__` compris. Leurs sources ne sont
pas consultées ni exigées ; leurs destinations absentes ne sont pas créées.
Le document `DEVOPS.md` reste préservé et n'est pas exigé dans le modèle.
La référence est `openspec/specs/projects-sync/spec.md`.

À la création, `create_project` exclut également l'entrée `.git` à la racine
du modèle dans sa sélection `find`, avant la copie récursive par `cp -a`.
Les autres fichiers cachés, dont `.gitignore`, sont conservés ; les exclusions
existantes de `project.env` et des documents conditionnels restent applicables.
Aucune opération Git n'est lancée par cette copie. L'exclusion ne concerne
pas les `.git` imbriqués et ne modifie aucun projet existant. La référence est
`openspec/specs/projects-template-creation/spec.md`.

Cette métadonnée ne lance aucun agent ni service. La mise à jour générale
sans identifiant et les critères de sélection des projets restent inchangés.
Aucune migration globale n'est réalisée ; les fichiers reçoivent la variable
lors de leur prochaine configuration interactive. Les références sont
`openspec/specs/implement-projects-update/spec.md` et
`openspec/specs/projects-general-update/spec.md`.

Les configurations de fournisseurs sont différentielles. Chaque fonction
`<provider>_update` valide d'abord les variables générales, puis ne modifie que
son propre bloc dans `project.env`. L'écriture passe par un fichier temporaire
et un remplacement atomique ; le fichier final reste propriété de
`ENV_DEVOPS_USER:DEVOPS_GROUP` avec le mode `660`.

### Arguments publics de construction Docker

`projects_docker_build` conserve ses contrôles existants, puis appelle
`projects_docker_load_build_args` pour lire `build/docker-build.args`.
Le fichier est optionnel ; son absence ou un contenu vide conserve la commande
sans argument supplémentaire. Chaque ligne utile suit `NOM=VALEUR` avec nom
ASCII `[A-Za-z_][A-Za-z0-9_]*`, unique et sans indentation. Une valeur vide,
les espaces, quotes, dollars, antislashs, Unicode, # et = restent littéraux.
Les blancs et commentaires # après indentation sont ignorés ; la dernière
ligne sans LF reste acceptée. CR et NUL sont refusés.

Fichier régulier et lisible, fichier et répertoire build non symboliques,
limite 65 536 octets. La lecture est également bornée si la ressource évolue
après stat, puis le descripteur est fermé. La validation complète précède
l'affectation du tableau de paires `--build-arg`, `NOM=VALEUR`. Aucun source,
eval, chargement d'environnement ou exécution de helper n'est ajouté.
Un refus bloque Docker avec catégorie et éventuellement numéro de ligne,
sans valeurs ; l'échec Docker reste non nul selon le comportement existant.

Le contenu est public et non sensible. Son accord avec une référence
applicative relève du projet consommateur. Le moteur ne peut pas déterminer
la sensibilité d'une valeur arbitraire et ne garantit pas de masquer les
arguments dans les sorties natives de Docker. Le module reste agnostique.
La référence est `openspec/specs/modify-projects-docker-build/spec.md`.
Les tests `tests/test_projects_docker_build_args.py` utilisent uniquement
fixtures, runuser/Docker simulés et actions CI/CD simulées.

### Variables des fournisseurs distants

| Fournisseur | Variables principales | Défaut notable |
|---|---|---|
| Forgejo | `REMOTE_FORGEJO_BASE_URL`, `REMOTE_FORGEJO_OWNER`, `REMOTE_FORGEJO_REPOSITORY`, `REMOTE_FORGEJO_NAME`, `REMOTE_FORGEJO_BRANCH`, `REMOTE_FORGEJO_SSL_VERIFY` | dépôt = identifiant, remote = `origin`, branche = `main`, TLS = `No` |
| GitLab | `REMOTE_GITLAB_BASE_URL`, `REMOTE_GITLAB_REGISTRY`, `REMOTE_GITLAB_OWNER`, `REMOTE_GITLAB_REPOSITORY`, `REMOTE_GITLAB_NAME`, `REMOTE_GITLAB_BRANCH`, `REMOTE_GITLAB_SSL_VERIFY` | dépôt = identifiant, remote = `origin`, branche = `main`, TLS = `No` |
| GitHub | `REMOTE_GITHUB_BASE_URL`, `REMOTE_GITHUB_OWNER`, `REMOTE_GITHUB_REPOSITORY`, `REMOTE_GITHUB_NAME`, `REMOTE_GITHUB_BRANCH` | dépôt = identifiant, remote = `origin`, branche = `main` |

`REMOTE_GITLAB_REGISTRY` est l'autorité explicite du registre Docker, sans
protocole ni chemin, avec un port éventuel conservé. Toute release GitLab
l'exige, y compris lorsque seule la publication Debian est activée.
`projects_gitlab_release` corrige séparément la configuration générale et
GitLab : seul un bloc incomplet déclenche sa fonction de mise à jour, puis
`project.env` est rechargé et revérifié. Les contrats principaux GitLab
portent ces comportements et la reprise limitée à `blob unknown to registry`.
Le change `configure-gitlab-container-registry` reste actif ; sa qualification
et son archivage restent distincts de cette synchronisation spécificative.

Les URL configurées ne contiennent pas d'identifiants. Elles servent à
construire un remote HTTPS de la forme :

```text
https://<hôte>/<propriétaire>/<dépôt>.git
```

Avant un push, le remote demandé est vérifié ou créé par la fonction dédiée
au fournisseur. Un remote absent est ajouté. Pour Forgejo, les URL de
récupération et de publication du seul remote configuré sont réalignées sur
`project.env` lorsqu'elles divergent, avec un diagnostic explicite. Les URL
multiples de ce remote sont ramenées à la seule destination déclarée ; un
échec de correction ou de vérification des URL effectives bloque le push.
Les autres remotes et `project.env` sont conservés. Une réexécution conforme
ne réécrit pas les URL. Pour GitLab et GitHub, un remote incohérent provoque
toujours un échec explicite sans remplacement.

Le remote configuré pour GitLab ou GitHub peut donc être différent de
`origin`. Un push fournisseur ne doit pas modifier le remote d'un autre
fournisseur.

La publication `rid projects github release <ID PROJECT>` construit ses
références GHCR avec `REMOTE_GITHUB_OWNER` et `REMOTE_GITHUB_REPOSITORY`
convertis en minuscules uniquement dans le chemin Docker. Le résumé CI/CD
affiche la même cible normalisée. Les variables chargées, `project.env`,
l'identité d'authentification et l'image locale restent inchangés ; la casse
du tag de version dérivé de Git est conservée. La référence est
`openspec/specs/implement-projects-github-release/spec.md`.

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
5. exécuter Git sous `ENV_DEVOPS_USER` avec `GIT_TERMINAL_PROMPT=0` ;
6. supprimer systématiquement les ressources temporaires par `trap`.

Le token n'est ni placé dans les arguments de Git, ni exposé par une invite
interactive. Toute erreur d'authentification est bloquante : aucun fallback
silencieux vers une saisie Username/Password n'est autorisé.

### Indisponibilité pendant une publication Git

Les commandes `rid projects forgejo|gitlab|github push <ID PROJECT>` distinguent
une indisponibilité reconnue d'un échec de publication. DNS, connexion TCP
impossible, délai dépassé et HTTP 502/503/504 produisent un message
« serveur indisponible — publication non confirmée » et un retour zéro.
Le code Git 128 seul ne suffit pas ; authentification, TLS, configuration et
rejet Git restent bloquants. Les diagnostics Git sont qualifiés en locale C.

Un contexte temporaire privé et sans secret transmet le signal, y compris
depuis les substitutions de commandes API. `PROJECTS_GIT_PUSH_STATUS` est un
statut d'exécution interne, réinitialisé à chaque push ; ce n'est pas une
variable de configuration. Les invites restent visibles. Les appels curl du
contexte sont bornés à 10 secondes de connexion et 30 secondes au total ;
aucune sonde réseau ni reprise automatique n'est ajoutée.

CI/CD poursuit les autres fournisseurs et les builds locaux activés, ignore les
releases du fournisseur indisponible et termine avec l'état « terminé avec
indisponibilités » si aucune autre erreur n'est rencontrée. Le parcours
`forgejo push all` distingue également ce résultat d'un succès complet.
Une coupure pendant le tag peut laisser la branche publiée : aucune annulation
automatique n'est effectuée et une reprise reste nécessaire.

Pendant les releases CI/CD, un contexte privé par fournisseur transmet les
indisponibilités reconnues des transports Git, API et Docker. Le bilan indique
une publication potentiellement partielle ; aucun rollback n'est tenté. Les
refus d'authentification, les erreurs TLS et les autres échecs restent bloquants.
Les diagnostics Docker sont qualifiés uniquement sur des motifs réseau natifs
reconnus ; un diagnostic ambigu reste une erreur.

`git_with_token` conserve le code Git original. Hors contexte de push, les
commandes de clonage et de release directe conservent leur gestion d'erreur.
Les références sont `openspec/specs/git-provider-availability/spec.md` et
`openspec/specs/projects-cicd/spec.md` ; les tests isolés sont dans
`tests/test_projects_provider_unavailable.py`.

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
`600` ou `660`. Les lecteurs Forgejo, GitHub et GitLab acceptent ces deux modes
pour les fichiers `.username` et `.token`, dans leurs parcours Git et API
existants, sans changer leur contenu ni leurs permissions. Les autres modes
sont refusés avant lecture. En mode `660`, les membres du groupe du fichier
peuvent lire et modifier les identifiants ; les permissions des répertoires
et les ACL restent inchangées.

Les nouveaux fichiers restent créés en `600` via un fichier temporaire puis
installés avec les droits de `ENV_DEVOPS_USER:DEVOPS_GROUP`. Les fichiers secrets
temporaires Git et curl restent en `600` et les répertoires temporaires privés
en `700`, avec nettoyage après utilisation, y compris en cas d'échec.

Le provider Forgejo est strict : ses transports ne demandent aucune saisie et
ne créent, suppriment ou remplacent aucun identifiant. Les parcours de push et
de release appellent forgejo_credentials_prepare avant ces transports.
Une paire absente ou incomplète passe par forgejo_credentials_setup uniquement
après consentement explicite. Un refus, une fin d’entrée, un fichier invalide
ou un token refusé ne déclenche aucun remplacement implicite.

Le setup accepte la saisie d’un token ou sa création API explicitement choisie.
Il valide une paire candidate dans un staging privé avant de publier seulement
les fichiers manquants. Les fichiers existants conservent leur contenu et leur
mode ; un échec de publication retire uniquement les nouveaux fichiers créés
par ce setup. Les temporaires sont nettoyés à la sortie. Le statut interne 3
de _forgejo_ensure_credentials désigne une paire incomplète pour l’orchestration ;
les transports exposent une erreur sans interaction. Aucun secret n’est ajouté
aux arguments des exécutables, URL ou diagnostics. Les tests sont isolés dans
tests/test_forgejo_credential_bootstrap.py.

Les modules `lib/forgejo-auth.sh`, `lib/gitlab-auth.sh` et
`lib/github-auth.sh` résolvent le remote HTTPS, vérifient les identifiants et
délèguent les opérations Git au cœur commun. L’autorité du remote GitLab est
traitée littéralement, y compris pour les adresses IPv6 entre crochets. Le token ne doit apparaître ni
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

Pour Forgejo, un dépôt existant conserve le fetch authentifié préalable et
`--force-with-lease`. Un dépôt annoncé absent ne déclenche ni fetch ni
création API : le premier push utilise
`--force-with-lease=refs/heads/<branche>:` pour attendre explicitement
l'absence de la branche distante, même si une référence de suivi locale est
héritée d'un ancien dépôt. Une création concurrente est refusée sans forçage
inconditionnel ; aucune référence locale n'est supprimée. Le tag du dernier
commit est publié sans forçage après la réussite du push de branche. La
création du dépôt reste conditionnée à la configuration push-to-create du
serveur. Les tests locaux sont dans `tests/test_projects_forgejo_push.py`.

La release du paquet DIU vers Forgejo est un parcours distinct. Il vérifie le
paquet présent dans `dist/`, ses métadonnées et l'état Git, puis utilise l'API
Forgejo pour créer ou alimenter une release sans remplacer une release
existante. Les détails du build, des deux syntaxes CLI, du projet source et de la sélection de version V2 restent dans `BUILD.md`.

`rid diu update` consulte d'abord anonymement les releases publiques de
`https://github.com/AzenorPixs/diu`, sans checkout, configuration ni jeton
GitHub. Curl ignore sa configuration personnelle pour éviter toute authentification
implicite. Si GitHub fournit un paquet admissible, il est retenu même si Forgejo
dispose d'une version supérieure ; une version installée égale ou supérieure
termine sans consulter Forgejo. Si GitHub est inaccessible, renvoie une réponse
invalide ou ne fournit aucun paquet admissible, le bloc Forgejo du projet local
est analysé indépendamment s'il est disponible et ses releases publiques sont
consultées en secours. GitLab est ignoré. Sans candidat, la commande échoue.

Avec `rid diu update <VERSION>`, la version Debian exacte est recherchée dans
les releases GitHub publiques seulement. Un candidat admissible est installé
même si la version locale est égale ou supérieure ; une version invalide,
absente ou inaccessible échoue sans secours Forgejo. Les métadonnées du paquet
restent vérifiées avant installation. Les arguments supplémentaires sont refusés.

Chaque source est paginée ; les brouillons et préversions sont exclus et les
versions stables x.y.z sont prioritaires avant comparaison Debian des assets
`diu_<version>_all.deb` associés au tag `v<version>`. Le paquet est vérifié
(nom, version, architecture) avant `dpkg` ; les temporaires sont supprimés.
Toute erreur après sélection (téléchargement, validation ou installation) bloque
sans essai sur l'autre source. `rid update diu` est un alias compatible.
La recherche et le téléchargement activent `curl --compressed` : les
encodages HTTP pris en charge localement, dont Zstandard lorsque disponible,
sont décodés avant l'analyse JSON et les contrôles du paquet. Un échec de
décodage est signalé et bloque l'installation. Les tests HTTP locaux utilisent
des réponses Zstandard et un paquet de fixture, sans installation réelle.

### Validation HTTP du lien d’asset Debian GitLab

projects_gitlab_release_debian vérifie séparément le succès du transport et
le statut HTTP final de création du lien d’asset. Une réponse hors 2xx ou
inexploitable arrête la publication sans message de succès. Le corps de réponse
n’est pas journalisé et aucun réessai ou effacement distant n’est ajouté.
Les tests de tests/test_projects.py utilisent uniquement des transports simulés.

## Orchestration des mises à jour

`rid update` est routé par `manage_update_action` vers `update_all` lorsqu'il
n'a pas d'argument. `rid update diu` reste limité à la mise à jour du DIUE.
Une commande avec moteur explicite reste limitée à ce moteur.

Le parcours actuel dans `modules/diu/update-all.sh` appelle successivement
`diu_update`, `system_update`, `environments_update`, `ia_update`,
`projects_update` puis `softwares_update`. La mise à jour des projets décrite
ci-dessus est donc incluse une seule fois. Son échec est mémorisé : le module
softwares est encore appelé, puis le code non nul projects est rendu. Lorsque
projects réussit, une erreur DIU est conservée ; si DIU et projects réussissent,
le code final softwares est conservé.

Chaque fonction appelée définit ses propres prérequis et traitements.
`environments_update` retourne actuellement un succès sans opération.
`softwares_update` délègue aux moteurs APT, GitHub et Flatpak du module.
`update_all` n'implémente pas d'isolation généralisée des participants, de
signalement uniforme des modules non applicables ou de bilan global enrichi.
La spécification de référence est `openspec/specs/universal-update/spec.md`.

La fonction `diu_update` exécute `update_diu` dans un sous-shell et revient
au parcours appelant après l’installation ; cette isolation propre au DIU ne
décrit pas le traitement de tous les participants.

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
sur les projets sont exécutées sous `ENV_DEVOPS_USER` afin de préserver le
propriétaire et l'environnement du dépôt.

## Validation technique

Les fixtures de mise à jour globale suivent le contrat courant : diu, system,
environments, ia, projects puis softwares. Elles simulent et journalisent
les frontières des modules ; les wrappers DIU/IA sont contrôlés séparément.
La configuration Git système des tests est redirigée vers des fichiers de
fixture, sans droit supplémentaire ni modification de /etc/gitconfig.

La référence Z1 du générateur Zsh est adoptée avec son inventaire de 14 fonctions
et un bloc de données littéral. Les empreintes sont contrôlées sans modifier
le générateur. Le pipeline APT est vérifié par nombre d’appels, contenu transmis
et préservation des trousseaux ; l’ordre de démarrage curl/gpg n’est pas imposé.

Les annotations ShellCheck locales distinguent les usages indirects Bash
(portée dynamique, variables chargées par source et résultats des modules),
les expansions volontairement différées et les diagnostics dont la structure
existante est conservée. Les marqueurs de dpkg-deb (Package et Version) sont
littéraux. Aucune désactivation globale n’est appliquée.


Les tests isolés sont regroupés dans `tests/test_*.py`. Ils couvrent notamment
la configuration et les variables système, les dépôts APT et les prérequis,
les moteurs logiciels et Flatpak, DisplayLink, l'aide CLI, les projets et
leurs modèles OpenSpec et DevOps, ainsi que les préparations DevOps.
Le répertoire `tests/` fournit l'inventaire des fichiers présents. Cette liste
de domaines n'est pas exhaustive et ne constitue pas une preuve de réussite
des tests ni de couverture complète des comportements.

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
sous l'utilisateur `ENV_DEVOPS_USER`. Les commandes de validation strictes
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
- seul le remote Forgejo configuré est réaligné automatiquement sur
  `project.env` ; les remotes GitLab et GitHub incohérents restent refusés ;
- une nouvelle recette logicielle doit être explicitement enregistrée et
  testée ;
- un déplacement, un renommage, une suppression ou une modification de
  convention nécessite l'autorisation prévue par `AGENTS.md`.

Toute évolution doit être minimale, réversible lorsque possible et limitée
aux fichiers nécessaires. Les fonctionnalités non documentées par une
spécification OpenSpec validée ne doivent pas être introduites par ce seul
document.

## Informations des modules

Chaque module fournit un fichier `infos.sh`. `rid infos` appelle directement,
dans cet ordre, desktop, diu, environnements, ia, projects, softwares et system.
Chaque commande `rid <module> infos` affiche au moins le titre du module.
La commande française `environnements` correspond au dossier `modules/environments/`.
`rid diu infos` réutilise `diu_version` pour afficher la version du paquet DIU
installé ; une version indisponible produit un diagnostic et un statut non nul.

`modules/system/infos.sh` contient :

- `system_info_network`, appelée par `rid system infos network`, conserve
  l'affichage des interfaces Ethernet 1 et 2 UP de l'ancienne `display_infos` ;
- `system_info_debian`, appelée par `rid system infos debian`, affiche les blocs
  SYSTEM DEBIAN, SYSTEM APT OFFICIAL, SYSTEM APT UNOFFICIAL et SYSTEM FLATPAK ;
- `system_info_drivers`, appelée par `rid system infos drivers`, affiche
  `SYSTEM_DRIVERS_DISPLAY_LINK`, puis la version du paquet `displaylink-driver`
  uniquement si la variable vaut `1`. Le paquet doit être en état `installed`
  avec une version non vide. Une lecture impossible affiche une version `UNSET`,
  un diagnostic et un statut non nul, sans modifier la configuration ;
- `system_info`, appelée par `rid system infos`, affiche le titre SYSTEM puis
  les informations Debian, pilotes, réseau dans cet ordre. Cette agrégation
  est également utilisée par `rid infos`. `rid system update` reste inchangé.

Les variables affichées sont explicitement sélectionnées, sous forme NOM=valeur.
Une variable absente affiche UNSET ; une valeur vide est préservée. L'ordre
exact est défini par la spécification OpenSpec `module-infos`.
Les agrégateurs poursuivent les autres blocs après un échec et renvoient un
statut non nul. Les fonctions d'information ne réalisent aucune mutation ;
le bootstrap historique de chargement et génération de configuration demeure.
Les commandes infos terminent avant l'installation linéaire. Leur aide et
celle des contextes intermédiaires restent disponibles avant le bootstrap.

## État statique DisplayLink

`modules/diu/variables/system/system_drivers_display_link.sh` déclare
`SYSTEM_DRIVERS_DISPLAY_LINK`, `STATIC`, `ENABLE`, scope `system`.
À la première initialisation, `variable_generator` interroge les paquets
`displaylink-driver` et `evdi-dkms` via `dpkg-query` : deux paquets en état
`installed` donnent `1` ; un paquet absent ou dans un état incomplet reconnu
produit `0` si les deux interrogations sont interprétables. Une erreur, un
outil absent ou un statut inexploitable produit `UNSET` avec diagnostic, même
si l'autre paquet est absent.

La valeur détectée est persistée dans `/root/diu/config/system.env`, puis
exportée. Une valeur existante `0`, `1` ou `UNSET` est conservée ; une valeur
invalide provoque une erreur sans écriture. Les échecs de persistance sont
propagés. L'état n'est pas recalculé après une installation externe.

La découverte initiale décrit les paquets, pas le fonctionnement du dock ni des
écrans. Une installation manuelle hors paquets Debian n'est pas couverte.
La valeur statique ne commande aucune installation automatique. Les commandes
explicites ci-dessous mettent à jour cet état après leurs contrôles finaux.

Le nettoyage retire l'ancienne affectation `DISPLAY_LINK` avant le chargement
de `variables.sh`, sans transférer son ancienne valeur ni la sauvegarder.

## Commandes DisplayLink

`modules/system/drivers.sh` expose :

- `system_drivers_install_displaylink` : `rid system drivers install displaylink` ;
- `system_drivers_remove_displaylink` : `rid system drivers remove displaylink`.

L'installation accepte seulement `SYSTEM_DEBIAN_ENVIRONNEMENT=PHYSICAL` ou
`PROXMOX`, quelle que soit la valeur statique DisplayLink. Elle installe ou
répare `dkms`, `displaylink-driver`, `evdi-dkms` et `libevdi-dev`. Ce dernier
fournit le lien `libevdi.so` utilisé par le gestionnaire DisplayLink. Les
headers du noyau courant sont requis : `linux-headers-<uname -r>` sur Debian,
`proxmox-headers-<uname -r>` ou `pve-headers-<uname -r>` pour un noyau PVE.
Les dépôts configurés doivent déjà fournir DisplayLink et ces dépendances.

Pour Linux 7.x, EVDI doit être au minimum 1.15.1. Une version installée
suffisante est conservée ; sinon un candidat APT suffisant est privilégié.
En dernier recours, le paquet officiel Debian est téléchargé depuis
`https://deb.debian.org/debian/pool/main/e/evdi/evdi-dkms_1.15.1+dfsg-1_all.deb`.
Son SHA256 fixé est
`afed3ea5fe42b3d4aea3bcc20c7f1baa894d8d07d292c34dd93f419de9493a1a` ;
nom, version et architecture sont aussi vérifiés avant APT. Aucun dépôt
sid/testing n'est ajouté. Le téléchargement utilise `curl`, déjà dans les
prérequis ; les contrôles utilisent les outils Debian existants. Une seule
transaction installe EVDI et ses dépendances. Ce minimum a été compilé pour
7.0.12 ; il ne garantit pas les futurs noyaux 7.x.

Avant de persister puis exporter `SYSTEM_DRIVERS_DISPLAY_LINK=1`, la commande
vérifie les paquets configurés, les headers, DKMS pour le noyau courant,
`libevdi.so`, le chargement du module et le service actif. La signature source
du module chargé est comparée à celle du module installé (`srcversion`). Un
module ancien est déchargé après arrêt du service puis rechargé. S'il reste
utilisé, la commande échoue explicitement. Une installation saine ne réinstalle
pas les paquets et ne redémarre pas le service. Aucun dock connecté n'est requis.

La suppression reste disponible dans tous les environnements. Elle arrête le
service, simule la suppression et refuse des suppressions supplémentaires,
retire `displaylink-driver` et `evdi-dkms` sans autoremove, puis contrôle leur
absence et le déchargement du module avant de persister puis exporter `0`.
DKMS, headers et bibliothèques partagées sont conservés. Un état déjà absent
réussit sans transaction APT.

La persistance remplace atomiquement l'affectation dans
`/root/diu/config/system.env` et préserve les autres lignes et les permissions
existantes. En cas d'échec, la valeur antérieure reste conservée. Une transaction
APT partiellement effectuée ou un service déjà arrêté ne sont pas annulés
automatiquement. Une nouvelle exécution reprend à partir de l'état constaté.
Les commandes ne valident pas l'activation des écrans dans GNOME ; celle-ci
reste à contrôler sur le poste.

### Configuration des hôtes réseau

`system_network_hosts` lit toujours `/root/diu/config/hosts.json`, quel que soit
le point d'entrée. Il crée les fichiers de production et de développement
absents avec un tableau vide, puis valide les couples de production avant la
génération. Un JSON invalide préserve `/etc/hosts`. Les commandes `projects
system network` gèrent exclusivement le JSON de production ; après ajout,
les couples sont triés par IP numérique puis par FQDN. Le paquet inclut un
modèle vide comme conffile Debian.
