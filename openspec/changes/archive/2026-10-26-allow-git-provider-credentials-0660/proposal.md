# Proposal

## Why

Les identifiants locaux partagés en mode `0660` sont refusés par les trois
fournisseurs, qui exigent exactement `0600`. Le développeur exige leur
utilisation sans modification de leurs permissions.

## What Changes

- Accepter exactement `0600` ou `0660` pour les fichiers `.username` et `.token`
  Forgejo, GitHub et GitLab, dans tous les consommateurs Git et API existants.
- Conserver les fichiers existants, leurs contenus et leurs permissions.
- Refuser les autres modes avant lecture et conserver les erreurs sur les
  fichiers absents ou vides, sans exposer les identifiants.
- Conserver la création des nouveaux identifiants et des secrets temporaires
  en `0600`, ainsi que les répertoires temporaires privés en `0700`.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `forgejo-auth`: lecture des identifiants en `0600` ou `0660`.
- `forgejo-release`: même politique pour les tokens existants.
- `implement-projects-forgejo-push`: acceptation des identifiants partagés.
- `implement-projects-github-push`: acceptation des identifiants partagés.
- `implement-projects-gitlab-push`: acceptation des identifiants partagés.

## Impact

Trois bibliothèques d'authentification, une suite de tests isolés et la
documentation technique/publique. Aucun changement de CLI, de dépendance,
de configuration, d'utilisateur, de groupe, d'ACL ou de déploiement.
Le groupe d'un fichier en `0660` peut lire et modifier son contenu.

## Validation du périmètre

Session SCM directe : proposition présentée puis explicitement validée par
le développeur (« Je valide »), le 26 octobre 2026. Le cycle comprend tests,
synchronisation des cinq spécifications, archivage et statistiques. Le seul
ajustement d'un change voisin concerne son scénario de permission devenu
contradictoire, sans archivage de ce change voisin.
