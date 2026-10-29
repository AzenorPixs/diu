## ADDED Requirements

### Requirement: Aide du packaging Debian DIU

Les aides SHALL présenter rid projects deb [ID PROJECT] et rid proj deb <ID PROJECT>, le défaut diu et la nature DIU des sources. help et ? SHALL fonctionner avant le bootstrap, sans construction ni configuration.

#### Scenario: Aide packaging sans effet

- **WHEN** une aide des deux syntaxes est demandée
- **THEN** elle explique la source et le défaut sans appeler le builder

