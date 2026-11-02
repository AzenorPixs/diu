## MODIFIED Requirements

### Requirement: Aide du build Debian générique

Les aides SHALL présenter rid projects build debian <ID PROJECT> et l'alias deb,
PROJECT_DEBIAN_PACKAGE avec Yes/YES/1 et la recette build/debian-package.json.
Les aides build, build debian et build deb, avec ou sans projet, SHALL rester
disponibles avant bootstrap sans construction ni lecture de configuration.

#### Scenario: Aide contextuelle
- **WHEN** l'aide de projects build, projects build deb ou projects build deb diu est demandée
- **THEN** elle présente les syntaxes et le contrat sans construction ni chargement de configuration

#### Scenario: aides des deux syntaxes
- **WHEN** help ou ? est demandé pour build, build debian ou build deb
- **THEN** la syntaxe canonique et l'alias sont expliqués sans effet de bord
