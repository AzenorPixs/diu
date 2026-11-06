## REMOVED Requirements

### Requirement: Mise à jour universelle
**Reason**: Le parcours général ne doit plus appeler softwares.
**Migration**: Utiliser `diu softwares update` séparément.

### Requirement: Intégration de la mise à jour générale des projets
**Reason**: Les codes de retour ne dépendent plus de softwares.
**Migration**: Aucune migration de configuration.

## ADDED Requirements

### Requirement: Parcours universel sans mise à jour générale des logiciels
`diu update` sans argument SHALL appeler `diu_update`, `system_update`, `environments_update`, `ia_update` et `projects_update` dans cet ordre, sans appeler `softwares_update`. Les étapes système conservent leurs propres opérations.

#### Scenario: Ordre du parcours
- **WHEN** `diu update` est invoqué sans argument
- **THEN** les cinq modules sont appelés dans l'ordre défini et `softwares_update` n'est pas appelé

#### Scenario: Échec
- **WHEN** projects ou DIU échoue
- **THEN** le résultat privilégie l'erreur projects puis l'erreur DIU

#### Scenario: Succès
- **WHEN** projects et DIU réussissent
- **THEN** le résultat du parcours est nul
