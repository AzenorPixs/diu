## Why

DEBIAN_TYPE est une configuration historique manuelle. Le DIU doit identifier
l'environnement courant sans réutiliser cette ancienne valeur.

## What Changes

- Déclarer SYSTEM_DEBIAN_ENVIRONNEMENT, DYNAMIC, ENABLE, scope system.
- Détecter DOCKER, LXC, VM, PROXMOX, PHYSICAL ou UNSET.
- Migrer les consommateurs et nettoyer DEBIAN_TYPE avant le chargement historique.
- Préserver le chargeur et le cycle actuel des variables dynamiques.

## Capabilities

### New Capabilities
- `system-debian-environnement`: détection et déclaration de l'environnement Debian.

### Modified Capabilities
- `legacy-variable-cleanup`: retrait de DEBIAN_TYPE et migration de ses consommateurs.

## Impact

Déclaration dans modules/diu/variables/system/, point d'entrée, nettoyage,
tests isolés et TECHNICAL.md. Aucun changement système pendant la session.
L'ancienne valeur manuelle n'est pas transférée. Aucun traitement d'installation
spécifique à Docker n'est ajouté. Aucun changement Git ni DisplayLink.
