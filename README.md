# Debian Installer Unifié (DIU)

Le DIU installe et configure Debian grâce à une architecture modulaire en
Bash. Le module `projects` gère également les projets de développement et
leurs publications Forgejo.

Les indicateurs `ENV_DEVOPS_TESTS_DOCKER` et `ENV_DEVOPS_TESTS_LXC` sont
initialisés indépendamment à `0` dans `/root/diu/config/environnements.env`
lorsqu'ils sont absents, puis exportés. Les valeurs existantes, même vides,
sont conservées ; les réexécutions normales ne créent aucun doublon.
Les nouvelles lignes de ces deux indicateurs portent un retrait de huit
espaces avant `export` ; les lignes déjà présentes ne sont pas reformatées.
Une erreur de persistance est bloquante. Cet ajout ne lance aucun test Docker
ou LXC ; les valeurs seront générées à la prochaine exécution normale du DIU
mis à jour.

La création avec `rid projects create <ID PROJECT>` et la mise à jour des
variables avec `rid projects update <ID PROJECT>` demandent
`PROJECT_ORCHESTRATED_CODING` : `No` pour un agent de codage autonome, `Yes`
pour un agent piloté par un orchestrateur. La valeur existante est proposée,
sinon `No` ; une entrée vide conserve ce défaut. Une variable absente dans
`project.env` vaut `No`, sans migration globale ni activation automatique.

Lors de la création depuis le modèle et de `rid projects sync <ID PROJECT>`
(y compris `sync all`), `ORCHESTRATED_CODING.md` est copié et personnalisé
uniquement si le mode du projet destination vaut `Yes`. Pour `No` ou une
variable absente ou vide, il n'est pas copié et une version destination
existante reste intacte. Pour `Yes`, son absence dans le modèle provoque une
erreur avant la copie des ressources du modèle.

La création exclut le `.git` à la racine du modèle : son dépôt Git n'est pas
transféré au nouveau projet. Les autres fichiers cachés, dont `.gitignore`,
restent copiés selon les règles existantes. Cette exclusion ne concerne pas
les `.git` imbriqués et ne modifie aucun projet existant.

`rid projects git init <ID PROJECT>` et `rid projects git update <ID PROJECT>`
ajoutent une exception Git `safe.directory` système limitée au chemin réel du
projet, pour permettre son utilisation par les comptes qui le partagent.
L'ajout nécessite les droits d'écriture système, reste sans doublon et ne
modifie ni le propriétaire du projet ni les autres exceptions. Une erreur
est bloquante ; les écritures précédentes restent en place.

`rid projects git status <ID PROJECTS>` indique la présence ou l'absence de
cette entrée système exacte et son chemin, sans l'ajouter. Des règles Git
globales prioritaires peuvent modifier son effet pour un compte donné.
Les détails figurent dans [le cadrage technique](TECHNICAL.md).

Pour construire une image avec `rid projects docker build <ID PROJECT>`, le
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
rid projects forgejo release <ID PROJECT>
```

La commande publie l’image Docker et/ou le paquet Debian selon
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` dans `project.env`.

Pour publier une image déjà construite vers GitHub Container Registry :

```bash
rid projects github release <ID PROJECT>
```

Le propriétaire et le dépôt sont convertis en minuscules dans les références
GHCR, y compris dans le résumé CI/CD : `AzenorPixs/PKeycloak` devient
`ghcr.io/azenorpixs/pkeycloak`. La configuration GitHub conserve sa casse ;
les tags Docker sont la version issue de l'unique tag Git de `HEAD` et `latest`.
Cette commande ne construit pas l'image.

`rid projects forgejo push <ID PROJECT>` réaligne automatiquement les URL de
récupération et de publication du remote Forgejo configuré sur `project.env`,
notamment si elles pointent encore vers le modèle. Ce remote utilise ensuite
la seule destination déclarée ; les autres remotes sont conservés. Une erreur
de réalignement bloque la publication. Pour un dépôt annoncé absent, le
premier push attend explicitement l'absence de la branche distante : une
ancienne référence de suivi locale ne le bloque plus et une création
concurrente reste protégée. La création du dépôt dépend de l'activation
push-to-create sur Forgejo. Les dépôts existants gardent le fetch préalable
et les tags sont publiés sans forçage. Ces corrections s'appliquent aussi au
parcours groupé `forgejo push all`.

Pendant un push Forgejo, GitLab ou GitHub, une indisponibilité réseau reconnue
est signalée comme « serveur indisponible — publication non confirmée ».
La commande retourne zéro ; elle n'annonce pas la publication comme réussie.
Le flux `rid projects cicd <ID PROJECT>` poursuit les autres fournisseurs et
le build local, puis ignore les releases du fournisseur indisponible. Sans
autre erreur, son résumé indique « terminé avec indisponibilités ».
`rid projects forgejo push all` poursuit également les autres projets.

Les refus d'authentification, erreurs de certificat, configurations incorrectes
et rejets Git restent bloquants. Une publication interrompue peut être
partielle et nécessite une reprise. Les commandes de release lancées
directement conservent leur gestion d'erreur.

Pour générer l'inventaire DevOps d'un projet :

```bash
rid projects template devops <ID PROJECT>
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
`debian:stable-slim`. Ces deux références restent affichées si Docker est
indisponible, sans vérification du socket ni téléchargement ou lancement
de l'image. Le tag suit Debian stable ; aucune version Debian n'est figée.
Sinon, cette rubrique et sa sonde Docker sont omises ; Docker-Compose reste présent.

La rubrique « Conteneur LXC, pour tests nécessitant des droits root » apparaît
indépendamment si `ENV_DEVOPS_TESTS_LXC` vaut exactement `1`. Elle suit Docker
lorsqu'il est présent, sinon Matériel, et précède Docker-Compose. Ses trois premières
puces sont :
« Variables d'accès disponible dans project.env », « Debian 13 », « Accès TPM OK ».
Ces mentions sont déclaratives, sans connexion LXC, lecture d'identifiants ni
qualification TPM distante. Pour chaque indicateur, une valeur absente, vide ou
différente de `1` omet sa rubrique. Le format reste `0.7` et les documents existants
adoptent ce comportement à leur prochaine génération normale.

Les deux rubriques activées ajoutent en dernière puce l'autorisation commune :
« Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests. »
Cette consigne explicite l'autorisation des tests pour les deux types d'agents.
Elle ne désactive pas les contrôles techniques de permissions imposés par les
outils ou leur plateforme. Docker comporte cinq puces et LXC quatre ; une
rubrique désactivée n'émet aucune puce d'autorisation.

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
