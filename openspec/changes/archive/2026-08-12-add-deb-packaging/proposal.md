## Why

Le DIU ne dispose actuellement d'aucun artefact Debian dédié permettant sa
distribution et son installation standardisées en production. Un paquet Debian
permettrait de regrouper les fichiers nécessaires dans un installable via
`dpkg -i`, avec une cible d'installation préparée sous `/root/diu`.

## What Changes

- Ajout d'une commande `rid proj deb <project_id>` déclenchant la construction
  d'un paquet Debian `.deb`
- Création d'un module `modules/projects/packaging.sh` contenant la fonction
  `build_deb()` responsable de la construction
- Le paquet produit sera généré dans le répertoire `dist/` du projet
- Le paquet contiendra uniquement les fichiers nécessaires au fonctionnement
  du DIU (scripts, lib/, configuration)
- La version du paquet est générée automatiquement au moment du build
  (format `YYYY.MM.DD.HH.MM`)
- Le mainteneur du paquet est une constante interne au composant de
  packaging
- `variables.sh` n'est ni requis ni lu pour la construction du paquet
- Le paquet ne doit pas remplacer la configuration locale
  `/root/diu/variables.sh` lors d'une installation ou mise à jour
- Le paquet préparera une installation sous `/root/diu` sur la machine cible
- Le répertoire `deb/` conserve exclusivement son rôle actuel de cache des
  paquets Debian externes utilisés par le DIU
- Les prérequis nécessaires à la construction seront vérifiés avant exécution ;
  la construction échouera explicitement si des outils indispensables sont absents

## Capabilities

### New Capabilities

- `deb-package`: Construction d'un paquet Debian de production contenant les
  fichiers nécessaires du DIU, généré dans `dist/`, installable sous `/root/diu`

### Modified Capabilities

Aucune. Le cap architectural `modules/projects/packaging.sh` est déjà validé
et sert de cible d'implémentation, mais ce changement ne modifie pas la
capacité `modular-architecture`.

## Impact

- Nouveau fichier : `modules/projects/packaging.sh`
- Nouveau répertoire : `dist/` (production des paquets)
- Modification de `root-install-debian.sh` : ajout du dispatch vers la fonction
  `build_deb()` via `manage_project_action`
- Aucune modification de la spécification `modular-architecture`
- Aucune publication Forgejo ni création de Release dans ce changement
