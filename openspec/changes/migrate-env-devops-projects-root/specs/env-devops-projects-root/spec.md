## ADDED Requirements

### Requirement: Utilisateur DevOps statique

DIU SHALL déclarer `ENV_DEVOPS_USER` avec `STATIC`, `ENABLE`, scope
`environnements` et défaut `root`. Une valeur déjà définie SHALL être conservée.

#### Scenario: Utilisateur absent

- **WHEN** aucune valeur de `ENV_DEVOPS_USER` n'est définie
- **THEN** DIU initialise et persiste la valeur `root`

#### Scenario: Utilisateur déjà défini

- **WHEN** `ENV_DEVOPS_USER` est déjà définie
- **THEN** DIU conserve et exporte sa valeur existante

### Requirement: Racine statique des projets DevOps

DIU SHALL déclarer `ENV_DEVOPS_PROJECTS_ROOT` avec `STATIC`, `ENABLE` et le
scope `environnements`. Une valeur nouvelle déjà configurée SHALL rester
prioritaire. Sinon une valeur historique explicite de `DEVOPS_PROJECTS_ROOT`
SHALL être reprise exactement. En leur absence, DIU SHALL construire le chemin
`/home/${ENV_DEVOPS_USER}/datas` et le persister comme valeur littérale.

#### Scenario: Valeur historique présente

- **WHEN** la nouvelle variable est absente et l'ancienne valeur est littérale
- **THEN** la nouvelle variable reçoit exactement cette valeur

#### Scenario: Utilisateur indisponible après initialisation

- **WHEN** aucune valeur nouvelle ou historique n'existe et `ENV_DEVOPS_USER` reste indisponible après tentative d'initialisation
- **THEN** l'initialisation échoue avec un diagnostic explicite sans persister de chemin invalide

#### Scenario: Rechargement

- **WHEN** le chemin généré par la nouvelle déclaration est rechargé
- **THEN** il ne dépend pas d'une expansion shell de `ENV_DEVOPS_USER` dans le fichier persisté

### Requirement: Ordre de la racine des projets et de l'utilisateur DevOps

Quand une déclaration persistée de `ENV_DEVOPS_PROJECTS_ROOT` référence
`ENV_DEVOPS_USER`, DIU SHALL rendre disponible la déclaration littérale de
`ENV_DEVOPS_USER` avant de charger cette racine, indépendamment du tri du fichier.
Une déclaration ambiguë ou une dépendance absente SHALL produire un diagnostic
explicite avant l'initialisation de la racine.

#### Scenario: Valeur dépendante

- **WHEN** la racine précède l'utilisateur dans le fichier de configuration
- **THEN** l'utilisateur est disponible avant le calcul de la racine ou le chargement échoue explicitement

#### Scenario: Déclarations unitaires présentes

- **WHEN** les fichiers `env_devops_user.sh` et `env_devops_projects_root.sh` existent
- **THEN** le générateur charge le fichier utilisateur une seule fois avant le fichier de racine

#### Scenario: Déclaration unitaire utilisateur absente

- **WHEN** `env_devops_user.sh` est absent
- **THEN** une valeur utilisateur déjà chargée reste utilisable et son absence est signalée si elle est nécessaire

#### Scenario: Défaut nécessaire avant le fichier de scope

- **WHEN** une racine persistée dépend de `ENV_DEVOPS_USER` et qu'aucune valeur utilisateur n'est chargée ou déclarée dans ce fichier
- **THEN** la déclaration unitaire utilisateur est initialisée avant le chargement de la racine
