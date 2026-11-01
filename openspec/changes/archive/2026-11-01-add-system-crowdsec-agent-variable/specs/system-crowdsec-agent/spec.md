## ADDED Requirements

### Requirement: Déclaration statique de SYSTEM_CROWDSEC_AGENT

Le DIU SHALL déclarer `SYSTEM_CROWDSEC_AGENT` dans
`modules/diu/variables/system/system_crowdsec_agent.sh` avec `STATIC`,
`ENABLE`, scope `system` et défaut `0`. Le chargeur existant SHALL découvrir
cette déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SYSTEM_CROWDSEC_AGENT` est absente au chargement
- **THEN** le DIU SHALL persister `export SYSTEM_CROWDSEC_AGENT=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_CROWDSEC_AGENT=0` dans le processus courant

#### Scenario: Valeur préconfigurée valide

- **WHEN** `SYSTEM_CROWDSEC_AGENT` est déjà définie à `0` ou `1`
- **THEN** le DIU SHALL préserver et exporter sa valeur sans réécriture

#### Scenario: Valeur préconfigurée invalide

- **WHEN** `SYSTEM_CROWDSEC_AGENT` est définie à une valeur autre que `0` ou
  `1`
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur CrowdSec renommé

Le bloc d’installation de l’agent SHALL utiliser `SYSTEM_CROWDSEC_AGENT` à la
place de `CROWDSEC_AGENT`. Une valeur absente ou `0` SHALL ignorer le bloc sans
erreur de variable non définie. Une valeur `1` SHALL conserver les traitements
CrowdSec existants.

#### Scenario: Agent activé

- **WHEN** `SYSTEM_CROWDSEC_AGENT` vaut `1`
- **THEN** le DIU SHALL conserver l’installation/configuration CrowdSec et
  bouncer existante

#### Scenario: Agent désactivé ou absent

- **WHEN** `SYSTEM_CROWDSEC_AGENT` est absente ou vaut `0`
- **THEN** le bloc SHALL être ignoré sans erreur de variable non définie
