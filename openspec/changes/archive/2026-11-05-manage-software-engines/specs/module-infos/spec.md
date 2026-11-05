## MODIFIED Requirements

### Requirement: Informations Debian

system_info_debian dans modules/system/infos.sh SHALL répondre à diu system infos debian et afficher les blocs et variables dans l’ordre exact décrit ci-dessous.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Valeurs affichées
- **WHEN** diu system infos debian est appelée
- **THEN** chaque variable est affichée sous la forme NOM=valeur dans l'ordre défini
- **AND** une variable absente affiche UNSET et une valeur vide reste vide
- **AND** aucune autre variable de configuration n'est exposée

#### Scenario: Ordre exact des informations Debian

- **WHEN** system_info_debian affiche les informations Debian
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

system_info_debian dans modules/system/infos.sh SHALL répondre à diu system
infos debian. L'affichage SHALL suivre cet ordre exact :

- SYSTEM DEBIAN : SYSTEM_DEBIAN_ENVIRONNEMENT, SYSTEM_DEBIAN_RELEASE, SYSTEM_TIME_ZONE.
- SYSTEM APT OFFICIAL : SYSTEM_APT_DEBIAN_UPDATES, SYSTEM_APT_DEBIAN_SOURCES,
  SYSTEM_APT_DEBIAN_BACKPORT, SYSTEM_APT_DEBIAN_CONTRIB, SYSTEM_APT_DEBIAN_NONFRFEE.
- SYSTEM APT UNOFFICIAL : SYSTEM_APT_CGPT, SYSTEM_APT_CROWDSEC, SYSTEM_APT_DOCKER,
  SYSTEM_APT_LEMONLDAP, SYSTEM_APT_MONGODB, SYSTEM_APT_NODEJS, SYSTEM_APT_NVIDIA,
  SYSTEM_APT_PROXMOX, SYSTEM_APT_VSCODE, SYSTEM_APT_WAZUH, SYSTEM_APT_WEBMIN.
- SYSTEM FLATPAK : SYSTEM_FLATPAK_ENGINE.

