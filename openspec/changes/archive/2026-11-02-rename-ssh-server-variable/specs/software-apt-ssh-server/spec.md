## ADDED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_SSH_SERVER

Le DIU SHALL déclarer `SOFTWARES_APT_SSH_SERVER` dans
`modules/diu/variables/softwares/software_apt_ssh_server.sh` avec `STATIC`,
`ENABLE`, scope `softwares` et défaut `0`. Le chargeur existant SHALL
découvrir cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_SSH_SERVER` est absente au chargement
- **THEN** le DIU SHALL persister
  `export SOFTWARES_APT_SSH_SERVER=0` dans `/root/diu/config/softwares.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateurs OpenSSH renommés

Les consommateurs SHALL utiliser `SOFTWARES_APT_SSH_SERVER` à la place de
`SSH`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1` SHALL
conserver l’installation APT de `openssh-server` et la préparation existante
des fichiers authorized_keys à partir de `KEY_SSH_ADMIN` et `KEY_SSH_ACME`.

#### Scenario: Serveur SSH désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** les blocs d’installation et de configuration SSH SHALL être ignorés
  sans erreur de variable non définie

#### Scenario: Serveur SSH activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL conserver les deux comportements OpenSSH existants
