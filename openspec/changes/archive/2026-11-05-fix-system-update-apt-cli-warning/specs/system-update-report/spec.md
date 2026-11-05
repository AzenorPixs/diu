# Bilan des mises à jour système

## MODIFIED Requirements

### Requirement: Bilan Debian
Le résultat MUST présenter la version Debian et les versions effectivement modifiées. Il MUST signaler les erreurs ou avertissements et leurs diagnostics sans déclarer le système à jour en cas d'échec. En absence de modification et d'erreur le bilan Debian MUST tenir sur une ligne. La ligne exacte `WARNING: apt does not have a stable CLI interface. Use with caution in scripts.` MUST NOT être considérée comme un avertissement de mise à jour ; tous les autres avertissements et codes d'erreur MUST rester pris en compte.

#### Scenario: Aucun paquet changé
- **WHEN** les opérations réussissent et aucune version installée ne change
- **THEN** le bilan Debian indique sa version et son état à jour sur une seule ligne.

#### Scenario: Message de compatibilité APT seul
- **WHEN** les opérations réussissent et que le seul avertissement est le message exact de compatibilité de l'interface APT
- **THEN** le bilan indique le succès sans afficher la sortie capturée.

#### Scenario: Échec ou avertissement
- **WHEN** une étape échoue ou un dépôt signale un avertissement, même si le message de compatibilité APT apparaît aussi
- **THEN** le bilan signale le problème et fournit les diagnostics sans déclarer le système à jour.
