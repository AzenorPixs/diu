# software-apt-crowdsec Specification

## Purpose
Définir les contrôles de configuration et d’installation CrowdSec dans le scope logiciels.

## Requirements

### Requirement: Contrôles CrowdSec dans le scope logiciels
DIU SHALL déclarer le dépôt APT CrowdSec, l'agent, le bouncer et leur clé API dans le scope `softwares`. Les états désirés agent et bouncer SHALL conserver les valeurs existantes ou être initialisés depuis l'état réel. La clé API SHALL rester protégée et les paquets SHALL être installés par APT.

#### Scenario: Valeurs logicielles CrowdSec initialisées
- **WHEN** les états désirés agent et bouncer sont absents et leurs états réels déterminables
- **THEN** DIU initialise chaque état désiré à partir de l'état réel
- **AND** le dépôt est déduit des sources APT et des contrôles agent/bouncer
- **AND** la clé API absente est initialisée vide sans être affichée

#### Scenario: Migration des valeurs historiques
- **WHEN** une valeur historique CrowdSec simple est présente
- **THEN** elle est migrée vers le nouveau nom correspondant sans changer sa valeur
- **AND** une valeur déjà configurée sous son nouveau nom reste prioritaire

#### Scenario: Migration et application de la clé API
- **WHEN** une clé API historique littérale est migrée ou appliquée à la configuration YAML du bouncer
- **THEN** sa valeur n'est pas affichée ni passée dans les arguments d'un processus enfant
- **AND** `softwares.env` et le YAML du bouncer sont protégés en mode `0600`

#### Scenario: Installation des paquets
- **WHEN** l'agent ou le bouncer CrowdSec est activé
- **THEN** le paquet correspondant est installé via APT

### Requirement: Migration sécurisée de la clé API CrowdSec
DIU SHALL migrer `SOFTWARES_CROWDSEC_BOUNCER_API_KEY` vers `SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY` avant désactivation de l'ancienne déclaration GLOBAL. La clé SHALL rester confidentielle et la configuration qui la contient SHALL être protégée en mode `0600`.

#### Scenario: Clé existante
- **WHEN** une ancienne clé littérale valide est présente
- **THEN** DIU la reprend sous le nouveau nom sans l'afficher et désactive l'ancienne déclaration

#### Scenario: Clé ambiguë
- **WHEN** une déclaration de clé est ambiguë ou dupliquée
- **THEN** DIU refuse la migration sans afficher la valeur ni supprimer la déclaration

### Requirement: URL distante du rôle bouncer
`SOFTWARE_APT_CROWDSEC_BOUNCER_API_URL` MAY définir l'URL de l'API distante du bouncer autonome. En son absence, DIU SHALL conserver une URL distante existante ou reprendre le repli historique ; une URL contenant des identifiants SHALL être refusée.

#### Scenario: URL distante déjà configurée
- **WHEN** le bouncer autonome utilise déjà une URL distante et qu'aucune nouvelle URL n'est fournie
- **THEN** DIU conserve cette URL lors de la convergence

#### Scenario: URL contenant des identifiants
- **WHEN** une URL fournie contient des identifiants de connexion
- **THEN** DIU refuse la configuration sans afficher l'URL
