# system-debian-apt Specification

## Purpose

Gérer les dépôts Debian officiels et les dépôts tiers du DIU depuis le module
system, avec le format deb822 à partir de Trixie et le format historique pour
les versions antérieures, tout en préservant les configurations existantes.

## Requirements

### Requirement: Variables de configuration

Le DIU SHALL déclarer les cinq variables APT Debian statiques, activées dans
le scope system, avec les valeurs par défaut demandées.

#### Scenario: Valeurs initiales

- **WHEN** une variable est absente
- **THEN** le générateur l'exporte avec sa valeur par défaut et la persiste
  dans `system.env`.

### Requirement: Configuration Debian par version

Le moteur SHALL écrire le format deb822 pour Trixie et les versions ultérieures
et le format historique pour Bookworm et les versions antérieures.

#### Scenario: Debian Trixie

- **WHEN** la release courante est Trixie ou plus récente
- **THEN** `debian.sources` contient release et security, avec les options
  variables, sans modifier les fichiers tiers.

#### Scenario: Debian Bookworm ou antérieure

- **WHEN** la release courante est Bookworm ou antérieure
- **THEN** `/etc/apt/sources.list` contient les dépôts Debian officiels et
  l'ancien `debian.sources` géré par le DIU est supprimé.

### Requirement: Mise à jour du sous-module APT

Le sous-module `rid system update apt` SHALL régénérer la configuration des
dépôts Debian officiels avant d'actualiser les index et d'exécuter la
transaction unique `apt-get dist-upgrade -y`. Cette régénération SHALL prendre
en compte `SYSTEM_APT_DEBIAN_UPDATES`, `SYSTEM_APT_DEBIAN_BACKPORT`,
`SYSTEM_APT_DEBIAN_CONTRIB`, `SYSTEM_APT_DEBIAN_NONFRFEE` et
`SYSTEM_APT_DEBIAN_SOURCES`, tout en préservant les dépôts tiers.

#### Scenario: Variables activées

- **WHEN** les variables contrib, non-free et backports valent `1`
- **THEN** les composants et suites correspondants sont présents avant la
  mise à jour globale appelée par `ridu`

#### Scenario: Variables désactivées

- **WHEN** une variable de dépôt vaut `0`
- **THEN** l'élément correspondant est absent de la configuration Debian
  régénérée

#### Scenario: Mise à jour officielle

- **WHEN** `diu system update apt debian` est exécuté
- **THEN** seuls les paquets des dépôts Debian officiels sont traités et les
  cibles sont affichées paquet par paquet

#### Scenario: Mise à jour APT globale

- **WHEN** `diu system update apt` est exécuté
- **THEN** APT actualise ses index puis exécute une seule transaction
  `dist-upgrade -y`

### Requirement: Isolation de Flatpak du sous-module APT

Le sous-module APT de `system` SHALL ne pas appliquer `SYSTEM_FLATPAK` et
SHALL ne jamais appeler `flatpak update`. Seule la commande explicite
`rid system update flatpak` SHALL pouvoir mettre à jour le paquet Debian
`flatpak`.

#### Scenario: Mise à jour APT

- **WHEN** `rid system update apt` est exécuté
- **THEN** aucune mise à jour ciblée de Flatpak n'est invoquée
- **AND** `flatpak update` n'est pas exécuté

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

Les dépôts tiers hors CrowdSec SHALL conserver leurs dix variables
`SYSTEM_APT_*` dans le scope system. Le dépôt CrowdSec SHALL utiliser
`SOFTWARES_APT_CROWDSEC` dans le scope logiciels. Sa valeur absente SHALL être
déduite des sources APT existantes et s'activer si l'agent ou le bouncer est
activé; une valeur déjà configurée SHALL rester prioritaire. Les migrations
historiques de `SYSTEM_APT_CROWDSEC` et `CROWDSEC_BOUNCER` SHALL préserver leur
valeur dans `softwares.env`.

#### Scenario: Dépôt CrowdSec activé

- **WHEN** le dépôt CrowdSec existe déjà ou l'agent/le bouncer est activé
- **AND** `SOFTWARES_APT_CROWDSEC` n'est pas configurée
- **THEN** le DIU active le dépôt APT CrowdSec

#### Scenario: Activation historique sans source présente

- **WHEN** un dépôt historique non-CrowdSec est activé par ses variables et
  que sa variable `SYSTEM_APT_*` est absente
- **AND** aucune source APT correspondante n'est détectée
- **THEN** son activation ou sa branche est initialisée et persistée

#### Scenario: Valeur persistée prioritaire

- **WHEN** une variable `SYSTEM_APT_*` est déjà initialisée, notamment à `0`
- **THEN** la détection et les variables historiques ne la remplacent pas

#### Scenario: MongoDB historique

- **WHEN** une source MongoDB `4.4` est détectée ou la version historique
  `4.4` est activée
- **THEN** `SYSTEM_APT_MONGODB` est initialisé à `4` si cette variable est absente
- **AND** le moteur utilise la clé et la suite MongoDB `4.4`

#### Scenario: Installation MongoDB sans branche explicite

- **WHEN** `rid system install apt mongodb` est exécuté
- **THEN** une branche configurée entre `4` et `8` est conservée
- **AND** la branche `8` est choisie si aucune branche valide n'est configurée
- **AND** les commandes `mongodb-4` à `mongodb-8` sélectionnent la branche explicite

#### Scenario: Wazuh activé et désactivé

- **WHEN** `SYSTEM_APT_WAZUH` vaut `1`, `4` ou `0`
- **THEN** le moteur reçoit respectivement `1`, `1` ou `0`
- **AND** la valeur configurée reste inchangée

#### Scenario: Valeur Wazuh invalide

- **WHEN** `SYSTEM_APT_WAZUH` possède une autre valeur
- **THEN** la configuration retourne un code non nul et un diagnostic explicite

#### Scenario: Initialisation et compatibilité des configurations de dépôts tiers

- **WHEN** DIU initialise ou applique la configuration d'un dépôt tiers
- **THEN** les dix variables APT tierces hors CrowdSec restent déclarées dans
  le scope `system`, déduites des sources existantes et persistées dans
  `system.env`
- **AND** les valeurs déjà configurées gardent la priorité

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

system_apt_repository_engine SHALL réutiliser les trousseaux disponibles selon les règles ci-dessous, installer une clé seulement lorsque nécessaire et propager les échecs en conservant TLS.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

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

#### Scenario: Réutilisation et installation contrôlée des trousseaux

- **WHEN** le moteur traite la clé d’un dépôt tiers activé
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

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

### Requirement: Repli du dépôt APT LemonLDAP depuis le réglage logiciel

`SYSTEM_APT_LEMONLDAP` SHALL rester le réglage système explicite du dépôt APT.
Si aucune source LemonLDAP n’est détectée et si `SYSTEM_APT_LEMONLDAP` n’est
pas déjà configurée, sa valeur initiale SHALL être activée lorsque
`SOFTWARES_APT_LEMONLDAP=1`.

#### Scenario: Installation logicielle active sans dépôt configuré

- **WHEN** aucune source LemonLDAP APT n’est détectée
- **AND** `SOFTWARES_APT_LEMONLDAP` vaut `1`
- **THEN** le DIU SHALL persister `SYSTEM_APT_LEMONLDAP=1` dans `system.env`

#### Scenario: Réglage système explicite prioritaire

- **WHEN** `SYSTEM_APT_LEMONLDAP` est déjà configurée
- **THEN** sa valeur SHALL rester prioritaire sur `SOFTWARES_APT_LEMONLDAP`

### Requirement: Repli du dépôt MongoDB depuis le réglage logiciel

`SYSTEM_APT_MONGODB` SHALL rester le réglage système explicite du dépôt APT.
Si aucune source MongoDB n’est détectée et si `SYSTEM_APT_MONGODB` n’est pas
déjà configurée, sa valeur initiale SHALL être déterminée par
`SOFTWARES_APT_MONGODB` et `MONGODB_VERSION`. Lorsque le logiciel est actif, la
version déclarée SHALL sélectionner la branche du dépôt comme auparavant.

#### Scenario: Installation logicielle active sans dépôt configuré

- **WHEN** aucune source MongoDB APT n’est détectée
- **AND** `SOFTWARES_APT_MONGODB` vaut `1`
- **AND** `MONGODB_VERSION` contient une version prise en charge
- **THEN** le DIU SHALL persister la branche correspondante dans
  `SYSTEM_APT_MONGODB`

#### Scenario: Réglage système explicite prioritaire

- **WHEN** `SYSTEM_APT_MONGODB` est déjà configurée
- **THEN** sa valeur SHALL rester prioritaire sur les réglages logiciels
