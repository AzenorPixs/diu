## MODIFIED Requirements

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
  `LOG_ROTATE` ou `FSTAB_CONFIG1` à `FSTAB_CONFIG6`
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

## ADDED Requirements

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
