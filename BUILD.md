# Construction du paquet Debian du DIU

## Objet

Ce document décrit exclusivement la construction du paquet Debian de
l'application Debian Installer Unifié (DIU).

Il formalise le chemin technique allant de la commande :

```bash
ridt proj cicddiu
```

à la production de l'artefact :

```text
dist/diu_<version>_all.deb
```

La gestion du commit, le push Git, la création d'une release Forgejo,
l'installation du paquet et la mise à jour du DIU ne sont décrites que
lorsqu'elles permettent de situer la phase de construction. Leur
fonctionnement détaillé reste hors du périmètre de ce document.

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

La fonction de construction travaille sur le projet `diu`, dont le chemin est
dérivé de :

```text
${DEVOPS_PROJECTS_ROOT}/diu
```

Pour le flux `cicddiu`, `DEVOPS_PROJECTS_ROOT` doit valoir
`/home/devops/datas`.

## Point d'entrée et chaîne d'appel

La commande `ridt proj cicddiu` utilise le script DIU de l'environnement de
développement. Le chemin d'exécution est le suivant :

```text
ridt proj cicddiu
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
rid proj deb
```

## Version du paquet

Sans arguments supplémentaires, `manage_project_action` produit un horodatage
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

Le commit et le tag sont créés avant la phase de construction. Au démarrage du
build, `build_deb_diu` recherche un tag Git pointant sur `HEAD` :

- si un tag est trouvé, le préfixe `v` est retiré et la valeur restante devient
  la version du paquet ;
- si aucun tag ne pointe sur `HEAD`, un horodatage local au format
  `YYYY.MM.DD.HH.MM` est généré comme valeur de repli.

Dans le flux normal `cicddiu`, le paquet, le commit et le tag utilisent donc la
même version horodatée.

## Prérequis

Avant toute construction, `build_deb_diu` vérifie :

- la présence de la commande `dpkg-deb` ;
- la prise en charge de l'option `--root-owner-group` ;
- l'existence du projet `${DEVOPS_PROJECTS_ROOT}/diu` ;
- la présence de `root-install-debian.sh` ;
- la présence de `deb/` ;
- la présence de `lib/` ;
- la présence de `modules/`.

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

## Écarts actuellement identifiés

Les écarts suivants existent entre l'implémentation observée et la
spécification OpenSpec `deb-package` :

- l'implémentation exige la présence de `deb/`, alors que ce répertoire n'est
  ni lu ni copié et ne figure pas parmi les prérequis définis par la
  spécification ;
- la spécification autorise `config/` lorsqu'il est nécessaire à la
  production, tandis que l'implémentation actuelle l'exclut systématiquement ;
- la spécification décrit `rid proj deb <project_id>`, tandis que le dispatch
  et `build_deb_diu` ciblent actuellement le projet `diu` sans utiliser de
  paramètre `project_id` ;
- la spécification décrit une version générée au moment du build, tandis que
  l'implémentation préfère un tag pointant sur `HEAD` et utilise l'horodatage
  uniquement en l'absence de tag. Dans le flux `cicddiu`, le tag par défaut est
  lui-même généré à partir de l'horodatage attendu.

Ce document constate ces écarts sans modifier les exigences OpenSpec. Leur
correction ou leur validation nécessite une évolution explicitement autorisée.
