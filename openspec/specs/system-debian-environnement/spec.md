# system-debian-environnement Specification

## Purpose
Identifier l'environnement Debian courant et l'exposer dans la variable
dynamique SYSTEM_DEBIAN_ENVIRONNEMENT, sans configuration manuelle persistante.

## Requirements

### Requirement: Déclaration dynamique de l'environnement

Le DIU SHALL déclarer SYSTEM_DEBIAN_ENVIRONNEMENT dans
`modules/diu/variables/system/system_debian_environnement.sh`, avec config DYNAMIC,
state ENABLE, scope system et default_value UNSET. Le fichier SHALL définir
variable_generator et être découvert par le chargeur existant sans modification.

#### Scenario: Variable absente
- **WHEN** la déclaration est chargée avec la variable absente
- **THEN** sa valeur est générée et exportée sans écriture persistante

#### Scenario: Variable déjà définie
- **WHEN** la variable est déjà définie, même vide
- **THEN** sa valeur est conservée sans nouvelle génération

### Requirement: Identification de l'environnement courant

Le générateur SHALL produire uniquement DOCKER, LXC, PHYSICAL, PROXMOX, VM ou
UNSET. Il SHALL examiner les conteneurs avant les machines virtuelles et SHALL
identifier Proxmox VE uniquement sur une machine détectée physique avec le
paquet pve-manager confirmé installé. Il SHALL utiliser systemd-detect-virt et
dpkg-query sans installer de dépendance ni modifier le système.

#### Scenario: Docker
- **WHEN** systemd-detect-virt identifie le conteneur courant comme docker
- **THEN** la valeur est DOCKER, même sur un hôte virtualisé ou Proxmox

#### Scenario: LXC
- **WHEN** le conteneur courant est identifié comme lxc ou lxc-libvirt
- **THEN** la valeur est LXC, indépendamment de l'hyperviseur de l'hôte

#### Scenario: Machine virtuelle
- **WHEN** aucun conteneur n'est détecté et un hyperviseur reconnu est détecté
- **THEN** la valeur est VM, même si pve-manager est installé dans cette VM

#### Scenario: Machine physique avec Proxmox
- **WHEN** aucune virtualisation n'est détectée et pve-manager est installé
- **THEN** la valeur est PROXMOX

#### Scenario: Machine physique sans Proxmox
- **WHEN** aucune virtualisation n'est détectée et pve-manager est absent ou non installé
- **THEN** la valeur est PHYSICAL

#### Scenario: Détection indéterminée
- **WHEN** un outil requis manque, une détection échoue de manière inattendue,
  les résultats sont incohérents ou l'environnement est inconnu ou non pris en charge
- **THEN** la valeur est UNSET avec un diagnostic stderr et un retour réussi
- **AND** aucune classification physique par défaut ne masque cet échec
