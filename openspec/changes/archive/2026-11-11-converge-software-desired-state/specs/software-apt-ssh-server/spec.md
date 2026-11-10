# Spec Delta

## MODIFIED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_SSH_SERVER

DIU SHALL déclarer `SOFTWARE_APT_SSH_SERVER` dans le scope `softwares`, migrer la valeur existante avant de désactiver l'ancienne déclaration GLOBAL et initialiser la nouvelle valeur depuis l'état réel uniquement en l'absence de valeur récupérable. Les valeurs non binaires SHALL provoquer une erreur explicite.

#### Scenario: Initialisation de la valeur absente

- **WHEN** aucune valeur nouvelle ou ancienne n'est disponible et que l'état réel est déterminable
- **THEN** DIU initialise et persiste `SOFTWARE_APT_SSH_SERVER` à partir de cet état réel

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la valeur cible ou la valeur ancienne migrable vaut `0` ou `1`
- **THEN** DIU conserve cette valeur et la rend disponible sous le nouveau nom
- **WHEN** une valeur nécessaire à la migration est invalide ou ambiguë
- **THEN** DIU refuse la migration et signale l'erreur

### Requirement: Consommateurs OpenSSH renommés

Les consommateurs SHALL utiliser `SOFTWARE_APT_SSH_SERVER` à la place de
`SSH`. Une valeur absente SHALL être traitée comme `0`. Une valeur `1` SHALL
conserver l’installation APT de `openssh-server` et la préparation existante
des fichiers authorized_keys à partir de `KEY_SSH_ADMIN` et `KEY_SSH_ACME`.

#### Scenario: Serveur SSH désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** les blocs d’installation et de configuration SSH SHALL être ignorés
  sans erreur de variable non définie

#### Scenario: Serveur SSH activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL conserver les deux comportements OpenSSH existants

## ADDED Requirements

### Requirement: Préservation des accès SSH existants
La convergence SSH SHALL préserver les clés autorisées déjà présentes, compléter les clés DIU sans les afficher et valider la configuration candidate avant de redémarrer le service. Une configuration ou un chemin ambigu SHALL interrompre l'opération.

#### Scenario: Clés préexistantes
- **WHEN** les clés DIU sont configurées et que d'autres clés autorisées existent
- **THEN** DIU conserve les clés existantes et ajoute seulement les clés manquantes

#### Scenario: Configuration candidate invalide
- **WHEN** la validation SSH de la configuration candidate échoue
- **THEN** DIU conserve les fichiers existants et signale l'échec sans redémarrer le service
