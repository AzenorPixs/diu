# software-apt-crowdsec Specification

## Purpose
Définir les contrôles de configuration et d’installation CrowdSec dans le scope logiciels.

## Requirements

### Requirement: Contrôles CrowdSec dans le scope logiciels

Le DIU SHALL déclarer le dépôt APT CrowdSec, l'installation de l'agent et du
bouncer, ainsi que leur clé API, dans le scope `softwares`. L'agent et le
bouncer SHALL avoir une valeur initiale `0`; la clé API SHALL être vide si
aucune valeur historique ou configurée n'existe. Les paquets CrowdSec SHALL
être installés par APT.

#### Scenario: Valeurs logicielles CrowdSec initialisées

- **WHEN** les valeurs CrowdSec sont absentes
- **THEN** les contrôles agent/bouncer sont persistés à `0` dans
  `softwares.env`
- **AND** le dépôt est déduit des sources APT et des contrôles agent/bouncer
- **AND** la clé API est initialisée vide sans être affichée

#### Scenario: Migration des valeurs historiques

- **WHEN** une valeur historique CrowdSec simple est présente
- **THEN** elle est migrée vers le nouveau nom correspondant sans changer sa
  valeur
- **AND** une valeur déjà configurée sous son nouveau nom reste prioritaire

#### Scenario: Migration et application de la clé API

- **WHEN** une clé API historique littérale est migrée ou appliquée à la
  configuration YAML du bouncer
- **THEN** sa valeur n'est pas affichée ni passée dans les arguments d'un
  processus enfant
- **AND** `softwares.env` et le YAML du bouncer sont protégés en mode `0600`

#### Scenario: Installation des paquets

- **WHEN** l'agent ou le bouncer CrowdSec est activé
- **THEN** le paquet correspondant est installé via APT
