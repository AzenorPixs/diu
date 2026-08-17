## Context

Le DIU est un installeur Debian unifié reposant sur un script principal
`root-install-debian.sh`, un fichier de variables `variables.sh`, et une
architecture modulaire documentée dans la spécification `modular-architecture`.

**Contenu distribué dans le paquet :**

- `root-install-debian.sh`
- `config/` (si présent et nécessaire)
- `lib/` (fonctions génériques)
- `modules/` (domaines fonctionnels, notamment `desktop/`, `environments/`,
  `projects/`, `softwares/`, `system/`)

**Configuration locale non distribuée :**

- `variables.sh` — configuration locale propre à chaque machine. Non requis
  et non lu pour la construction du paquet. La machine cible fournit sa
  propre configuration locale.

Ce change introduit la capacité de produire un paquet Debian contenant le
contenu distribué, généré dans `dist/`, installable sous `/root/diu`.

La spécification fonctionnelle est décrite dans `specs/deb-package/spec.md`.

## Goals / Non-Goals

**Goals:**

- Produire un paquet `.deb` installable contenant les fichiers de production
  du DIU
- Générer le paquet dans `dist/` à la racine du projet
- Déployer le contenu sous `/root/diu` lors de l'installation
- Valider les prérequis et le projet cible avant construction
- Exposer la construction via `rid proj deb <project_id>`

**Non-Goals:**

- Publication sur Forgejo ou création de Release
- Gestion ou embarquement des paquets Debian externes téléchargés par le
  DIU dans son cache `deb/`
- Support de projets non-DIU
- Gestion et création runtime du cache `deb/` (hors périmètre de ce
  change, pourra faire l'objet d'un changement OpenSpec séparé)
- Création de `variables.sh` lorsqu'il est absent de la machine cible
- Ajout automatique de variables manquantes dans `variables.sh`
- Future fonction `ensure_variable()`

## Décisions

### Décision 1 : Version du paquet

**Choix :** La version du paquet est générée automatiquement au moment du
build à partir de l'heure locale de la machine de build.

**Format :** `YYYY.MM.DD.HH.MM` (année.mois.jour.heure.minute).

**Exemple :** `2026.08.12.03.15`

**Rationale :** Cette approche rend le packaging totalement indépendant de
`variables.sh` et de toute configuration locale. Chaque build produit une
version unique et chronologiquement identifiable.

**Utilisation :** La même valeur est utilisée dans le champ `Version:` du
fichier `DEBIAN/control` et dans le nom du fichier `.deb` :
`diu_<VERSION>_all.deb`.

### Décision 2 : Outils de construction

**Choix :** `dpkg-deb` avec l'option `--root-owner-group` comme outil de
construction du paquet.

**Rationale :** `dpkg-deb` est l'outil Debian retenu pour la construction
de paquets. Il constitue un prérequis explicitement vérifié par `build_deb()`.

**Prérequis de construction :**

- `dpkg-deb` : doit être présent sur la machine de build
- `dpkg-deb --root-owner-group` : doit être supporté (disponible depuis
  dpkg 1.21.18, Debian 12 Bookworm et ultérieur)

**Stratégie de privilèges :** La construction est exclusivement non
privilégiée. Si `dpkg-deb --root-owner-group` n'est pas disponible dans
l'environnement cible, la construction échoue avec un message identifiant
la capacité manquante. `build_deb()` ne demande pas une élévation de
privilèges.

**Alternative considérée :** `fpm` — rejeté car c'est une dépendance
supplémentaire non disponible par défaut sur Debian.

**Vérification :** La fonction `build_deb()` vérifie la disponibilité de
`dpkg-deb` et de l'option `--root-owner-group` avant de procéder. Si la
vérification échoue, un message d'erreur est affiché et la construction
s'arrête avec le code 1.

### Décision 3 : Structure du paquet

**Choix :** Le contenu du DIU est déployé sous `/root/diu/` avec
l'arborescence suivante :

```
/root/diu/
├── root-install-debian.sh
├── config/          (si présent et nécessaire)
├── lib/
│   └── *.sh
└── modules/
    ├── desktop/
    ├── environments/
    ├── projects/
    ├── softwares/
    └── system/
```

**Rationale :** Cette structure respecte l'architecture modulaire du DIU.
Les fichiers `softwares/` et `system/` se trouvent sous `modules/`, pas à
la racine de `/root/diu/`. `variables.sh` n'est pas distribué car il
constitue une configuration locale spécifique à chaque machine cible.

### Décision 4 : Arborescence de construction

**Choix :** Utiliser un répertoire temporaire de staging contenant uniquement
les fichiers à empaqueter, puis appeler `dpkg-deb` sur ce répertoire.

**Zones de stockage :**

- `deb/` : cache runtime de paquets Debian externes. Non embarqué dans le
  paquet. Non lu ni modifié pendant le build.
- `dist/` : répertoire des artefacts produits par le projet. Le paquet `.deb`
  y est déposé à l'issue de la construction.
- Répertoire temporaire de staging : zone éphémère utilisée uniquement pendant
  l'exécution de `build_deb()`. Supprimée après construction.

**Étapes :**

1. Créer un répertoire temporaire `$(mktemp -d)`
2. Créer l'arborescence cible `${tmpdir}/root/diu/`
3. Copier les éléments de la liste blanche (cf. spec `deb-package`)
4. Créer le répertoire de contrôle `${tmpdir}/DEBIAN/`
5. Générer le fichier `${tmpdir}/DEBIAN/control`
6. Exécuter `dpkg-deb --build "${tmpdir}" "${destination}"`
7. Supprimer le répertoire temporaire

**Nom de l'artefact :** L'artefact est nommé selon la convention Debian :

`diu_<version>_all.deb`

Exemple : `diu_16.07.2026_all.deb`

**Rationale :** Cette convention identifie le paquet, sa version et son
architecture. Le champ `_all` indique un paquet contenant du code
interprétable sur toutes les architectures (scripts Bash).

### Décision 5 : Fichier de contrôle Debian

**Choix :** Générer le fichier `control` avec les champs suivants :

- `Package: diu`
- `Version:` : valeur générée automatiquement au format `YYYY.MM.DD.HH.MM`
- `Architecture: all` (paquet contenant des scripts Bash, pas de binaires
  compilés)
- `Maintainer:` : `Anthony DEMARD <postmaster@pixs.fr>`
- `Description: Debian Installeur Unifié`

**Champ Maintainer :** La valeur `Anthony DEMARD <postmaster@pixs.fr>` est
codée en dur dans `build_deb()`. Elle constitue une constante interne au
composant de packaging, pas une variable de configuration de la machine.

**Champ Depends :** Le paquet déclare `Depends: awk`. Cette dépendance a été
retenue après analyse des besoins runtime du contenu distribué. `awk` est
utilisé à de nombreuses reprises dans le DIU sans vérification préalable, et
n'est pas fourni par un paquet `Essential: yes`. Aucune autre dépendance
runtime spécifique n'est déclarée par ce change.

### Décision 6 : Dispatch de la commande rid proj deb

**Choix :** Ajouter un cas `deb` dans la fonction `manage_project_action` de
`root-install-debian.sh`.

**Signature de `build_deb()` :**

```bash
build_deb() {
    local project_id="$1"
    ...
}
```

La fonction reçoit uniquement `project_id`. Le `project_name` n'est pas
transmis car il n'est pas nécessaire à la construction du paquet. Le chemin
du projet est dérivé de `$DEVOPS_PROJECTS_ROOT/$project_id` dans la fonction.

**Rationale :** Le dispatch existant (`manage_project_action`) gère déjà les
actions `bash`, `del`, `gita`, `gitc`, `giti`, `gitp`, `gits`, `ocro`, `ocrw`,
`ocsh`. L'ajout d'un cas `deb` suit le pattern établi.

**Implémentation :** Le cas `deb` appelle `build_deb "$project_id"`. La
fonction `build_deb` est définie dans `modules/projects/packaging.sh` et
sourcée par `root-install-debian.sh`.

### Décision 7 : Emplacement du fichier packaging.sh

**Choix :** `modules/projects/packaging.sh` conformément au cap architectural
validé.

**Rationale :** Le répertoire `modules/projects/` est le domaine fonctionnel
dédié à la gestion de projets du DIU. Le packaging est une opération de
projet. Le fichier sera sourcé par `root-install-debian.sh`.

## Risques / Trade-offs

**[Risque] dpkg-deb non disponible** → Vérification explicite avant
construction. Message d'erreur clair et arrêt avec code 1.

**[Risque] Heure système incorrecte** → La version générée dépend de l'heure
locale. Si l'heure est incorrecte, la version sera incohérente. Ce risque
est accepté car il relève de la responsabilité de l'administrateur système.

**[Risque] Fichiers manquants dans le projet cible** → Validation systématique
des éléments requis (`root-install-debian.sh`, `lib/`, `modules/`) avant
construction. Arrêt explicite en cas d'absence.

**[Risque] Permissions insuffisantes pour dpkg-deb** → Si `--root-owner-group`
n'est pas disponible, la construction échoue avec un message suggérant la
mise à jour de dpkg ou l'utilisation d'un environnement compatible.

**[Point à déterminer] Dépendances runtime du paquet** → L'analyse du contenu
de production déterminera si un champ `Depends:` est nécessaire et, le cas
échéant, quelles dépendances doivent y figurer.
