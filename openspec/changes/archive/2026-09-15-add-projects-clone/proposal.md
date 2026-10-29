# PRJ02 — Clonage local des projets

## Why

Dupliquer un projet existant exige aujourd'hui une copie manuelle, qui peut
transférer involontairement les métadonnées Git du projet source et conserver
son identifiant dans `project.env`. La destination ne peut alors pas être
traitée comme un projet DIU distinct.

## What Changes

- Ajouter la fonction `clone_project <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`.
- Ajouter la commande publique `rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>`.
- Copier récursivement le projet source dans une destination nouvelle, en
  excluant tous les répertoires nommés `.git` et leur contenu.
- Remplacer la seule affectation `PROJECT_ID` du `project.env` cloné par
  l'identifiant de destination, sans modifier les autres paramètres.
- Mettre à jour l'aide contextuelle des projets.

## Capabilities

### New Capabilities

- `projects-clone`: clonage local, sans métadonnées Git, d'un projet géré.

### Modified Capabilities

- `rid-help`: exposition de la commande de clonage dans l'aide contextuelle.

## Impact

Le routage des projets, `modules/projects/projects.sh`, `lib/rid-help.sh` et
leurs tests ciblés sont concernés. Aucune opération réseau, aucune commande
Git, aucune dépendance supplémentaire et aucune modification du projet source
ne sont introduites.
