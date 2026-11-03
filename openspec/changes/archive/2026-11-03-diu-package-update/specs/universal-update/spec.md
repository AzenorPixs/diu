## MODIFIED Requirements

### Requirement: Mise à jour universelle

`rid update` sans argument SHALL lancer la mise à jour générale de chaque module du DIU. Il SHALL appeler `diu_update` en premier, puis `system_update`, `environments_update`, `ia_update`, `projects_update` et `softwares_update`.

Les comportements de mise à jour, leurs prérequis et leurs validations restent définis par les modules concernés.

#### Scenario: Invocation globale
- **WHEN** `rid update` est invoqué sans argument
- **THEN** DIU appelle les mises à jour générales des modules dans l'ordre défini

### Requirement: Intégration de la mise à jour générale des projets

`rid update` SHALL appeler une seule fois la mise à jour générale des projets, après les modules DIU, système, environnements et IA et avant logiciels. Un échec projects SHALL être conservé dans le résultat global même si softwares_update réussit. Après cet échec, softwares_update SHALL être appelé. Lorsque projects réussit mais que diu échoue, le code non nul de diu SHALL être conservé après les autres modules. Si projects et diu réussissent, le retour final de softwares_update SHALL être conservé. Les moteurs logiciels explicites SHALL rester inchangés. Cette évolution SHALL NOT ajouter d'autre opération projects.

#### Scenario: Ordre conservé
- **WHEN** `rid update` est appelé sans argument et tous les modules réussissent
- **THEN** diu, system, environments, ia, projects puis softwares sont appelés dans cet ordre
- **AND THEN** le traitement des modèles des projets est appelé une seule fois

#### Scenario: Échec projects et réussite softwares
- **WHEN** projects_update échoue et softwares_update réussit
- **THEN** softwares_update est exécuté puis rid update rend le code non nul de projects

#### Scenario: Échec du DIU
- **WHEN** diu_update échoue et projects_update réussit
- **THEN** les autres modules sont appelés et le code non nul de diu est retourné

#### Scenario: Échec softwares après réussite projects
- **WHEN** projects_update et diu_update réussissent et softwares_update échoue
- **THEN** rid update conserve le code non nul de softwares

#### Scenario: Ordre et résultat de la mise à jour globale
- **WHEN** rid update intègre la mise à jour générale des projets
- **THEN** le traitement des modèles est exécuté une seule fois et les résultats projects et softwares sont propagés selon les règles ci-dessus
- **AND** les mises à jour des autres modules restent dans l’ordre défini
