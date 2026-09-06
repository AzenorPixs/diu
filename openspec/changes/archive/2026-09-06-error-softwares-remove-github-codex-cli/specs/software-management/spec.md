## ADDED Requirements

### Requirement: Cohérence persistée de l'état Codex CLI

Après une installation ou une désinstallation réussie de Codex CLI, DIU SHALL
persister la valeur correspondante de `SOFTWARES_APT_CODEX_CLI` dans
`/root/diu/config/softwares.env` lorsque ce fichier est accessible en écriture.

#### Scenario: Désinstallation persistée

- **WHEN** `rid softwares remove github codex-cli` réussit
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `0` dans le processus courant
- **AND** la configuration persistée contient `export SOFTWARES_APT_CODEX_CLI=0`
- **AND** une initialisation ultérieure ne considère pas Codex CLI comme installé

#### Scenario: Mise à jour après désinstallation

- **WHEN** `rid softwares update github codex-cli` est invoqué alors que
  `SOFTWARES_APT_CODEX_CLI` vaut `0`
- **THEN** DIU n'effectue aucun accès réseau ni téléchargement
- **AND** DIU affiche que Codex CLI n'est pas installé
- **AND** la commande réussit sans erreur d'opération
