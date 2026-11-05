# system-update-report Specification

## Purpose
Présenter un bilan fiable de la mise à jour Debian et des logiciels DIU activés, avec les versions observées et les diagnostics utiles.

## Requirements

### Requirement: Mise à jour Debian et bilan fiable
`diu system update` MUST conserver la configuration et la mise à jour APT système, dist-upgrade, autoclean, autopurge, autoremove et les prérequis. Sa sortie MUST être masquée durant l'exécution, avec une animation en terminal interactif.

#### Scenario: Phase système
- **WHEN** la commande est lancée
- **THEN** les opérations système et le nettoyage sont exécutés avec leur sortie masquée.

### Requirement: Bilan Debian
Le résultat MUST présenter la version Debian et les versions effectivement modifiées. Il MUST signaler les erreurs ou avertissements et leurs diagnostics sans déclarer le système à jour en cas d'échec. En absence de modification et d'erreur le bilan Debian MUST tenir sur une ligne.

#### Scenario: Aucun paquet changé
- **WHEN** les opérations réussissent et aucune version installée ne change
- **THEN** le bilan Debian indique sa version et son état à jour sur une seule ligne.

#### Scenario: Échec ou avertissement
- **WHEN** une étape échoue ou un dépôt signale un avertissement, même si le message de compatibilité APT apparaît aussi
- **THEN** le bilan signale le problème et fournit les diagnostics sans déclarer le système à jour.

### Requirement: Avis de compatibilité APT
La ligne exacte `WARNING: apt does not have a stable CLI interface. Use with caution in scripts.` MUST NOT être considérée comme un avertissement de mise à jour. Les autres avertissements et codes d'erreur MUST rester pris en compte.

#### Scenario: Message de compatibilité APT seul
- **WHEN** les opérations réussissent et que le seul avertissement est le message exact de compatibilité de l'interface APT
- **THEN** le bilan indique le succès sans afficher la sortie capturée.

### Requirement: Moteurs et logiciels activés
La commande MUST présenter APT, GitHub et Flatpak avec leur état et vérifier les dépendances des moteurs actifs. Les moteurs désactivés MUST conserver leurs dépendances. Elle MUST mettre à jour et afficher les logiciels DIU dont la variable vaut 1 pour les moteurs actifs, avec leur version actuelle ou les versions avant et après changement. Elle MUST NOT mettre à jour les applications Flatpak sans variable DIU active.

#### Scenario: Logiciel déjà à jour
- **WHEN** le moteur et le logiciel sont activés et que sa version ne change pas
- **THEN** son nom et sa version actuelle sont affichés.

#### Scenario: Logiciel mis à jour par APT
- **WHEN** la phase Debian modifie un logiciel APT DIU activé
- **THEN** le bilan du moteur présente les versions observées avant et après.

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
