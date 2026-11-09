# PRJ14 — Exclusion du dépôt Git lors de la copie du modèle

## Why

Un modèle de projet peut contenir son propre répertoire `.git`. Le recopier
dans un nouveau projet transfère accidentellement son historique, ses remotes
et sa configuration Git, alors que la création du projet ne doit pas gérer le
dépôt Git.

## What Changes

- Exclure le répertoire `.git` du modèle local lors de la création d'un projet.
- Préserver la copie de tous les autres éléments du modèle, sous réserve de
  l'exclusion existante de `project.env`, de l'exclusion du `pyproject.toml`
  racine pour un projet non Python selon `projects-template-devops`, et de la
  copie conditionnelle de `ancien protocole local` définie par
  condition-project-orchestrated-coding-copy.
- Vérifier par un test ciblé qu'aucun dépôt Git du modèle n'est présent dans
  le projet créé.

## Capabilities

### New Capabilities

- `projects-template-creation`: Création d'un projet depuis un modèle local
  sans transférer ses métadonnées Git.

### Modified Capabilities

- Aucune.

## Impact

La fonction `create_project` de `modules/projects/projects.sh` et ses tests
ciblés sont concernés. Aucune commande Git, configuration Git, dépendance ou
interface publique ne change.
