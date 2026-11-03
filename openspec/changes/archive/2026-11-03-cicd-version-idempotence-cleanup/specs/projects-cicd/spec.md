## ADDED Requirements

### Requirement: Version facultative du CI/CD
La commande `rid projects cicd <ID PROJECT> [VERSION]` SHALL accepter une version stable x.y.z, la valider et mettre à jour l'unique affectation PROJECT_VERSION de la configuration existante avant le flux. Une configuration absente ou ambiguë SHALL provoquer un diagnostic sans modification. La forme explicite historique avec message et tag SHALL rester utilisable.

#### Scenario: Version fournie
- **WHEN** une version x.y.z valide est fournie et la configuration est valide
- **THEN** PROJECT_VERSION est créée ou mise à jour avant l'exécution normale du flux

#### Scenario: Version inchangée
- **WHEN** PROJECT_VERSION contient déjà la version demandée
- **THEN** la commande informe que la version est déjà configurée sans réécrire le fichier

#### Scenario: Version invalide ou configuration ambiguë
- **WHEN** la version est invalide ou la configuration ambiguë
- **THEN** la commande échoue avant toute écriture et sans lancer le flux

### Requirement: Reprise idempotente du CI/CD
Le flux SHALL indiquer comme informations les étapes déjà satisfaites. Il SHALL NOT remplacer de tag ni publier le contenu d'un autre commit sous une version existante. Les erreurs réelles SHALL rester bloquantes.

#### Scenario: Version attribuée à un autre commit
- **WHEN** la version demandée désigne déjà un autre commit
- **THEN** le flux informe que cette version est déjà attribuée et ne publie pas le nouveau commit sous cette version

#### Scenario: Publication déjà présente
- **WHEN** le dépôt ou l'artefact cible est déjà publié pour la version cohérente
- **THEN** le bilan indique son état existant sans signaler une erreur
