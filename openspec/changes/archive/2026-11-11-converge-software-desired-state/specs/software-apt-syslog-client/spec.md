# Spec Delta

## MODIFIED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_SYSLOG_CLIENT

DIU SHALL déclarer `SOFTWARE_APT_SYSLOG_CLIENT` dans le scope `softwares`, migrer la valeur existante avant de désactiver l'ancienne déclaration GLOBAL et initialiser la nouvelle valeur depuis l'état réel uniquement en l'absence de valeur récupérable. Les valeurs non binaires SHALL provoquer une erreur explicite.

#### Scenario: Initialisation de la valeur absente

- **WHEN** aucune valeur nouvelle ou ancienne n'est disponible et que l'état réel est déterminable
- **THEN** DIU initialise et persiste `SOFTWARE_APT_SYSLOG_CLIENT` à partir de cet état réel

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la valeur cible ou la valeur ancienne migrable vaut `0` ou `1`
- **THEN** DIU conserve cette valeur et la rend disponible sous le nouveau nom
- **WHEN** une valeur nécessaire à la migration est invalide ou ambiguë
- **THEN** DIU refuse la migration et signale l'erreur

### Requirement: Consommateur syslog renommé

Le point d’entrée SHALL utiliser `SOFTWARE_APT_SYSLOG_CLIENT` à la place de
`SYSLOG_CLIENT`. Une valeur absente SHALL être traitée comme `0`. Une valeur
`1` SHALL conserver l’installation rsyslog et son transfert vers
`SYSLOG_CLIENT_SERVER`.

#### Scenario: Client syslog désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le rôle client SHALL ne pas être configuré sans erreur de variable non définie
- **AND** le paquet partagé est conservé si le rôle serveur le requiert

#### Scenario: Client syslog activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer rsyslog et transférer les journaux vers
  `SYSLOG_CLIENT_SERVER`
