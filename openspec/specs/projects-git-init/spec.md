# projects-git-init Specification

## Purpose
Définir la commande publique canonique pour initialiser le dépôt Git local
d'un projet sans conserver une abréviation historique ambiguë.

## Requirements

### Requirement: Initialisation Git sous le sous-contexte projects git

DIU MUST exposer l'initialisation d'un dépôt Git local par la commande
`diu projects git init <ID PROJECT>`. Cette commande MUST initialiser le
dépôt du projet désigné. La commande historique
`diu projects giti <ID PROJECT>` MUST NOT être reconnue comme une commande
publique valide.

#### Scenario: Initialisation avec la commande canonique

- **WHEN** l'utilisateur exécute `diu projects git init diu`
- **THEN** DIU initialise le dépôt Git local du projet `diu`

#### Scenario: Rejet de la commande historique

- **WHEN** l'utilisateur exécute `diu projects giti diu`
- **THEN** DIU échoue avec un code de retour non nul
- **AND THEN** aucune initialisation Git n'est exécutée

### Requirement: Exception système limitée au projet initialisé

`diu projects git init <ID PROJECT>` MUST enregistrer une exception
`safe.directory` en portée système pour le chemin absolu canonique du projet,
y compris si un dépôt existe déjà. L'opération MUST rester silencieuse en
cas de succès et MUST NOT ajouter de joker ni modifier les autres entrées.
Une entrée exacte active MUST NOT être ajoutée une seconde fois.

#### Scenario: Nouveau dépôt ou dépôt existant sans exception

- **GIVEN** un projet valide sans entrée système exacte active
- **WHEN** l'initialisation Git du projet est demandée
- **THEN** le chemin canonique est ajouté à la configuration Git système
- **AND** les comportements d'initialisation existants sont conservés

#### Scenario: Réexécution idempotente

- **GIVEN** le chemin canonique déjà présent après la dernière entrée vide
- **WHEN** l'initialisation est redemandée
- **THEN** aucune seconde entrée n'est ajoutée
- **AND** l'opération réussie reste silencieuse

### Requirement: Contrôles de l'enregistrement système

Une entrée vide MUST réinitialiser les entrées antérieures pour le contrôle
de présence. Un chemin finissant par `/*` ou contenant un saut de ligne MUST
être refusé. Toute erreur de lecture ou d'écriture MUST produire un
diagnostic et un retour non nul avant de poursuivre l'initialisation.

#### Scenario: Réinitialisation de la liste

- **GIVEN** le chemin du projet suivi d'une entrée système vide
- **WHEN** l'exception est enregistrée
- **THEN** le chemin est ajouté après cette réinitialisation

#### Scenario: Erreur système

- **GIVEN** une configuration Git système illisible, invalide ou non modifiable
- **WHEN** l'initialisation nécessite la lecture ou l'ajout de l'exception
- **THEN** la commande échoue explicitement sans poursuivre l'initialisation

#### Scenario: Réinitialisation prioritaire par un fichier système inclus

- **GIVEN** une entrée du fichier principal neutralisée par un include système
- **WHEN** l'exception est enregistrée ou revérifiée
- **THEN** la commande MUST signaler un échec sans annoncer une exception active
- **AND** les réexécutions MUST NOT accumuler de nouvelles entrées identiques
- **AND** les règles incluses MUST rester intactes
