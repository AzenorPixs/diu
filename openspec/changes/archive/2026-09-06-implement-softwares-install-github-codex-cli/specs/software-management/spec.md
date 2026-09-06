# software-management Specification

## Purpose

Définir l’installation, la désinstallation et la mise à jour de Codex CLI par
le moteur GitHub du DIU.

## ADDED Requirements

### Requirement: Variables Codex CLI

DIU SHALL déclarer `SOFTWARES_APT_CODEX_CLI` avec une valeur initiale `0` et
`SOFTWARES_APT_CODEX_CLI_HOME` avec une valeur initiale `~/.codex`.
Lors de l’initialisation, DIU SHALL positionner la première variable à `1`
lorsqu’un binaire `codex` exécutable est présent, et à `0` sinon. La valeur
persistée du répertoire HOME SHALL rester cohérente avec la valeur configurée.

#### Scenario: Codex absent

- **WHEN** aucun binaire Codex CLI exécutable n’est disponible
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`

#### Scenario: Codex présent

- **WHEN** un binaire Codex CLI exécutable est disponible
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `1`

### Requirement: Installation GitHub de Codex CLI

`rid softwares install github codex-cli` SHALL installer Codex CLI depuis une
GitHub Release du dépôt `openai/codex`. La cible SHALL être exclusivement
Linux x86_64 avec l’artefact `codex-package-x86_64-unknown-linux-musl.tar.gz`.
L’opération SHALL vérifier le digest SHA-256 avant toute installation et SHALL
échouer sans présenter l’installation comme réussie si la vérification échoue.

#### Scenario: Installation valide

- **WHEN** une release GitHub compatible est disponible et son archive est
  vérifiée
- **THEN** DIU installe Codex CLI et ses ressources nécessaires
- **AND** `SOFTWARES_APT_CODEX_CLI` vaut `1`

#### Scenario: Plateforme non supportée

- **WHEN** l’installation n’est pas exécutée sur Linux x86_64
- **THEN** DIU retourne une erreur explicite sans téléchargement ni mutation

### Requirement: Désinstallation sans suppression du profil

`rid softwares remove github codex-cli` SHALL supprimer les binaires, liens et
releases installées par DIU, mais SHALL préserver le répertoire et les données
du profil défini par `SOFTWARES_APT_CODEX_CLI_HOME`.

#### Scenario: Désinstallation

- **WHEN** Codex CLI est installé par DIU
- **THEN** ses binaires et artefacts d’installation sont supprimés
- **AND** le profil Codex n’est pas supprimé
- **AND** `SOFTWARES_APT_CODEX_CLI` vaut `0`

### Requirement: Mise à jour ciblée depuis GitHub

`rid softwares update github codex-cli` SHALL comparer la version locale de
Codex CLI avec la dernière release GitHub. Elle SHALL télécharger et installer
la release uniquement si elle est supérieure. Elle SHALL définir `CODEX_HOME`
à partir de `SOFTWARES_APT_CODEX_CLI_HOME` lors de l’exécution de Codex CLI.

#### Scenario: Nouvelle release

- **WHEN** GitHub fournit une version supérieure à la version locale
- **THEN** DIU installe la nouvelle version après vérification SHA-256

#### Scenario: Version à jour

- **WHEN** la version locale est égale ou supérieure à la release GitHub
- **THEN** DIU n’effectue aucun téléchargement ni remplacement

### Requirement: Mise à jour globale GitHub

`rid softwares update github` SHALL traiter Codex CLI uniquement lorsque sa
variable d’état indique qu’il est installé. `rid softwares update` et
`rid update` SHALL inclure cette opération une seule fois.

#### Scenario: Codex absent

- **WHEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`
- **THEN** la mise à jour globale n’installe pas Codex CLI

#### Scenario: Codex installé

- **WHEN** `SOFTWARES_APT_CODEX_CLI` vaut `1`
- **THEN** la mise à jour globale compare puis met à jour Codex CLI si nécessaire
