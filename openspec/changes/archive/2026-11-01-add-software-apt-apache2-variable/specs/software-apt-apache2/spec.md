## ADDED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_APACHE2

Le DIU SHALL déclarer `SOFTWARES_APT_APACHE2` dans
`modules/diu/variables/softwares/software_apt_apache2.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_APACHE2` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_APACHE2=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter `SOFTWARES_APT_APACHE2=0` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `SOFTWARES_APT_APACHE2` est déjà définie à `0` ou `1`
- **THEN** le DIU SHALL préserver et exporter sa valeur sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `SOFTWARES_APT_APACHE2` est définie à une valeur autre que `0` ou
  `1`
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur Apache2 renommé

Le consommateur APT Apache2 du point d’entrée SHALL utiliser
`SOFTWARES_APT_APACHE2` à la place de `APACHE2`. Une valeur absente ou `0`
SHALL ignorer son bloc sans erreur de variable non définie. Une valeur `1`
SHALL conserver les installations APT existantes.

#### Scenario: Apache2 activé

- **WHEN** `SOFTWARES_APT_APACHE2` vaut `1`
- **THEN** le DIU SHALL conserver l’installation Apache2 existante pour la
  version Debian détectée

#### Scenario: Apache2 désactivé ou absent

- **WHEN** `SOFTWARES_APT_APACHE2` est absent ou vaut `0`
- **THEN** le bloc d’installation SHALL être ignoré sans erreur de variable
  non définie
