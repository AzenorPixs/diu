## ADDED Requirements

### Requirement: agrégation des indisponibilités Forgejo

Le parcours groupé MUST poursuivre après une indisponibilité reconnue et
MUST la distinguer des pushes publiés. Il MUST retourner zéro si aucun échec
réel n'est rencontré, sans annoncer que tous les projets ont été publiés.
Un autre échec MUST conserver le résultat final non nul existant.

#### Scenario: projet indisponible et projet publié

- **WHEN** un projet est indisponible et un autre est publié
- **THEN** le parcours termine avec un état indiquant les indisponibilités et un code zéro

#### Scenario: erreur réelle dans le parcours

- **WHEN** un push échoue pour une cause non qualifiée comme indisponibilité
- **THEN** le parcours continue et termine avec un code non nul
