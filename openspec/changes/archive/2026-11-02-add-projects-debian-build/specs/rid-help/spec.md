## ADDED Requirements

### Requirement: Aide du build Debian générique
L'aide SHALL présenter `rid projects build deb <ID PROJECT>`, l'indicateur PROJECT_DEBIAN_PACKAGE, les valeurs Yes/YES/1 et la recette build/debian-package.json. help et ? SHALL fonctionner avant le bootstrap et sans écriture.

#### Scenario: Aide contextuelle
- **WHEN** l'aide de projects build, projects build deb ou projects build deb diu est demandée
- **THEN** elle présente la syntaxe et le contrat sans construction ni chargement de configuration
