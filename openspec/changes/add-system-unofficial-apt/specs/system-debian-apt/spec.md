## ADDED Requirements

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
