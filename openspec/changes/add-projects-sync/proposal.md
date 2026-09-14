## Why

Les projets de développement ne disposent pas d'une synchronisation ciblée de
leurs fichiers de gouvernance et de leurs ressources OpenCode depuis le modèle
local. Leur mise à jour manuelle est répétitive et peut laisser les projets
gérés dans des états divergents.

## What Changes

- Ajouter la commande `rid projects sync <ID PROJECT>`.
- Ajouter une synchronisation ciblée depuis
  `/home/${DEVOPS_USER}/datas/template`
  vers le projet désigné, avec écrasement des éléments gérés par le modèle.
- Personnaliser les seuls fichiers Markdown copiés en remplaçant `Template`
  par `PROJECT_NAME` et `template` par `PROJECT_ID`.
- Refuser toute synchronisation avant copie si le répertoire modèle est
  indisponible.
- Mettre à jour l'aide publique de la gestion des projets.

## Capabilities

### New Capabilities

- `projects-sync`: synchronisation ciblée des ressources de projet depuis le
  modèle local.

### Modified Capabilities

- `rid-help`: exposition de la commande de synchronisation des projets dans
  l'aide contextuelle.

## Impact

Le routage des projets, le module `modules/projects/projects.sh`, l'aide
`rid` et leurs tests ciblés sont concernés. Aucune dépendance, opération
réseau ou modification Git n'est ajoutée.
