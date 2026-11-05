## MODIFIED Requirements

### Requirement: Initialisation Git sous le sous-contexte projects git

DIU MUST exposer l'initialisation d'un dépôt Git local par la commande
`diu projects git init <ID PROJECT>`. Lorsque le projet désigné ne possède pas
de dépôt local, cette commande MUST l'initialiser et créer son premier commit
sans demander de saisie ni produire de sortie lorsqu'elle réussit. En cas
d'échec, DIU MUST retourner un code non nul avec un diagnostic. La commande historique
`diu projects giti <ID PROJECT>` MUST NOT être reconnue comme une commande
publique valide.

#### Scenario: Initialisation locale sans interaction

- **WHEN** l'utilisateur exécute `diu projects git init diu`
- **AND WHEN** le projet `diu` ne possède pas de dépôt Git local
- **THEN** DIU initialise le dépôt local et crée son premier commit sans
  attendre de saisie ni afficher de sortie

#### Scenario: Initialisation avec la commande canonique

- **WHEN** l'utilisateur exécute `diu projects git init diu`
- **THEN** DIU initialise le dépôt Git local du projet `diu`

#### Scenario: Rejet de la commande historique

- **WHEN** l'utilisateur exécute `diu projects giti diu`
- **THEN** DIU échoue avec un code de retour non nul
- **AND THEN** aucune initialisation Git n'est exécutée
