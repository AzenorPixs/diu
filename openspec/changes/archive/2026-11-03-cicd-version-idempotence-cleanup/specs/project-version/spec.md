## MODIFIED Requirements

### Requirement: Commits et traitements groupés
Les commits et CICD SHALL utiliser le tag v<VERSION> lorsque PROJECT_VERSION est déclarée. Leur nom automatique SHALL utiliser VERSION et une description explicite SHALL rester utilisable. La version SHALL être relue pour chaque projet sans fuite entre projets.

#### Scenario: Collision
- **WHEN** un nouveau commit versionné est nécessaire et le tag existe déjà
- **THEN** la commande n'effectue aucun nouveau commit sous cette version et ne remplace pas le tag
- **AND THEN** elle informe que la version est déjà attribuée

#### Scenario: Arbre inchangé
- **WHEN** aucune modification n'est à enregistrer et que le tag de la version demandée est absent
- **THEN** aucun commit vide n'est créé et le tag peut être créé sur HEAD si la vérification des dépôts configurés ne révèle aucune collision

#### Scenario: Tag déjà présent sur HEAD
- **WHEN** le tag de la version demandée désigne déjà HEAD
- **THEN** le traitement l'indique sans recréer ni déplacer le tag

## ADDED Requirements

### Requirement: Priorité des versions stables
Les sélecteurs de version DIU SHALL privilégier les versions stables x.y.z sur les versions horodatées. La comparaison native Debian SHALL rester inchangée et aucun epoch ne SHALL être ajouté.

#### Scenario: Versions stable et horodatée disponibles
- **WHEN** une version stable et une version horodatée sont candidates
- **THEN** DIU sélectionne la version stable
