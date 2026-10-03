## Why

La préparation des projets ne fournit pas de commande dédiée à l'initialisation
ou à la mise à jour OpenSpec. Le développeur a validé ce périmètre autonome,
avec intégration avant la génération DevOps et archivage après validation.

## What Changes

- Ajouter `rid projects template <ID PROJECT> openspec` sous `ENV_DEVOPS_USER`.
- Initialiser avec le profil custom et, si OPENCODE=1, l'outil opencode.
- Exécuter `openspec update` lorsque le dossier openspec existe déjà.
- Appeler cette opération en fin de création, avant le template DevOps.
- Actualiser les aides, la documentation technique et les tests isolés.

## Capabilities

### New Capabilities

- `projects-template-openspec`: Initialisation et actualisation OpenSpec d'un projet.

### Modified Capabilities

- `projects-template-devops`: Ordre des opérations finales de création.
- `rid-help`: Présentation de la commande OpenSpec et du flux de création.

## Impact

modules/projects/template.sh, modules/projects/projects.sh, root-install-debian.sh,
lib/rid-help.sh, TECHNICAL.md et les tests projets, templates et aide sont concernés.
Les autres changes, les opérations Git et l'installation système sont exclus.
