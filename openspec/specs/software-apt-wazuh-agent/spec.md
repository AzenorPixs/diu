# software-apt-wazuh-agent Specification

## Purpose
Définir la déclaration et les consommateurs du contrôle logiciel wazuh-agent.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_WAZUH_AGENT

DIU SHALL déclarer `SOFTWARE_APT_WAZUH_AGENT` dans le scope `softwares`, migrer la valeur existante avant de désactiver l'ancienne déclaration GLOBAL et initialiser la nouvelle valeur depuis l'état réel uniquement en l'absence de valeur récupérable. Les valeurs non binaires SHALL provoquer une erreur explicite.

#### Scenario: Initialisation de la valeur absente

- **WHEN** aucune valeur nouvelle ou ancienne n'est disponible et que l'état réel est déterminable
- **THEN** DIU initialise et persiste `SOFTWARE_APT_WAZUH_AGENT` à partir de cet état réel

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la valeur cible ou la valeur ancienne migrable vaut `0` ou `1`
- **THEN** DIU conserve cette valeur et la rend disponible sous le nouveau nom
- **WHEN** une valeur nécessaire à la migration est invalide ou ambiguë
- **THEN** DIU refuse la migration et signale l'erreur

### Requirement: Consommateur Wazuh agent renommé

Le point d’entrée SHALL utiliser `SOFTWARE_APT_WAZUH_AGENT` à la place de
`WAZUH_CLIENT`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver le téléchargement et l’installation Debian du paquet agent,
ainsi que son activation. `WAZUH_CLIENT_VERSION` SHALL continuer à sélectionner
la version téléchargée.

#### Scenario: Agent désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le paquet agent ne SHALL pas être installé sans erreur de variable
  non définie

#### Scenario: Agent activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL installer et démarrer l’agent à la version configurée

### Requirement: Paramètres sécurisés d'enregistrement Wazuh
L'installation initiale SHALL utiliser `SOFTWARE_APT_WAZUH_AGENT_MANAGER` et `SOFTWARE_APT_WAZUH_AGENT_REGISTRATION_PASSWORD` fournis par un canal local sécurisé. `SOFTWARE_APT_WAZUH_AGENT_GROUP` et `SOFTWARE_APT_WAZUH_AGENT_PROTOCOL` MAY préciser groupe et protocole. Le mot de passe SHALL NOT être affiché ni journalisé.

#### Scenario: Paramètres absents ou invalides
- **WHEN** le serveur ou le mot de passe d'enregistrement est absent ou invalide
- **THEN** DIU refuse l'installation avant téléchargement et conserve l'état désiré

#### Scenario: Paramètres valides
- **WHEN** les paramètres d'enregistrement sont disponibles et valides
- **THEN** DIU les transmet au processus d'installation sans les afficher ni les persister par cette opération
