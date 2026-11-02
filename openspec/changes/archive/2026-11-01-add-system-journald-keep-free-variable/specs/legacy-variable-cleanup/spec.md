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
  `LOG_ROTATE`, `JOURNALD_MAX_USE`, `JOURNALD_KEEP_FREE` ou
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

## ADDED Requirements

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
