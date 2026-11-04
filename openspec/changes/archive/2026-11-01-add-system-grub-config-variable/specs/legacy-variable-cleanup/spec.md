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
  `PROXY`, `DRIVERS_NVIDIA`, `FSTAB`, `FILES2RAM`, `GRUB_CONFIG` ou
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
