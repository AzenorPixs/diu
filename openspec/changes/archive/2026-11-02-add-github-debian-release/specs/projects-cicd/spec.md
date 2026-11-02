## MODIFIED Requirements

### Requirement: activation Docker du flux

Le flux MUST appeler le build Docker et les publications Docker uniquement
lorsque PROJECT_DOCKERED vaut exactement Yes. Toute autre valeur MUST ignorer
ces opérations, sans empêcher le build ni les publications Debian activés.

#### Scenario: projet non Dockerisé
- **WHEN** PROJECT_DOCKERED est absent ou différent de Yes et le packaging Debian est désactivé
- **THEN** aucune construction ni publication d'artefact n'est appelée

#### Scenario: projet Debian sans Docker
- **WHEN** PROJECT_DOCKERED est absent ou différent de Yes et PROJECT_DEBIAN_PACKAGE vaut Yes
- **THEN** le build Docker est ignoré et le build Debian est exécuté avant les publications Debian éligibles
- **AND THEN** aucune publication Docker n'est appelée et la publication Debian GitHub est éligible


### Requirement: activation Debian du flux

Le flux MUST appeler le même moteur que rid projects build debian <ID PROJECT>
uniquement lorsque PROJECT_DEBIAN_PACKAGE vaut Yes, YES ou 1. Une clé absente,
vide ou différente MUST ignorer cette construction et l'indiquer au bilan.
Sans Docker, les publications Debian Forgejo/GitLab/GitHub MUST rester
éligibles selon leur configuration. Un échec ou une indisponibilité MUST
conserver les règles de bilan et de poursuite du flux.

#### Scenario: valeurs actives
- **WHEN** la variable vaut Yes, YES ou 1
- **THEN** un unique build Debian est appelé à l'étape 4 avant les publications

#### Scenario: projet désactivé
- **WHEN** la clé est absente, vide ou différente des trois valeurs actives
- **THEN** le builder Debian n'est pas appelé et le bilan indique le build ignoré

#### Scenario: recette absente
- **WHEN** le packaging est activé mais la recette est absente
- **THEN** le builder échoue explicitement, aucune release n'est lancée et le bilan indique l'échec

#### Scenario: GitHub Debian à l'étape 5
- **WHEN** le paquet est construit, Docker est désactivé et GitHub est configuré et disponible
- **THEN** l'étape 5 appelle le publisher Debian GitHub et le bilan indique sa réussite ou son échec
