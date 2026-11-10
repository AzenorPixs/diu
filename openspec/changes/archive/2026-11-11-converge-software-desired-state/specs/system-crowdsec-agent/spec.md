# Spec Delta

## MODIFIED Requirements

### Requirement: Déclaration statique de SYSTEM_CROWDSEC_AGENT
DIU SHALL déclarer `SOFTWARE_APT_CROWDSEC_AGENT`, préserver les valeurs existantes et initialiser la valeur absente depuis l'état réel. Les valeurs non binaires SHALL être refusées.

#### Scenario: Initialisation de la valeur absente
- **WHEN** aucune valeur migrable n'existe et que l'état réel est déterminable
- **THEN** DIU initialise et persiste `SOFTWARE_APT_CROWDSEC_AGENT` à partir de l'état réel

#### Scenario: Valeur préconfigurée valide
- **WHEN** la valeur vaut `0` ou `1`
- **THEN** elle est conservée

#### Scenario: Valeur préconfigurée invalide
- **WHEN** la valeur est différente de `0` et `1`
- **THEN** la déclaration échoue avec un diagnostic stderr

### Requirement: Consommateur CrowdSec renommé
Le bloc d'installation SHALL utiliser `SOFTWARE_APT_CROWDSEC_AGENT` et installer le paquet `crowdsec` avec APT. Une valeur `0` SHALL ignorer le bloc ; une valeur `1` SHALL conserver la configuration existante.

#### Scenario: Agent activé
- **WHEN** `SOFTWARE_APT_CROWDSEC_AGENT` vaut `1`
- **THEN** le paquet `crowdsec` est installé via APT

#### Scenario: Agent désactivé ou absent
- **WHEN** `SOFTWARE_APT_CROWDSEC_AGENT` vaut `0`
- **THEN** le bloc est ignoré
