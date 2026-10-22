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

### Accès sudo sans mot de passe au compte DevOps

À la fin du bloc `ENV_DEVOPS=1`, `configure_devops_sudoers` génère
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

À la fin de la branche active du bloc `ENV_DOCKER=1`, avant son `else` de
désactivation, `configure_docker_sudoers` génère
`/etc/sudoers.d/99-diu-docker` si `ENV_DOCKER_USER` existe. Chaque compte humain
retenu reçoit `compte ALL=(ENV_DOCKER_USER) NOPASSWD: ALL`, avec les noms réels.
La sélection UID/shell, les exclusions et les contrôles de publication sont
identiques à ceux décrits pour DevOps, y compris l'exclusion des comptes
configurés DevOps, Docker et IA. Un bloc désactivé ou un compte absent ne
révoque pas de règles déjà installées.

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
bloc `ENV_DEVOPS=1` et `PYTHON=1` conserve en commentaires l'installation,
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
`${DEVOPS_PROJECTS_ROOT}/<ID PROJECT>` (à défaut,
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

`projects_template_devops_render` produit la version documentaire `0.6`.
Après le titre et la version, le document identifie DIU comme générateur,
indique le début du relevé en UTC au format `YYYY-MM-DDTHH:MM:SSZ` et publie
la classification fournie par `SYSTEM_DEBIAN_ENVIRONNEMENT`.

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
dépendances Python proviennent uniquement de
`[project].dependencies` dans `pyproject.toml` et sont recherchées d'abord
dans les venv du projet, puis avec le Python DevOps en repli explicite.
L'inventaire ne vaut ni qualification fonctionnelle, ni validation d'un
environnement Python unique, ni preuve de réussite des tests du projet.

Les parcours individuel, groupé et final de création produisent cet en-tête
une seule fois. Le titre, l'ordre relatif des rubriques existantes, les sondes,
les droits et le propriétaire sont conservés. À observations identiques, le contenu technique
reste identique hors horodatage. Les anciens documents prennent le format
`0.6` lors de leur prochaine génération normale ; aucune migration ni retouche
manuelle n'est nécessaire. La référence est
`openspec/specs/projects-template-devops/spec.md`.

La rubrique « Prompts », après le gestionnaire de paquets Python et avant les
tests navigateurs, indique le dossier `/home/${ENV_DEVOPS_USER}/datas/prompts`
et son index `/home/${ENV_DEVOPS_USER}/datas/prompts/INDEX.md`. Ces chemins
réutilisent le domicile DevOps construit depuis `ENV_DEVOPS_USER`, indépendamment
de `DEVOPS_PROJECTS_ROOT`. La rubrique ne lit, ne sonde ni ne crée ces ressources ;
leur absence n'empêche pas la génération.

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
`DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK` et `TIME_ZONE`, avec `export` facultatif et espaces initiaux éventuels.
Elle conserve les autres variables, commentaires et noms voisins.

La fonction accepte un chemin de fichier optionnel, ce qui permet les tests
isolés. Elle est idempotente : l'absence du fichier ou l'absence de la ligne à
supprimer est un succès sans réécriture. Toute erreur de lecture ou d'écriture
bloque le chargement suivant.

Les consommateurs utilisent `SYSTEM_DEBIAN_RELEASE` et
`SYSTEM_DEBIAN_ENVIRONNEMENT`, `SYSTEM_DRIVERS_DISPLAY_LINK` et `SYSTEM_TIME_ZONE`. Les valeurs historiques ne sont pas transférées.
Le nettoyage intervient à la prochaine exécution du DIU, sans sauvegarde
automatique des anciennes affectations supprimées.

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

La création depuis le modèle et `rid projects sync <ID PROJECT>` utilisent
ce lecteur sur la configuration destination avant la copie. Le document
racine `ORCHESTRATED_CODING.md` est copié, personnalisé et reçoit le
propriétaire prévu seulement pour `Yes`. Pour `No`, absence ou valeur vide,
la source n'est pas requise et une destination existante reste intacte,
y compris ses attributs. Pour `Yes`, une source absente ou non régulière
provoque un échec avant toute copie du modèle. À la création, le répertoire
et la configuration déjà préparés sont conservés en cas d'échec. `sync all`
décide séparément pour chaque projet et poursuit après échec avec un résultat
global non nul. Les commandes `template openspec`, `template devops` et
`template all` restent indépendantes de cette copie documentaire.

`rid projects sync` synchronise uniquement `AGENTS.md`, `.gitignore`
et le protocole conditionnel décrit ci-dessus. En mode unitaire ou groupé,
`PROMPTS/` n'est plus exigé dans le modèle et reste exclu de la synchronisation :
une destination existante est préservée, y compris ses droits et son propriétaire,
et une destination absente n'est pas créée. Les ressources
OpenCode et CAB du projet (`.opencode/{commands,config,skills,broker}`) et le
broker global `/home/${DEVOPS_USER}/.opencode/broker` restent intacts : contenu,
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
`DEVOPS_USER:DEVOPS_GROUP` avec le mode `660`.

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
5. exécuter Git sous `DEVOPS_USER` avec `GIT_TERMINAL_PROMPT=0` ;
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

CI/CD poursuit les autres fournisseurs et le build local activé, ignore les
releases du fournisseur indisponible et termine avec l'état « terminé avec
indisponibilités » si aucune autre erreur n'est rencontrée. Le parcours
`forgejo push all` distingue également ce résultat d'un succès complet.
Une coupure pendant le tag peut laisser la branche publiée : aucune annulation
automatique n'est effectuée et une reprise reste nécessaire.

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
existante. Les détails du build du paquet restent dans `BUILD.md`.

`update_diu` consulte publiquement la dernière release Forgejo du paquet DIU,
compare les versions Debian, télécharge l'artefact attendu, vérifie son nom et
sa version, puis l'installe avec `dpkg`. Ce parcours public n'utilise pas les
identifiants Forgejo/Git.

## Orchestration des mises à jour

`rid update` est routé par `manage_update_action` vers `update_all` lorsqu'il
n'a pas d'argument. `rid update diu` reste limité à la mise à jour du DIUE.
Une commande avec moteur explicite reste limitée à ce moteur.

Le parcours actuel dans `modules/diu/update-all.sh` appelle successivement
`system_update`, `diu_update`, `environments_update`, `ia_update`,
`projects_update` puis `softwares_update`. La mise à jour des projets décrite
ci-dessus est donc incluse une seule fois. Son échec est mémorisé : le module
softwares est encore appelé, puis le code non nul projects est rendu. Lorsque
projects réussit, le code final softwares est conservé.

Chaque fonction appelée définit ses propres prérequis et traitements.
`environments_update` retourne actuellement un succès sans opération.
`softwares_update` délègue aux moteurs APT, GitHub et Flatpak du module.
`update_all` n'implémente pas d'isolation généralisée des participants, de
signalement uniforme des modules non applicables ou de bilan global enrichi.
La spécification de référence est `openspec/specs/universal-update/spec.md`.

La fonction `diu_update` exécute `update_diu` dans un sous-shell. L'installation
par `exec dpkg --install` remplace ainsi ce sous-processus et permet le retour
au parcours appelant ; cette isolation propre au DIU ne décrit pas le
traitement de tous les participants.

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
