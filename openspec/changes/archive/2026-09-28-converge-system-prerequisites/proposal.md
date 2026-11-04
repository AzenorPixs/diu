# SYS14 — Convergence des prérequis système par environnement

## Why

Le parcours historique vérifie seulement `aptitude` avant d'installer une
liste de prérequis propre à l'environnement. Le module `system` vérifie chaque
paquet, mais sa liste ne comprend pas tous les prérequis historiques.

## What Changes

- Centraliser les listes générales dans `system_install_prerequisites`.
- Conserver le socle initial et ajouter `acl` pour LXC, PHYSICAL, VM, DOCKER
  et PROXMOX ; ajouter `conntrack`, `glances` et `rsync` pour PROXMOX.
- Utiliser exactement les mêmes prérequis pour DOCKER et VM.
- Conserver le socle initial pour un environnement absent ou non reconnu.
- Remplacer les listes historiques par un appel à la fonction commune au
  même emplacement, sans déplacer ni modifier le bloc DisplayLink PHYSICAL.
- Préserver le tri, la déduplication et le contrôle individuel des paquets ;
  propager explicitement un échec APT sans poursuivre les installations.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `system-prerequisites` : composition par famille et appel partagé entre
  installation historique et mise à jour système.

## Impact

Fichiers concernés : `modules/system/apt.sh`, `root-install-debian.sh`,
`tests/test_system_apt.py`, `TECHNICAL.md` et la spécification
`system-prerequisites`.

Des paquets manquants auparavant ignorés seront installés lors des prochaines
exécutions. Les mises à jour système appliqueront les compléments de leur
famille. Aucun changement des dépôts, du packaging ou des autres blocs
logiciels n'est inclus. La session ne réalise aucune installation système,
opération Git ou autre effet externe.

Le développeur a validé ce périmètre, son cycle OpenSpec et son archivage,
avec la correction explicite de conserver DisplayLink dans le monolithe.
