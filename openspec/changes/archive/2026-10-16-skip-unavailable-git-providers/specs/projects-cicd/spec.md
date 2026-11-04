## MODIFIED Requirements

### Requirement: commande CI/CD d'un projet

`rid projects cicd <ID PROJECT>` MUST créer commit/tag, puis appeler dans
l'ordre `git_commit`, les pushes Forgejo/GitLab/GitHub éligibles, le build
Docker activé et les releases éligibles. Elle MUST afficher un résumé.
Un échec hors indisponibilité reconnue MUST arrêter le flux avec résumé et
code non nul ; une indisponibilité MUST suivre le contrat de poursuite.

#### Scenario: résumé du flux complet

- **WHEN** un projet possède une configuration complète des trois fournisseurs
  et `PROJECT_DOCKERED=Yes`
- **THEN** la commande appelle les huit opérations dans l'ordre défini
- **AND THEN** son résumé présente le commit, les trois pushes, le build et les
  trois releases avec leurs cibles

#### Scenario: ordre du flux complet

- **WHEN** un projet possède une configuration complète des trois fournisseurs
  et `PROJECT_DOCKERED=Yes`
- **THEN** la commande appelle les huit opérations dans l'ordre défini

#### Scenario: résumé d'un échec

- **WHEN** une opération éligible échoue après le commit hors indisponibilité reconnue
- **THEN** la commande retourne un code non nul
- **AND THEN** elle affiche les opérations déjà réussies et l'opération en échec

### Requirement: fournisseurs conditionnels et silencieux

Avant chaque push ou release, le flux MUST vérifier la configuration du
fournisseur. Une configuration absente, incomplète ou incohérente MUST ignorer
l'opération sans appel ni initialisation interactive, et l'indiquer au résumé.
Un échec effectivement appelé MUST interrompre le flux avec code non nul,
sauf indisponibilité reconnue traitée par le contrat de poursuite.

#### Scenario: fournisseur incomplet

- **WHEN** la configuration d'un fournisseur est incomplète
- **THEN** ses opérations ne sont pas appelées et aucune sortie de saut n'est
  produite pendant le flux
- **AND THEN** le résumé final les indique comme ignorées

#### Scenario: Forgejo incomplet

- **WHEN** la configuration Forgejo du projet est incomplète
- **THEN** `forgejo_push` et `projects_forgejo_release` ne sont pas appelées
- **AND THEN** aucune sortie de saut n'est produite

#### Scenario: GitLab incomplet

- **WHEN** la configuration GitLab ou son registre est incomplète
- **THEN** `gitlab_push` et `projects_gitlab_release` ne sont pas appelées
- **AND THEN** aucune sortie de saut n'est produite

#### Scenario: GitHub incomplet

- **WHEN** la configuration GitHub est incomplète
- **THEN** `github_push` et `projects_github_release` ne sont pas appelées
- **AND THEN** aucune sortie de saut n'est produite

## ADDED Requirements

### Requirement: poursuite avec fournisseurs indisponibles

Après un push indisponible, CI/CD MUST poursuivre les autres fournisseurs et
le build activé, et MUST ignorer les releases du fournisseur concerné.
Le résumé MUST distinguer publication non confirmée, publication réussie et
release ignorée. Sans autre erreur, le flux MUST retourner zéro avec l'état
« terminé avec indisponibilités ». Les statuts MUST être réinitialisés par appel.

#### Scenario: fournisseur inaccessible parmi trois

- **WHEN** un push est indisponible et les autres opérations éligibles réussissent
- **THEN** les autres fournisseurs et le build sont traités
- **AND THEN** les releases du fournisseur indisponible sont ignorées
- **AND THEN** le résumé indique terminé avec indisponibilités et le code final vaut zéro

#### Scenario: erreur réelle après une indisponibilité

- **WHEN** un fournisseur est indisponible puis une autre opération échoue pour une autre cause
- **THEN** le flux retourne un code non nul avec le résumé partiel
