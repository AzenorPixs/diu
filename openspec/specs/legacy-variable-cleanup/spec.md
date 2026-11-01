# legacy-variable-cleanup Specification

## Purpose
Retirer de manière idempotente les déclarations historiques de distribution, d'environnement, de DisplayLink et de fuseau horaire avant le chargement de la configuration. Utiliser SYSTEM_DEBIAN_RELEASE, SYSTEM_DEBIAN_ENVIRONNEMENT, SYSTEM_DRIVERS_DISPLAY_LINK et SYSTEM_TIME_ZONE dans les consommateurs du DIU.

## Requirements

### Requirement: Nettoyage de la configuration historique

Le DIU SHALL appeler `config_cleanup` avant de sourcer
`/root/diu/variables.sh`. La fonction SHALL supprimer les affectations simples
des variables historiques listées dans le scénario sans exposer leurs valeurs
ni modifier les autres lignes. Elle SHALL migrer les valeurs littérales
acceptées vers les nouveaux noms système si ceux-ci ne sont pas déclarés. Elle
SHALL accepter un chemin optionnel, par défaut `/root/diu/variables.sh`.

#### Scenario: Anciennes déclarations présentes

- **WHEN** le fichier contient une ou plusieurs affectations de
  `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE`, `PROXY_CA`,
  `PROXY`, `DRIVERS_NVIDIA`, `FSTAB`, `FILES2RAM`, `GRUB_CONFIG`, `IPv6`,
  `LOG_ROTATE`, `JOURNALD_MAX_USE`, `JOURNALD_KEEP_FREE`, `NO_SLEEP`,
  `CROWDSEC_AGENT` ou
  `FSTAB_CONFIG1` à `FSTAB_CONFIG6`
- **THEN** les affectations historiques SHALL être supprimées avant le
  chargement
- **AND** leurs dernières valeurs simples littérales SHALL être persistées
  sous leurs nouveaux noms si aucune déclaration correspondante n’existe
  dans `system.env`
- **AND** les nouveaux noms, noms voisins, commentaires et autres variables
  SHALL être conservés

#### Scenario: Absence et répétition

- **WHEN** le fichier ou une déclaration à supprimer est absent, ou le
  nettoyage est répété
- **THEN** le nettoyage SHALL réussir sans réécrire le fichier

#### Scenario: Erreur de lecture ou écriture

- **WHEN** une lecture ou suppression échoue, ou une affectation historique
  n’est pas un littéral simple accepté
- **THEN** le nettoyage SHALL retourner un code non nul avec un diagnostic
  sur stderr sans contenu de configuration
- **AND** le démarrage SHALL NOT poursuivre le chargement de la configuration

### Requirement: Consommateurs migrés

Les consommateurs du projet SHALL utiliser les nouveaux noms système
spécifiés pour les variables migrées. Les mentions de l’ancien nom SHALL être
limitées à la migration, sa documentation et ses tests. Les modalités de
transfert des valeurs historiques SHALL suivre l’exigence de nettoyage et les
spécifications propres à chaque variable.

#### Scenario: Sélection de distribution

- **WHEN** une opération choisit un comportement selon la distribution Debian
- **THEN** elle utilise SYSTEM_DEBIAN_RELEASE selon la déclaration dynamique existante

#### Scenario: Sélection de l’environnement

- **WHEN** une opération choisit un comportement selon le type d’environnement
- **THEN** elle utilise SYSTEM_DEBIAN_ENVIRONNEMENT selon sa déclaration dynamique
- **AND** les branches existantes LXC, PHYSICAL, PROXMOX et VM sont conservées

#### Scenario: Préférence DisplayLink migrée
- **WHEN** une commande explicite DisplayLink valide son installation ou sa suppression
- **THEN** elle met à jour SYSTEM_DRIVERS_DISPLAY_LINK sans transférer la valeur historique
- **AND** le parcours historique ne consomme plus cette préférence pour installer automatiquement le pilote

#### Scenario: Fuseau horaire migré
- **WHEN** le parcours historique configure le fuseau horaire
- **THEN** il utilise SYSTEM_TIME_ZONE sans transférer TIME_ZONE

#### Scenario: Configuration GRUB migrée
- **WHEN** le point d’entrée consulte le contrôle de configuration GRUB
- **THEN** il utilise `SYSTEM_GRUB_CONFIG` à la place de `GRUB_CONFIG`
- **AND** une valeur historique littérale `0` ou `1` est migrée selon
  l’exigence « Migration de GRUB_CONFIG »

### Requirement: Migration IPv6

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `IPv6` vers `SYSTEM_IPV6` si
cette dernière n’est pas déjà déclarée dans `system.env`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur IPv6 littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `IPv6`
- **THEN** la dernière valeur SHALL être persistée exactement sous
  `SYSTEM_IPV6` si aucune déclaration nouvelle n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: Nouvelle valeur IPv6 déjà configurée

- **WHEN** `system.env` déclare déjà `SYSTEM_IPV6`
- **THEN** sa valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur IPv6 ambiguë

- **WHEN** une affectation `IPv6` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `system.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateur IPv6 migré

Le point d’entrée SHALL utiliser `SYSTEM_IPV6` à la place de `IPv6` pour
activer ou désactiver IPv6.

#### Scenario: Utilisation du nouveau nom

- **WHEN** le point d’entrée applique le réglage IPv6
- **THEN** il utilise `SYSTEM_IPV6` et conserve le comportement sysctl existant

### Requirement: Migration de LOG_ROTATE

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `LOG_ROTATE` vers
`SYSTEM_LOG_ROTATE` si cette dernière n’est pas déjà déclarée dans
`system.env`. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur logrotate littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `LOG_ROTATE`
- **THEN** la dernière valeur SHALL être persistée exactement sous
  `SYSTEM_LOG_ROTATE` si aucune déclaration nouvelle n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: Nouvelle valeur logrotate déjà configurée

- **WHEN** `system.env` déclare déjà `SYSTEM_LOG_ROTATE`
- **THEN** sa valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur logrotate ambiguë

- **WHEN** une affectation `LOG_ROTATE` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `system.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateur logrotate migré

Le point d’entrée SHALL utiliser `SYSTEM_LOG_ROTATE` à la place de
`LOG_ROTATE` pour activer le bloc logrotate.

#### Scenario: Utilisation du nouveau nom

- **WHEN** le point d’entrée décide d’écrire `/etc/logrotate.conf`
- **THEN** il consulte `SYSTEM_LOG_ROTATE` et conserve le comportement existant

### Requirement: Migration de JOURNALD_MAX_USE

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `JOURNALD_MAX_USE` vers
`SYSTEM_JOURNALD_MAX_USE` si ce nouveau nom n’est pas déjà déclaré dans
`system.env`. Les littéraux acceptés SHALL être un entier suivi
facultativement d’une unité journald `K`, `M`, `G`, `T`, `P` ou `E`, avec
guillemets simples ou doubles facultatifs. Une forme exigeant une
interprétation shell SHALL bloquer le nettoyage sans mutation.

#### Scenario: Ancienne limite littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations littérales
  simples de `JOURNALD_MAX_USE`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SYSTEM_JOURNALD_MAX_USE` si aucune valeur nouvelle n’existe
- **AND** les affectations historiques SHALL être supprimées

#### Scenario: Nouvelle limite déjà configurée

- **WHEN** `system.env` déclare déjà `SYSTEM_JOURNALD_MAX_USE`
- **THEN** sa valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne limite ambiguë

- **WHEN** une affectation `JOURNALD_MAX_USE` nécessite une interprétation
  shell ou ne respecte pas le format littéral accepté
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `system.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateurs journald migrés

Le point d’entrée SHALL consulter `SYSTEM_JOURNALD_MAX_USE` pour les limites
`SystemMaxUse` et `RuntimeMaxUse`.

#### Scenario: Utilisation de la nouvelle limite

- **WHEN** le DIU configure journald
- **THEN** les deux directives utilisent `SYSTEM_JOURNALD_MAX_USE`

### Requirement: Migration de JOURNALD_KEEP_FREE

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `JOURNALD_KEEP_FREE` vers
`SYSTEM_JOURNALD_KEEP_FREE` si ce nouveau nom n’est pas déjà déclaré dans
`system.env`. Les littéraux acceptés SHALL être un entier suivi
facultativement d’une unité journald `K`, `M`, `G`, `T`, `P` ou `E`, avec
guillemets simples ou doubles facultatifs. Une forme exigeant une
interprétation shell SHALL bloquer le nettoyage sans mutation.

#### Scenario: Ancienne réserve littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations littérales
  simples de `JOURNALD_KEEP_FREE`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SYSTEM_JOURNALD_KEEP_FREE` si la nouvelle valeur n’existe pas
- **AND** les affectations historiques SHALL être supprimées

#### Scenario: Nouvelle réserve déjà configurée

- **WHEN** `system.env` déclare déjà `SYSTEM_JOURNALD_KEEP_FREE`
- **THEN** sa valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne réserve ambiguë

- **WHEN** une affectation `JOURNALD_KEEP_FREE` nécessite une interprétation
  shell ou ne respecte pas le format littéral accepté
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `system.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateurs journald migrés pour l’espace libre

Le point d’entrée SHALL consulter `SYSTEM_JOURNALD_KEEP_FREE` pour les limites
`SystemKeepFree` et `RuntimeKeepFree`.

#### Scenario: Utilisation de la nouvelle réserve

- **WHEN** le DIU configure journald
- **THEN** les deux directives utilisent `SYSTEM_JOURNALD_KEEP_FREE`

### Requirement: Migration de NO_SLEEP

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `NO_SLEEP` vers `SYSTEM_NO_SLEEP`
si ce nouveau nom n’est pas déjà déclaré dans `system.env`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur NO_SLEEP littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `NO_SLEEP`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SYSTEM_NO_SLEEP` si aucune valeur nouvelle n’existe
- **AND** les affectations historiques SHALL être supprimées

#### Scenario: Nouvelle valeur NO_SLEEP déjà configurée

- **WHEN** `system.env` déclare déjà `SYSTEM_NO_SLEEP`
- **THEN** sa valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur NO_SLEEP ambiguë

- **WHEN** une affectation `NO_SLEEP` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `system.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateur de veille migré

Le point d’entrée SHALL utiliser `SYSTEM_NO_SLEEP` à la place de `NO_SLEEP`
pour contrôler la création de `nosleep.conf`.

#### Scenario: Utilisation du nouveau nom

- **WHEN** le DIU configure la veille systemd
- **THEN** il consulte `SYSTEM_NO_SLEEP` et conserve le comportement existant

### Requirement: Migration de APACHE2 vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `APACHE2` vers
`SOFTWARES_APT_APACHE2` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Une affectation nécessitant une interprétation shell SHALL bloquer le
nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur APACHE2 littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `APACHE2`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_APACHE2` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: Valeur SOFTWARES_APT_APACHE2 déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_APACHE2`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur APACHE2 ambiguë

- **WHEN** une affectation `APACHE2` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateur Apache2 migré

Le point d’entrée SHALL utiliser `SOFTWARES_APT_APACHE2` à la place de
`APACHE2` pour activer le bloc d’installation Apache2.

#### Scenario: Utilisation du nouveau nom

- **WHEN** le DIU décide d’installer Apache2
- **THEN** il consulte `SOFTWARES_APT_APACHE2` et conserve le comportement APT
  existant

### Requirement: Migration de CROWDSEC_AGENT

`config_cleanup` SHALL migrer les valeurs simples de `CROWDSEC_AGENT`,
`SYSTEM_CROWDSEC_AGENT`, `CROWDSEC_BOUNCER`, `SYSTEM_APT_CROWDSEC` et la clé
`CROWDSEC_BOUNCER_API_KEY` vers leurs nouveaux noms dans `softwares.env`.
Les valeurs agent/bouncer/dépôt `0` ou `1` sont préservées exactement. La clé
API est transférée opaque, sans exécution ni affichage, et le fichier reçoit
le mode `0600`. Une valeur sous son nouveau nom reste prioritaire; toute
affectation ancienne ambiguë bloque sans modifier les fichiers.

#### Scenario: Ancienne valeur CROWDSEC_AGENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `CROWDSEC_AGENT`
- **THEN** la dernière valeur littérale `0` ou `1` est transférée exactement
  vers `SOFTWARES_APT_CROWDSEC_AGENT` si aucune valeur nouvelle n'existe
- **AND** les anciennes affectations sont supprimées

#### Scenario: Nouvelle valeur CROWDSEC_AGENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_CROWDSEC_AGENT`
- **THEN** sa valeur reste prioritaire et n'est pas réécrite

#### Scenario: Ancienne valeur CROWDSEC_AGENT ambiguë

- **WHEN** une affectation CrowdSec nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage échoue sans supprimer l'affectation ni modifier les
  fichiers de configuration
- **AND** il n'affiche pas la valeur

#### Scenario: Clé API historique littérale

- **WHEN** `variables.sh` contient une clé API littérale simple
- **THEN** elle est transférée sans affichage vers
  `SOFTWARES_CROWDSEC_BOUNCER_API_KEY`
- **AND** `softwares.env` reçoit le mode `0600`
- **AND** l'affectation historique est supprimée

#### Scenario: Clé API ambiguë

- **WHEN** l'affectation historique de la clé API n'est pas un littéral simple
- **THEN** le nettoyage échoue sans évaluer ni afficher son contenu
- **AND** les fichiers restent inchangés

### Requirement: Consommateur CrowdSec migré

Le point d’entrée SHALL utiliser `SYSTEM_CROWDSEC_AGENT` à la place de
`CROWDSEC_AGENT` pour activer l’installation de l’agent.

#### Scenario: Utilisation du nouveau nom

- **WHEN** le DIU décide d’installer l’agent CrowdSec
- **THEN** il consulte `SYSTEM_CROWDSEC_AGENT` et conserve le comportement
  d’installation existant

### Requirement: Migration de GRUB_CONFIG

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `GRUB_CONFIG` vers
`SYSTEM_GRUB_CONFIG` si cette dernière n’est pas déjà déclarée dans
`system.env`. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Valeur historique simple

- **WHEN** `variables.sh` contient une ou plusieurs affectations littérales
  simples de `GRUB_CONFIG`
- **THEN** la dernière valeur SHALL être persistée dans `system.env` si
  `SYSTEM_GRUB_CONFIG` n’y est pas déjà déclarée
- **AND** les affectations `GRUB_CONFIG` SHALL être supprimées
- **AND** une dernière valeur `1` SHALL rester `1`

#### Scenario: Nouvelle valeur déjà configurée

- **WHEN** `system.env` déclare déjà `SYSTEM_GRUB_CONFIG`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite par
  la valeur historique

#### Scenario: Valeur ambiguë

- **WHEN** une affectation `GRUB_CONFIG` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `system.env`
- **AND** SHALL NOT afficher son contenu
