## MODIFIED Requirements

### Requirement: Migration de CROWDSEC_AGENT

`config_cleanup` SHALL migrer les valeurs simples de `CROWDSEC_AGENT`,
`SYSTEM_CROWDSEC_AGENT`, `CROWDSEC_BOUNCER`, `SYSTEM_APT_CROWDSEC` et la clé
`CROWDSEC_BOUNCER_API_KEY` vers leurs nouveaux noms dans `softwares.env`.
Les valeurs agent/bouncer/dépôt `0` ou `1` sont préservées exactement. La clé
API est transférée opaque, sans exécution ni affichage, et le fichier reçoit
le mode `0600`. Une valeur sous son nouveau nom reste prioritaire; toute
affectation ancienne ambiguë bloque sans modifier les fichiers.

#### Scenario: Ancienne valeur CROWDSEC_AGENT littérale

- **WHEN** `variables.sh` contient une ou plusieurs affectations simples de
  `CROWDSEC_AGENT`
- **THEN** la dernière valeur littérale `0` ou `1` est transférée exactement
  vers `SOFTWARES_APT_CROWDSEC_AGENT` si aucune valeur nouvelle n'existe
- **AND** les anciennes affectations sont supprimées

#### Scenario: Nouvelle valeur CROWDSEC_AGENT déjà configurée

- **WHEN** `softwares.env` déclare déjà `SOFTWARES_APT_CROWDSEC_AGENT`
- **THEN** sa valeur reste prioritaire et n'est pas réécrite

#### Scenario: Ancienne valeur CROWDSEC_AGENT ambiguë

- **WHEN** une affectation CrowdSec nécessite une interprétation shell ou ne
  vaut pas littéralement `0` ou `1`
- **THEN** le nettoyage échoue sans supprimer l'affectation ni modifier les
  fichiers de configuration
- **AND** il n'affiche pas la valeur

#### Scenario: Clé API historique littérale

- **WHEN** `variables.sh` contient une clé API littérale simple
- **THEN** elle est transférée sans affichage vers
  `SOFTWARES_CROWDSEC_BOUNCER_API_KEY`
- **AND** `softwares.env` reçoit le mode `0600`
- **AND** l'affectation historique est supprimée

#### Scenario: Clé API ambiguë

- **WHEN** l'affectation historique de la clé API n'est pas un littéral simple
- **THEN** le nettoyage échoue sans évaluer ni afficher son contenu
- **AND** les fichiers restent inchangés
