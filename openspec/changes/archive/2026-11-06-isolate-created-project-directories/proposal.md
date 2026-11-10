# Isoler les dossiers des nouveaux projets

## Why

Un nouveau projet ne doit pas reprendre les dossiers locaux ni les données OpenSpec propres au modèle.

## What Changes

Exclure `.worktrees`, `config`, `output`, `.cab-tests` et `openspec` de la copie ; créer les trois dossiers locaux vides et initialiser OpenSpec. Retirer la règle particulière visant l'ancien document de protocole.

## Capabilities

### Modified Capabilities
- `projects-template-creation`: filtrer les dossiers puis créer les répertoires locaux.
- `implement-projects-update`: retirer l'ancien contrat particulier du document de protocole.

## Impact

Création de projets, tests et documentation. Aucun projet existant n'est modifié ; pas de CI/CD.
