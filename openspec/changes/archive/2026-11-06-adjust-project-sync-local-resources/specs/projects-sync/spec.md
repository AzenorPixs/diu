## MODIFIED Requirements

### Requirement: Copie ciblée et autoritaire du modèle

DIU MUST écraser AGENTS.md et .gitignore depuis le modèle, et MUST NOT consulter ni copier ancien protocole local.
DIU MUST préserver DEVELOPMENT_MAP.md sans le copier ni le créer.
DIU MUST créer `.cab-tests` selon les règles
ci-dessous et préserver les autres destinations
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
- **THEN** ancien protocole local n'est pas requis dans le modèle et toute destination existante reste intacte

#### Scenario: Préservation du protocole pour un projet autonome

- **WHEN** la synchronisation unitaire ou groupée concerne un projet dont le mode vaut No ou est absent ou vide
- **THEN** ancien protocole local n'est pas requis dans le modèle et toute destination existante reste intacte

## ADDED Requirements

### Requirement: Répertoire local de tests CAB

Pour chaque projet synchronisé, DIU MUST créer `.cab-tests` à la racine s'il
est absent, sans consulter ni copier son contenu depuis le modèle. Un dossier
existant et son contenu MUST rester inchangés. Un dossier nouvellement créé
MUST recevoir le propriétaire prévu pour le projet. Si la création ou
l'attribution du propriétaire échoue, la synchronisation MUST signaler l'échec
et retourner un code non nul ; les écritures précédentes restent en place.

#### Scenario: Dossier absent

- **WHEN** le projet valide ne contient pas `.cab-tests`
- **THEN** la synchronisation crée un dossier vide, y compris en mode groupé

#### Scenario: Dossier existant

- **WHEN** `.cab-tests` existe comme dossier et contient des données locales
- **THEN** son contenu, ses droits et son propriétaire restent inchangés

#### Scenario: Création impossible

- **WHEN** une entrée incompatible empêche la création de `.cab-tests`
- **THEN** la synchronisation signale l'erreur et retourne un code non nul

### Requirement: Préservation de la carte de développement

DIU MUST NOT consulter, copier, créer ou modifier DEVELOPMENT_MAP.md pendant
la synchronisation unitaire ou groupée, quel que soit le mode de pilotage.
La source modèle n'est pas requise. Toute entrée existante à destination,
y compris un répertoire ou un lien symbolique, MUST rester intacte.

#### Scenario: Carte absente du projet

- **WHEN** la carte est absente du projet, que la source modèle existe ou non
- **THEN** la synchronisation ne crée pas de carte et peut réussir

#### Scenario: Carte existante

- **WHEN** une entrée DEVELOPMENT_MAP.md existe dans le projet
- **THEN** la synchronisation la préserve sans changement de contenu, droits ou propriétaire

## REMOVED Requirements

### Requirement: Copie initiale de la carte de développement

**Reason**: La carte ne fait plus partie des ressources synchronisées.
**Migration**: Les cartes existantes sont préservées et les cartes absentes ne sont plus créées.

### Requirement: Source conditionnelle de la carte de développement

**Reason**: La source de la carte n'est plus utilisée par la synchronisation.
**Migration**: Aucune source de carte n'est nécessaire.
