## ADDED Requirements

### Requirement: Repli du dépôt APT Wazuh depuis le réglage logiciel

`SYSTEM_APT_WAZUH` SHALL rester le réglage système explicite du dépôt APT.
Lorsque sa valeur n’est pas configurée et qu’aucune source n’est détectée, le
repli historique SHALL activer la branche Wazuh 4 uniquement lorsque
`SOFTWARES_APT_WAZUH_SERVER=1` et `WAZUH_SERVER_UPGRADE=1`.

#### Scenario: Serveur et mise à niveau activés sans dépôt détecté

- **WHEN** aucune source Wazuh APT n’est détectée
- **AND** `SOFTWARES_APT_WAZUH_SERVER=1`
- **AND** `WAZUH_SERVER_UPGRADE=1`
- **THEN** le DIU SHALL persister `SYSTEM_APT_WAZUH=4`

#### Scenario: Repli désactivé

- **WHEN** le serveur Wazuh ou `WAZUH_SERVER_UPGRADE` vaut `0`
- **THEN** le repli SHALL persister `SYSTEM_APT_WAZUH=0`
