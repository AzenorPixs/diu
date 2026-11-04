## ADDED Requirements

### Requirement: Migration de APACHE2 vers le scope logiciels

Avant de sourcer `/root/diu/variables.sh`, `config_cleanup` SHALL migrer la
dernière valeur littérale simple `0` ou `1` de `APACHE2` vers
`SOFTWARES_APT_APACHE2` dans `softwares.env` si le nouveau nom n’y est pas déjà
déclaré. Une affectation nécessitant une interprétation shell SHALL bloquer le
nettoyage sans modifier les fichiers.

#### Scenario: Ancienne valeur APACHE2 littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `APACHE2`
- **THEN** la dernière valeur SHALL être transférée exactement vers
  `SOFTWARES_APT_APACHE2` dans `softwares.env` si aucune nouvelle valeur
  n’existe
- **AND** les anciennes affectations SHALL être supprimées

#### Scenario: Valeur SOFTWARES_APT_APACHE2 déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_APACHE2`
- **THEN** cette valeur SHALL rester prioritaire et ne pas être réécrite

#### Scenario: Ancienne valeur APACHE2 ambiguë

- **WHEN** une affectation `APACHE2` nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage SHALL échouer sans supprimer l’affectation ni modifier
  `softwares.env`
- **AND** SHALL NOT afficher son contenu

### Requirement: Consommateur Apache2 migré

Le point d’entrée SHALL utiliser `SOFTWARES_APT_APACHE2` à la place de
`APACHE2` pour activer le bloc d’installation Apache2.

#### Scenario: Utilisation du nouveau nom

- **WHEN** le DIU décide d’installer Apache2
- **THEN** il consulte `SOFTWARES_APT_APACHE2` et conserve le comportement APT
  existant
