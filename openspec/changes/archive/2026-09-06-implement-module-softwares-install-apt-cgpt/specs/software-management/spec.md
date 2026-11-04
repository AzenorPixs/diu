## ADDED Requirements

### Requirement: Variables ChatGPT du moteur APT

Le scope `softwares` SHALL déclarer `SOFTWARES_APT_CHATGPT` et
`SOFTWARES_APT_CHATGPT_HOME` avec l'état `ENABLE`. La valeur par défaut de
`SOFTWARES_APT_CHATGPT` SHALL être `0`, puis son initialisation SHALL détecter
le statut installé du paquet Debian `chatgpt` et produire `1` lorsqu'il est
installé. La valeur par défaut de `SOFTWARES_APT_CHATGPT_HOME` SHALL être
`~/.codex`.

#### Scenario: ChatGPT absent au démarrage

- **WHEN** le paquet Debian `chatgpt` n'est pas installé
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `0`

#### Scenario: ChatGPT présent au démarrage

- **WHEN** le paquet Debian `chatgpt` est installé
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `1`

### Requirement: Installation APT de ChatGPT

`rid install apt chatgpt` et `rid softwares install apt chatgpt` SHALL utiliser
la recette explicite ChatGPT. Lorsque `SYSTEM_APT_CGPT` ne vaut pas `1`, elle SHALL préparer le
dépôt avec le moteur `system`, actualiser les index APT, puis installer le
paquet `chatgpt`. Après une installation réussie, elle SHALL modifier
`/usr/share/applications/chatgpt.desktop` pour définir une entrée
`Exec=env CODEX_HOME=<HOME résolu> chatgpt %U`.

#### Scenario: Dépôt CGPT absent

- **WHEN** ChatGPT est installé alors que `SYSTEM_APT_CGPT` vaut `0`
- **THEN** le dépôt CGPT est préparé, les index sont actualisés, puis le paquet
  `chatgpt` est installé
- **AND** le fichier desktop reçoit la variable `CODEX_HOME`

#### Scenario: Dépôt CGPT déjà disponible

- **WHEN** ChatGPT est installé alors que `SYSTEM_APT_CGPT` vaut `1`
- **THEN** la recette n'installe pas à nouveau le dépôt
- **AND** elle installe le paquet puis modifie le fichier desktop

### Requirement: Désinstallation APT de ChatGPT

`rid remove apt chatgpt` et `rid softwares remove apt chatgpt` SHALL supprimer le paquet `chatgpt`, puis
retirer le dépôt CGPT avec le moteur `system`, puis actualiser les index APT.
Tout échec SHALL être propagé et l'ordre SHALL être conservé.

#### Scenario: Désinstallation complète

- **WHEN** ChatGPT est installé et le dépôt CGPT est actif
- **THEN** DIU supprime le paquet, retire le dépôt, puis actualise les index
  APT

### Requirement: Mise à jour sélective APT de ChatGPT

`rid update apt chatgpt` et `rid softwares update apt chatgpt` SHALL mettre à jour uniquement le paquet
`chatgpt` sans installer un paquet absent, puis SHALL réappliquer la
modification de `/usr/share/applications/chatgpt.desktop`.

#### Scenario: Paquet absent

- **WHEN** ChatGPT n'est pas installé
- **THEN** la mise à jour échoue explicitement sans installation

#### Scenario: Mise à jour disponible

- **WHEN** ChatGPT est installé
- **THEN** APT est invoqué avec `--only-upgrade` et la cible `chatgpt`
- **AND** la ligne desktop contient `CODEX_HOME`
