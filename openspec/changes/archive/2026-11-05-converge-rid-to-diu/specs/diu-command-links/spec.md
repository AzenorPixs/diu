## MODIFIED Requirements

### Requirement: Résolution du point d'entrée
Le point d'entrée MUST charger ses bibliothèques depuis le répertoire de son fichier réel lorsqu'il est appelé par lien symbolique. Les alias générés MUST utiliser les noms `diu` et `diut` ; les anciens noms ne sont plus générés.

#### Scenario: Aide par lien
- **WHEN** le point d'entrée est appelé par lien avec `help`
- **THEN** il charge son aide depuis son installation ou son dépôt cible.

#### Scenario: Alias générés
- **WHEN** les alias de commande DIU sont générés
- **THEN** `diu` appelle le point d’entrée installé et `diut` appelle le point d’entrée de développement.
