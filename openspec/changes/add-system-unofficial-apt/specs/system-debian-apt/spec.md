## ADDED Requirements

### Requirement: Moteur commun des dépôts tiers

Le module `system` SHALL fournir `system_apt_repository_engine` pour
configurer les dépôts tiers gérés. À partir d'un état, d'un nom, d'une clé GPG,
d'un type, de suites, d'architectures et d'URI validés, il SHALL installer le
trousseau dans `/usr/share/keyrings` et écrire un unique fichier géré. Il SHALL
utiliser le format deb822 (`.sources`) pour Debian Trixie et les versions
ultérieures, et le format historique (`.list`) pour Bookworm et les versions
antérieures.

#### Scenario: Dépôt tiers activé

- **WHEN** un dépôt tiers géré est activé
- **THEN** son trousseau et son unique fichier de configuration correspondant
  au format de la version Debian sont présents
- **AND** le format alternatif géré par le DIU est absent

#### Scenario: Dépôt tiers désactivé

- **WHEN** un dépôt tiers géré est désactivé
- **THEN** ses fichiers `.sources`, `.list` et son trousseau gérés sont supprimés
- **AND** les fichiers tiers non gérés par le DIU sont préservés

### Requirement: Dépôts NVIDIA sans composant APT

Pour Debian Trixie et les versions ultérieures, les fichiers deb822 des dépôts
NVIDIA SHALL omettre la ligne `Components`.

#### Scenario: Configuration des dépôts NVIDIA

- **WHEN** `SYSTEM_APT_NVIDIA=1` et que la configuration APT est régénérée
- **THEN** `nvidia.sources` et `nvidia-container-toolkit.sources` contiennent
  leurs champs `Types`, `URIs`, `Suites`, `Architectures` et `Signed-By`
- **AND** aucun de ces deux fichiers ne contient de ligne `Components`
- **AND** les autres dépôts APT conservent leur comportement actuel

### Requirement: Dépôts OpenAI

Le système SHALL déclarer `SYSTEM_APT_CGPT` avec `config=STATIC`, `scope=system`,
`state=ENABLE` et une valeur par défaut `0`. Si elle n'est pas initialisée,
sa valeur SHALL être déduite des déclarations APT existantes contenant
OpenAI, ChatGPT ou Codex, puis persistée.

#### Scenario: Installation

- **WHEN** `rid system install apt cgpt` est exécuté
- **THEN** la source APT ChatGPT Desktop est déclarée statiquement par le DIU
- **AND** la clé GPG embarquée dans le DIU est installée localement sans téléchargement
- **AND** aucune source APT supplémentaire n'est créée pour l'installateur Codex
- **AND** `SYSTEM_APT_CGPT` vaut `1`

#### Scenario: Suppression

- **WHEN** `rid system remove apt cgpt` est exécuté
- **THEN** les fichiers APT OpenAI gérés sont supprimés
- **AND** `SYSTEM_APT_CGPT` vaut `0`
