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
une cible openspec symbolique ou non répertoire. Elle SHALL NOT lire project.env.
L'identifiant all SHALL désigner uniquement le projet all.

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

- **WHEN** la commande vise openspec all
- **THEN** seul le projet all est traité

#### Scenario: Projet nommé devops

- **WHEN** la commande vise openspec devops
- **THEN** OpenSpec traite uniquement le projet devops, sans lancer la génération DevOps

#### Scenario: DevOps pour un projet nommé openspec

- **WHEN** la commande vise devops openspec
- **THEN** seule la génération DevOps du projet openspec est appelée
