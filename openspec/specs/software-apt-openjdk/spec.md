# software-apt-openjdk Specification

## Purpose
Définir la déclaration et les consommateurs du contrôle logiciel openjdk.

## Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_OPENJDK

DIU SHALL déclarer `SOFTWARE_APT_OPENJDK` dans le scope `softwares`, migrer la valeur existante avant de désactiver l'ancienne déclaration GLOBAL et initialiser la nouvelle valeur depuis l'état réel uniquement en l'absence de valeur récupérable. Les valeurs non binaires SHALL provoquer une erreur explicite.

#### Scenario: Initialisation de la valeur absente

- **WHEN** aucune valeur nouvelle ou ancienne n'est disponible et que l'état réel est déterminable
- **THEN** DIU initialise et persiste `SOFTWARE_APT_OPENJDK` à partir de cet état réel

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la valeur cible ou la valeur ancienne migrable vaut `0` ou `1`
- **THEN** DIU conserve cette valeur et la rend disponible sous le nouveau nom
- **WHEN** une valeur nécessaire à la migration est invalide ou ambiguë
- **THEN** DIU refuse la migration et signale l'erreur

### Requirement: Consommateur OpenJDK renommé

Le point d’entrée SHALL utiliser `SOFTWARE_APT_OPENJDK` à la place de
`OPENJDK`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1`
SHALL conserver l’installation et la configuration APT existantes: OpenJDK 17
sur Bullseye/Bookworm et OpenJDK 21 sur Trixie.

#### Scenario: OpenJDK désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** l’installation OpenJDK SHALL être ignorée sans erreur de variable
  non définie

#### Scenario: OpenJDK activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL sélectionner la version et les paquets selon Debian
