# Spec Delta

## MODIFIED Requirements

### Requirement: Parcours universel sans mise à jour générale des logiciels
`diu update` sans argument SHALL appeler `diu_update`, `system_update`, `environments_update`, `ia_update`, `projects_update` et `softwares_update` dans cet ordre. La dernière étape SHALL converger les logiciels sans mettre à jour leurs versions.

#### Scenario: Ordre du parcours
- **WHEN** `diu update` est invoqué sans argument
- **THEN** les six modules sont appelés dans l'ordre défini et `softwares_update` est exécuté en dernier

#### Scenario: Échec
- **WHEN** une étape contrôlée échoue
- **THEN** le résultat est non nul et conserve la priorité de l'erreur projects puis de l'erreur DIU sur les autres erreurs

#### Scenario: Succès
- **WHEN** toutes les étapes contrôlées réussissent
- **THEN** le résultat du parcours est nul
