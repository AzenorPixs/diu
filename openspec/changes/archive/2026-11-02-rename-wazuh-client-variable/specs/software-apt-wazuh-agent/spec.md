## ADDED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_WAZUH_AGENT

Le DIU SHALL déclarer `SOFTWARES_APT_WAZUH_AGENT` dans
`modules/diu/variables/softwares/software_apt_wazuh_agent.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_WAZUH_AGENT` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_WAZUH_AGENT=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur Wazuh agent renommé

Le point d’entrée SHALL utiliser `SOFTWARES_APT_WAZUH_AGENT` à la place de
`WAZUH_CLIENT`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver le téléchargement et l’installation Debian du paquet agent,
ainsi que son activation. `WAZUH_CLIENT_VERSION` SHALL continuer à sélectionner
la version téléchargée.

#### Scenario: Agent désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le paquet agent ne SHALL pas être installé sans erreur de variable
  non définie

#### Scenario: Agent activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer et démarrer l’agent à la version configurée
