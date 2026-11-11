## Why
Les variantes APT nécessitent des prérequis de sources explicites. Les premières initialisations actuelles utilisent des défauts actifs ou des recherches textuelles qui ne distinguent pas les sources désactivées. Des recettes logicielles historiques restent dans le monolithe.

## What Changes
- Détecter les sources APT actives avant initialisation des variables absentes, préserver les valeurs persistées et les branches MongoDB/Wazuh.
- Séparer non-free et non-free-firmware avec deux variables indépendantes, à zéro en absence de déclaration active.
- Déclarer les cinq variantes et les traitements particuliers des 23 logiciels APT dans GLOBAL ; conserver les opérations génériques et retirer les blocs logiciels historiques du monolithe.
- Préparer automatiquement les composants et dépôts requis avant installation, y compris en convergence ; versions des .deb directs résolues par les déclarations et mises à jour par system.
- Préserver les logiciels et recettes DevOps, Docker et IA, les rôles partagés et la configuration utilisateur.

## Capabilities
### New Capabilities
- apt-source-initialization: lecture fiable des sources et initialisation persistante des variables.
- apt-software-declarations: recettes GLOBAL et prérequis des cinq variantes.
### Modified Capabilities
- system-debian-apt: composants indépendants, initialisation et fonctions SYSTEM.
- software-management: opérations communes et commandes actuelles réconciliées.

## Impact
modules/system, modules/softwares, déclarations GLOBAL system/softwares, blocs SOFTWARES_APT du point d’entrée, tests, documentation et aides. DEVOPS.md préexistant conservé. Cycle OpenSpec, statistiques et CICD inclus. Code non attribué ; normalisation ultérieure par ACL.
