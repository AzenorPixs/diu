## MODIFIED Requirements

### Requirement: Déclaration statique de SYSTEM_CROWDSEC_AGENT

Le DIU SHALL déclarer `SOFTWARES_APT_CROWDSEC_AGENT` en `STATIC`, `ENABLE`,
scope `softwares` et défaut `0` dans son module logiciel. Il SHALL persister
la valeur absente dans `softwares.env`, préserver les valeurs `0` ou `1`, et
refuser toute autre valeur avec un diagnostic stderr.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SOFTWARES_APT_CROWDSEC_AGENT` est absente
- **THEN** le DIU persiste et exporte `SOFTWARES_APT_CROWDSEC_AGENT=0`

#### Scenario: Valeur préconfigurée valide

- **WHEN** la valeur vaut `0` ou `1`
- **THEN** elle est conservée sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** la valeur est différente de `0` et `1`
- **THEN** la déclaration échoue avec un diagnostic stderr

### Requirement: Consommateur CrowdSec renommé

Le bloc d'installation SHALL utiliser `SOFTWARES_APT_CROWDSEC_AGENT` et
installer le paquet `crowdsec` avec APT. Une valeur absente ou `0` SHALL
ignorer le bloc; une valeur `1` SHALL conserver la configuration existante.

#### Scenario: Agent activé

- **WHEN** `SOFTWARES_APT_CROWDSEC_AGENT` vaut `1`
- **THEN** le paquet `crowdsec` est installé via APT

#### Scenario: Agent désactivé ou absent

- **WHEN** `SOFTWARES_APT_CROWDSEC_AGENT` est absente ou vaut `0`
- **THEN** le bloc est ignoré sans erreur de variable non définie
