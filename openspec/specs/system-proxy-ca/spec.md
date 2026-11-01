# system-proxy-ca Specification

## Purpose
Déclarer et persister le réglage système d’installation de l’autorité de certification proxy.

## Requirements

### Requirement: Déclaration statique de l’option proxy CA

Le DIU SHALL déclarer `SYSTEM_PROXY_CA` dans `modules/diu/variables/system/system_proxy_ca.sh` avec `config=STATIC`, `state=ENABLE`, `scope=system` et `default_value=0`. Le chargeur existant SHALL découvrir cette déclaration sans modification.

#### Scenario: Initialisation par défaut

- **WHEN** `SYSTEM_PROXY_CA` est absente au chargement de la déclaration
- **THEN** le DIU SHALL persister `export SYSTEM_PROXY_CA=0` dans `/root/diu/config/system.env`
- **AND** SHALL exporter `SYSTEM_PROXY_CA=0` dans le processus courant

#### Scenario: Valeur existante

- **WHEN** `SYSTEM_PROXY_CA` est déjà définie, y compris à une valeur vide
- **THEN** le DIU SHALL conserver et exporter sa valeur sans réécrire sa déclaration persistante

#### Scenario: Échec de persistance

- **WHEN** le répertoire ou le fichier de configuration ne peut pas être créé ou écrit
- **THEN** la déclaration SHALL retourner un statut non nul avec un diagnostic sur stderr
- **AND** SHALL NOT exporter une nouvelle valeur

### Requirement: Consommation de l’option système

Le point d’entrée SHALL utiliser `SYSTEM_PROXY_CA` pour décider s’il exécute le traitement existant d’installation et de vérification de la CA. Une valeur `1` SHALL conserver ce traitement ; une valeur absente ou égale à `0` SHALL l’ignorer sans erreur de variable non définie.

#### Scenario: Option active

- **WHEN** `SYSTEM_PROXY_CA` vaut `1`
- **THEN** le DIU SHALL exécuter le traitement CA existant sans en modifier les certificats, chemins ou commandes

#### Scenario: Option désactivée ou absente

- **WHEN** `SYSTEM_PROXY_CA` est absente ou vaut `0`
- **THEN** le DIU SHALL poursuivre sans exécuter le traitement CA et sans erreur de variable non définie

### Requirement: Migration de la configuration historique

Avant de sourcer `/root/diu/variables.sh`, le DIU SHALL supprimer les affectations simples historiques de `PROXY_CA`, sans transférer leur valeur vers `SYSTEM_PROXY_CA` ni l’afficher. Lorsque la nouvelle variable est absente, son défaut `0` SHALL s’appliquer.

#### Scenario: Ancienne affectation présente

- **WHEN** `variables.sh` contient une affectation simple de `PROXY_CA`
- **THEN** le nettoyage SHALL la retirer avant le chargement du fichier
- **AND** le DIU SHALL initialiser `SYSTEM_PROXY_CA` selon sa déclaration modulaire

#### Scenario: Noms voisins et commentaires

- **WHEN** le fichier contient `PROXY_CA_EXTRA`, `SYSTEM_PROXY_CA` ou une ligne commentée
- **THEN** le nettoyage SHALL les conserver sans réécriture
