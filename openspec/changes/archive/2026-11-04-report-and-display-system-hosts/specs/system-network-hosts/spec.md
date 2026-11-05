## ADDED Requirements

### Requirement: Consultation et résultat ciblé hosts

La commande `system network hosts` SHALL afficher le contenu actuel de `/etc/hosts` et retourner une erreur si la lecture échoue. La commande ciblée `system network hosts update` SHALL émettre une ligne de résultat avec `✅` en cas de succès ou `❌` et une cause courte en cas d'échec. Elle SHALL conserver un code non nul en cas d'erreur.

#### Scenario: Consultation du fichier
- **WHEN** `system network hosts` est invoqué
- **THEN** le contenu actuel de `/etc/hosts` est affiché sans modification.

#### Scenario: Mise à jour réussie
- **WHEN** `system network hosts update` réussit
- **THEN** une seule ligne avec une coche verte est affichée et le code de retour est nul.

#### Scenario: Mise à jour échouée
- **WHEN** la génération échoue après le dispatch
- **THEN** une seule ligne avec croix rouge et cause courte est affichée et le code de retour est non nul.
