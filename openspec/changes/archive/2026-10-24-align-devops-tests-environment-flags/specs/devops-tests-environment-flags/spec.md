## MODIFIED Requirements

### Requirement: Initialisation indépendante et persistante

Chaque variable absente SHALL être persistée à `0` dans
`/root/diu/config/environnements.env`, puis exportée à `0`.
Chaque nouvelle ligne SHALL commencer par huit espaces ASCII avant
`export NOM=0`. La déclaration SHALL créer le répertoire de configuration si
nécessaire et SHALL conserver les autres lignes du fichier.

#### Scenario: Première initialisation

- **WHEN** les deux variables et le fichier de configuration sont absents
- **THEN** le fichier contient une déclaration `export NOM=0` précédée exactement de huit espaces pour chacune des deux variables
- **AND** les deux variables valent `0` dans l'environnement des processus enfants

#### Scenario: Configuration partielle

- **WHEN** une seule des deux variables est absente après chargement de la configuration
- **THEN** seule cette variable est initialisée et persistée à `0`, avec huit espaces avant `export`
- **AND** la valeur de l'autre variable et les lignes préexistantes sont conservées sans reformatage

### Requirement: Désactivation déclarative limitée

Une déclaration dont `state` vaut `DISABLE` SHALL retirer sa variable de
l'environnement et supprimer uniquement sa ligne `export NOM=` exacte du
fichier persistant, avec ou sans espaces ou tabulations initiaux.
Un échec de suppression SHALL produire un statut non nul et un diagnostic
stderr.

#### Scenario: Retrait d'une déclaration désactivée

- **WHEN** la déclaration d'une variable est désactivée
- **THEN** cette variable et sa ligne persistante sont retirées, que le retrait initial soit absent, composé d'espaces ou de tabulations
- **AND** l'autre variable et les noms voisins sont conservés
