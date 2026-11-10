## ADDED Requirements

### Requirement: Identifiants des pushes directs en rejeu
Avant de créer le clone d'un push direct GitHub ou GitLab rejouant un tag existant, DIU SHALL préparer les identifiants dans le projet source. Les identifiants existants SHALL être réutilisés sans nouvelle saisie et la préparation SHALL échouer explicitement en cas d'erreur. Les secrets SHALL rester hors des diagnostics.

#### Scenario: Identifiants déjà présents
- **WHEN** un tag existant est rejoué et que les identifiants du fournisseur sont présents et valides dans le projet source
- **THEN** le rejeu utilise ces identifiants sans demander leur saisie

#### Scenario: Identifiants absents
- **WHEN** les identifiants nécessaires à un push direct GitHub ou GitLab sont absents
- **THEN** leur initialisation éventuelle a lieu dans le projet source avant le clonage et reste disponible après nettoyage du clone

#### Scenario: Échec de préparation
- **WHEN** la préparation des identifiants échoue
- **THEN** aucun clone de rejeu ni transport Git n'est lancé

#### Scenario: Autres parcours
- **WHEN** le push direct concerne Forgejo ou que CI/CD exécute son parcours habituel
- **THEN** ces parcours conservent leur comportement existant
