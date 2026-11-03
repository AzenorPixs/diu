## MODIFIED Requirements

### Requirement: Copie ciblée et autoritaire du modèle

DIU MUST écraser AGENTS.md et .gitignore depuis le modèle, et MUST NOT consulter ni copier ORCHESTRATED_CODING.md.
DIU MUST copier DEVELOPMENT_MAP.md uniquement si sa destination est absente,
selon les règles de copie initiale. DIU MUST préserver les autres destinations
et MUST NOT copier, créer, personnaliser, supprimer ou modifier les droits ou
le propriétaire de DEVOPS.md à la racine, en mode unitaire ou groupé.

#### Scenario: Écrasement d'un élément géré

- **WHEN** un fichier géré existe déjà dans le projet destination
- **THEN** sa version issue du modèle devient la version présente après
  synchronisation, avec la personnalisation Markdown spécifiée

#### Scenario: Préservation d'un élément non géré

- **WHEN** le projet contient un élément hors de la sélection conservée
- **THEN** cet élément reste intact après la synchronisation

#### Scenario: Préservation du document d'environnement existant

- **WHEN** le projet destination possède un DEVOPS.md
- **THEN** son contenu, ses droits et son propriétaire restent inchangés

#### Scenario: Absence de création du document d'environnement

- **WHEN** le projet destination ne possède aucun DEVOPS.md
- **THEN** la synchronisation n'en crée pas, même si le modèle en contient un

#### Scenario: Copie du protocole pour un projet piloté

- **WHEN** la synchronisation unitaire ou groupée concerne un projet dont le mode vaut Yes
- **THEN** ORCHESTRATED_CODING.md n'est pas requis dans le modèle et toute destination existante reste intacte

#### Scenario: Préservation du protocole pour un projet autonome

- **WHEN** la synchronisation unitaire ou groupée concerne un projet dont le mode vaut No ou est absent ou vide
- **THEN** ORCHESTRATED_CODING.md n'est pas requis dans le modèle et toute destination existante reste intacte
