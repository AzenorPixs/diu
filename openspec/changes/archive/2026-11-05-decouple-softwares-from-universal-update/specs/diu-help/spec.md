## ADDED Requirements

### Requirement: Aide de la séparation des mises à jour
Les aides SHALL indiquer que `diu update` ne lance pas `diu softwares update` et SHALL présenter cette dernière commande comme disponible séparément.

#### Scenario: Aide de mise à jour
- **WHEN** l'utilisateur demande l'aide de `diu update` ou de `diu softwares update`
- **THEN** l'aide décrit la séparation et la commande directe sans exécuter de mise à jour
