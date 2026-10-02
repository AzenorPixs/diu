# projects-template-openspec Specification

## Purpose
Définir l'initialisation et l'actualisation OpenSpec d'un projet ciblé sous
ENV_DEVOPS_USER, avec le profil custom et l'intégration OpenCode conditionnelle,
avant la génération DevOps lors de la création d'un projet.

## Requirements

### Requirement: Commande OpenSpec ciblée

DIU SHALL exposer `rid projects template <ID PROJECT> openspec` et
`projects_template_openspec` avec exactement un identifiant de projet. Le
chemin SHALL utiliser DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas.
La fonction SHALL refuser les identifiants vides, chemins, points et caractères
de contrôle, un utilisateur DevOps absent ou invalide, un projet absent ou
symbolique, et une cible openspec symbolique ou non répertoire. Elle SHALL NOT
lire project.env. L'identifiant all SHALL désigner uniquement le projet all.

#### Scenario: Projet absent ou paramètres invalides

- **WHEN** un prérequis n'est pas satisfait
- **THEN** la commande rend un code non nul avec diagnostic sans appeler su

#### Scenario: Projet nommé all

- **WHEN** la commande vise all openspec
- **THEN** seul le projet all est traité

### Requirement: Initialisation ou actualisation sous le compte DevOps

La fonction SHALL exécuter dans le répertoire du projet, via
`su - "$ENV_DEVOPS_USER" -c`, `openspec update` si le dossier openspec existe.
Sinon, elle SHALL exécuter `openspec init --tools opencode --profile custom`
si OPENCODE=1 et `openspec init --profile custom` si OPENCODE=0. Une valeur
OPENCODE absente ou différente SHALL empêcher l'initialisation avec diagnostic.
Les caractères spéciaux du chemin SHALL être transmis littéralement au shell
enfant. Un échec SHALL produire un diagnostic et un code non nul, sans succès.
La fonction SHALL NOT supprimer les écritures partielles d'OpenSpec.

#### Scenario: Initialisation avec OpenCode

- **WHEN** openspec est absent et OPENCODE=1
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --tools opencode --profile custom dans le projet

#### Scenario: Initialisation sans OpenCode

- **WHEN** openspec est absent et OPENCODE=0
- **THEN** le compte ENV_DEVOPS_USER exécute openspec init --profile custom dans le projet

#### Scenario: Actualisation indépendante du choix OpenCode

- **WHEN** le dossier openspec existe déjà, notamment après copie du modèle
- **THEN** le compte ENV_DEVOPS_USER exécute openspec update dans le projet

#### Scenario: Chemin contenant des caractères shell

- **WHEN** le chemin contient espaces, apostrophes, dollars ou backticks
- **THEN** le shell enfant rejoint exactement ce chemin sans interpréter son contenu comme une commande

#### Scenario: Échec de l'outil

- **WHEN** su ou OpenSpec échoue
- **THEN** l'opération signale un échec sans annoncer de succès ni supprimer le projet
