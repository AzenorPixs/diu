# Debian Installer Unifié (DIU)

La normalisation du compte DevOps applique `2770` aux répertoires et `0770`
aux fichiers ordinaires et aux clés HMAC du journal CAB ; les fichiers sensibles
conservent leurs règles spécifiques.

Les moteurs logiciels se pilotent avec `diu system engine install apt|github|flatpak` et `diu system engine remove apt|github|flatpak`. L’activation vérifie les dépendances et la désactivation conserve les paquets installés. L’état `SYSTEM_FLATPAK` existant est repris dans `SYSTEM_FLATPAK_ENGINE` ; `SYSTEM_APT_ENGINE` vaut 1 par défaut. La vue `diu infos softwares` tient compte de ces états.

`diu infos softwares` présente les logiciels déclarés par moteur, avec un indicateur de disponibilité et la couleur de leur état configuré. La même vue figure dans `diu infos` ; `diu softwares infos` reste disponible. Un état inconnu est marqué `?`.

Le paquet issu du constructeur historique crée le lien `diu` lors de sa
configuration si son nom est libre. Le constructeur générique ne fournit pas
ce script de configuration. Après une exécution de DIU, le lien `diut` est
créé si `${ENV_DEVOPS_PROJECTS_ROOT}/diu/root-install-debian.sh` existe et si
son nom est libre. Le script installé vérifie aussi `diu` à chaque démarrage
en root, même pour l’aide, et le crée si le nom est libre. Les chemins déjà
occupés dans `/usr/local/bin` sont conservés. Les alias générés utilisent
`diu` et `diut`, avec les raccourcis `diuo` (ouverture), `diuu` (mise à jour)
et `ndiu` (édition du script installé). Les anciens alias DIU ne sont plus
générés ; les fichiers d’alias et les sessions shell existants ne sont pas
migrés automatiquement.

Le DIU installe et configure Debian grâce à une architecture modulaire en
Bash. Le module `projects` gère également les projets de développement et
leurs publications Forgejo.

`diu system update` lance `diu system engine update` puis `diu system network update`. La mise à jour des moteurs enchaîne les parcours `diu system engine apt update`,
`diu system engine github update` et `diu system engine flatpak update`. Le parcours APT produit son bilan Debian ; GitHub vérifie le moteur et
met à jour Codex CLI lorsqu’il est configuré ; Flatpak vérifie ses dépendances
et Flathub. Chaque parcours ciblé est indépendant. Les anciennes commandes
`diu system apt update`, `diu system github update` et `diu system flatpak update`
ne sont plus acceptées. Les anciennes syntaxes
`diu system update apt [debian]`, `diu system update debian` et
`diu system update flatpak` ne sont plus acceptées.

`diu system network hosts` affiche `/etc/hosts`. `diu system network hosts update`
reconstruit ce fichier et affiche une coche verte si la mise à jour réussit ;
en cas d’échec, une croix rouge indique brièvement la cause. La génération utilise les
interfaces détectées. `diu system network update`, `diu system update` et
`diu update` effectuent aussi cette opération. Les entrées préexistantes,
y compris les anciens noms Docker, ne sont pas conservées. Les couples IP/FQDN
configurés dans `/root/diu/config/hosts.json` sont ajoutés après les lignes
standard, y compris avec `diut`. Un fichier absent est créé avec `[]` ;
un fichier invalide empêche la reconstruction. Le fichier de développement
absent est aussi créé vide, sans être utilisé pour générer `/etc/hosts`.

Les commandes `diu system network hosts add <IP> <FQDN>`, `del <IP> <FQDN>`,
`hosts del all` et `hosts list` gèrent uniquement le JSON de production. Après un ajout,
les couples sont triés par IP numérique, IPv4 avant IPv6, puis par FQDN.

`diu diu update` recherche anonymement le paquet Debian dans les releases
publiques de [AzenorPixs/diu](https://github.com/AzenorPixs/diu), sans
configuration locale ni authentification GitHub. GitHub est prioritaire : un
paquet admissible y est retenu sans consulter Forgejo, même si Forgejo propose
une version plus récente. Si GitHub est inaccessible ou ne fournit aucun
paquet admissible, les releases publiques de Forgejo sont interrogées en
secours si leur configuration locale est disponible. GitLab est ignoré.
La commande contrôle la version et les métadonnées du paquet avant installation.

`diu diu update 1.1.7` installe exactement la version 1.1.7 si son paquet est
présent dans une release GitHub admissible, même si cette version est déjà
installée ou si la version locale est plus récente. Une version explicite
absente ou inaccessible entraîne une erreur sans secours Forgejo.

`diu update diu` reste un alias de `diu diu update`.

Les indicateurs `ENV_DEVOPS_TESTS_DOCKER` et `ENV_DEVOPS_TESTS_LXC` sont
initialisés indépendamment à `0` dans `/root/diu/config/environnements.env`
lorsqu'ils sont absents, puis exportés. Les valeurs existantes, même vides,
sont conservées ; les réexécutions normales ne créent aucun doublon.
Les nouvelles lignes de ces deux indicateurs portent un retrait de huit
espaces avant `export` ; les lignes déjà présentes ne sont pas reformatées.
Une erreur de persistance est bloquante. Cet ajout ne lance aucun test Docker
ou LXC ; les valeurs seront générées à la prochaine exécution normale du DIU
mis à jour.

La création avec `diu projects create <ID PROJECT>` et la mise à jour des
variables avec `diu projects update <ID PROJECT>` demandent
`PROJECT_ORCHESTRATED_CODING` : `No` pour un agent de codage autonome, `Yes`
pour un agent piloté par un orchestrateur. La valeur existante est proposée,
sinon `No` ; une entrée vide conserve ce défaut. Une variable absente dans
`project.env` vaut `No`, sans migration globale ni activation automatique.

La création et la mise à jour demandent également le nom, le type (BASH par
défaut, GO, JAVASCRIPT, PERL et PYTHON sont proposés), les options Docker et
paquet Debian (`Yes` ou `No`, `No` par défaut) et `PROJECT_VERSION` au format
`x.y.z`. La mise à jour propose la version existante ; une version est requise
si elle est absente.

À la création, `.worktrees/`, `config/`, `output/`, `.cab-tests/` et
`openspec/` ne sont pas copiés depuis le modèle. Les trois dossiers `config/`,
`output/` et `.cab-tests/` sont créés vides ; OpenSpec est initialisé ensuite.

`diu projects sync <ID PROJECT>` (y compris `sync all`) synchronise uniquement
les fichiers `AGENTS.md` et `.gitignore`. Les autres fichiers, notamment
`DEVELOPMENT_MAP.md`, `CHANGELOG.md` et `DEVOPS.md`, restent intacts. Il crée `.cab-tests`
à la racine du projet lorsque le dossier manque ; son contenu existant est
conservé et aucun contenu n'est copié depuis le modèle.
Les autres dossiers, notamment `.git`, `.worktree` et `output`, ne sont pas
synchronisés.

La création exclut le `.git` à la racine du modèle : son dépôt Git n'est pas
transféré au nouveau projet. Les autres fichiers cachés, dont `.gitignore`,
restent copiés selon les règles existantes. Cette exclusion ne concerne pas
les `.git` imbriqués et ne modifie aucun projet existant.

`diu projects git init <ID PROJECT>` et `diu projects git update <ID PROJECT>`
ajoutent une exception Git `safe.directory` système limitée au chemin réel du
projet, pour permettre son utilisation par les comptes qui le partagent.
L'ajout nécessite les droits d'écriture système, reste sans doublon et ne
modifie ni le propriétaire du projet ni les autres exceptions. Une erreur
est bloquante ; les écritures précédentes restent en place.

`diu projects git status <ID PROJECTS>` indique la présence ou l'absence de
cette entrée système exacte et son chemin, sans l'ajouter. Des règles Git
globales prioritaires peuvent modifier son effet pour un compte donné.
Les détails figurent dans [le cadrage technique](TECHNICAL.md).

La version du projet peut être déclarée dans `project.env` :

```text
PROJECT_VERSION=1.0.0
```

Cette clé optionnelle est prioritaire pour les commits/tags, les builds Debian
et Docker et leurs publications. Le format est `x.y.z`, sans préfixe v ni zéro
initial sur les trois entiers sauf 0. Une valeur présente vide, invalide ou
dupliquée provoque une erreur ; sans clé, les mécanismes antérieurs restent
inchangés. Debian utilise d'abord cette valeur, puis la recette et les tags
selon le constructeur. Docker produit les tags VERSION et latest.
Le tag Git local est `v1.0.0` et ne change pas de commit. Les pushes directs
acceptent une version explicite ou utilisent un horodatage ; une version déjà
attribuée est rejouée isolément. La réconciliation CI/CD peut remplacer un tag
distant divergent sous protection de sa valeur observée. Pour une nouvelle livraison après attribution d'un tag,
incrémenter PROJECT_VERSION. Un arbre inchangé ne crée pas de commit vide.
Les publications Docker utilisent l'image locale versionnée et refusent une
image absente ; les publications Debian refusent un paquet de version différente.
Les aides de commit, push, CICD et build rappellent ce contrat avant bootstrap.
Les [règles techniques](TECHNICAL.md) et le [packaging](BUILD.md) détaillent les contrôles.

Le flux `diu projects cicd <ID PROJECT> [VERSION]` accepte une version `x.y.z`
facultative. Elle est enregistrée dans `PROJECT_VERSION` avant le traitement.
Une version `PROJECT_VERSION` déjà attribuée est rejouée depuis une copie isolée du commit de
son tag : les modifications locales en attente restent disponibles et ne sont
pas incluses. Le tag local reste inchangé. Avant chaque push, DIU refuse un
tag distant supérieur ou non comparable. Sinon la branche distante est alignée
sur le commit sélectionné et le tag divergent est remplacé, avec protection par
leur valeur observée. Une version stable prime sur un horodatage. Le contrôle
des autres tags est une photographie avant le push : leur création concurrente
n’est pas couverte par le lease. Si le tag est remplacé, la publication des
artefacts de cette forge est ignorée et leur cohérence reste à vérifier. Le paquet issu du rejeu est conservé sous
`dist/replay/<TAG>/<SHA256>/` sans écraser un fichier existant. La publication Docker
est ignorée lors du rejeu, DIU ne vérifiant pas l'immutabilité du tag distant ;
les publications Debian restent indépendantes. Avec un
arbre inchangé et un tag local absent, le tag peut être créé sur le commit
courant sans commit vide ; les tags distants sont contrôlés avant publication. La forme historique explicite
`diu projects cicd <ID PROJECT> <MESSAGE> <TAG>` reste disponible.

Le flux exécute six étapes :

1. Commit et tag.
2. Pushes Git configurés.
3. Build Docker activé.
4. Build Debian, uniquement pour `PROJECT_DEBIAN_PACKAGE=Yes/YES/1`.
5. Publications des artefacts activés.
6. Bilan des deux builds et des publications.

Le build Debian fonctionne aussi sans Docker et utilise le même moteur que
`diu projects build debian <ID PROJECT>`. Une recette absente pour un projet
activé ou un échec du build empêche les releases ; les pushes déjà réalisés
restent publiés. Debian seul peut être publié sur Forgejo/GitLab/GitHub selon
leur configuration ; les conditions Debian GitHub sont les mêmes que Forgejo.
Un asset Debian déjà présent est signalé sans prétendre que son contenu a été
vérifié ; un asset manquant peut être ajouté sans remplacer les fichiers présents.
Les messages de publication identifient la forge, le tag et les contrôles
effectivement réalisés, sans afficher les identifiants secrets.
`diu projects cicd help` et `diu projects cicd <ID PROJECT> help` décrivent ces
étapes avant bootstrap. Le détail figure dans [BUILD.md](BUILD.md).

Pour les sélections de versions DIU, une version stable `x.y.z` est prioritaire
sur un horodatage. Aucun epoch n'est ajouté au paquet Debian : `dpkg` et APT
conservent leur propre ordre de versions, y compris pour un ancien paquet
horodaté déjà installé.

Pour construire le paquet Debian d'un projet :

```bash
diu projects build debian <ID PROJECT>
```

La syntaxe `diu projects build deb <ID PROJECT>` reste un alias compatible.

Le projet fournit `build/debian-package.json`, qui décrit les métadonnées et
les copies ; elle peut fixer le mode octal d’un fichier et reste hors du paquet. `PROJECT_DEBIAN_PACKAGE`
dans `project.env` doit valoir `Yes`, `YES` ou `1`. Sinon, la commande informe
que le projet ne produit aucun paquet Debian et termine sans construction.
Pour un projet activé, une recette absente empêche le build avec une erreur.
Le résultat est déposé dans `dist/` ; les anciens paquets de même nom et
architecture y sont supprimés après succès. Le format et les contrôles sont
décrits dans [BUILD.md](BUILD.md). L'aide est disponible avec
`diu projects build debian help` ou `?`, avant bootstrap.
La recette DIU reproduit le paquet historique, avec un point d’entrée toujours exécutable ; `diu projects deb diu` et
`rcicddiu` conservent leur fonctionnement. Aucun paquet n'est installé par le build.

Pour construire une image avec `diu projects docker build <ID PROJECT>`, le
projet peut fournir le fichier public optionnel `build/docker-build.args` :

```text
# Paramètres publics propres à ce projet
APP_VERSION=1.2.3
BUILD_MODE=release
```

DIU transmet ces lignes comme arguments Docker, sans interprétation shell.
Les quotes restent dans la valeur, les dollars ne sont pas développés et une
valeur vide reste vide. Les commentaires/blancs sont ignorés. Noms invalides,
doublons, CR/NUL, liens symboliques, fichiers non réguliers/illisibles ou
supérieurs à 64 Kio bloquent la construction. La dernière ligne sans LF est
acceptée. Le fichier ne doit contenir aucun secret ; les paramètres et leur
cohérence applicative restent dans chaque projet. Sans fichier, le parcours
existant est conservé. Aucun helper applicatif n'est exécuté.

Le [dossier de validation](openspec/changes/archive/2026-10-15-support-project-docker-build-args/review.md)
et son [rapport d'archive](openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTIQUES.md)
conservent les preuves et limites de cette évolution.

Pour publier les artefacts activés d’un projet :

```bash
diu projects forgejo release <ID PROJECT>
```

La commande publie l’image Docker et/ou le paquet Debian selon
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` dans `project.env`.

Pour publier les artefacts déjà construits vers GitHub :

```bash
diu projects github release <ID PROJECT>
```

`PROJECT_DOCKERED=Yes/YES/1` publie l'image sur GHCR et
`PROJECT_DEBIAN_PACKAGE=Yes/YES/1` publie le .deb dans GitHub Releases.
Les deux activations peuvent être utilisées ensemble ; aucune construction
n'est déclenchée par cette commande. Comme sur Forgejo, un paquet unique et
cohérent, une version valide, un HEAD synchronisé et un tag correspondant sont
requis. Une release existante n'est jamais remplacée ; un upload échoué laisse
une erreur explicite et éventuellement une release incomplète, sans rollback.
Les contrôles et cas de repli sont détaillés dans [BUILD.md](BUILD.md).

Le propriétaire et le dépôt sont convertis en minuscules dans les références
GHCR, y compris dans le résumé CI/CD : `AzenorPixs/PKeycloak` devient
`ghcr.io/azenorpixs/pkeycloak`. La configuration GitHub conserve sa casse ;
les tags Docker sont la version issue de l'unique tag Git de `HEAD` et `latest`.
Cette commande ne construit pas l'image.

`diu projects forgejo push <ID PROJECT>` réaligne automatiquement les URL de
récupération et de publication du remote Forgejo configuré sur `project.env`,
notamment si elles pointent encore vers le modèle. Ce remote utilise ensuite
la seule destination déclarée ; les autres remotes sont conservés. Une erreur
de réalignement bloque la publication. Pour un dépôt annoncé absent, le
premier push attend explicitement l'absence de la branche distante : une
ancienne référence de suivi locale ne le bloque plus et une création
concurrente reste protégée. La création du dépôt dépend de l'activation
push-to-create sur Forgejo. Les pushes directs individuels réutilisent la réconciliation Git CI/CD :
les branches et le tag demandé sont alignés sur le commit local sous lease si
aucun tag distant supérieur ou non comparable ne bloque la publication. `forgejo push all` conserve son parcours groupé.

Les commandes `diu projects forgejo|gitlab|github push <ID PROJECT> [VERSION]`
préparent le commit et le tag avant le push. VERSION suit le format `x.y.z` ;
sans argument, le tag utilise l'horodatage. Ce choix ne modifie pas
`PROJECT_VERSION`. Une version déjà attribuée est rejouée depuis le commit du
tag, en préservant les changements locaux en attente. Les identifiants GitHub
et GitLab sont préparés dans le projet source avant le rejeu et restent
disponibles après suppression du clone. Les artefacts associés
à un éventuel tag distant remplacé doivent être vérifiés.

Pendant un push Forgejo, GitLab ou GitHub, une indisponibilité réseau reconnue
est signalée comme « serveur indisponible — publication non confirmée ».
La commande retourne zéro ; elle n'annonce pas la publication comme réussie.
Le flux `diu projects cicd <ID PROJECT>` poursuit les autres fournisseurs et
les builds locaux activés, puis ignore les releases du fournisseur indisponible. Sans
autre erreur, son résumé indique « terminé avec indisponibilités ». Une panne
réseau reconnue pendant une release CI/CD est également signalée sans bloquer
les autres fournisseurs : la publication peut être partielle et doit être reprise.
Les releases directes conservent leur comportement d’erreur.
`diu projects forgejo push all` poursuit également les autres projets.

Les refus d'authentification, erreurs de certificat, configurations incorrectes
et rejets Git restent bloquants. Une publication interrompue peut être
partielle et nécessite une reprise. Les commandes de release lancées
directement conservent leur gestion d'erreur.

Les fichiers locaux `config/<fournisseur>.username` et
`config/<fournisseur>.token` de Forgejo, GitHub et GitLab acceptent exactement
les modes `0600` et `0660`, dans les parcours Git et API existants. Les fichiers
existants conservent leur contenu et leurs permissions. Les autres modes
restent refusés. Avec `0660`, le groupe peut lire et modifier les identifiants.
Les nouveaux identifiants et les secrets temporaires restent créés en `0600`.

Pour générer l'inventaire DevOps d'un projet :

```bash
diu projects template devops <ID PROJECT>
```

`DEVOPS.md` est généré au format documentaire `0.7`, avec provenance DIU,
début du relevé UTC et classification de l'environnement d'exécution fournie
par DIU. Les dépendances Python sont recherchées en priorité dans les venv du projet
(`.venv`, `venv`, `env`, puis autres chemins triés), avec repli DevOps explicite.
Chaque résultat indique son interpréteur, son environnement et son
installation observée. Les recherches ou sondes impossibles sont signalées
comme non vérifiables. Cet inventaire ne valide pas une composition Python
unique et ne constitue ni une qualification fonctionnelle ni une preuve de
réussite des tests.

Si `pyproject.toml` déclare Cython ou Nuitka dans `[build-system].requires`, DIU
ajoute une seule rubrique « Python - Outils de compilation » après le gestionnaire
de paquets Python et avant Prompts. Elle contient uniquement les outils déclarés,
Cython puis Nuitka, avec contraintes ou extras éventuels comme `Nuitka[build-wheel]`.
Une découverte commune et des sondes isolées dans les venv du projet indiquent,
pour chaque outil indépendamment, sa version et ses chemins, « non installé »
si l’absence est établie, ou « installation non vérifiable » sinon, notamment
sans venv. Un outil non déclaré n’est ni sondé ni affiché ; sans les deux, la
rubrique et sa découverte sont omises. Aucun paquet global ne sert de repli,
aucun paquet n’est installé, aucun manifeste n’est modifié et aucune compilation
n’est lancée. Le format reste `0.7` ; les documents existants adoptent ce rendu
à leur prochaine génération normale.

La rubrique « Système d'exploitation » affiche le nom de l'OS puis le résultat
de `hostname -f` en deuxième puce. Le nom est relevé dans le contexte
d'exécution DIU, sans valeur codée en dur ni modification du réseau ou du nom
d'hôte. La sonde est limitée à 15 secondes ; une indisponibilité ou une sortie
invalide est indiquée explicitement sans bloquer la génération.

Avant les inventaires et les sondes, DIU ajoute les droits d'exécution
manquants aux sept outils DevOps présents : Go, Node, npm, OpenCode, OpenSpec,
Python et pip. Cette préparation vise uniquement leurs chemins connus dans
le domicile DevOps et les cibles de liens qui y restent confinées. Les
propriétaires, droits de lecture et d'écriture, outils hôte et autres fichiers
restent inchangés. Aucun outil absent n'est installé. Une cible externe ou
non ordinaire, ou un échec de préparation, bloque la génération et conserve
le document précédent ; les droits déjà ajoutés ne sont pas annulés. Le format
documentaire reste `0.7`, appliqué à la prochaine génération normale.

Après l'OS, la section « Matériel » contient « TPM », avec chemin en premier
(`/dev/tpmrm0` prioritaire), version, fabricant, identifiant fournisseur,
révision de spécification et banques/indices PCR alloués. Le fabricant est
le code ASCII observé et l'identifiant son code hexadécimal. La collecte est
locale, bornée et en lecture seule ; les propriétés impossibles à relever
restent explicites sans bloquer le document. Aucun outil ni droit n'est
modifié et les valeurs des PCR ne sont pas lues. Les documents existants
adoptent ce rendu à leur prochaine génération normale, au format `0.7`.

La rubrique « Conteneur Docker, pour tests nécessitant des droits root » apparaît
uniquement si `ENV_DEVOPS_TESTS_DOCKER` vaut exactement `1`. Elle indique la
version détectée, le binaire, puis `/var/run/docker.sock` et l'image
`debian:stable-slim`. Ces références et la puce Accès TPM OK restent affichées
indisponible, sans vérification du socket ni téléchargement ou lancement
de l'image. La puce Accès TPM OK décrit le contexte de test configuré ; elle
ne constitue pas une sonde ni une qualification d'un autre hôte. Le tag suit
Debian stable ; aucune version Debian n'est figée.
Sinon, cette rubrique et sa sonde Docker sont omises ; Docker-Compose reste présent.

La rubrique « Conteneur LXC, pour tests nécessitant des droits root accessible en SSH » apparaît
indépendamment si `ENV_DEVOPS_TESTS_LXC` vaut exactement `1`. Elle suit Docker
lorsqu'il est présent, sinon Matériel, et précède OpenSSH & SSHPASS, puis Docker-Compose. Ses trois premières
puces sont :
« Variables d'accès disponible dans project.env pour l'accès SSH », « Debian 13 », « Accès TPM OK ».
Ces mentions sont déclaratives, sans connexion LXC, lecture d'identifiants ni
qualification TPM distante. Pour chaque indicateur, une valeur absente, vide ou
différente de `1` omet sa rubrique. Le format reste `0.7` et les documents existants
adoptent ce comportement à leur prochaine génération normale.

Les deux rubriques activées contiennent l'autorisation commune :
« Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests. »
Cette consigne explicite l'autorisation des tests pour les deux types d'agents.
Elle ne désactive pas les contrôles techniques de permissions imposés par les
outils ou leur plateforme. Docker comporte six puces et LXC cinq.
L’autorisation est dernière pour Docker et quatrième pour LXC. LXC se termine par :
« Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests. »
Une rubrique désactivée n’émet aucune puce d’autorisation ni de conservation
des dépendances de test.

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

La rubrique « Prompts » indique `/home/${ENV_DEVOPS_USER}/datas/prompts` et
`/home/${ENV_DEVOPS_USER}/datas/prompts/INDEX.md`, avec le compte DevOps
configuré, indépendamment de la racine des projets. Ces ressources ne sont
ni lues ni créées ; les documents existants adoptent le format `0.7` à leur
prochaine génération.

Les manifestes `package.json` des composants et workspaces sont regroupés sous
NPM ; `.opencode/package.json` figure sous OpenCode. Les dépendances directes
sont séparées par catégorie, avec contrainte déclarée, version verrouillée
npm (formats 2/3) et version observée localement, puis chemin réel
d'installation. Un verrou ne prouve pas une installation ; les formats non
analysés et recherches incomplètes restent explicites. La collecte ne lance
aucun gestionnaire, script ou paquet et n'utilise aucun repli npm global.
Les détails sont décrits dans
[le cadrage technique](TECHNICAL.md#traçabilité-du-document-devops).

`diu system update` met à jour Debian, puis présente les moteurs et les versions des logiciels DIU activés. Les opérations APT sont discrètes et leurs diagnostics sont affichés en cas de problème.
