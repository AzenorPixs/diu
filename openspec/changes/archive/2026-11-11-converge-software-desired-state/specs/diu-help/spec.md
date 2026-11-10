# Spec Delta

## MODIFIED Requirements

### Requirement: Aide de la séparation des mises à jour
Les aides SHALL indiquer que `diu update` lance la convergence `diu softwares update` en dernier et que la mise à jour des versions relève des commandes système.

#### Scenario: Aide de mise à jour
- **WHEN** l'utilisateur demande l'aide de `diu update` ou de `diu softwares update`
- **THEN** l'aide décrit la convergence et la commande directe sans exécuter de mise à jour
