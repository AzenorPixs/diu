# projects-git-analyse Specification

## Purpose
Définir l'accès public à l'analyse du dépôt Git local d'un projet.

## Requirements

### Requirement: Analyse Git sous le sous-contexte projects git

DIU SHALL exposer l'analyse Git locale via
`rid projects git analyse <ID PROJECTS>`. Cette commande SHALL appeler la
fonction existante `git_analyse` avec l'identifiant fourni. La commande
historique `rid projects gita <ID PROJECT>` SHALL NOT être reconnue.

#### Scenario: Analyse d'un projet

- **WHEN** l'utilisateur exécute `rid projects git analyse diu`
- **THEN** DIU appelle `git_analyse` avec `diu`

#### Scenario: Commande historique retirée

- **WHEN** l'utilisateur exécute `rid projects gita diu`
- **THEN** DIU échoue avec un code de retour non nul sans lancer l'analyse Git
