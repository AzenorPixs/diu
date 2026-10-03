## ADDED Requirements

### Requirement: Aide du template OpenSpec

Les aides projects et projects template SHALL présenter
`rid projects template <ID PROJECT> openspec`. L'aide d'un projet ciblé SHALL
présenter cette commande ; l'aide terminale openspec SHALL fonctionner avec
help et ? avant tout chargement de configuration et sans mutation. Elle SHALL
expliquer init avec le profil custom, le choix OPENCODE et update pour un
dossier OpenSpec existant. L'aide create SHALL préciser OpenSpec avant DevOps.
Les aides DevOps et all devops SHALL être préservées ; all openspec SHALL
décrire seulement le projet nommé all. Les arguments surnuméraires ou invalides
SHALL être rejetés avec une aide contextuelle.

#### Scenario: Découverte et aide terminale

- **WHEN** help ou ? suit projects, projects template, projects template application ou projects template application openspec
- **THEN** l'aide présente la commande OpenSpec appropriée sans charger la configuration

#### Scenario: Création avec OpenSpec

- **WHEN** l'utilisateur demande projects create help
- **THEN** l'aide indique OpenSpec avant la génération DEVOPS.md

#### Scenario: Arguments invalides

- **WHEN** une aide openspec contient un chemin de projet invalide ou un argument supplémentaire
- **THEN** un code d'erreur et une aide contextuelle sont rendus sans effet de bord
