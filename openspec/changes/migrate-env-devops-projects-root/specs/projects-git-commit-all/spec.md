## MODIFIED Requirements

### Requirement: commit local de tous les projets configurés

DIU MUST exposer `rid projects git commit all`. La commande MUST générer une seule
valeur locale au format `YYYY.MM.DD.HH.MM` comme message de commit et le tag
`v` suivi de cette même valeur. Elle MUST transmettre ces deux valeurs à
`git_commit()` pour chaque projet sélectionné.

#### Scenario: plusieurs projets configurés

- **WHEN** l'utilisateur exécute `rid projects git commit all`
- **THEN** DIU parcourt les sous-répertoires directs de
  `${ENV_DEVOPS_PROJECTS_ROOT}`
- **AND THEN** il appelle `git_commit()` une fois pour chaque projet
  sélectionné avec le même message et le même tag
