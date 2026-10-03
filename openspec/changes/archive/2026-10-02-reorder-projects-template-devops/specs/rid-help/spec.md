## MODIFIED Requirements

### Requirement: Aide de génération du modèle DevOps

L'aide rid projects help SHALL présenter rid projects template devops <ID PROJECT>
et rid projects template devops all. Les aides du contexte template, du
sélecteur devops et de la commande terminale SHALL fonctionner avec help et ?,
avant tout chargement de configuration et sans génération. Les arguments
surnuméraires, les chemins, les sélecteurs inconnus et les anciens contextes
par projet sans sélecteur SHALL être rejetés avec une aide contextuelle.
L'aide create SHALL préciser la génération finale de DEVOPS.md.

#### Scenario: Aide intermédiaire ou terminale

- **WHEN** help ou ? suit projects template, projects template devops ou projects template devops application
- **THEN** l'aide présente la nouvelle syntaxe avec l'identifiant de projet sans écriture

#### Scenario: Aide inconnue sous template

- **WHEN** un sélecteur inconnu, une ancienne syntaxe ou des arguments supplémentaires sont suivis de help
- **THEN** l'aide rend un code d'erreur et suggère le contexte template ou devops

#### Scenario: Aide de création

- **WHEN** l'utilisateur exécute rid projects create help
- **THEN** l'aide indique la création depuis le modèle et la génération finale de DEVOPS.md

#### Scenario: Aide du traitement groupé

- **WHEN** help ou ? suit projects template devops all
- **THEN** l'aide présente la génération pour tous les projets configurés avec les cinq variables requises
- **AND THEN** aucune configuration n'est chargée et aucun document n'est généré

#### Scenario: Découverte du traitement groupé

- **WHEN** l'utilisateur demande projects help, projects template help ou projects template devops help
- **THEN** l'aide présente les commandes individuelle et all

### Requirement: Aide du template OpenSpec

Les aides projects et projects template SHALL présenter
`rid projects template openspec <ID PROJECT>` avec le libellé
« Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT> ».
Les aides `projects template openspec` et `projects template openspec <ID PROJECT>`
SHALL fonctionner avec help et ? avant tout chargement de configuration et
sans mutation. L'aide spécifique SHALL expliquer init avec le profil custom,
le choix OPENCODE et update pour un dossier OpenSpec existant. L'aide create
SHALL préciser OpenSpec avant DevOps. Les aides DevOps individuelles et groupées
SHALL suivre `projects template devops <ID PROJECT>` et `projects template devops all` ;
openspec all SHALL décrire seulement le projet nommé all. Les arguments
surnuméraires ou invalides et l'ancienne syntaxe terminale qui ne correspond
pas déjà à une commande valide SHALL être rejetés avec une aide contextuelle.

#### Scenario: Découverte et aide terminale

- **WHEN** help ou ? suit projects, projects template, projects template openspec ou projects template openspec application
- **THEN** l'aide présente la nouvelle commande OpenSpec sans charger la configuration

#### Scenario: Création avec OpenSpec

- **WHEN** l'utilisateur demande projects create help
- **THEN** l'aide indique OpenSpec avant la génération DEVOPS.md

#### Scenario: Arguments invalides

- **WHEN** une aide OpenSpec contient un chemin invalide, un argument supplémentaire ou la syntaxe projects template application openspec help
- **THEN** un code d'erreur et une aide contextuelle sont rendus sans effet de bord
