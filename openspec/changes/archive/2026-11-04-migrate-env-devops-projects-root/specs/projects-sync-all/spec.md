## MODIFIED Requirements

### Requirement: Commande de synchronisation groupée

DIU MUST accepter `rid projects sync all` pour synchroniser chaque projet
valide présent directement sous `/home/${ENV_DEVOPS_USER}/datas`. Pour chaque
projet sélectionné, la synchronisation MUST appliquer le même comportement
observable que `rid projects sync <ID PROJECT>` et utiliser
`/home/${ENV_DEVOPS_USER}/datas/template` comme source de vérité.

#### Scenario: Synchronisation de plusieurs projets valides

- **WHEN** l'utilisateur exécute `rid projects sync all` et que plusieurs
  projets valides sont présents
- **THEN** DIU synchronise chacun de ces projets depuis le modèle local

### Requirement: Sélection des projets synchronisables

La commande groupée MUST considérer uniquement les sous-répertoires directs
de `/home/${ENV_DEVOPS_USER}/datas` qui possèdent un `project.env` valide. Une
configuration est valide lorsque `PROJECT_ID` correspond au nom du
répertoire et que `PROJECT_NAME` est défini et non vide. Les répertoires sans
configuration valide MUST être ignorés sans être modifiés. Le répertoire
`/home/${ENV_DEVOPS_USER}/datas/template` MUST être exclu du parcours, même s'il
contient un fichier `project.env`.

#### Scenario: Répertoire non configuré

- **WHEN** un sous-répertoire de données ne contient pas un `project.env`
  valide
- **THEN** DIU l'ignore sans le synchroniser ni le modifier

#### Scenario: Exclusion du modèle

- **WHEN** `rid projects sync all` est exécutée
- **THEN** DIU ne traite pas le répertoire `template` comme un projet à
  synchroniser

### Requirement: Absence de projet sélectionnable

Lorsque `/home/${ENV_DEVOPS_USER}/datas` ne contient aucun projet valide, la
commande groupée MUST terminer avec succès sans synchroniser de répertoire et
en indiquant qu'aucun projet n'a été sélectionné.

#### Scenario: Aucun projet valide

- **WHEN** l'utilisateur exécute `rid projects sync all` sans projet valide
- **THEN** DIU ne modifie aucun répertoire
- **AND THEN** DIU retourne un code nul avec un diagnostic explicite
