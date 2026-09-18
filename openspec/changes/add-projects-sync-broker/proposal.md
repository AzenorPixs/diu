## Why

Les projets gérés doivent disposer des ressources du broker CAB nécessaires à
l'intégration OpenCode–Codex. La synchronisation actuelle ne copie que le
modèle de projet et ne peut donc pas fournir ces ressources.

## What Changes

- Ajouter à `sync_project` la synchronisation de
  `/home/devops/datas/cab/src` vers `.opencode/broker` du projet.
- Exclure les répertoires `__pycache__` de la source et retirer le cache
  Python direct déjà présent dans la destination.
- Rendre les fichiers CAB source autoritaires en cas de conflit de chemin,
  sans convertir la copie en miroir destructif.
- Ajouter à `sync_project_all` la synchronisation globale de
  `/home/devops/datas/cab/src` vers `/home/devops/.opencode/broker`.
- Couvrir ces comportements par les tests ciblés existants.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `projects-sync` : la synchronisation d'un projet inclut les ressources CAB
  contrôlées.

## Impact

Sont concernés `modules/projects/projects.sh`, les tests ciblés
`tests/test_projects.py` et la spécification `projects-sync`. Aucun routage,
aucune dépendance, aucune interface publique ni configuration Git ne change.
