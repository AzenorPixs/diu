# technical-accounts-passwords Specification

## Purpose
Préserver les mots de passe existants lors du provisionnement des comptes
techniques DevOps, Docker et IA, sans définir de mot de passe pour les nouveaux.

## Requirements

### Requirement: Provisionnement des comptes techniques sans mot de passe

DIU SHALL préserver le mot de passe des comptes DevOps, Docker et IA existants
et SHALL créer les comptes absents sans définir leur mot de passe. DIU SHALL NOT
utiliser les variables `ENV_DEVOPS_PASSWORD`, `ENV_DOCKER_PASSWORD` et
`ENV_IA_PASSWORD` pour provisionner ces comptes. Les groupes et le traitement
rootless existants SHALL rester inchangés.

#### Scenario: Compte technique existant

- **WHEN** l'environnement est activé et son compte existe déjà
- **THEN** DIU conserve son mot de passe et poursuit son provisionnement

#### Scenario: Compte technique absent

- **WHEN** l'environnement est activé et son compte n'existe pas
- **THEN** DIU crée le compte sans lui définir de mot de passe

#### Scenario: Ancienne variable de mot de passe absente

- **WHEN** la variable de mot de passe historique du compte n'est pas définie
- **THEN** le provisionnement du compte ne dépend pas de cette variable
