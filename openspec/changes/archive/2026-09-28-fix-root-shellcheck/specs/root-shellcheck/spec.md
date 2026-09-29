## ADDED Requirements

### Requirement: Validation statique du point d'entrée
root-install-debian.sh SHALL réussir bash -n et ShellCheck sans diagnostic. Les corrections SHALL préserver les comportements existants non concernés et SHALL ne pas désactiver globalement des diagnostics. Les annotations locales SHALL être justifiées par un import externe, un usage indirect ou une expansion volontairement différée démontrée.

#### Scenario: Analyse statique
- **WHEN** bash -n et shellcheck analysent root-install-debian.sh
- **THEN** les deux commandes réussissent sans diagnostic

### Requirement: Préservation des arguments et données générées
Les expansions scalaires SHALL conserver les espaces et caractères de glob comme un seul argument. Les listes intentionnelles SHALL rester des arguments distincts. Les scripts et configurations générés SHALL conserver leurs dollars littéraux, échappements et ordre des lignes. IPv6 et GATEWAY SHALL conserver leur contrat de configuration externe sans nouvelle valeur implicite.

#### Scenario: Valeur scalaire contenant un espace
- **WHEN** une commande consomme une valeur scalaire contenant un espace
- **THEN** cette valeur est transmise comme un argument unique

#### Scenario: Liste d'images Docker
- **WHEN** plusieurs identifiants d'images sont retournés
- **THEN** la suppression reçoit chaque identifiant séparément
- **AND** une liste vide ne déclenche pas de suppression
- **AND** un échec de découverte est signalé et ne déclenche pas de suppression

#### Scenario: Configuration générée
- **WHEN** les blocs de génération sont exécutés avec des données contrôlées
- **THEN** les lignes générées conservent leur contenu attendu, notamment les dollars littéraux et les antislashs

### Requirement: Transmission des arguments CLI
La route rid projects ocsh <ID PROJECT> SHALL transmettre l'identifiant à launch_oc_shell. La route rid docker rootless inspect <USER> <CONTAINER> SHALL transmettre l'utilisateur et le conteneur à docker_rootless_inspect sans variable locale indéfinie.

#### Scenario: Shell du projet
- **WHEN** rid projects ocsh demo est appelée
- **THEN** launch_oc_shell reçoit demo

#### Scenario: Inspection du conteneur
- **WHEN** rid docker rootless inspect devops demo est appelée
- **THEN** docker_rootless_inspect reçoit devops et demo
