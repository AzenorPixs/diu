# Spec Delta

## MODIFIED Requirements

### Requirement: Configuration et compatibilité des dépôts tiers

Les dépôts tiers hors CrowdSec SHALL conserver leurs dix variables
`SYSTEM_APT_*` dans le scope system. Le dépôt CrowdSec SHALL utiliser
`SOFTWARE_APT_CROWDSEC` dans le scope logiciels. Sa valeur absente SHALL être
déduite des sources APT existantes et s'activer si l'agent ou le bouncer est
activé; une valeur déjà configurée SHALL rester prioritaire. Les migrations
historiques de `SYSTEM_APT_CROWDSEC` et `CROWDSEC_BOUNCER` SHALL préserver leur
valeur dans `softwares.env`.

#### Scenario: Dépôt CrowdSec activé

- **WHEN** le dépôt CrowdSec existe déjà ou l'agent/le bouncer est activé
- **AND** `SOFTWARE_APT_CROWDSEC` n'est pas configurée
- **THEN** le DIU active le dépôt APT CrowdSec

#### Scenario: Activation historique sans source présente

- **WHEN** un dépôt historique non-CrowdSec est activé par ses variables et
  que sa variable `SYSTEM_APT_*` est absente
- **AND** aucune source APT correspondante n'est détectée
- **THEN** son activation ou sa branche est initialisée et persistée

#### Scenario: Valeur persistée prioritaire

- **WHEN** une variable `SYSTEM_APT_*` est déjà initialisée, notamment à `0`
- **THEN** la détection et les variables historiques ne la remplacent pas

#### Scenario: MongoDB historique

- **WHEN** une source MongoDB `4.4` est détectée ou la version historique
  `4.4` est activée
- **THEN** `SYSTEM_APT_MONGODB` est initialisé à `4` si cette variable est absente
- **AND** le moteur utilise la clé et la suite MongoDB `4.4`

#### Scenario: Installation MongoDB sans branche explicite

- **WHEN** `diu system install apt mongodb` est exécuté
- **THEN** une branche configurée entre `4` et `8` est conservée
- **AND** la branche `8` est choisie si aucune branche valide n'est configurée
- **AND** les commandes `mongodb-4` à `mongodb-8` sélectionnent la branche explicite

#### Scenario: Wazuh activé et désactivé

- **WHEN** `SYSTEM_APT_WAZUH` vaut `1`, `4` ou `0`
- **THEN** le moteur reçoit respectivement `1`, `1` ou `0`
- **AND** la valeur configurée reste inchangée

#### Scenario: Valeur Wazuh invalide

- **WHEN** `SYSTEM_APT_WAZUH` possède une autre valeur
- **THEN** la configuration retourne un code non nul et un diagnostic explicite

#### Scenario: Initialisation et compatibilité des configurations de dépôts tiers

- **WHEN** DIU initialise ou applique la configuration d'un dépôt tiers
- **THEN** les dix variables APT tierces hors CrowdSec restent déclarées dans
  le scope `system`, déduites des sources existantes et persistées dans
  `system.env`
- **AND** les valeurs déjà configurées gardent la priorité

### Requirement: Repli du dépôt APT LemonLDAP depuis le réglage logiciel

`SYSTEM_APT_LEMONLDAP` SHALL rester le réglage système explicite du dépôt APT.
Si aucune source LemonLDAP n’est détectée et si `SYSTEM_APT_LEMONLDAP` n’est
pas déjà configurée, sa valeur initiale SHALL être activée lorsque
`SOFTWARE_APT_LEMONLDAP=1`.

#### Scenario: Installation logicielle active sans dépôt configuré

- **WHEN** aucune source LemonLDAP APT n’est détectée
- **AND** `SOFTWARE_APT_LEMONLDAP` vaut `1`
- **THEN** le DIU SHALL persister `SYSTEM_APT_LEMONLDAP=1` dans `system.env`

#### Scenario: Réglage système explicite prioritaire

- **WHEN** `SYSTEM_APT_LEMONLDAP` est déjà configurée
- **THEN** sa valeur SHALL rester prioritaire sur `SOFTWARE_APT_LEMONLDAP`

### Requirement: Repli du dépôt MongoDB depuis le réglage logiciel

`SYSTEM_APT_MONGODB` SHALL rester le réglage système explicite du dépôt APT.
Si aucune source MongoDB n’est détectée et si `SYSTEM_APT_MONGODB` n’est pas
déjà configurée, sa valeur initiale SHALL être déterminée par
`SOFTWARE_APT_MONGODB` et `MONGODB_VERSION`. Lorsque le logiciel est actif, la
version déclarée SHALL sélectionner la branche du dépôt comme auparavant.

#### Scenario: Installation logicielle active sans dépôt configuré

- **WHEN** aucune source MongoDB APT n’est détectée
- **AND** `SOFTWARE_APT_MONGODB` vaut `1`
- **AND** `MONGODB_VERSION` contient une version prise en charge
- **THEN** le DIU SHALL persister la branche correspondante dans
  `SYSTEM_APT_MONGODB`

#### Scenario: Réglage système explicite prioritaire

- **WHEN** `SYSTEM_APT_MONGODB` est déjà configurée
- **THEN** sa valeur SHALL rester prioritaire sur les réglages logiciels

### Requirement: Repli du dépôt APT Wazuh depuis le réglage logiciel

`SYSTEM_APT_WAZUH` SHALL rester le réglage système explicite du dépôt APT.
Lorsque sa valeur n’est pas configurée et qu’aucune source n’est détectée, le
repli historique SHALL activer la branche Wazuh 4 uniquement lorsque
`SOFTWARE_APT_WAZUH_SERVER=1` et `WAZUH_SERVER_UPGRADE=1`.

#### Scenario: Serveur et mise à niveau activés sans dépôt détecté

- **WHEN** aucune source Wazuh APT n’est détectée
- **AND** `SOFTWARE_APT_WAZUH_SERVER=1`
- **AND** `WAZUH_SERVER_UPGRADE=1`
- **THEN** le DIU SHALL persister `SYSTEM_APT_WAZUH=4`

#### Scenario: Repli désactivé

- **WHEN** le serveur Wazuh ou `WAZUH_SERVER_UPGRADE` vaut `0`
- **THEN** le repli SHALL persister `SYSTEM_APT_WAZUH=0`
