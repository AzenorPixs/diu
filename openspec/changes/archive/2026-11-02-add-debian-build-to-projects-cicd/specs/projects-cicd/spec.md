## MODIFIED Requirements

### Requirement: commande CI/CD d'un projet

Le flux MUST exécuter six étapes : commit/tag, pushes configurés, build Docker
activé, build Debian activé, publications éligibles, bilan. Les deux builds MUST
être indépendants. Un échec bloquant MUST interrompre les étapes restantes avec
bilan partiel ; une indisponibilité reconnue MUST conserver la poursuite prévue.

#### Scenario: résumé du flux complet
- **WHEN** les trois fournisseurs sont complets, PROJECT_DOCKERED vaut Yes et le packaging Debian est désactivé
- **THEN** les huit opérations historiques sont appelées dans le même ordre
- **AND THEN** le bilan présente les cibles et indique le build Debian ignoré

#### Scenario: ordre du flux complet
- **WHEN** les trois fournisseurs sont complets, PROJECT_DOCKERED vaut Yes et le packaging Debian est désactivé
- **THEN** commit, trois pushes, build Docker et trois publications sont appelés dans cet ordre

#### Scenario: résumé d'un échec
- **WHEN** une opération éligible échoue après le commit hors indisponibilité reconnue
- **THEN** le flux retourne un code non nul et affiche les réussites et l'opération en échec

#### Scenario: ordre du flux mixte
- **WHEN** les trois fournisseurs sont complets, PROJECT_DOCKERED vaut Yes et PROJECT_DEBIAN_PACKAGE vaut Yes
- **THEN** le flux appelle commit, trois pushes, build Docker, build Debian puis trois fonctions de publication dans cet ordre
- **AND THEN** le bilan expose les six étapes et les deux résultats de build

#### Scenario: échec du build Debian
- **WHEN** le build Debian activé échoue
- **THEN** aucune publication d'artefact n'est appelée et le flux retourne un code non nul avec bilan partiel
- **AND THEN** les pushes Git déjà réalisés ne sont pas annulés

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
- **AND THEN** aucune publication Docker ni release GitHub n'est appelée

### Requirement: poursuite avec fournisseurs indisponibles

Après un push indisponible, CI/CD MUST poursuivre les autres fournisseurs et
les builds activés, et MUST ignorer les releases du fournisseur concerné.
Le résumé MUST distinguer publication non confirmée, publication réussie et
release ignorée. Sans autre erreur, le flux MUST retourner zéro avec l'état
« terminé avec indisponibilités ». Les statuts MUST être réinitialisés par appel.

#### Scenario: fournisseur inaccessible parmi trois

- **WHEN** un push est indisponible et les autres opérations éligibles réussissent
- **THEN** les autres fournisseurs et les builds activés sont traités
- **AND THEN** les releases du fournisseur indisponible sont ignorées
- **AND THEN** le résumé indique terminé avec indisponibilités et le code final vaut zéro

#### Scenario: erreur réelle après une indisponibilité

- **WHEN** un fournisseur est indisponible puis une autre opération échoue pour une autre cause
- **THEN** le flux retourne un code non nul avec le résumé partiel

### Requirement: aide CI/CD

Les aides `rid projects help`, `rid projects cicd help` et
`rid projects cicd <ID PROJECT> help` MUST présenter la commande et sa
syntaxe et les six étapes, dont le build Debian conditionnel, sans exécuter le flux.

#### Scenario: aide CI/CD

- **WHEN** l'utilisateur demande `rid projects cicd help`
- **THEN** l'aide affiche `rid projects cicd <ID PROJECT>`
- **AND THEN** aucune opération CI/CD n'est appelée


## ADDED Requirements

### Requirement: activation Debian du flux

Le flux MUST appeler le même moteur que rid projects build debian <ID PROJECT>
uniquement lorsque PROJECT_DEBIAN_PACKAGE vaut Yes, YES ou 1. Une clé absente,
vide ou différente MUST ignorer cette construction et l'indiquer au bilan.
Sans Docker, les publications Debian existantes Forgejo/GitLab MUST rester
éligibles selon leur configuration ; aucune publication Debian GitHub n'est ajoutée.

#### Scenario: valeurs actives
- **WHEN** la variable vaut Yes, YES ou 1
- **THEN** un unique build Debian est appelé à l'étape 4 avant les publications

#### Scenario: projet désactivé
- **WHEN** la clé est absente, vide ou différente des trois valeurs actives
- **THEN** le builder Debian n'est pas appelé et le bilan indique le build ignoré

#### Scenario: recette absente
- **WHEN** le packaging est activé mais la recette est absente
- **THEN** le builder échoue explicitement, aucune release n'est lancée et le bilan indique l'échec
