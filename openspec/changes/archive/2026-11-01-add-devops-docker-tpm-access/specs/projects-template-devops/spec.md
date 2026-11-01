## MODIFIED Requirements

### Requirement: Références Docker des tests nécessitant des droits root

La rubrique Docker SHALL porter le titre exact
`Conteneur Docker, pour tests nécessitant des droits root`. Lorsque
`ENV_DEVOPS_TESTS_DOCKER` vaut exactement `1`, elle SHALL contenir six puces,
dans cet ordre : version détectée ou diagnostic existant, chemin du binaire ou
diagnostic existant, `/var/run/docker.sock`, `debian:stable-slim`,
`Accès TPM OK`, puis la puce commune d’autorisation. Le socket, l’image et la
mention TPM restent des références documentaires fixes. La mention TPM décrit
le contexte de test configuré ; elle ne constitue pas une détection dynamique
ni une qualification d’un autre hôte.

#### Scenario: Docker disponible

- **WHEN** `ENV_DEVOPS_TESTS_DOCKER` vaut exactement `1`
- **THEN** la rubrique porte le titre exact et les six puces dans l'ordre prévu
- **AND** le socket, l'image et la mention TPM apparaissent une seule fois

#### Scenario: Docker désactivé

- **WHEN** `ENV_DEVOPS_TESTS_DOCKER` est absent, vide ou différent de `1`
- **THEN** la rubrique Docker, ses six puces et sa sonde sont omises

#### Scenario: Docker indisponible

- **GIVEN** `ENV_DEVOPS_TESTS_DOCKER` vaut exactement `1`
- **WHEN** le binaire Docker est absent ou sa sonde échoue
- **THEN** les diagnostics existants sont conservés dans les premières puces
- **AND** le socket, l'image et la mention TPM restent indiqués sans nouvelle sonde ou action Docker

#### Scenario: Portée documentaire des références

- **WHEN** la rubrique Docker est générée
- **THEN** le générateur ne sonde pas le socket, ne télécharge ni ne lance l'image, ne modifie aucune permission, n’effectue aucune nouvelle sonde TPM et ne transmet aucun périphérique
- **AND** la mention ne garantit pas l’accès TPM depuis un autre hôte ou une configuration différente
