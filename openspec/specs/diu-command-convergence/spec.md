# diu-command-convergence Specification

## Purpose
Définir les noms publics DIU, les alias générés et les interfaces d’aide, en préservant le routage métier et les archives historiques.

## Requirements

### Requirement: Commandes publiques et alias DIU
DIU MUST employer `diu` comme commande de production et `diut` comme commande de développement dans son code, ses aides et ses diagnostics. Le générateur d’alias MUST définir `diu`, `diut`, `diuo`, `diuu` et `ndiu` avec les cibles et arguments des anciens raccourcis correspondants. Il MUST NOT générer les anciens alias DIU. Les raccourcis CI/CD conservés MUST appeler `diut`.

#### Scenario: Génération des raccourcis
- **WHEN** le bloc d’alias DIU est généré
- **THEN** les raccourcis de production, développement, ouverture, mise à jour et édition portent les noms DIU et conservent leurs cibles et arguments.

#### Scenario: Préservation d’un alias sans rapport
- **WHEN** les alias Docker sont générés
- **THEN** l’alias `drid` conserve sa commande `docker run --rm --entrypoint id`.

### Requirement: Interfaces et documentation d’aide
Les fonctions d’aide MUST utiliser le préfixe `diu_` et la bibliothèque MUST être nommée `lib/diu-help.sh`. Les appels et tests MUST employer ces interfaces. Les spécifications courantes et les deltas actifs concernés MUST employer les nouvelles commandes ; la capacité d’aide courante MUST être `diu-help`. Les archives historiques MUST être préservées.

#### Scenario: Aide avant configuration
- **WHEN** une aide valide est demandée au point d’entrée sans configuration de production
- **THEN** elle est affichée avec la commande `diu`, les mêmes sous-commandes et un code de retour nul.

#### Scenario: Diagnostic de commande incorrecte
- **WHEN** une syntaxe incorrecte est reçue
- **THEN** le code de retour et le traitement existants sont conservés et le diagnostic propose la commande `diu`.

#### Scenario: Périmètre local
- **WHEN** la convergence des sources est réalisée
- **THEN** les configurations d’alias et sessions shell installées ne sont pas modifiées et aucune CI/CD n’est déclenchée.
