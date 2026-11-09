## MODIFIED Requirements

### Requirement: Copie ciblée et autoritaire du modèle

DIU MUST copier uniquement AGENTS.md, .gitignore,
.opencode/{commands,config,skills} et PROMPTS, et ancien protocole local
seulement pour Yes lu selon implement-projects-update, récursivement pour les
répertoires. Le modèle MUST écraser
les éléments copiés. DIU MUST préserver les autres destinations et MUST NOT
copier, créer, personnaliser, supprimer ou modifier les droits ou le
propriétaire de DEVOPS.md à la racine, en mode unitaire ou groupé.

#### Scenario: Écrasement d'un élément géré

- **WHEN** un fichier ou un contenu de répertoire géré existe déjà dans le projet destination
- **THEN** sa version issue du modèle devient la version présente après la synchronisation

#### Scenario: Préservation d'un élément non géré

- **WHEN** le projet destination contient un élément hors de la sélection
- **THEN** cet élément est conservé après la synchronisation

#### Scenario: Préservation du document d'environnement existant

- **WHEN** le projet destination possède un DEVOPS.md et la synchronisation réussit
- **THEN** son contenu, ses droits et son propriétaire restent inchangés

#### Scenario: Absence de création du document d'environnement

- **WHEN** le projet destination ne possède aucun DEVOPS.md, même si le modèle en contient un
- **THEN** aucun DEVOPS.md n'est créé à la racine du projet destination

#### Scenario: Copie du protocole pour un projet piloté

- **WHEN** le mode destination vaut Yes et le document modèle est disponible
- **THEN** ancien protocole local est copié, personnalisé et reçoit le propriétaire du projet

#### Scenario: Préservation du protocole pour un projet autonome

- **WHEN** le mode destination vaut No ou est absent ou vide
- **THEN** ancien protocole local n'est pas copié et sa destination existante reste intacte
