## MODIFIED Requirements

### Requirement: Copie ciblée et autoritaire du modèle

DIU MUST écraser AGENTS.md et .gitignore depuis le modèle, et
ORCHESTRATED_CODING.md uniquement pour Yes lu selon implement-projects-update.
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

- **WHEN** le mode destination vaut Yes et le document modèle est disponible
- **THEN** ORCHESTRATED_CODING.md est copié, personnalisé et reçoit le propriétaire du projet

#### Scenario: Préservation du protocole pour un projet autonome

- **WHEN** le mode destination vaut No ou est absent ou vide
- **THEN** ORCHESTRATED_CODING.md n'est pas copié et sa destination existante reste intacte

## ADDED Requirements

### Requirement: Copie initiale de la carte de développement

DIU MUST copier DEVELOPMENT_MAP.md du modèle à la racine du projet seulement
si aucune entrée de ce nom n'existe à destination. Une entrée existante,
y compris répertoire ou lien symbolique pendant, MUST rester intacte sans
personnalisation ni changement de droits ou de propriétaire. Cette décision
MUST être indépendante de PROJECT_ORCHESTRATED_CODING et prise pour chaque
projet en mode unitaire ou groupé.

#### Scenario: Carte absente du projet

- **WHEN** la destination est absente et le modèle contient DEVELOPMENT_MAP.md
  comme fichier régulier
- **THEN** DIU copie ce document, personnalise Template et template selon
  les règles Markdown et applique le propriétaire des ressources synchronisées

#### Scenario: Carte existante préservée après réexécution

- **WHEN** une carte existe déjà et la synchronisation est exécutée ou répétée
- **THEN** le contenu, les droits, le propriétaire, l'inode et la date de
  modification restent inchangés
- **AND THEN** la source de cette carte n'est pas requise

#### Scenario: Entrée destination de type différent

- **WHEN** DEVELOPMENT_MAP.md désigne un répertoire ou un lien symbolique,
  y compris un lien pendant
- **THEN** DIU préserve cette entrée et ne copie pas la carte du modèle

### Requirement: Source conditionnelle de la carte de développement

Si DEVELOPMENT_MAP.md est absent à destination, DIU MUST vérifier que la source
modèle est un fichier régulier avant toute copie dans ce projet. Une source
absente ou de type incorrect MUST provoquer un diagnostic explicite et un code
non nul avant la copie des ressources du modèle. En mode groupé, cet échec
MUST préserver le parcours des autres projets selon projects-sync-all.

#### Scenario: Source absente ou incorrecte et carte à initialiser

- **WHEN** la carte destination est absente et la source est absente ou désigne
  un répertoire
- **THEN** la synchronisation échoue sans copier de ressource dans ce projet

#### Scenario: Synchronisation groupée avec états mixtes

- **WHEN** certains projets possèdent une carte et d'autres n'en possèdent pas
- **THEN** chaque carte existante est préservée et seules les cartes absentes
  sont initialisées depuis une source régulière disponible

#### Scenario: Échec conditionnel pendant le parcours groupé

- **WHEN** la source est absente et un projet sans carte précède un projet
  possédant déjà une carte
- **THEN** le premier projet échoue avant copie, le second peut être synchronisé
  et le parcours groupé retourne un code non nul
