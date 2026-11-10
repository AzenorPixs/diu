# Spec Delta

## MODIFIED Requirements

### Requirement: Variables ChatGPT du moteur APT
DIU SHALL déclarer l'état désiré `SOFTWARE_APT_CHATGPT`, préserver une valeur existante et ne détecter le paquet que pour une première initialisation sans valeur migrable. DIU SHALL NOT utiliser la variable historique de personnalisation `SOFTWARES_APT_CHATGPT_HOME`.

#### Scenario: ChatGPT absent au démarrage
- **WHEN** aucune valeur désirée n'existe et que le paquet ChatGPT est absent
- **THEN** DIU initialise `SOFTWARE_APT_CHATGPT` à `0`

#### Scenario: ChatGPT présent au démarrage
- **WHEN** aucune valeur désirée n'existe et que le paquet ChatGPT est présent
- **THEN** DIU initialise `SOFTWARE_APT_CHATGPT` à `1`

#### Scenario: Persistance cohérente
- **WHEN** l'état désiré ChatGPT est initialisé
- **THEN** `softwares.env` contient `SOFTWARE_APT_CHATGPT`
- **AND** DIU ne persiste pas la variable historique de personnalisation

### Requirement: Installation GitHub de Codex CLI
`diu softwares install github codex-cli` SHALL installer Codex CLI depuis une GitHub Release du dépôt `openai/codex`. La cible SHALL être exclusivement Linux x86_64 avec l'artefact `codex-package-x86_64-unknown-linux-musl.tar.gz`. L'opération SHALL vérifier le digest SHA-256 avant toute installation et SHALL échouer sans présenter l'installation comme réussie si la vérification échoue.

#### Scenario: Installation valide
- **WHEN** une release GitHub compatible est disponible et son archive est vérifiée
- **THEN** DIU installe Codex CLI et ses ressources nécessaires
- **AND** `SOFTWARE_GITHUB_CODEX_CLI` vaut `1`

#### Scenario: Plateforme non supportée
- **WHEN** l'installation n'est pas exécutée sur Linux x86_64
- **THEN** DIU retourne une erreur explicite sans téléchargement ni mutation

### Requirement: Désinstallation sans suppression du profil
`diu softwares remove github codex-cli` SHALL supprimer les binaires, liens et releases installées par DIU, mais SHALL préserver le répertoire et les données du profil utilisateur.

#### Scenario: Désinstallation
- **WHEN** Codex CLI est installé par DIU
- **THEN** ses binaires et artefacts d'installation sont supprimés
- **AND** le profil Codex n'est pas supprimé
- **AND** `SOFTWARE_GITHUB_CODEX_CLI` vaut `0`

### Requirement: Désactivation de la variable HOME Codex CLI
DIU SHALL NOT créer, utiliser ou persister `SOFTWARES_APT_CODEX_CLI_HOME`. L'installation SHALL exposer directement le binaire extrait par un lien symbolique et SHALL NOT générer de wrapper shell.

#### Scenario: Codex installé
- **WHEN** l'état réel de Codex CLI correspond à `SOFTWARE_GITHUB_CODEX_CLI=1`
- **THEN** la convergence ne change pas sa version

### Requirement: Mise à jour globale APT
`diu softwares update apt` SHALL converger les logiciels APT gérés vers leur état désiré, sans lancer de mise à jour globale APT. `diu update` SHALL appeler cette convergence via `softwares_update` en fin de parcours.

#### Scenario: Mise à jour globale
- **WHEN** l'utilisateur invoque `diu softwares update apt`
- **THEN** DIU converge les logiciels APT gérés sans mettre à jour leurs versions

#### Scenario: Mise à jour globale du DIU
- **WHEN** l'utilisateur invoque `diu update`
- **THEN** DIU appelle la convergence générale du module logiciels en dernier

### Requirement: Organisation des modules
Le chargement SHALL respecter l'ordre `diu`, `system`, `softwares`, puis les autres modules. La configuration des dépôts et la mise à jour globale APT restent fournies par `system`.

#### Scenario: Ordre de chargement
- **WHEN** DIU démarre
- **THEN** le module `system` est chargé avant `softwares`
- **AND** les modules suivants sont chargés après `softwares`

### Requirement: Mise à jour sélective APT de ChatGPT
`diu softwares update apt chatgpt` SHALL converger ChatGPT vers son état désiré sans mise à jour de version. La commande générique historique `diu update apt chatgpt` conserve son contrat propre hors de cette convergence.

#### Scenario: Paquet absent
- **WHEN** ChatGPT est absent et son état désiré est 1
- **THEN** DIU demande son installation et vérifie son état

#### Scenario: ChatGPT installé
- **WHEN** ChatGPT est installé et son état désiré est 1
- **THEN** DIU indique que l'état réel est conforme sans mettre à jour le paquet

### Requirement: Mise à jour globale APT du module softwares
`diu softwares update apt` SHALL converger chaque logiciel APT géré, installé ou absent, vers son état désiré. La commande SHALL NOT effectuer de mise à jour des versions APT.

#### Scenario: Ordre des phases
- **WHEN** l'utilisateur invoque `diu softwares update apt`
- **THEN** DIU vérifie l'état désiré et réel de chaque logiciel APT géré puis corrige les écarts

#### Scenario: Logiciel absent
- **WHEN** un logiciel géré est absent et son état désiré vaut 1
- **THEN** DIU demande son installation et vérifie son état réel

### Requirement: Dispatch de la mise à jour du module softwares
`diu softwares update` SHALL lancer la convergence des moteurs activés dans l'ordre APT, Flatpak, GitHub. Les échecs SHALL être signalés et les moteurs suivants SHALL être traités.

#### Scenario: Mise à jour du module softwares
- **WHEN** l'utilisateur invoque `diu softwares update`
- **THEN** DIU converge les moteurs activés dans l'ordre APT, Flatpak, GitHub

### Requirement: Mise à jour du sous-module GitHub
`diu softwares update github` SHALL converger tous les logiciels GitHub gérés vers leur état désiré. La commande SHALL poursuivre les logiciels indépendants après un échec et retourner un résultat non nul en cas d'échec.

#### Scenario: Mise à jour globale
- **WHEN** la convergence globale GitHub est invoquée
- **THEN** DIU converge chaque logiciel GitHub géré

#### Scenario: Échec isolé
- **WHEN** la convergence d'un logiciel GitHub échoue
- **THEN** DIU signale l'échec après traitement des autres logiciels indépendants

### Requirement: Variables Codex CLI
DIU SHALL déclarer `SOFTWARE_GITHUB_CODEX_CLI` dans le scope `softwares` et conserver sa valeur persistée. En son absence initiale, DIU SHALL migrer l'ancienne valeur si elle existe ou l'initialiser depuis l'état réel du logiciel.

#### Scenario: Codex absent
- **WHEN** aucun état désiré n'existe et que Codex CLI est absent
- **THEN** DIU initialise l'état désiré à 0

#### Scenario: Codex présent
- **WHEN** aucun état désiré n'existe et que Codex CLI est présent
- **THEN** DIU initialise l'état désiré à 1

### Requirement: Mise à jour ciblée depuis GitHub
`diu softwares update github codex-cli` SHALL converger Codex CLI vers son état désiré sans mettre à jour sa version lorsqu'il est déjà présent.

#### Scenario: Nouvelle release
- **WHEN** Codex CLI est présent et son état désiré est 1, même si une release plus récente existe
- **THEN** la convergence ne remplace pas sa version

#### Scenario: Version à jour
- **WHEN** l'état réel de Codex CLI correspond à son état désiré
- **THEN** DIU ne télécharge ni ne remplace le logiciel

### Requirement: Mise à jour globale GitHub
`diu softwares update github` SHALL converger Codex CLI vers sa variable d'état désiré. `diu softwares update` SHALL inclure cette convergence une seule fois. `diu update` SHALL conserver la mise à jour de Codex CLI par la phase système lorsque applicable.

#### Scenario: Codex absent
- **WHEN** `SOFTWARE_GITHUB_CODEX_CLI` vaut `0` et Codex CLI est absent
- **THEN** la convergence n'installe pas Codex CLI

### Requirement: Cohérence persistée de l'état Codex CLI
Les commandes explicites install et remove de Codex CLI SHALL persister respectivement les états désirés 1 et 0. La convergence SHALL conserver cet état même en cas d'échec de l'opération.

#### Scenario: Désinstallation persistée
- **WHEN** `diu softwares remove github codex-cli` est demandé
- **THEN** l'état désiré 0 est persisté et la désinstallation est demandée

#### Scenario: Mise à jour après désinstallation
- **WHEN** `diu softwares update github codex-cli` est invoqué alors que l'état désiré et l'état réel valent 0
- **THEN** DIU signale la convergence sans téléchargement ni installation

### Requirement: Cohérence persistée de l'état ChatGPT
Les commandes explicites install et remove de ChatGPT SHALL persister respectivement les états désirés 1 et 0. La convergence SHALL conserver cet état même en cas d'échec de l'opération.

#### Scenario: Installation persistée
- **WHEN** `diu softwares install apt chatgpt` est demandé
- **THEN** l'état désiré 1 est persisté et l'installation est demandée

#### Scenario: Désinstallation persistée
- **WHEN** `diu softwares remove apt chatgpt` est demandé
- **THEN** l'état désiré 0 est persisté et la désinstallation est demandée
