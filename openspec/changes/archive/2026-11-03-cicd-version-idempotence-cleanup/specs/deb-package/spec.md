## MODIFIED Requirements

### Requirement: Version du paquet

PROJECT_VERSION, lorsqu’elle est déclarée et valide, SHALL déterminer la version du paquet. Sans cette clé, la version SHALL suivre les tags de HEAD en privilégiant les versions stables sur les horodatages, puis l’horodatage local sans Git ou tag ; ambiguïtés et erreurs Git SHALL rester bloquantes.

#### Scenario: Version générée
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** aucun tag de HEAD n'est disponible
- **THEN** le champ Version et le nom du paquet utilisent le même horodatage local YYYY.MM.DD.HH.MM
- **AND** la version est affichée lors de la construction

#### Scenario: Version issue du tag
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** HEAD possède v1.2.3 ou 1.2.3 comme unique version valide
- **THEN** le paquet utilise 1.2.3 ; des variantes équivalentes ne créent pas d’ambiguïté

#### Scenario: Versions de tags ambiguës
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** HEAD possède plusieurs versions distinctes après application de la priorité stable ou un tag inexploitable
- **THEN** le build échoue avant publication et préserve dist/

#### Scenario: Tag stable et horodaté
- **WHEN** HEAD porte une seule version stable et un ou plusieurs tags horodatés
- **THEN** le constructeur retient la version stable
