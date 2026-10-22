## ADDED Requirements

### Requirement: Enregistrement système après mise à jour Git locale

Après l'enregistrement réussi des variables locales, `git_update` MUST
enregistrer l'exception système exacte du chemin canonique du projet selon
les mêmes règles d'idempotence et d'erreur que `git_init`. Le questionnaire,
les variables distantes et générales et la signature publique MUST rester
inchangés. La fonction interne `git_update_local` MUST rester limitée aux
variables locales et MUST NOT écrire `safe.directory`.

#### Scenario: Mise à jour avec exception absente

- **WHEN** le questionnaire Git local se termine et les variables sont enregistrées
- **THEN** l'exception exacte est enregistrée en portée système
- **AND** une nouvelle exécution n'ajoute pas de doublon

#### Scenario: Échec du questionnaire ou de l'enregistrement local

- **WHEN** la mise à jour locale échoue
- **THEN** aucune écriture safe.directory n'est tentée

#### Scenario: Échec de l'enregistrement système

- **GIVEN** les variables locales enregistrées et l'ajout système impossible
- **WHEN** git_update tente d'enregistrer l'exception
- **THEN** la commande retourne un échec explicite
- **AND** les variables déjà enregistrées sont conservées
