## MODIFIED Requirements

### Requirement: Aide du template OpenSpec

Les aides projects et projects template SHALL présenter
`rid projects template openspec <ID PROJECT>` avec le libellé
« Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT> ».
Les aides `projects template openspec` et `projects template openspec <ID PROJECT>`
SHALL fonctionner avec help et ? avant tout chargement de configuration et
sans mutation. L'aide spécifique SHALL expliquer init avec le profil custom,
le choix OPENCODE et update pour un dossier OpenSpec existant. L'aide create
SHALL préciser OpenSpec avant DevOps. Les aides DevOps et all devops SHALL
être préservées ; openspec all SHALL décrire seulement le projet nommé all.
Les arguments surnuméraires ou invalides et l'ancienne syntaxe terminale
SHALL être rejetés avec une aide contextuelle.

#### Scenario: Découverte et aide terminale

- **WHEN** help ou ? suit projects, projects template, projects template openspec ou projects template openspec application
- **THEN** l'aide présente la nouvelle commande OpenSpec sans charger la configuration

#### Scenario: Création avec OpenSpec

- **WHEN** l'utilisateur demande projects create help
- **THEN** l'aide indique OpenSpec avant la génération DEVOPS.md

#### Scenario: Arguments invalides

- **WHEN** une aide OpenSpec contient un chemin invalide, un argument supplémentaire ou la syntaxe projects template application openspec help
- **THEN** un code d'erreur et une aide contextuelle sont rendus sans effet de bord
