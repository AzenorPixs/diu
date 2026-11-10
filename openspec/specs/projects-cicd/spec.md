# projects-cicd Specification

## Purpose
Définir l'orchestration CI/CD conditionnelle d'un projet géré par DIU.

## Requirements

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

### Requirement: aide CI/CD

Les aides `diu projects help`, `diu projects cicd help` et
`diu projects cicd <ID PROJECT> help` MUST présenter la commande et sa
syntaxe et les six étapes, dont le build Debian conditionnel, sans exécuter le flux.

#### Scenario: aide CI/CD

- **WHEN** l'utilisateur demande `diu projects cicd help`
- **THEN** l'aide affiche `diu projects cicd <ID PROJECT>`
- **AND THEN** aucune opération CI/CD n'est appelée

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

### Requirement: activation Debian du flux

Le flux MUST appeler le même moteur que diu projects build debian <ID PROJECT>
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

### Requirement: Version facultative du CI/CD
La commande `diu projects cicd <ID PROJECT> [VERSION]` SHALL accepter une version stable x.y.z, la valider et mettre à jour l'unique affectation PROJECT_VERSION de la configuration existante avant le flux. Une configuration absente ou ambiguë SHALL provoquer un diagnostic sans modification. La forme explicite historique avec message et tag SHALL rester utilisable.

#### Scenario: Version fournie
- **WHEN** une version x.y.z valide est fournie et la configuration est valide
- **THEN** PROJECT_VERSION est créée ou mise à jour avant l'exécution normale du flux

#### Scenario: Version inchangée
- **WHEN** PROJECT_VERSION contient déjà la version demandée
- **THEN** la commande informe que la version est déjà configurée sans réécrire le fichier

#### Scenario: Version invalide ou configuration ambiguë
- **WHEN** la version est invalide ou la configuration ambiguë
- **THEN** la commande échoue avant toute écriture et sans lancer le flux

### Requirement: Reprise idempotente du CI/CD
Le flux SHALL indiquer comme informations les étapes déjà satisfaites. Pour une version déjà attribuée, il SHALL poursuivre les étapes sur les sources isolées du commit du tag, préserver les modifications en attente, préserver les artefacts existants et appliquer la règle d’autorité des tags aux références distantes. Les erreurs réelles SHALL rester bloquantes.

#### Scenario: Version attribuée à un autre commit
- **WHEN** la version demandée désigne déjà un autre commit
- **THEN** le flux informe que cette version est déjà attribuée et ne publie pas le nouveau commit sous cette version
- **AND THEN** les étapes ultérieures utilisent uniquement le commit du tag

#### Scenario: Publication déjà présente
- **WHEN** le dépôt ou l'artefact cible est déjà publié pour la version cohérente
- **THEN** le bilan indique son état existant sans signaler une erreur

#### Scenario: Modifications en attente
- **WHEN** des fichiers indexés, modifiés ou non suivis sont présents au lancement du rejeu
- **THEN** ils sont préservés et exclus des sources de construction

#### Scenario: Branche distante plus récente
- **WHEN** un tag distant est supérieur à la version demandée
- **THEN** le fournisseur est refusé avant toute modification distante

#### Scenario: Erreur de vérification distante
- **WHEN** le fournisseur est inaccessible ou qu’une référence change pendant la publication
- **THEN** le flux signale l’erreur ou l’indisponibilité selon les règles applicables

#### Scenario: Immutabilité Docker non confirmée
- **WHEN** le rejeu ne peut pas confirmer l'immutabilité du tag Docker distant
- **THEN** la publication Docker est ignorée et indiquée sans erreur
- **AND THEN** la publication Debian reste éligible indépendamment

### Requirement: Messages cohérents des publications
Les publications Debian SHALL identifier le fournisseur et le tag dans leurs messages. Les vérifications effectivement réalisées SHALL être annoncées sans exposer de secret ni attribuer à un fournisseur un contrôle non exécuté. Les informations de projet SHALL être visuellement alignées.

#### Scenario: Paquet déjà publié
- **WHEN** un paquet existe déjà sur un fournisseur
- **THEN** le message mentionne le fournisseur et le tag concerné

#### Scenario: Vérification réussie
- **WHEN** une authentification, synchronisation ou vérification de tag est réellement réussie
- **THEN** le résultat est indiqué pour le fournisseur concerné

#### Scenario: Vérification non effectuée
- **WHEN** un fournisseur ne réalise pas une vérification
- **THEN** aucun message ne prétend qu'elle a réussi

#### Scenario: Répertoire de rejeu
- **WHEN** une publication utilise un contexte de rejeu isolé
- **THEN** le répertoire affiché est identifié comme isolé

### Requirement: poursuite après indisponibilité pendant une release

Dans `diu projects cicd <ID PROJECT> [VERSION]`, une indisponibilité réseau reconnue pendant une release Forgejo, GitLab ou GitHub MUST être signalée comme publication non confirmée et MUST permettre de poursuivre les autres fournisseurs éligibles. Sans autre erreur, le bilan MUST indiquer les indisponibilités et le retour MUST être zéro. Toute publication déjà effectuée MUST être conservée et sa possible partialité signalée. Les statuts MUST être isolés entre appels et fournisseurs.

#### Scenario: release interrompue par une panne reconnue

- **WHEN** une release rencontre une indisponibilité réseau reconnue et les autres opérations éligibles réussissent
- **THEN** les fournisseurs suivants sont traités et le bilan indique la publication non confirmée
- **AND THEN** le code de retour est zéro

#### Scenario: panne après publication partielle

- **WHEN** un artefact ou une référence a pu être publié avant l’indisponibilité
- **THEN** le bilan indique que la publication peut être partielle et qu’une reprise est nécessaire
- **AND THEN** aucun rollback ni succès complet n’est annoncé

#### Scenario: erreur non qualifiée

- **WHEN** une release échoue pour un refus d’authentification, une erreur TLS ou de configuration, un rejet ou une autre cause non reconnue comme indisponibilité
- **THEN** l’erreur reste bloquante et le retour est non nul

#### Scenario: commandes directes et rejeu

- **WHEN** la release est appelée directement hors CI/CD ou le flux rejoue une version existante
- **THEN** le contrat des releases directes et les restrictions du rejeu restent inchangés
