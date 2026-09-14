## ADDED Requirements

### Requirement: commit local de tous les projets configurés

DIU MUST exposer `rid projects git commit all`. La commande MUST générer une seule
valeur locale au format `YYYY.MM.DD.HH.MM` comme message de commit et le tag
`v` suivi de cette même valeur. Elle MUST transmettre ces deux valeurs à
`git_commit()` pour chaque projet sélectionné.

#### Scenario: plusieurs projets configurés

- **WHEN** l'utilisateur exécute `rid projects git commit all`
- **THEN** DIU parcourt les sous-répertoires directs de
  `${DEVOPS_PROJECTS_ROOT}`
- **AND THEN** il appelle `git_commit()` une fois pour chaque projet
  sélectionné avec le même message et le même tag

### Requirement: sélection non interactive des projets

`git_commit_all()` MUST sélectionner uniquement un répertoire contenant un
fichier `project.env` dont `PROJECT_ID`, `PROJECT_NAME`, `GIT_USER_NAME` et
`GIT_USER_EMAIL` sont définis. `PROJECT_ID` MUST correspondre au nom du
répertoire. Un répertoire non conforme MUST être annoncé et ignoré ; DIU MUST
NOT appeler les assistants de mise à jour de configuration pour ce répertoire.

#### Scenario: configuration absente ou incomplète

- **WHEN** un sous-répertoire ne contient pas `project.env` ou contient une
  des variables requises absente ou incohérente
- **THEN** DIU l'ignore avec un diagnostic
- **AND THEN** aucun commit ni assistant de configuration n'est exécuté pour
  ce répertoire

### Requirement: poursuite après un échec de commit

`git_commit_all()` MUST poursuivre le parcours lorsque `git_commit()` échoue
pour un projet sélectionné. Après le parcours, elle MUST retourner un code non
nul si au moins un commit a échoué.

#### Scenario: échec isolé

- **WHEN** le commit d'un projet sélectionné échoue et qu'un autre projet est
  encore sélectionné
- **THEN** DIU tente le commit de l'autre projet
- **AND THEN** la commande retourne un code non nul après le parcours
