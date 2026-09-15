## Why

Le DIU ne permet pas encore de créer un projet depuis son modèle puis de
fusionner le contenu d'un dépôt GitLab distant configuré.

## What Changes

- Ajouter `rid projects gitlab clone <ID PROJECT>` et `gitlab_clone`.
- Réutiliser la création, la configuration GitLab et l'authentification HTTPS
  existantes.
- Cloner puis fusionner le dépôt sans transférer de métadonnée Git.

## Impact

Le routage, l'aide, le module Git des projets, l'authentification GitLab et
leurs tests ciblés sont concernés. Le clonage local existant reste inchangé.
