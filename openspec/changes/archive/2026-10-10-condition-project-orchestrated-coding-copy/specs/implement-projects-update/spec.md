## ADDED Requirements

### Requirement: Copie conditionnelle du protocole de codage piloté

Pour la création depuis le modèle et la synchronisation, DIU MUST copier le
document racine ancien protocole local si et seulement si
project_orchestrated_coding_get retourne Yes depuis le project.env destination.
La copie MUST suivre la personnalisation Markdown et les règles de propriété
existantes.

#### Scenario: Projet piloté

- **WHEN** le mode destination vaut Yes et le document modèle est disponible
- **THEN** la création ou synchronisation copie le document, avec remplacement de Template et template
- **AND** une version destination gérée est écrasée à la synchronisation

#### Scenario: Configuration du modèle ou du shell différente

- **WHEN** le modèle ou le shell indique Yes et le projet destination indique No ou omet la variable
- **THEN** le document n'est pas copié et la configuration destination est préservée

### Requirement: Préservation du protocole en mode autonome

Pour No, une variable absente ou vide, DIU MUST NOT copier, créer, supprimer,
personnaliser ou changer les attributs d'un document destination existant,
et MUST NOT exiger le document source lors de la création ou synchronisation.

#### Scenario: Projet autonome ou historique

- **WHEN** le mode destination vaut No ou est absent ou vide
- **THEN** le document modèle n'est pas copié et une destination existante reste intacte
- **AND** une source absente n'empêche pas l'opération

### Requirement: Échec avant copie du modèle

Une valeur de mode invalide MUST provoquer un échec avant toute copie du
modèle. Pour Yes, une source ancien protocole local absente ou non régulière
MUST provoquer le même échec. La création MAY conserver le répertoire et la
configuration déjà préparés ; elle MUST NOT annoncer un succès.

#### Scenario: Mode invalide ou source requise indisponible

- **WHEN** le mode est invalide ou vaut Yes avec un document modèle absent ou non régulier
- **THEN** l'opération échoue avant toute copie du modèle et sans message de succès

### Requirement: Décision du mode pour chaque projet synchronisé

La synchronisation groupée MUST décider de la copie du protocole séparément
pour chaque projet. Elle MUST conserver la poursuite après échec et son code
de retour non nul en présence d'un projet en échec.

#### Scenario: Synchronisation groupée de modes différents

- **WHEN** plusieurs projets ont des modes distincts, dont un projet piloté en échec
- **THEN** chaque projet reçoit uniquement les copies correspondant à son mode
- **AND** les projets suivants sont traités et le résultat global est non nul
