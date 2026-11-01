# system-proxy Specification

## Purpose
Déclarer et utiliser le réglage système qui active la configuration des
proxies HTTP/HTTPS existante.

## ADDED Requirements

### Requirement: Déclaration modulaire du drapeau proxy

Le DIU SHALL déclarer `SYSTEM_PROXY` dans
`modules/diu/variables/system/system_proxy.sh` avec `config=STATIC`,
`state=ENABLE`, `scope=system` et `default_value=0`. Le chargeur existant
SHALL découvrir cette déclaration sans modification.

#### Scenario: Initialisation par défaut

- **WHEN** `SYSTEM_PROXY` n’est pas déjà définie au chargement de la déclaration
- **THEN** le DIU SHALL persister `export SYSTEM_PROXY=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_PROXY=0` dans le processus courant

#### Scenario: Valeur existante

- **WHEN** `SYSTEM_PROXY` est déjà définie, y compris à une valeur vide
- **THEN** le DIU SHALL conserver et exporter sa valeur sans réécrire sa
  déclaration persistante

### Requirement: Consommation du drapeau proxy système

Les blocs existants de configuration proxy système et Java SHALL utiliser
`SYSTEM_PROXY` à la place du drapeau historique `PROXY`. Une valeur `1` SHALL
conserver les traitements existants ; une valeur absente ou `0` SHALL les
ignorer sans erreur de variable non définie. Les variables `PROXY_HTTP` et
`PROXY_HTTP_HOST` SHALL conserver leur rôle et leur nom.

#### Scenario: Proxy activé

- **WHEN** `SYSTEM_PROXY` vaut `1`
- **THEN** le DIU SHALL exécuter les traitements proxy système et Java
  existants, sans modifier leurs chemins, commandes ou paramètres

#### Scenario: Proxy désactivé ou absent

- **WHEN** `SYSTEM_PROXY` est absente ou vaut `0`
- **THEN** le DIU SHALL ignorer ces traitements sans erreur de variable non
  définie

### Requirement: Migration sûre de l’affectation historique

Avant de sourcer `/root/diu/variables.sh`, le nettoyage SHALL migrer une
affectation historique littérale `PROXY=0` ou `PROXY=1` vers
`SYSTEM_PROXY`, sauf si `system.env` la déclare déjà. Une affectation ambiguë
SHALL échouer sans mutation. En l’absence d’affectation historique, le défaut
`0` SHALL s’appliquer.

#### Scenario: Valeur historique simple

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples
  littérales de `PROXY` valant `0` ou `1`
- **THEN** le nettoyage SHALL persister la dernière valeur effective dans
  `system.env` si `SYSTEM_PROXY` n’y est pas déclarée
- **AND** SHALL retirer toutes les affectations historiques simples

#### Scenario: Configuration nouvelle déjà définie

- **WHEN** `system.env` déclare déjà `SYSTEM_PROXY`
- **THEN** cette configuration SHALL prévaloir et le nettoyage SHALL retirer
  les affectations historiques `PROXY` sans les transférer

#### Scenario: Valeur historique ambiguë ou erreur de persistance

- **WHEN** une affectation historique `PROXY` ne respecte pas le format
  littéral accepté ou que la persistance échoue
- **THEN** le nettoyage SHALL retourner un statut non nul avec diagnostic
  sans contenu de configuration
- **AND** SHALL préserver l’affectation historique pour permettre une
  correction ou une reprise
