## ADDED Requirements

### Requirement: État désiré d'OpenCode V2

DIU SHALL déclarer `SOFTWARE_GITHUB_OPENCODE` dans le scope `softwares`, préserver toute valeur valide persistée et, en l'absence de valeur, initialiser l'état depuis le seul binaire exécutable `/usr/local/bin/opencode`. DIU SHALL NOT détecter OpenCode via le `PATH` général ou `/home/devops/.opencode`.

#### Scenario: Première déclaration sans binaire système

- **WHEN** `SOFTWARE_GITHUB_OPENCODE` n'est pas persistée et `/usr/local/bin/opencode` est absent
- **THEN** DIU initialise `SOFTWARE_GITHUB_OPENCODE=0`

#### Scenario: Première déclaration avec binaire système

- **WHEN** `SOFTWARE_GITHUB_OPENCODE` n'est pas persistée et `/usr/local/bin/opencode` est exécutable
- **THEN** DIU initialise `SOFTWARE_GITHUB_OPENCODE=1`

#### Scenario: Ancienne installation utilisateur

- **WHEN** OpenCode existe uniquement sous `/home/devops/.opencode` ou un autre chemin du `PATH`
- **THEN** DIU initialise `SOFTWARE_GITHUB_OPENCODE=0`

### Requirement: Installation du CLI OpenCode V2 depuis GitHub

`diu softwares install github opencode` SHALL installer le CLI d'une release stable V2 du dépôt `anomalyco/opencode`, uniquement sur Linux x86_64. Avant toute mutation, DIU SHALL vérifier le digest `SHA256SUMS` de l'archive CLI attendue et exposer le binaire géré sous `/usr/local/lib/opencode` à `/usr/local/bin/opencode`.

#### Scenario: Dernière release globale V1

- **WHEN** GitHub `/releases/latest` référence une release V1 mais une release stable V2 compatible existe
- **THEN** DIU choisit la release V2 compatible et ignore la V1

#### Scenario: Artefact vérifié

- **WHEN** une release stable V2 compatible fournit les deux artefacts et le digest correspond
- **THEN** DIU installe le CLI et `SOFTWARE_GITHUB_OPENCODE` vaut `1`

#### Scenario: Release ou digest invalide

- **WHEN** aucune release V2 stable compatible, l'archive, son manifeste ou son digest ne peut être validé
- **THEN** DIU retourne un code non nul sans présenter l'installation comme réussie
- **AND** aucun nouveau binaire n'est exposé à `/usr/local/bin/opencode`

#### Scenario: Artefact desktop

- **WHEN** la release publie aussi `opencode-desktop-linux-amd64.deb`
- **THEN** DIU utilise l'archive CLI `opencode-linux-x64.tar.gz` et ne télécharge pas le paquet desktop

#### Scenario: Plateforme non supportée

- **WHEN** le système ou l'architecture n'est pas Linux x86_64
- **THEN** DIU retourne une erreur avant téléchargement ou mutation

### Requirement: Retrait et mise à jour d'OpenCode

`diu softwares remove github opencode` SHALL retirer le lien `/usr/local/bin/opencode` seulement s'il pointe vers l'installation gérée par DIU et supprimer uniquement le répertoire d'installation OpenCode géré. La recette SHALL préserver les configurations des utilisateurs et projets. Une mise à jour SHALL comparer la version système à la dernière release stable V2 sélectionnée et ne remplacer le binaire que si la release est plus récente.

#### Scenario: Installation DIU retirée

- **WHEN** le lien `/usr/local/bin/opencode` pointe vers la cible d'installation DIU
- **THEN** la recette retire le lien et le répertoire d'installation géré
- **AND** `SOFTWARE_GITHUB_OPENCODE` vaut `0`
- **AND** les configurations utilisateur et projet restent intactes

#### Scenario: Chemin système non possédé

- **WHEN** `/usr/local/bin/opencode` est un fichier ordinaire ou un lien vers une autre cible
- **THEN** DIU refuse le remplacement ou le retrait sans supprimer ce chemin

#### Scenario: Version système déjà à jour

- **WHEN** le binaire système est égal ou supérieur à la release stable V2 retenue
- **THEN** DIU conserve le binaire sans réinstallation

### Requirement: Présentation d'OpenCode dans l'inventaire logiciel

`diu infos softwares` SHALL présenter OpenCode sous le moteur GitHub et afficher l'état de `SOFTWARE_GITHUB_OPENCODE`, sans le classer sous APT.

#### Scenario: État OpenCode présent

- **WHEN** `SOFTWARE_GITHUB_OPENCODE` vaut `1`
- **THEN** l'inventaire affiche OpenCode comme actif sous GitHub

#### Scenario: État OpenCode absent

- **WHEN** `SOFTWARE_GITHUB_OPENCODE` vaut `0`
- **THEN** l'inventaire affiche OpenCode comme inactif sous GitHub
