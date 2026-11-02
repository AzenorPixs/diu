## ADDED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_OMADA

Le DIU SHALL déclarer `SOFTWARES_APT_OMADA` dans
`modules/diu/variables/softwares/software_apt_omada.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_OMADA` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_OMADA=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs Omada renommés

Le point d’entrée SHALL utiliser `SOFTWARES_APT_OMADA` à la place de `OMADA`
pour l’installation et les règles firewall. Une valeur absente SHALL être
traitée comme `0`. Une valeur `1` SHALL conserver le téléchargement et
l’installation conditionnels du paquet sélectionné par `OMADA_VERSION`.

#### Scenario: Omada désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** l’installation et les règles firewall Omada SHALL être ignorées sans
  erreur de variable non définie

#### Scenario: Omada activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer le paquet de la version configurée et garder
  les règles firewall Omada existantes
