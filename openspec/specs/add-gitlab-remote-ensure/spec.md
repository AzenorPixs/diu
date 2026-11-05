# Gestion automatique du remote GitLab des projets DIU

## Purpose

Définir la gestion sûre et configurable du remote GitLab des projets DIU.

## Requirements

### Requirement: remote GitLab dédié

La commande `diu projects gitlab push <ID PROJECT>` MUST utiliser le remote défini par `REMOTE_GITLAB_NAME` et ne MUST pas modifier le remote Forgejo `origin` lorsque les deux noms sont différents.

#### Scenario: remote GitLab absent

- **GIVEN** que `REMOTE_GITLAB_NAME` et les variables `REMOTE_GITLAB_*` sont conformes
- **AND** que le remote GitLab n'existe pas dans le dépôt local
- **WHEN** `diu projects gitlab push <ID PROJECT>` est exécuté
- **THEN** le remote GitLab est ajouté avec l'URL construite depuis `REMOTE_GITLAB_BASE_URL`, `REMOTE_GITLAB_OWNER` et `REMOTE_GITLAB_REPOSITORY`
- **AND** le push est effectué vers ce remote

#### Scenario: remote GitLab déjà conforme

- **GIVEN** que le remote défini par `REMOTE_GITLAB_NAME` existe
- **AND** que son URL correspond à la configuration GitLab
- **WHEN** un push GitLab est demandé
- **THEN** le remote est conservé sans modification
- **AND** le push est effectué vers ce remote

#### Scenario: remote GitLab incohérent

- **GIVEN** que le remote défini par `REMOTE_GITLAB_NAME` existe avec une autre URL
- **WHEN** un push GitLab est demandé
- **THEN** la commande échoue explicitement
- **AND** aucun remote existant n'est écrasé

### Requirement: identifiants et remote sélectionné

La validation du remote et la résolution du dépôt GitLab MUST utiliser `REMOTE_GITLAB_NAME`, y compris lorsque sa valeur est `ecn`. Le mécanisme d'identification temporaire existant MUST rester utilisé pour le token.

#### Scenario: remote configuré sélectionné

- **GIVEN** que `REMOTE_GITLAB_NAME` vaut `ecn`
- **WHEN** un push GitLab authentifié est demandé
- **THEN** la validation et la résolution utilisent le remote `ecn`
- **AND** le token utilise le mécanisme temporaire existant
