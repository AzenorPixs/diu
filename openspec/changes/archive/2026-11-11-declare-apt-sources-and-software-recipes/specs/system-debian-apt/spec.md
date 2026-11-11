## MODIFIED Requirements
### Requirement: Variables de configuration
DIU SHALL déclarer les variables Debian contrib, non-free, non-free-firmware, deb-src, updates et backports dans le scope system. Les variables absentes SHALL être initialisées depuis les sources Debian actives, à zéro lorsque leur élément est absent ; les valeurs existantes valides SHALL être conservées.
#### Scenario: Valeurs initiales
- **WHEN** une variable est absente et que son composant ou sa suite est déclaré dans une source Debian active
- **THEN** sa valeur un est persistée dans system.env
#### Scenario: Élément absent
- **WHEN** une variable est absente et que son élément n’est pas déclaré
- **THEN** sa valeur zéro est persistée

### Requirement: Configuration et compatibilité des dépôts tiers

Les dépôts tiers hors CrowdSec SHALL conserver leurs dix variables
`SYSTEM_APT_*` dans le scope system. Le dépôt CrowdSec SHALL utiliser
`SOFTWARE_APT_CROWDSEC` dans le scope logiciels. Sa valeur absente SHALL être
déduite uniquement des sources APT actives ; une valeur déjà configurée SHALL rester prioritaire. Les migrations
historiques de `SYSTEM_APT_CROWDSEC` et `CROWDSEC_BOUNCER` SHALL préserver leur
valeur dans `softwares.env`.

#### Scenario: Dépôt CrowdSec activé

- **WHEN** le dépôt CrowdSec existe dans une source active
- **AND** `SOFTWARE_APT_CROWDSEC` n'est pas configurée
- **THEN** le DIU active le dépôt APT CrowdSec

#### Scenario: Activation historique sans source présente

- **WHEN** un dépôt historique non-CrowdSec est activé par ses variables et
  que sa variable `SYSTEM_APT_*` est absente
- **AND** aucune source APT correspondante n'est détectée
- **THEN** sa variable est initialisée à zéro ; une installation ultérieure peut activer son prérequis

#### Scenario: Valeur persistée prioritaire

- **WHEN** une variable `SYSTEM_APT_*` est déjà initialisée, notamment à `0`
- **THEN** la détection et les variables historiques ne la remplacent pas

#### Scenario: MongoDB historique

- **WHEN** une source MongoDB `4.4` active est détectée
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
SYSTEM_APT_LEMONLDAP SHALL rester prioritaire lorsqu’il est configuré. En absence de valeur, son initialisation SHALL utiliser uniquement les sources APT actives ; le souhait logiciel SHALL NOT activer un dépôt absent. La préparation lors de l’installation reste distincte.

#### Scenario: Installation logicielle active sans dépôt configuré
- **WHEN** aucune source active correspondante n’est détectée et que le logiciel est demandé
- **THEN** la valeur absente du dépôt est initialisée à zéro

#### Scenario: Réglage système explicite prioritaire
- **WHEN** SYSTEM_APT_LEMONLDAP est déjà configuré
- **THEN** sa valeur est conservée à l’initialisation

### Requirement: Repli du dépôt MongoDB depuis le réglage logiciel
SYSTEM_APT_MONGODB SHALL rester prioritaire lorsqu’il est configuré. En absence de valeur, son initialisation SHALL utiliser uniquement les sources APT actives ; le souhait logiciel SHALL NOT activer un dépôt absent. La préparation lors de l’installation reste distincte.

#### Scenario: Installation logicielle active sans dépôt configuré
- **WHEN** aucune source active correspondante n’est détectée et que le logiciel est demandé
- **THEN** la valeur absente du dépôt est initialisée à zéro

#### Scenario: Réglage système explicite prioritaire
- **WHEN** SYSTEM_APT_MONGODB est déjà configuré
- **THEN** sa valeur est conservée à l’initialisation

### Requirement: Repli du dépôt APT Wazuh depuis le réglage logiciel
SYSTEM_APT_WAZUH SHALL être initialisé uniquement depuis les sources actives lorsqu’il est absent, à quatre pour la branche 4.x, à zéro sinon. Le souhait logiciel et WAZUH_SERVER_UPGRADE SHALL NOT suffire à activer sa valeur initiale.
#### Scenario: Serveur et mise à niveau activés sans dépôt détecté
- **WHEN** le serveur et sa mise à niveau sont demandés mais qu’aucune source Wazuh n’est active
- **THEN** la variable absente est initialisée à zéro
#### Scenario: Repli désactivé
- **WHEN** aucune source Wazuh n’est déclarée et qu’aucune valeur n’est configurée
- **THEN** SYSTEM_APT_WAZUH est persisté à zéro
