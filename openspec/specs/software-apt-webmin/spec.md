# software-apt-webmin Specification

## Purpose
Définir la déclaration et les consommateurs du contrôle logiciel webmin.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_WEBMIN

Le DIU SHALL déclarer `SOFTWARES_APT_WEBMIN` dans
`modules/diu/variables/softwares/software_apt_webmin.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_WEBMIN` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_WEBMIN=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur Webmin renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_WEBMIN` à la place de `WEBMIN`.
Une valeur absente SHALL être traitée comme `0`. Une valeur `1` SHALL conserver
l’installation APT de Webmin; une valeur `0` SHALL conserver le parcours de
suppression existant. `SYSTEM_APT_WEBMIN` SHALL rester le réglage système du
dépôt APT.

#### Scenario: Webmin désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le parcours de purge conditionnel SHALL s’exécuter sans erreur de
  variable non définie

#### Scenario: Webmin activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer le paquet APT `webmin`
