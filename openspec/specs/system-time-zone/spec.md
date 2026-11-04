# system-time-zone Specification

## Purpose
Initialiser et conserver le fuseau horaire système dans SYSTEM_TIME_ZONE, avec détection locale et repli Europe/Paris.

## Requirements

### Requirement: Déclaration statique du fuseau horaire
Le DIU SHALL déclarer SYSTEM_TIME_ZONE dans modules/diu/variables/system/system_time_zone.sh avec config STATIC, state ENABLE, scope system et default_value Europe/Paris. Le chargeur SHALL rester inchangé. Une variable absente SHALL être générée, persistée dans /root/diu/config/system.env avec échappement Bash puis exportée. Une erreur de persistance SHALL produire un diagnostic stderr et un statut non nul sans exporter la nouvelle valeur.

#### Scenario: Première initialisation
- **WHEN** SYSTEM_TIME_ZONE est absente
- **THEN** la valeur générée est persistée puis exportée

#### Scenario: Valeur existante
- **WHEN** SYSTEM_TIME_ZONE est déjà définie, même vide
- **THEN** sa valeur est conservée sans détection ni écriture

#### Scenario: Persistance impossible
- **WHEN** le répertoire ou le fichier de configuration ne peut être écrit
- **THEN** le chargement échoue avec diagnostic sans exporter une nouvelle valeur

#### Scenario: Déclaration désactivée
- **WHEN** state vaut DISABLE
- **THEN** la variable est retirée de l'environnement et seule sa déclaration persistante exacte est supprimée

### Requirement: Détection locale et repli
variable_generator SHALL interroger timedatectl show --property=Timezone --value. Une réponse non vide avec statut de succès SHALL être utilisée. Une commande absente, une erreur ou une réponse vide SHALL produire default_value avec un diagnostic stderr et un statut de succès permettant la persistance du repli.

#### Scenario: Détection réussie
- **WHEN** timedatectl réussit et retourne Europe/London
- **THEN** la valeur générée est Europe/London

#### Scenario: Détection indisponible
- **WHEN** timedatectl est absent, échoue ou retourne une valeur vide
- **THEN** la valeur générée est Europe/Paris avec diagnostic
