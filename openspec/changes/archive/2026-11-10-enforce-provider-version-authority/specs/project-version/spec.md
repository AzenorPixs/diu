## MODIFIED Requirements

### Requirement: Commits et traitements groupés
Les commits et CICD SHALL utiliser le tag v<VERSION> lorsque PROJECT_VERSION est déclarée. Leur nom automatique SHALL utiliser VERSION et une description explicite SHALL rester utilisable. La version SHALL être relue pour chaque projet sans fuite entre projets.

#### Scenario: Collision
- **WHEN** un nouveau commit versionné est nécessaire et le tag existe déjà
- **THEN** la commande n'effectue aucun nouveau commit sous cette version et ne remplace pas le tag
- **AND THEN** elle informe que la version est déjà attribuée

#### Scenario: Arbre inchangé
- **WHEN** aucune modification n'est à enregistrer et que le tag de la version demandée est absent
- **THEN** aucun commit vide n'est créé et le tag peut être créé sur HEAD
- **AND THEN** un push direct ou CI/CD applique la règle d’autorité des versions avant toute modification distante

#### Scenario: Tag déjà présent sur HEAD
- **WHEN** le tag de la version demandée désigne déjà HEAD
- **THEN** le traitement l'indique sans recréer ni déplacer le tag


## ADDED Requirements

### Requirement: Autorité de la version sur les fournisseurs
Avant un push individuel Forgejo, GitLab ou GitHub ou un push CI/CD, DIU SHALL comparer le tag demandé aux tags distants et refuser toute publication si un tag distant est supérieur ou non comparable. Une version stable SHALL primer sur un horodatage. Si les tags distants sont égaux ou inférieurs, la branche et le tag demandés SHALL désigner le commit local sélectionné avec protection par SHA attendu. Les autres tags SHALL être conservés.

#### Scenario: Version distante supérieure
- **WHEN** un tag distant est supérieur au tag demandé
- **THEN** aucun push de branche ou de tag n'est effectué sur ce fournisseur

#### Scenario: Version distante égale ou inférieure
- **WHEN** tous les tags distants sont égaux ou inférieurs au tag demandé
- **THEN** la branche distante et le tag demandé sont alignés sur le commit sélectionné, même si leur historique diffère

#### Scenario: Version stable et horodatage
- **WHEN** un tag stable est comparé à un tag horodaté
- **THEN** la version stable est supérieure

#### Scenario: Tag non comparable
- **WHEN** un tag distant ou demandé ne peut être comparé aux formats stables et horodatés reconnus
- **THEN** la publication est refusée avec un diagnostic

#### Scenario: Modification concurrente
- **WHEN** la branche ou le tag ciblé change après sa lecture
- **THEN** le lease refuse son écrasement et l'erreur est signalée

#### Scenario: Fournisseur d'un push direct
- **WHEN** un fournisseur est indiqué dans la commande directe
- **THEN** seul ce fournisseur est publié
