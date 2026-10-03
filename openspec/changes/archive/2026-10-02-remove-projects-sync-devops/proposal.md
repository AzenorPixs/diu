## Why

La synchronisation du modèle écrase actuellement DEVOPS.md, alors que ce
document décrit l'environnement propre à chaque projet. Le développeur a
validé son retrait de la sélection synchronisée, sans supprimer les documents
existants ni modifier leur génération dédiée.

## What Changes

- Retirer DEVOPS.md des prérequis du modèle, de la préparation, de la copie
  et du changement de propriétaire dans la synchronisation unitaire.
- Appliquer ce comportement à la synchronisation groupée utilisant la même
  fonction.
- Préserver le contenu, les droits et le propriétaire d'un DEVOPS.md existant
  et ne pas créer de document absent, même si le modèle en contient un.
- Accepter un modèle sans DEVOPS.md tout en conservant les autres contrôles.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `projects-sync` : DEVOPS.md ne fait plus partie des ressources gérées.

## Impact

Sont concernés modules/projects/projects.sh, tests/test_projects.py et la
spécification projects-sync. La génération dédiée, la création de projets,
les interfaces publiques et les ressources CAB restent inchangées. Aucun
projet réel n'est synchronisé, aucune dépendance ni opération Git n'est
introduite. Les autres changes actifs restent hors périmètre.
