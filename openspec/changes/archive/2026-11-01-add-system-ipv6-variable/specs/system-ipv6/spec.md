## ADDED Requirements

### Requirement: Déclaration statique de SYSTEM_IPV6

Le DIU SHALL déclarer `SYSTEM_IPV6` dans
`modules/diu/variables/system/system_ipv6.sh` avec `STATIC`, `ENABLE`, scope
`system`. Le chargeur existant SHALL découvrir cette déclaration sans
modification.

#### Scenario: Initialisation depuis l’état sysctl

- **WHEN** `SYSTEM_IPV6` est absente au chargement
- **THEN** `variable_generator()` SHALL lire
  `sysctl -n net.ipv6.conf.all.disable_ipv6`
- **AND** SHALL produire `SYSTEM_IPV6=1` si sysctl retourne `0`
- **AND** SHALL produire `SYSTEM_IPV6=0` si sysctl retourne `1`
- **AND** le DIU SHALL persister puis exporter la valeur déduite dans
  `/root/diu/config/system.env`

#### Scenario: Erreur ou valeur sysctl invalide

- **WHEN** sysctl échoue ou retourne une valeur autre que `0` ou `1`
- **THEN** la génération SHALL échouer avec un diagnostic stderr
- **AND** SHALL ne pas persister ni exporter `SYSTEM_IPV6`

#### Scenario: Valeur préconfigurée

- **WHEN** `SYSTEM_IPV6` est déjà définie à `0` ou `1`
- **THEN** le DIU SHALL préserver et exporter sa valeur sans sonder sysctl ni
  réécrire sa déclaration

### Requirement: Consommateur IPv6 renommé

Le consommateur IPv6 du point d’entrée SHALL utiliser `SYSTEM_IPV6` à la place
de `IPv6`. Une valeur absente SHALL équivaloir à `0`. Les traitements sysctl
existants SHALL rester inchangés.

#### Scenario: IPv6 activé

- **WHEN** `SYSTEM_IPV6` vaut `1`
- **THEN** le DIU SHALL retirer le fichier de désactivation IPv6 s’il existe

#### Scenario: IPv6 désactivé

- **WHEN** `SYSTEM_IPV6` est absent ou vaut `0`
- **THEN** le DIU SHALL conserver l’écriture et l’application des paramètres
  sysctl de désactivation IPv6
