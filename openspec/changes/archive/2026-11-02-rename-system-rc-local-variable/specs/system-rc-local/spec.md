## ADDED Requirements

### Requirement: Déclaration statique de SYSTEM_RC_LOCAL

Le DIU SHALL déclarer `SYSTEM_RC_LOCAL` dans
`modules/diu/variables/system/system_rc_local.sh` avec `STATIC`, `ENABLE`,
scope `system` et défaut `0`. Le chargeur existant SHALL découvrir cette
déclaration sans modification.

#### Scenario: Initialisation de la valeur absente

- **WHEN** `SYSTEM_RC_LOCAL` est absente au chargement
- **THEN** le DIU SHALL persister `export SYSTEM_RC_LOCAL=0` dans
  `/root/diu/config/system.env`
- **AND** SHALL exporter cette valeur dans le processus courant

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la variable vaut `0` ou `1`
- **THEN** sa valeur SHALL être préservée et exportée sans réécriture
- **WHEN** elle vaut toute autre valeur
- **THEN** la déclaration SHALL échouer avec un diagnostic stderr

### Requirement: Consommateur rc.local renommé

Le point d’entrée SHALL utiliser `SYSTEM_RC_LOCAL` à la place de `RCLOCAL`.
Une valeur absente SHALL être traitée comme `0`. Une valeur `1` SHALL
conserver la génération actuelle de `/etc/rc.local`.

#### Scenario: rc.local désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le bloc de génération SHALL être ignoré sans erreur de variable non
  définie

#### Scenario: rc.local activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL conserver la génération et les permissions actuelles de
  `/etc/rc.local`
