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

### Requirement: Réutilisation des trousseaux APT disponibles

Pour un dépôt tiers activé, `system_apt_repository_engine` SHALL réutiliser
`/usr/share/keyrings/<name>-archive-keyring.gpg` lorsqu'il s'agit d'un fichier
lisible et non vide. Il MUST NOT télécharger ni reconvertir cette clé dans ce
cas et SHALL préserver son contenu tout en régénérant les sources APT.
Si le trousseau est absent, vide ou illisible, le moteur SHALL conserver
l'installation par téléchargement et conversion. Un échec de téléchargement
ou de conversion SHALL produire un diagnostic et un retour non nul, sans
désactiver la vérification TLS. Ces règles SHALL s'appliquer aux deux formats
APT sans modifier le comportement de désactivation du dépôt.

#### Scenario: Trousseau déjà disponible avec réseau défaillant

- **WHEN** un dépôt activé possède un trousseau géré lisible et non vide
- **AND** le téléchargement de sa clé échouerait, notamment avec une erreur TLS
- **THEN** ni `curl` ni `gpg --dearmor` n'est appelé
- **AND** le contenu du trousseau est préservé et les sources APT sont générées

#### Scenario: Trousseau absent ou vide

- **WHEN** le trousseau géré d'un dépôt activé est absent ou vide
- **THEN** la clé est téléchargée et convertie avant la génération des sources
- **AND** une nouvelle exécution réutilise le trousseau ainsi installé

#### Scenario: Trousseau illisible

- **WHEN** le trousseau géré d'un dépôt activé n'est pas lisible
- **THEN** il n'est pas considéré disponible et l'installation est tentée

#### Scenario: Échec d'installation d'une clé nécessaire

- **WHEN** aucun trousseau disponible ne permet la réutilisation
- **AND** le téléchargement ou la conversion échoue
- **THEN** le moteur signale l'échec et retourne un code non nul
- **AND** la configuration APT du dépôt n'est pas réécrite

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
