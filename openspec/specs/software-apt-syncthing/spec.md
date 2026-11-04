# software-apt-syncthing Specification

## Purpose
Définir la gestion par le DIU de l’installation APT de Syncthing, pilotée par
`SOFTWARES_APT_SYNCTHING`. La spécification couvre la déclaration de ce réglage
et le comportement d’installation ; le DIU ne crée ni ne modifie `.stignore`.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_SYNCTHING

Le DIU SHALL déclarer `SOFTWARES_APT_SYNCTHING` dans
`modules/diu/variables/softwares/software_apt_syncthing.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_SYNCTHING` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_SYNCTHING=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs Syncthing renommés

Les consommateurs SHALL utiliser `SOFTWARES_APT_SYNCTHING` à la place de
`SYNCTHING`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver l’installation APT de Syncthing sans créer ni modifier
`.stignore`.

#### Scenario: Syncthing désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** aucun paquet Syncthing ni fichier `.stignore` spécifique ne SHALL
  être créé sans erreur de variable non définie
- **AND** un fichier `.stignore` déjà présent SHALL rester inchangé

#### Scenario: Syncthing activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer Syncthing
- **AND** SHALL laisser tout fichier `.stignore` existant inchangé
