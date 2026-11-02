# Construction des paquets Debian

## Version prioritaire optionnelle

`PROJECT_VERSION=1.0.0` dans `project.env` est prioritaire pour les deux
constructeurs Debian. La clé est lue isolément comme une affectation littérale
unique `x.y.z`, éventuellement citée et commentée, sans exécuter le fichier.
Les trois entiers sont sans zéro initial sauf `0` ; la longueur est limitée à
128 caractères. Une clé présente vide, dupliquée ou invalide est une erreur.
Une clé absente conserve exactement les mécanismes précédents.

La priorité du constructeur générique est `PROJECT_VERSION`, puis `version`
de la recette, puis tags de `HEAD`, puis horodatage local. Le constructeur
historique utilise `PROJECT_VERSION`, puis ses règles tags/horodatage.
Les publications vérifient que la version déclarée correspond au paquet et
au tag `v<VERSION>` de `HEAD`, sans déplacer un tag existant.

## Construction générique par recette

```bash
rid projects build debian <ID PROJECT>
```

Le moteur `modules/projects/debian-build.sh` sélectionne un enfant direct de
`DEVOPS_PROJECTS_ROOT`. Il lit uniquement `PROJECT_DEBIAN_PACKAGE` dans
`project.env`, sans exécuter le fichier : `Yes`, `YES` et `1` activent le build.
Une valeur absente, vide ou différente affiche que le projet ne produit aucun
paquet Debian et termine avec succès avant de rechercher la recette.
Les doublons ou affectations nécessitant une interprétation sont des erreurs.

Le fichier public obligatoire est `build/debian-package.json`. S'il manque
pour un projet activé, le message indique son chemin et l'impossibilité de
construire. Une recette illisible, symbolique ou invalide est également refusée.
Le moteur utilise `jq`, déjà prévu dans les prérequis DIU, et `dpkg-deb`.
Il assemble des sources préparées, sans compilation ni exécution de hook.

### Format de la recette

La [recette DIU](build/debian-package.json) fournit les champs obligatoires
`package`, `architecture`, `maintainer`, `description`, `files`, et le tableau
facultatif `depends`. Chaque copie de `files` définit une `source` relative au
projet et une `destination` absolue dans le paquet. Un champ facultatif
`version` fournit une version Debian littérale, après PROJECT_VERSION. Sans
ces deux valeurs, les règles de tags et de repli calendaire ci-dessous s'appliquent.
Les sources sont les fichiers de travail, y compris non committés.

Les champs inconnus et les caractères de contrôle sont refusés. Sources et
recette doivent être non symboliques ; les liens et fichiers spéciaux dans les
sources sont refusés dans cette première version. Les sources restent dans le
projet, les destinations dans le staging hors `/DEBIAN` et ne se recouvrent pas.
Une source ne peut englober la recette ou `dist/` ; déclarer les sous-répertoires
à copier explicitement. Les caches, configurations privées et fichiers
temporaires reconnus par les contrôles sont refusés, sans suppression silencieuse.
La recette n'est jamais embarquée. Elle ne doit contenir aucun secret.

### Résultat et rotation

La commande construit avec `dpkg-deb --build --root-owner-group`, puis dépose
`dist/<package>_<version>_<architecture>.deb`. Les temporaires sont nettoyés.
Après dépôt, seuls les anciens paquets de même nom et architecture sont
supprimés. Un paquet de même nom de fichier est remplacé ; les autres noms,
architectures et fichiers sont conservés. Un échec avant dépôt ne lance aucune
rotation. Une erreur de rotation est signalée même si le nouveau paquet existe.
Cette commande ne lance ni tests, installation, commit, push ou release.
Le bootstrap commun de `rid` charge et initialise toujours sa configuration.

`rid projects build help`, `rid projects build debian help` et
`rid projects build debian diu help` (ou `?`) expliquent ce contrat avant bootstrap.
La syntaxe `rid projects build deb <ID PROJECT>` et ses aides restent des alias compatibles.
`rid` utilise le moteur installé sous `/root/diu` ; `ridt` utilise celui du dépôt.

## Construction Debian dans la CI/CD générique

`rid projects cicd <ID PROJECT>` suit les six étapes commit/tag, pushes Git,
build Docker, build Debian, publications et bilan. À l'étape 4, il appelle
le même moteur que `rid projects build debian <ID PROJECT>`, uniquement pour
PROJECT_DEBIAN_PACKAGE=Yes/YES/1, même si Docker est désactivé. Les règles
existantes de recette, version, copie, dépôt et rotation restent celles du
constructeur déclaratif. Une recette absente ou un échec de build bloque les
releases ; le bilan indique l'échec et les pushes Git antérieurs sont conservés.

Les publications constituent l'étape 5 et le bilan des deux builds l'étape 6.
Debian seul utilise les publications Forgejo/GitLab/GitHub, avec les mêmes
conditions de paquet et de version pour GitHub que sur Forgejo. Les fournisseurs indisponibles ne sont
pas publiés, mais les builds locaux activés restent exécutés. Les tests utilisent
uniquement fixtures, paquets locaux et transports simulés, sans CI/CD réelle.

## Publication Debian GitHub

`rid projects github release <ID PROJECT>` sélectionne Docker seul, Debian seul
ou les deux avec les indicateurs Yes/YES/1. Docker reste publié sur GHCR et
Debian dans GitHub Releases. Pour les deux, la présence du paquet est vérifiée
avant Docker ; un échec ultérieur peut laisser une publication partielle,
explicitement signalée sans rollback automatique.


`projects_github_release_debian` dans `modules/projects/github-release.sh`
publie un paquet déjà construit selon les conditions Forgejo : activation
PROJECT_DEBIAN_PACKAGE=Yes/YES/1, un seul .deb régulier dans dist, Package égal
à l'identifiant projet et fichier `<ID>_<VERSION>_all.deb` concordant, architecture
all. La version utilise le helper commun avec Forgejo et PROJECT_VERSION reste
prioritaire. Aucune construction n'est déclenchée par la publication.

Le remote déclaré doit correspondre au remote Git réel. Après fetch authentifié,
la branche courante doit être celle attendue et HEAD doit égaler la branche
distante configurée. Le tag distant est vérifié jusqu'au commit ; il n'est
jamais déplacé. En absence de source Git locale, un tag déjà présent est refusé,
comme sur Forgejo. Un tag absent peut être créé sur le HEAD synchronisé.
Une release déjà présente provoque un refus sans remplacement d'asset.

GitHub reçoit le paquet par upload binaire via son upload_url. L'origine et le
chemin sont vérifiés avant transmission des credentials ; le token reste dans
un fichier temporaire 0600, jamais dans les arguments. Les résultats HTTP/JSON,
nom, état et taille de l'asset sont vérifiés. Une erreur après création signale
une release incomplète, sans rollback ou remplacement automatique. Les tests
simulent les API et les credentials ; seuls les paquets de fixture sont réels.
Références : [GitHub Releases](https://docs.github.com/en/rest/releases/releases)
et [assets de release](https://docs.github.com/en/rest/releases/assets).

## Compatibilité du constructeur historique DIU

`rid projects deb [ID PROJECT]`, `rid proj deb <ID PROJECT>` et `cicddiu`
conservent le constructeur `build_deb_diu`, indépendant de la nouvelle recette.
Leurs règles spécifiques sont décrites dans les sections suivantes.
La nouvelle recette DIU produit les mêmes métadonnées, contenu, modes et
propriétaires à sources et version identiques. Les horodatages peuvent faire
varier les octets de l'archive. `tests/test_projects_build_deb.py` compare les
paquets de fixture et teste un projet sans arborescence DIU.

## Environnement de construction

Le flux CI/CD du DIU est autorisé uniquement dans l'environnement de
développement :

```text
/home/devops/datas/diu
```

Le répertoire d'installation en production est :

```text
/root/diu
```

La fonction build_deb_diu accepte un identifiant de projet source optionnel,
par défaut diu. Elle sélectionne cet enfant direct de DEVOPS_PROJECTS_ROOT,
refuse un identifiant invalide, un lien symbolique ou une sortie de la racine.
Le projet doit contenir les sources de production DIU ; le nom du paquet reste diu.

Pour le flux `cicddiu`, `DEVOPS_PROJECTS_ROOT` doit valoir
`/home/devops/datas`.

## Point d'entrée et chaîne d'appel

La commande `ridt projects cicddiu` utilise le script DIU de l'environnement de
développement. Le chemin d'exécution est le suivant :

```text
ridt projects cicddiu
        │
        ▼
root-install-debian.sh
        │
        ▼
manage_project_action
        │
        ├── génère le nom du commit par défaut
        ├── génère le tag par défaut
        │
        ▼
cicd_project_diu
        │
        ├── étape 1 : commit Git
        ├── étape 2 : push Git
        ├── étape 3 : construction du paquet Debian
        │                │
        │                ▼
        │          build_deb_diu
        │
        └── étape 4 : publication de la release Forgejo
```

La construction du paquet est réalisée uniquement par la fonction
`build_deb_diu`, définie dans :

```text
modules/projects/diu-packaging.sh
```

Elle peut également être déclenchée directement avec :

```bash
rid projects deb
```

La commande directe est rid projects deb [ID PROJECT], avec diu par défaut.
L’alias rid proj deb <ID PROJECT> exige une source explicite. L’aide des deux
syntaxes est disponible avant le bootstrap ; les arguments supplémentaires
sont refusés. Les appels sans argument de cicddiu restent compatibles.

## Version du paquet

Sans PROJECT_VERSION ni arguments supplémentaires, `manage_project_action` produit un horodatage
local au format :

```text
YYYY.MM.DD.HH.MM
```

Cet horodatage devient :

- le nom du commit par défaut ;
- le tag Git par défaut, préfixé par `v`.

Exemple :

```text
commit : 2026.09.03.17.25
tag    : v2026.09.03.17.25
```

Le commit et le tag du flux cicddiu restent créés avant le build. En absence de PROJECT_VERSION, la politique
V2 retient l’unique version Debian valide portée par les tags de HEAD, après
retrait du préfixe v éventuel. Les tags équivalents v1.2.3 et 1.2.3 désignent une
seule version. Un tag inexploitable, plusieurs versions distinctes ou un échec
de consultation Git provoquent un arrêt explicite avant publication.

Sans PROJECT_VERSION, et sans métadonnées Git à la racine du projet source ou
sans tag de HEAD, le builder utilise l’heure locale YYYY.MM.DD.HH.MM. Il distingue l’absence de tag
d’une erreur de lecture. La release utilise la même sélection et exige son
égalité avec la version du paquet. Sans tag, elle conserve cette version du
paquet sans générer un nouvel horodatage ; son tag est v<VERSION>.
Les versions issues de tags ne sont donc pas limitées au format calendaire.

## Prérequis

Avant toute construction, `build_deb_diu` vérifie :

- la présence de la commande `dpkg-deb` ;
- la prise en charge de l'option `--root-owner-group` ;
- l'existence du projet `${DEVOPS_PROJECTS_ROOT}/diu` ;
- la présence de `root-install-debian.sh` ;
- la présence de `lib/` ;
- la présence de `modules/`.

deb/ est un cache runtime sans rôle dans le build : son absence est admise.

Un prérequis absent provoque l'arrêt de la construction avec un message
d'erreur et un code de retour non nul.

## Préparation des répertoires

Le répertoire `dist/` est créé à la racine du projet lorsqu'il n'existe pas.
Il constitue la destination finale des artefacts et n'est jamais utilisé comme
source du paquet.

Deux répertoires temporaires distincts sont ensuite employés :

1. un répertoire de staging créé avec `mktemp -d` ;
2. un répertoire de construction créé à la racine du projet avec le motif
   `.diu-build.XXXXXX`.

Le staging reproduit l'emplacement d'installation attendu :

```text
<staging>/
├── DEBIAN/
│   └── control
└── root/
    └── diu/
```

## Contenu du paquet

La construction applique une liste blanche. L'implémentation actuelle copie
uniquement :

```text
root-install-debian.sh
lib/
modules/
```

Ces éléments sont placés sous :

```text
<staging>/root/diu/
```

Le paquet installe donc son contenu applicatif sous `/root/diu`.

Les éléments suivants ne sont pas embarqués :

- `variables.sh` ;
- `config/` ;
- `deb/` ;
- `dist/` ;
- `.git/` ;
- `.opencode/` ;
- `openspec/` ;
- les caches et environnements virtuels ;
- les journaux et fichiers temporaires ;
- les fichiers de secrets ou d'identifiants reconnus par le contrôle du
  staging.

L'exclusion de `variables.sh` et de `config/` évite d'écraser la configuration
locale d'une machine lors de l'installation ou de la mise à jour du paquet.
La nouvelle gestion des variables distribuée avec le module `diu` initialise
et met à jour cette configuration au moment de l'exécution du DIU.

## Contrôle du staging

Avant de produire le paquet, la fonction inspecte récursivement
`<staging>/root/diu`.

La construction échoue si elle trouve un répertoire interdit, notamment :

```text
.git  .opencode  openspec  deb  dist  .cache  __pycache__
node_modules  .venv  venv  logs  tmp
```

Elle échoue également si elle trouve un fichier interdit, notamment :

```text
*.pyc  *.pyo  *.log  *.tmp  *.temp  *.swp  *.swo  *~
*.bak  *.orig  *.rej  .env  *.env
credentials.json  credentials.yaml  secrets.json  secrets.yaml
```

Ce contrôle constitue une barrière de sécurité complémentaire à la liste
blanche. Aucun paquet ne doit être construit lorsqu'un élément interdit est
détecté.

Le répertoire de contrôle DEBIAN est préparé en mode exact 0755, sans hériter
du bit setgid du répertoire parent. Cette modification concerne seulement le staging.

## Métadonnées Debian

Le fichier `<staging>/DEBIAN/control` est généré pendant la construction avec
les champs suivants :

```text
Package: diu
Version: <version>
Architecture: all
Maintainer: Anthony DEMARD <postmaster@pixs.fr>
Description: Debian Installeur Unifié
Depends: awk
```

`Architecture: all` indique que le paquet distribue des scripts et ne contient
pas de binaire compilé propre à une architecture matérielle.

La version placée dans le champ `Version` doit être identique à celle présente
dans le nom de l'artefact.

## Construction et publication locale

Le nom de l'artefact suit la convention :

```text
diu_<version>_all.deb
```

La construction est exécutée avec :

```bash
dpkg-deb --build --root-owner-group <staging> <répertoire-build>/<paquet>
```

L'option `--root-owner-group` inscrit `root:root` comme propriétaire des
fichiers dans l'archive sans imposer une construction privilégiée.

Le paquet est d'abord produit dans le répertoire de construction temporaire.
Il est déplacé dans `dist/` uniquement après le succès de `dpkg-deb`. Cette
séquence évite de publier un artefact incomplet.

Après la publication réussie du nouveau paquet, les anciens fichiers
`diu_*_all.deb` sont supprimés de `dist/`. Le nouveau paquet est explicitement
exclu de cette rotation et les autres fichiers éventuellement présents dans
`dist/` ne sont pas supprimés.

Si la construction ou le déplacement du nouvel artefact échoue, les anciens
paquets restent disponibles dans `dist/`.

## Nettoyage

Après une construction réussie, le staging et le répertoire de construction
temporaire sont supprimés.

Les branches d'erreur nettoient les répertoires temporaires déjà créés avant de
retourner un échec. La suppression ne doit jamais cibler le projet source ni
les anciens artefacts tant que le nouveau paquet n'a pas été publié avec
succès.

## Vérification de l'artefact

Les métadonnées du paquet peuvent être contrôlées avec :

```bash
dpkg-deb --info "dist/diu_<version>_all.deb"
```

Son contenu peut être contrôlé avec :

```bash
dpkg-deb --contents "dist/diu_<version>_all.deb"
```

Les vérifications minimales portent sur :

- le nom `diu` ;
- la version et sa concordance avec le nom du fichier ;
- l'architecture `all` ;
- le mainteneur ;
- la dépendance `awk` ;
- la présence de `root-install-debian.sh`, `lib/` et `modules/` sous
  `/root/diu` ;
- l'absence des configurations locales, sources de développement, secrets,
  caches et fichiers temporaires.

## Réconciliation du 28 octobre 2026

Le plan ACSM-DIU-BOOTSTRAP-PACKAGING-20261028-R1 adopte C1 et V2 :
source paramétrable avec compatibilité CLI, suppression du prérequis deb/,
et préférence normative pour une version de tag valide. Les contrats et le
code sont réconciliés dans reconcile-diu-deb-packaging-contract, conservé actif.

Les tests tests/test_diu_packaging.py utilisent des sources fictives, un paquet
Debian réel de fixture, des transports simulés et un dépôt Git local isolé.
Ils couvrent contenu, versions, aides, refus, rotation et préservation après
échec. Ils n’installent aucun paquet sur la machine et ne publient rien.
