# Spec Delta

## MODIFIED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_APACHE2
DIU SHALL déclarer `SOFTWARE_APT_APACHE2`, migrer la valeur existante avant désactivation de l'ancienne déclaration GLOBAL et initialiser l'état absent à partir de l'état réel. Toute valeur invalide SHALL être refusée.

#### Scenario: Initialisation de la valeur absente
- **WHEN** aucune valeur nouvelle ou ancienne n'est disponible et que l'état réel est déterminable
- **THEN** DIU initialise et persiste `SOFTWARE_APT_APACHE2` selon l'état réel

#### Scenario: Valeur préconfigurée valide
- **WHEN** une valeur nouvelle ou ancienne migrable vaut `0` ou `1`
- **THEN** DIU préserve sa valeur sous le nouveau nom

#### Scenario: Valeur préconfigurée invalide
- **WHEN** une valeur nécessaire est invalide ou ambiguë
- **THEN** DIU refuse la migration avec un diagnostic

### Requirement: Consommateur Apache2 renommé
Le consommateur APT Apache2 SHALL utiliser `SOFTWARE_APT_APACHE2`. Une valeur `0` SHALL ignorer son bloc. Une valeur `1` SHALL conserver les installations APT existantes.

#### Scenario: Apache2 activé
- **WHEN** `SOFTWARE_APT_APACHE2` vaut `1`
- **THEN** DIU conserve l'installation Apache2 existante pour la version Debian détectée

#### Scenario: Apache2 désactivé ou absent
- **WHEN** `SOFTWARE_APT_APACHE2` vaut `0`
- **THEN** le bloc d'installation est ignoré
