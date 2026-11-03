## ADDED Requirements

### Requirement: Reprise de publication Debian
La publication Debian GitLab SHALL conserver une release existante et ses assets. Un asset attendu déjà disponible SHALL être signalé comme déjà publié ; un asset manquant MAY être ajouté sans remplacement.

#### Scenario: Asset déjà présent
- **WHEN** la release cohérente contient déjà l'asset attendu
- **THEN** la commande informe de sa présence sans créer de lien ou upload supplémentaire

#### Scenario: Asset absent
- **WHEN** la release cohérente ne contient pas l'asset attendu
- **THEN** la commande peut publier cet asset sans remplacer les assets présents
