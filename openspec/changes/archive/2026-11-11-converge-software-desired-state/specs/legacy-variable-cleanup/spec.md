# Spec Delta

## MODIFIED Requirements

### Requirement: Migration de APACHE2 vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `APACHE2` vers
`SOFTWARE_APT_APACHE2` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Une affectation nécessitant une interprétation shell SHALL bloquer le
nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur APACHE2 littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `APACHE2`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_APACHE2` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: Valeur SOFTWARES_APT_APACHE2 déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_APACHE2`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur APACHE2 ambiguë

- **WHEN** une affectation `APACHE2` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateur Apache2 migré

Le point d’entrée SHALL utiliser `SOFTWARE_APT_APACHE2` à la place de
`APACHE2` pour activer le bloc d’installation Apache2.

#### Scenario: Utilisation du nouveau nom

- **WHEN** le DIU décide d’installer Apache2
- **THEN** il consulte `SOFTWARE_APT_APACHE2` et conserve le comportement APT
  existant

### Requirement: Migration de CROWDSEC_AGENT

`config_cleanup` SHALL migrer les valeurs simples de `CROWDSEC_AGENT`,
`SYSTEM_CROWDSEC_AGENT`, `CROWDSEC_BOUNCER`, `SYSTEM_APT_CROWDSEC` et la clé
`CROWDSEC_BOUNCER_API_KEY` vers leurs nouveaux noms dans `softwares.env`.
Les valeurs agent/bouncer/dépôt `0` ou `1` sont préservées exactement. 

#### Scenario: Ancienne valeur CROWDSEC_AGENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `CROWDSEC_AGENT`
- **THEN** la dernière valeur littérale `0` ou `1` est transférée exactement
  vers `SOFTWARE_APT_CROWDSEC_AGENT` si aucune valeur nouvelle n'existe
- **AND** les anciennes affectations sont supprimées

#### Scenario: Nouvelle valeur CROWDSEC_AGENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_CROWDSEC_AGENT`
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

### Requirement: Migration de FASTFETCH vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `FASTFETCH` vers
`SOFTWARE_APT_FASTFETCH` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur FASTFETCH littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `FASTFETCH`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_FASTFETCH` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: Valeur SOFTWARES_APT_FASTFETCH déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_FASTFETCH`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur FASTFETCH ambiguë

- **WHEN** une affectation `FASTFETCH` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de JSVC vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `JSVC` vers
`SOFTWARE_APT_JSVC` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Une affectation nécessitant une interprétation shell SHALL bloquer le
nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur JSVC littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `JSVC`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_JSVC` dans `softwares.env` si aucune nouvelle valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_JSVC déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_JSVC`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur JSVC ambiguë

- **WHEN** une affectation `JSVC` nécessite une interprétation shell ou ne vaut
  pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de LEMONLDAP vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `LEMONLDAP` vers
`SOFTWARE_APT_LEMONLDAP` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur LEMONLDAP littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `LEMONLDAP`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_LEMONLDAP` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_LEMONLDAP déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_LEMONLDAP`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur LEMONLDAP ambiguë

- **WHEN** une affectation `LEMONLDAP` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de MONGODB vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `MONGODB` vers
`SOFTWARE_APT_MONGODB` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Il SHALL préserver `MONGODB_VERSION`. Une affectation nécessitant une
interprétation shell SHALL bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur MONGODB littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `MONGODB`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_MONGODB` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** une affectation `MONGODB_VERSION` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_MONGODB déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_MONGODB`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur MONGODB ambiguë

- **WHEN** une affectation `MONGODB` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de OPENJDK vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `OPENJDK` vers
`SOFTWARE_APT_OPENJDK` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Une affectation nécessitant une interprétation shell SHALL bloquer le
nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur OPENJDK littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `OPENJDK`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_OPENJDK` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_OPENJDK déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_OPENJDK`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur OPENJDK ambiguë

- **WHEN** une affectation `OPENJDK` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de OMADA vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `OMADA` vers
`SOFTWARE_APT_OMADA` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Il SHALL préserver `OMADA_VERSION`. Une affectation nécessitant une
interprétation shell SHALL bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur OMADA littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `OMADA`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_OMADA` dans `softwares.env` si aucune nouvelle valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** une affectation `OMADA_VERSION` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_OMADA déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_OMADA`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur OMADA ambiguë

- **WHEN** une affectation `OMADA` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de OPENVSWITCH vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `OPENVSWITCH` vers
`SOFTWARE_APT_OPENVSWITCH` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur OPENVSWITCH littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `OPENVSWITCH`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_OPENVSWITCH` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_OPENVSWITCH déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_OPENVSWITCH`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur OPENVSWITCH ambiguë

- **WHEN** une affectation `OPENVSWITCH` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de POSTGRESQL vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `POSTGRESQL` vers
`SOFTWARE_APT_POSTGRESQL` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur POSTGRESQL littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `POSTGRESQL`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_POSTGRESQL` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_POSTGRESQL déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_POSTGRESQL`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur POSTGRESQL ambiguë

- **WHEN** une affectation `POSTGRESQL` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de POSTFIX vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `POSTFIX` vers
`SOFTWARE_APT_POSTFIX` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Il SHALL préserver `POSTFIX_RELAY_HOST`. Une affectation nécessitant
une interprétation shell SHALL bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur POSTFIX littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `POSTFIX`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_POSTFIX` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `POSTFIX_RELAY_HOST` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_POSTFIX déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_POSTFIX`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur POSTFIX ambiguë

- **WHEN** une affectation `POSTFIX` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de QEMU_GUEST_AGENT vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `QEMU_GUEST_AGENT` vers
`SOFTWARE_APT_QEMU_GUEST_AGENT` dans `softwares.env` si le nouveau nom n’y est
pas déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur QEMU_GUEST_AGENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `QEMU_GUEST_AGENT`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_QEMU_GUEST_AGENT` dans `softwares.env` si aucune nouvelle
  valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_QEMU_GUEST_AGENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_QEMU_GUEST_AGENT`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur ambiguë

- **WHEN** une affectation `QEMU_GUEST_AGENT` nécessite une interprétation
  shell ou ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de SYSLOG_CLIENT vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `SYSLOG_CLIENT` vers
`SOFTWARE_APT_SYSLOG_CLIENT` dans `softwares.env` si le nouveau nom n’y est
pas déjà déclaré. Il SHALL préserver `SYSLOG_CLIENT_SERVER`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur SYSLOG_CLIENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `SYSLOG_CLIENT`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_SYSLOG_CLIENT` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `SYSLOG_CLIENT_SERVER` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_SYSLOG_CLIENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_SYSLOG_CLIENT`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur SYSLOG_CLIENT ambiguë

- **WHEN** une affectation `SYSLOG_CLIENT` nécessite une interprétation shell
  ou ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de SYSLOG_SERVER vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `SYSLOG_SERVER` vers
`SOFTWARE_APT_SYSLOG_SERVER` dans `softwares.env` si le nouveau nom n’y est
pas déjà déclaré. Il SHALL préserver les variables `SYSLOG_SERVER_SKIL_*`. Une
affectation nécessitant une interprétation shell SHALL bloquer le nettoyage
sans modifier les fichiers.

#### Scenario: Ancienne valeur SYSLOG_SERVER littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `SYSLOG_SERVER`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_SYSLOG_SERVER` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** les affectations `SYSLOG_SERVER_SKIL_*` SHALL rester inchangées

#### Scenario: SOFTWARES_APT_SYSLOG_SERVER déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_SYSLOG_SERVER`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur SYSLOG_SERVER ambiguë

- **WHEN** une affectation `SYSLOG_SERVER` nécessite une interprétation shell
  ou ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de SSH vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `SSH` vers
`SOFTWARE_APT_SSH_SERVER` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Il SHALL préserver les variables `KEY_SSH_*`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur SSH littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `SSH`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_SSH_SERVER` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** les affectations `KEY_SSH_*` SHALL rester inchangées

#### Scenario: SOFTWARES_APT_SSH_SERVER déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_SSH_SERVER`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur SSH ambiguë

- **WHEN** une affectation `SSH` nécessite une interprétation shell ou ne vaut
  pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de SYNCTHING vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `SYNCTHING` vers
`SOFTWARE_APT_SYNCTHING` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Une affectation nécessitant une interprétation shell SHALL
bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur SYNCTHING littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `SYNCTHING`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_SYNCTHING` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_SYNCTHING déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_SYNCTHING`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur SYNCTHING ambiguë

- **WHEN** une affectation `SYNCTHING` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de WEBMIN vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `WEBMIN` vers
`SOFTWARE_APT_WEBMIN` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Il SHALL préserver `SYSTEM_APT_WEBMIN`. Une affectation nécessitant
une interprétation shell SHALL bloquer le nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur WEBMIN littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `WEBMIN`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_WEBMIN` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `SYSTEM_APT_WEBMIN` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_WEBMIN déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_WEBMIN`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur WEBMIN ambiguë

- **WHEN** une affectation `WEBMIN` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de WAZUH_CLIENT vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `WAZUH_CLIENT` vers
`SOFTWARE_APT_WAZUH_AGENT` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Il SHALL préserver `WAZUH_CLIENT_VERSION`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur WAZUH_CLIENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `WAZUH_CLIENT`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_WAZUH_AGENT` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `WAZUH_CLIENT_VERSION` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_WAZUH_AGENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_WAZUH_AGENT`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur WAZUH_CLIENT ambiguë

- **WHEN** une affectation `WAZUH_CLIENT` nécessite une interprétation shell
  ou ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de WAZUH_SERVER vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `WAZUH_SERVER` vers
`SOFTWARE_APT_WAZUH_SERVER` dans `softwares.env` si le nouveau nom n’y est pas
déjà déclaré. Il SHALL préserver `WAZUH_SERVER_UPGRADE`. Une affectation
nécessitant une interprétation shell SHALL bloquer le nettoyage sans modifier
les fichiers.

#### Scenario: Ancienne valeur WAZUH_SERVER littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `WAZUH_SERVER`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_WAZUH_SERVER` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées
- **AND** `WAZUH_SERVER_UPGRADE` SHALL rester inchangée

#### Scenario: SOFTWARES_APT_WAZUH_SERVER déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_WAZUH_SERVER`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur WAZUH_SERVER ambiguë

- **WHEN** une affectation `WAZUH_SERVER` nécessite une interprétation shell ou
  ne vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de ZOOM vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `ZOOM` vers
`SOFTWARE_APT_ZOOM` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Une affectation nécessitant une interprétation shell SHALL bloquer le
nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur ZOOM littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `ZOOM`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_ZOOM` dans `softwares.env` si aucune nouvelle valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_ZOOM déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_ZOOM`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur ZOOM ambiguë

- **WHEN** une affectation `ZOOM` nécessite une interprétation shell ou ne vaut
  pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Migration de ZSH vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `ZSH` vers `SOFTWARE_APT_ZSH`
dans `softwares.env` si le nouveau nom n’y est pas déjà déclaré. Une
affectation nécessitant une interprétation shell SHALL bloquer le nettoyage
sans modifier les fichiers.

#### Scenario: Ancienne valeur ZSH littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `ZSH`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARE_APT_ZSH` dans `softwares.env` si aucune nouvelle valeur n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: SOFTWARES_APT_ZSH déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARE_APT_ZSH`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur ZSH ambiguë

- **WHEN** une affectation `ZSH` nécessite une interprétation shell ou ne vaut
  pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu
