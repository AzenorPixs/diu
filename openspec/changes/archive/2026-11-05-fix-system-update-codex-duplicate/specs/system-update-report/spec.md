# Bilan des mises à jour système

## ADDED Requirements

### Requirement: Bilan GitHub sans doublon
Dans `diu system update`, le logiciel GitHub activé MUST apparaître une seule fois dans le bilan de succès avec sa version actuelle ou ses versions avant et après mise à jour. Les diagnostics de la recette MUST être restitués en cas d'échec. Les commandes logicielles directes MUST conserver leur sortie.

#### Scenario: Logiciel déjà à jour
- **WHEN** Codex CLI activé est déjà à jour et sa vérification réussit
- **THEN** le bilan contient une seule ligne `• Codex CLI` avec sa version actuelle.

#### Scenario: Logiciel mis à jour
- **WHEN** Codex CLI activé est mis à jour avec succès
- **THEN** le bilan contient une seule ligne `• Codex CLI` présentant les versions avant et après.

#### Scenario: Échec de la recette
- **WHEN** la recette GitHub échoue
- **THEN** ses diagnostics sont affichés et la commande signale l'échec.
