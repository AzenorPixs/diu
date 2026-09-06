## ADDED Requirements

### Requirement: Cohérence persistée de l'état ChatGPT

Après une installation ou une désinstallation réussie de ChatGPT par le
moteur APT, DIU SHALL persister la valeur correspondante de
`SOFTWARES_APT_CHATGPT` dans `/root/diu/config/softwares.env` lorsque ce
fichier est accessible en écriture.

#### Scenario: Installation persistée

- **WHEN** `rid softwares install apt chatgpt` réussit
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `1` dans le processus courant
- **AND** la configuration persistée contient
  `export SOFTWARES_APT_CHATGPT=1`

#### Scenario: Désinstallation persistée

- **WHEN** `rid softwares remove apt chatgpt` réussit
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `0` dans le processus courant
- **AND** la configuration persistée contient
  `export SOFTWARES_APT_CHATGPT=0`
- **AND** une initialisation ultérieure ne considère pas ChatGPT comme installé
