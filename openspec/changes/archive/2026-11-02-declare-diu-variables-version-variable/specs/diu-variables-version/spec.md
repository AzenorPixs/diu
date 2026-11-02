## ADDED Requirements

### Requirement: Version dynamique des variables DIU

Le DIU SHALL déclarer `DIU_VARIABLES_VERSION` dans
`modules/diu/variables/diu/diu_variables_version.sh` avec `DYNAMIC`, `ENABLE`
et scope `diu`. `variable_generator()` SHALL lire exactement la version du
paquet Debian `diu` installé avec `dpkg-query` et ne SHALL pas persister le
résultat.

#### Scenario: Version du paquet disponible

- **WHEN** `DIU_VARIABLES_VERSION` n’est pas déjà définie et le paquet `diu`
  est installé
- **THEN** le générateur SHALL exporter sa version Debian dans
  `DIU_VARIABLES_VERSION`
- **AND** SHALL NOT écrire cette valeur dans `diu.env`

#### Scenario: Version indisponible

- **WHEN** `dpkg-query` est absent, échoue ou ne retourne aucune version
- **THEN** le module SHALL échouer avec un diagnostic stderr et un statut non
  nul
- **AND** SHALL retirer toute valeur `DIU_VARIABLES_VERSION` partielle

### Requirement: Résumé de version des variables

Le résumé final SHALL afficher `DIU_VARIABLES_VERSION` à la place de
`VERSION_VARIABLES`.

#### Scenario: Résumé final

- **WHEN** le point d’entrée atteint son résumé final
- **THEN** la version du paquet DIU installée est affichée depuis
  `DIU_VARIABLES_VERSION`
