## MODIFIED Requirements

### Requirement: Informations réseau du système

Le DIU SHALL déplacer display_infos vers system_info_network dans
modules/system/infos.sh et SHALL l'appeler via rid system infos network.
L'affichage réseau et l'appel du parcours historique SHALL être préservés.

#### Scenario: Interfaces réseau
- **WHEN** les informations réseau sont demandées
- **THEN** les interfaces Ethernet 1 et 2 UP sont affichées avec leurs champs existants
- **AND** les interfaces DOWN ou absentes ne sont pas affichées

### Requirement: Informations Debian

system_info_debian dans modules/system/infos.sh SHALL répondre à rid system
infos debian. L'affichage SHALL suivre cet ordre exact :

- SYSTEM DEBIAN : SYSTEM_DEBIAN_ENVIRONNEMENT, SYSTEM_DEBIAN_RELEASE, SYSTEM_TIME_ZONE.
- SYSTEM APT OFFICIAL : SYSTEM_APT_DEBIAN_UPDATES, SYSTEM_APT_DEBIAN_SOURCES,
  SYSTEM_APT_DEBIAN_BACKPORT, SYSTEM_APT_DEBIAN_CONTRIB, SYSTEM_APT_DEBIAN_NONFRFEE.
- SYSTEM APT UNOFFICIAL : SYSTEM_APT_CGPT, SYSTEM_APT_CROWDSEC, SYSTEM_APT_DOCKER,
  SYSTEM_APT_LEMONLDAP, SYSTEM_APT_MONGODB, SYSTEM_APT_NODEJS, SYSTEM_APT_NVIDIA,
  SYSTEM_APT_PROXMOX, SYSTEM_APT_VSCODE, SYSTEM_APT_WAZUH, SYSTEM_APT_WEBMIN.
- SYSTEM FLATPAK : SYSTEM_FLATPAK.

#### Scenario: Valeurs affichées
- **WHEN** rid system infos debian est appelée
- **THEN** chaque variable est affichée sous la forme NOM=valeur dans l'ordre défini
- **AND** une variable absente affiche UNSET et une valeur vide reste vide
- **AND** aucune autre variable de configuration n'est exposée

### Requirement: Agrégation des informations

system_info SHALL afficher le titre SYSTEM puis appeler system_info_debian,
system_info_drivers et system_info_network dans cet ordre, via rid system infos. La fonction infos de
modules/diu/infos.sh SHALL répondre à rid infos et appeler les informations des
modules desktop, diu, environnements, ia, projects, softwares et system dans
cet ordre. Les commandes rid <module> infos SHALL être disponibles. Les modules
sans contenu SHALL afficher au moins leur titre. Leurs fonctions SHALL être
placées dans modules/<module>/infos.sh, avec environments pour environnements.
Les agrégateurs SHALL appeler directement les fonctions, sans récursion.

#### Scenario: Informations globales
- **WHEN** rid infos est appelée
- **THEN** les sept blocs sont affichés une fois dans l'ordre défini
- **AND** le parcours d'installation n'est pas exécuté après la commande

#### Scenario: Informations DIU
- **WHEN** rid diu infos est appelée
- **THEN** le titre DIU et la version du paquet DIU installé sont affichés via diu_version
- **AND** si la version est indisponible, un diagnostic et un statut non nul sont produits

#### Scenario: Échec partiel
- **WHEN** une sous-fonction d'un agrégateur échoue
- **THEN** les autres sous-fonctions sont appelées et l'agrégateur retourne un statut non nul

### Requirement: Routage strict

Les nouvelles commandes SHALL rejeter les arguments excédentaires et feuilles
inconnues avec un code 2 et une indication d'aide contextuelle. Les fonctions
infos SHALL ne pas modifier de configuration ni exécuter d'installation ; le
bootstrap existant reste inchangé.

#### Scenario: Mauvaise feuille système
- **WHEN** rid system infos inconnu est appelée
- **THEN** un code 2 est retourné et rid system infos help est proposé

### Requirement: Informations des pilotes système
system_info_drivers dans modules/system/infos.sh SHALL répondre à rid system infos drivers et afficher la section SYSTEM DRIVERS puis SYSTEM_DRIVERS_DISPLAY_LINK sous la forme NOM=valeur. Une variable absente SHALL afficher UNSET ; une valeur vide SHALL rester vide. La fonction SHALL ne pas modifier la configuration ni installer de logiciel.

#### Scenario: Pilote déclaré installé
- **WHEN** SYSTEM_DRIVERS_DISPLAY_LINK vaut exactement 1
- **THEN** la version du paquet displaylink-driver en état installed est interrogée avec dpkg-query et affichée après la variable

#### Scenario: Pilote non déclaré installé
- **WHEN** la variable vaut 0, UNSET, est vide ou absente
- **THEN** seule la variable est affichée sans interrogation de version

#### Scenario: Version indisponible
- **WHEN** la variable vaut 1 mais le paquet est absent, incomplet, sans version ou son interrogation échoue
- **THEN** la version affiche UNSET avec un diagnostic et un statut non nul
- **AND** la configuration est préservée
