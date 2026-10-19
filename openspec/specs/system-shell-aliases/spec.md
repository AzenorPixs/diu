# system-shell-aliases Specification

## Purpose

Définir le chemin de l'index commun des prompts dans l'alias `ci` de la
configuration Zsh générée pour root, en préservant les autres lignes générées.

## Requirements

### Requirement: Index des prompts dans l'alias ci de root

La configuration Zsh générée pour root SHALL définir exactement
`alias ci='cat /home/devops/datas/prompts/INDEX.md'`.
La correction de ce chemin SHALL préserver les autres lignes générées.

#### Scenario: Génération de l'alias ci

- **WHEN** le DIU génère la configuration Zsh de root
- **THEN** l'alias ci exécute `cat /home/devops/datas/prompts/INDEX.md`
- **AND** l'alias ci ne référence plus `/home/devops/datas/template/PROMPTS/INDEX.md`

#### Scenario: Préservation du contenu non concerné

- **WHEN** le contenu Zsh généré est comparé à celui précédant la correction
- **THEN** seule la ligne de l'alias ci change
- **AND** toutes les autres lignes sont identiques
