# devops-home-openspec Specification

## Purpose
Définir l'initialisation ou l'actualisation des commandes OpenSpec dans le
domicile ENV_DEVOPS_USER à la fin du bloc OPENSPEC=1, avec le profil custom
et l'intégration OpenCode conditionnelle, indépendamment des templates de projets.

## Requirements

### Requirement: Préparation OpenSpec du domicile DevOps

À la fin du bloc OPENSPEC=1, après la vérification du binaire, DIU SHALL
exécuter un shell de connexion via `su - "$ENV_DEVOPS_USER" -c` dans
`/home/${ENV_DEVOPS_USER}`. Le shell SHALL disposer des chemins
`/home/${ENV_DEVOPS_USER}/node/current/bin` et
`/home/${ENV_DEVOPS_USER}/.local/npm/bin` dans PATH. DIU SHALL préserver
l'installation et la configuration existantes ainsi que les templates de
projets. Le bloc désactivé SHALL NOT lancer cette préparation.

#### Scenario: Bloc désactivé

- **WHEN** OPENSPEC=0
- **THEN** aucune préparation OpenSpec du domicile n'est exécutée

#### Scenario: Compte et répertoire

- **WHEN** le binaire OpenSpec a été vérifié dans le bloc actif
- **THEN** la préparation s'exécute via su sous ENV_DEVOPS_USER dans son domicile explicite avec les chemins Node et npm DevOps

### Requirement: Sélection init ou update

Le shell enfant SHALL exécuter `openspec update` lorsque le dossier openspec
existe dans le domicile, indépendamment de OPENCODE. En son absence, il SHALL
exécuter `openspec init --tools opencode --profile custom` si OPENCODE=1 et
`openspec init --profile custom` si OPENCODE=0. Une valeur OPENCODE absente ou
différente SHALL empêcher l'initialisation avec diagnostic et code non nul.
Les chemins et valeurs interpolés SHALL être transmis littéralement au shell
enfant, sans interprétation de leur contenu comme commande.

#### Scenario: Initialisation avec OpenCode

- **WHEN** le dossier openspec est absent et OPENCODE=1
- **THEN** openspec init --tools opencode --profile custom est exécuté une fois

#### Scenario: Initialisation sans OpenCode

- **WHEN** le dossier openspec est absent et OPENCODE=0
- **THEN** openspec init --profile custom est exécuté une fois

#### Scenario: Actualisation

- **WHEN** le dossier openspec existe
- **THEN** openspec update est exécuté une fois, indépendamment de OPENCODE

#### Scenario: Choix OpenCode invalide

- **WHEN** le dossier openspec est absent et OPENCODE est absent ou différent de 0 et 1
- **THEN** aucun appel OpenSpec n'est exécuté et un diagnostic avec code non nul est produit

### Requirement: Gestion des erreurs de préparation

Un échec de changement de répertoire, de su ou d'OpenSpec SHALL arrêter DIU
avec un diagnostic et un code non nul avant la suite du traitement. DIU SHALL
annoncer le succès uniquement après une préparation réussie. DIU SHALL NOT
supprimer les écritures partielles produites par OpenSpec.

#### Scenario: Répertoire inaccessible

- **WHEN** le shell enfant ne peut pas rejoindre le domicile
- **THEN** aucun appel OpenSpec n'est exécuté et DIU s'arrête avec diagnostic

#### Scenario: Échec de su ou OpenSpec

- **WHEN** su ou la commande OpenSpec échoue
- **THEN** DIU s'arrête avec diagnostic sans annoncer la réussite de la préparation ni supprimer les écritures partielles
