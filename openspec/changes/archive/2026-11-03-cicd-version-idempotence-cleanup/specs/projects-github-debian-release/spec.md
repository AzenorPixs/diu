## MODIFIED Requirements

### Requirement: Protection des releases existantes
Une release existante SHALL être conservée sans remplacement d'asset ni suppression. Un asset attendu déjà présent SHALL être indiqué comme déjà publié. Un asset attendu absent MAY être ajouté à une release cohérente. Un tag absent MAY être créé sur HEAD après vérification des conditions, comme Forgejo.

#### Scenario: Release déjà présente
- **WHEN** une release et son asset attendu existent pour le tag de version cohérent
- **THEN** la commande informe que l'asset est déjà publié sans POST de release ou d'asset

#### Scenario: Release incomplète
- **WHEN** une release cohérente existe mais ne contient pas l'asset attendu
- **THEN** la commande peut ajouter cet asset sans remplacer les autres

#### Scenario: Tag absent
- **WHEN** le tag distant est absent et HEAD est synchronisé
- **THEN** le tag puis la release sont créés sur ce HEAD, sans écrasement concurrent
