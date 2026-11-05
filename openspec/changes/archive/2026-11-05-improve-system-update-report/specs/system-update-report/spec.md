# Bilan des mises à jour système

## ADDED Requirements

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
- **WHEN** une étape échoue ou un dépôt signale un avertissement
- **THEN** le bilan signale le problème et fournit les diagnostics sans déclarer le système à jour.

### Requirement: Moteurs et logiciels activés
La commande MUST présenter APT, GitHub et Flatpak avec leur état et vérifier les dépendances des moteurs actifs. Les moteurs désactivés MUST conserver leurs dépendances. Elle MUST mettre à jour et afficher les logiciels DIU dont la variable vaut 1 pour les moteurs actifs, avec leur version actuelle ou les versions avant et après changement. Elle MUST NOT mettre à jour les applications Flatpak sans variable DIU active.

#### Scenario: Logiciel déjà à jour
- **WHEN** le moteur et le logiciel sont activés et que sa version ne change pas
- **THEN** son nom et sa version actuelle sont affichés.

#### Scenario: Logiciel mis à jour par APT
- **WHEN** la phase Debian modifie un logiciel APT DIU activé
- **THEN** le bilan du moteur présente les versions observées avant et après.
