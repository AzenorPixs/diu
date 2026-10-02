## ADDED Requirements

### Requirement: Aide de génération du modèle DevOps

L'aide `rid projects help` SHALL présenter `rid projects template devops`.
Les aides `rid projects template help`, `rid projects template ?`,
`rid projects template devops help` et `rid projects template devops ?`
SHALL présenter cette commande avec une description concise, avant tout
chargement de configuration ou génération de document. Un contexte template
inconnu SHALL rendre une erreur et proposer l'aide du dernier contexte reconnu.

#### Scenario: Aide intermédiaire ou terminale

- **WHEN** help ou ? suit projects template ou projects template devops
- **THEN** la commande de génération et sa description sont affichées sans écriture

#### Scenario: Aide inconnue sous template

- **WHEN** une sous-commande template inconnue est suivie de help
- **THEN** DIU échoue et suggère `rid projects template help`
