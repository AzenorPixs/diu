# projects-cicd Specification

## Purpose
Définir l'orchestration CI/CD conditionnelle d'un projet géré par DIU.

## Requirements

### Requirement: commande CI/CD d'un projet

Le système MUST exposer `rid projects cicd <ID PROJECT>`. La commande MUST
créer les valeurs de commit et de tag par défaut selon le comportement existant
puis appeler, dans cet ordre, `git_commit`, les pushes Forgejo, GitLab et
GitHub éligibles, `projects_docker_build` lorsque Docker est activé, puis les
releases Forgejo, GitLab et GitHub éligibles. À la terminaison, elle MUST
afficher un résumé console du commit, des pushes, du build et des releases.
Lorsqu'une opération appelée échoue, elle MUST afficher le résumé partiel avant
de retourner un code non nul.

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

- **WHEN** une opération éligible échoue après le commit
- **THEN** la commande retourne un code non nul
- **AND THEN** elle affiche les opérations déjà réussies et l'opération en échec

### Requirement: fournisseurs conditionnels et silencieux

Avant chaque push ou release de fournisseur, le système MUST vérifier la
complétude de sa configuration dans `project.env`. Une configuration absente,
incomplète ou incohérente MUST ignorer l'opération correspondante sans sortie,
sans appel de fonction et sans initialisation interactive. Une opération
effectivement appelée qui échoue MUST interrompre le flux avec un code non nul.
Le résumé final MUST indiquer qu'une opération a été ignorée, sans modifier son
caractère silencieux pendant le flux.

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

### Requirement: activation Docker du flux

Le flux MUST appeler `projects_docker_build` et les releases éligibles
uniquement lorsque `PROJECT_DOCKERED` vaut exactement `Yes`. Pour toute autre
valeur, il MUST ignorer ces opérations sans sortie.

#### Scenario: projet non Dockerisé

- **WHEN** `PROJECT_DOCKERED` est absent ou différent de `Yes`
- **THEN** aucune construction ni release n'est appelée

### Requirement: aide CI/CD

Les aides `rid projects help`, `rid projects cicd help` et
`rid projects cicd <ID PROJECT> help` MUST présenter la commande et sa
syntaxe sans exécuter le flux.

#### Scenario: aide CI/CD

- **WHEN** l'utilisateur demande `rid projects cicd help`
- **THEN** l'aide affiche `rid projects cicd <ID PROJECT>`
- **AND THEN** aucune opération CI/CD n'est appelée
