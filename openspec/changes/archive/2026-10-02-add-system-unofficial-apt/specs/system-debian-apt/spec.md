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

### Requirement: Configuration et compatibilité des dépôts tiers

Le DIU SHALL déclarer les onze variables statiques `SYSTEM_APT_CROWDSEC`,
`SYSTEM_APT_DOCKER`, `SYSTEM_APT_LEMONLDAP`, `SYSTEM_APT_MONGODB`,
`SYSTEM_APT_NODEJS`, `SYSTEM_APT_NVIDIA`, `SYSTEM_APT_PROXMOX`,
`SYSTEM_APT_VSCODE`, `SYSTEM_APT_WAZUH`, `SYSTEM_APT_WEBMIN` et
`SYSTEM_APT_CGPT` dans le scope `system`. Leur valeur absente SHALL être
déduite des sources APT existantes, puis persistée dans `system.env`.
Une valeur déjà initialisée MUST NOT être remplacée par la détection ou les
variables historiques.

En l'absence d'une source détectée et d'une valeur initialisée, le DIU SHALL
préserver l'activation historique de CrowdSec (`CROWDSEC_BOUNCER=1`), de
LemonLDAP (`LEMONLDAP=1`), de MongoDB (`MONGODB=1` avec une version reconnue)
et de Wazuh (`WAZUH_SERVER=1` et `WAZUH_SERVER_UPGRADE=1`). Les autres valeurs
absentes SHALL rester désactivées lorsqu'aucune source n'est détectée.

Pour MongoDB, les branches `4` à `8` SHALL rester disponibles ; la branche
historique `4` SHALL utiliser la clé et la suite `4.4`. Les sources historiques
`4.4` SHALL être détectées comme branche `4`. La suite Debian de MongoDB SHALL
rester `bullseye` pour Bullseye et `bookworm` pour Bookworm et les versions
ultérieures, conformément au choix existant pour ces dernières.
L'installation `apt mongodb` SHALL conserver une branche déjà configurée de
`4` à `8`, ou choisir `8` si aucune branche valide n'est configurée.
Les formes `mongodb-4` à `mongodb-8` SHALL sélectionner la branche demandée.

Pour Wazuh, `0` SHALL désactiver le dépôt et `4` SHALL activer la branche 4.
La valeur historique `1` SHALL rester acceptée comme activation de cette
branche. Les valeurs `1` et `4` SHALL être transmises au moteur commun sous
forme d'activation `1`, sans modifier la valeur persistée. Toute autre valeur
SHALL provoquer un diagnostic et un retour non nul.

#### Scenario: Activation historique sans source présente

- **WHEN** un dépôt historique est activé par ses variables et sa variable `SYSTEM_APT_*` est absente
- **AND** aucune source APT correspondante n'est détectée
- **THEN** son activation ou sa branche est initialisée et persistée

#### Scenario: Valeur persistée prioritaire

- **WHEN** une variable `SYSTEM_APT_*` est déjà initialisée, notamment à `0`
- **THEN** la détection et les variables historiques ne la remplacent pas

#### Scenario: MongoDB historique

- **WHEN** une source MongoDB `4.4` est détectée ou la version historique `4.4` est activée
- **THEN** `SYSTEM_APT_MONGODB` est initialisé à `4` si cette variable est absente
- **AND** le moteur utilise une clé et une suite MongoDB `4.4` avec la suite Debian prévue

#### Scenario: Installation MongoDB sans branche explicite

- **WHEN** `rid system install apt mongodb` est exécuté
- **THEN** une branche configurée entre `4` et `8` est conservée
- **AND** si aucune branche valide n'est configurée, la branche `8` est choisie
- **AND** une commande `mongodb-4` à `mongodb-8` sélectionne la branche explicite

#### Scenario: Wazuh activé et désactivé

- **WHEN** `SYSTEM_APT_WAZUH` vaut `1`, `4` ou `0`
- **THEN** le moteur reçoit respectivement `1`, `1` ou `0` pour le dépôt Wazuh de branche 4
- **AND** la valeur configurée reste inchangée

#### Scenario: Valeur Wazuh invalide

- **WHEN** `SYSTEM_APT_WAZUH` possède une autre valeur
- **THEN** la configuration des dépôts retourne un code non nul et un diagnostic explicite

### Requirement: Configuration unique dans le monolithe

Le bloc APT du monolithe SHALL déléguer les dépôts tiers déjà gérés à
`system_apt_debian_configure`. Il MUST NOT redéclarer CrowdSec, LemonLDAP,
MongoDB ou Wazuh dans ses branches Bookworm et Bullseye. Les traitements
indépendants de ces recettes et les installations de logiciels SHALL être
préservés. La recette FusionDirectory SHALL rester distincte et conserver
son contrôle par `DIU_APT_REPOSITORY_FD`.

#### Scenario: Exécution historique Bookworm ou Bullseye

- **WHEN** le bloc APT du monolithe est exécuté sur Bookworm ou Bullseye
- **THEN** les dépôts tiers gérés ne sont déclarés que par le moteur commun
- **AND** les traitements système et la recette FusionDirectory restent disponibles

### Requirement: Réutilisation des trousseaux APT disponibles

Pour un dépôt tiers activé, `system_apt_repository_engine` SHALL réutiliser
`/usr/share/keyrings/<name>-archive-keyring.gpg` lorsqu'il s'agit d'un fichier
lisible et non vide. Il MUST NOT télécharger ni reconvertir cette clé dans ce
cas et SHALL préserver son contenu tout en régénérant les sources APT.
Si le trousseau est absent, vide ou illisible, le moteur SHALL conserver
l'installation par téléchargement et conversion, sauf pour CrowdSec lorsqu'un
trousseau historique lisible et non vide est disponible sous le nom
`crowdsec-crowdsec-archive-keyring.gpg` dans le même répertoire : il SHALL
alors copier ce trousseau vers le nom géré sans téléchargement.
Un échec de téléchargement
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

#### Scenario: Trousseau CrowdSec historique disponible

- **WHEN** le trousseau CrowdSec géré est absent, vide ou illisible
- **AND** `crowdsec-crowdsec-archive-keyring.gpg` est un fichier lisible et non vide dans le même répertoire
- **THEN** le moteur SHALL copier ce trousseau vers le nom géré sans téléchargement
- **AND** le contenu du trousseau historique est préservé

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
