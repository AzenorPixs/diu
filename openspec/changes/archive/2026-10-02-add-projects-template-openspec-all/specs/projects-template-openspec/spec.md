## MODIFIED Requirements

### Requirement: Commande OpenSpec ciblée

DIU SHALL exposer `rid projects template openspec <ID PROJECT>` et
`projects_template_openspec` avec exactement un identifiant de projet. Le
sélecteur openspec après template SHALL être prioritaire sur le routage
DevOps. L'ancienne syntaxe SHALL être rejetée lorsqu'elle ne correspond pas
déjà à une commande valide avec sélecteur openspec ou devops. Le chemin SHALL
utiliser DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas. La fonction
SHALL refuser les identifiants vides, chemins, points et caractères de contrôle,
un utilisateur DevOps absent ou invalide, un projet absent ou symbolique, et
une cible openspec symbolique ou non répertoire. La fonction individuelle
SHALL NOT lire project.env. La CLI SHALL réserver all au traitement groupé ;
la fonction individuelle SHALL pouvoir traiter directement le projet all.

#### Scenario: Nouvelle syntaxe

- **WHEN** l'utilisateur exécute rid projects template openspec application
- **THEN** projects_template_openspec reçoit exactement application

#### Scenario: Ancienne syntaxe

- **WHEN** l'utilisateur exécute rid projects template application openspec
- **THEN** la commande rend un code non nul et présente la nouvelle syntaxe sans exécuter OpenSpec

#### Scenario: Projet absent ou paramètres invalides

- **WHEN** un prérequis n'est pas satisfait ou la CLI contient un argument supplémentaire
- **THEN** la commande rend un code non nul avec diagnostic sans appeler su

#### Scenario: Projet nommé all

- **WHEN** la boucle groupée sélectionne un dossier nommé all
- **THEN** la fonction individuelle traite ce projet une seule fois sans relancer le traitement groupé

#### Scenario: Projet nommé devops

- **WHEN** la commande vise openspec devops
- **THEN** OpenSpec traite uniquement le projet devops, sans lancer la génération DevOps

#### Scenario: DevOps pour un projet nommé openspec

- **WHEN** la commande vise devops openspec
- **THEN** seule la génération DevOps du projet openspec est appelée

## ADDED Requirements

### Requirement: Sélection OpenSpec de tous les projets configurés

DIU SHALL exposer `rid projects template openspec all` et
projects_template_openspec_all. La sélection SHALL réutiliser celle de
DevOps all : dossiers directs, cachés compris, avec project.env ordinaire
et affectations littérales non vides PROJECT_ID, PROJECT_NAME, PROJECT_TYPE,
PROJECT_DOCKERED et PROJECT_DEBIAN_PACKAGE. PROJECT_ID SHALL correspondre au
nom du dossier ; 0 et No SHALL être acceptés comme renseignés. Les dossiers
et project.env symboliques, identifiants invalides et configurations absentes,
illisibles, incomplètes ou discordantes SHALL être signalés puis ignorés. La sélection SHALL NOT
exécuter project.env, hériter de valeurs du shell ou afficher les valeurs.

#### Scenario: Projets éligibles

- **WHEN** des projets ordinaires, cachés ou nommés template et all remplissent les cinq critères
- **THEN** chacun est sélectionné une fois, sans parcourir leurs sous-dossiers

#### Scenario: Configuration invalide ou chemin symbolique

- **WHEN** une configuration est absente, vide, discordante, non littérale ou symbolique, ou le dossier est symbolique
- **THEN** le projet est ignoré sans exécuter sa configuration ni appeler OpenSpec

### Requirement: Exécution groupée OpenSpec et bilan

La fonction groupée SHALL valider ses arguments, le compte ENV_DEVOPS_USER,
les droits d'exécution root ou du compte DevOps, la racine des projets et
le Python système avant traitement. Elle SHALL appeler directement la
fonction OpenSpec individuelle pour chaque projet sélectionné et poursuivre
après un échec individuel. Elle SHALL afficher les nombres sélectionnés,
réussis, ignorés et échoués et rendre un code non nul si une opération échoue.
Sans projet éligible, elle SHALL afficher ce fait et un bilan puis rendre un
succès. Les trois commandes individuelles, leur compte su et leur appel
avant DevOps lors de create SHALL être conservés.

#### Scenario: Initialisation et actualisation mélangées

- **WHEN** les projets sélectionnés comprennent des dossiers avec et sans OpenSpec
- **THEN** chacun utilise sa branche individuelle init ou update sous ENV_DEVOPS_USER

#### Scenario: Échec puis réussite

- **WHEN** un projet échoue puis un autre réussit
- **THEN** les deux sont traités et le bilan compte l'échec et la réussite
- **AND THEN** le code final est non nul et les fichiers existants sont conservés

#### Scenario: Aucun projet éligible

- **WHEN** aucun projet ne remplit les critères
- **THEN** aucun appel su n'est effectué, un bilan est affiché et la commande réussit

#### Scenario: Prérequis invalide

- **WHEN** la racine, le compte, les droits, Python ou les arguments sont invalides
- **THEN** un diagnostic et un code non nul sont rendus avant traitement
