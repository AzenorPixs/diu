## MODIFIED Requirements

### Requirement: commit local de tous les projets configurés

DIU MUST exposer `diu projects git commit all`. La commande MUST générer une seule
valeur locale au format `YYYY.MM.DD.HH.MM` comme message de commit et le tag
`v` suivi de cette même valeur. Elle MUST transmettre ces deux valeurs à
`git_commit()` pour chaque projet sélectionné. Lorsqu'un projet sélectionné ne
possède pas de dépôt Git local, DIU MUST l'initialiser avant de tenter son
commit.

#### Scenario: plusieurs projets configurés

- **WHEN** l'utilisateur exécute `diu projects git commit all`
- **THEN** DIU parcourt les sous-répertoires directs de
  `${DEVOPS_PROJECTS_ROOT}`
- **AND THEN** il appelle `git_commit()` une fois pour chaque projet
  sélectionné avec le même message et le même tag

#### Scenario: dépôt local absent pour un projet sélectionné

- **WHEN** l'utilisateur exécute `diu projects git commit all`
- **AND WHEN** un projet sélectionné ne possède pas de dépôt Git local
- **THEN** DIU initialise le dépôt local de ce projet avant de tenter son
  commit
