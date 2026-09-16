## MODIFIED Requirements

### Requirement: Commit Git sous le sous-contexte projects git

DIU MUST exposer le commit d'un dépôt Git local par la commande
`rid projects git commit <ID PROJECT> [COMMIT]`. Lorsque le dépôt Git local du
projet est absent, DIU MUST l'initialiser avant de poursuivre le commit. Si
l'initialisation est annulée ou échoue, DIU MUST NOT exécuter le commit. Lorsque
le message facultatif est absent, DIU MUST conserver la génération existante
d'un nom et d'un tag de commit par défaut. La commande historique
`rid projects gitc <ID PROJECT> [COMMIT]` MUST NOT être reconnue comme une
commande publique valide.

#### Scenario: Commit avec la commande canonique

- **WHEN** l'utilisateur exécute `rid projects git commit diu publication`
- **THEN** DIU transmet le projet `diu` et le message `publication` à
  l'opération de commit Git locale

#### Scenario: Initialisation avant un commit sans dépôt local

- **WHEN** l'utilisateur exécute `rid projects git commit diu publication`
- **AND WHEN** le projet `diu` ne possède pas de dépôt Git local
- **THEN** DIU initialise le dépôt local avant d'exécuter le commit

#### Scenario: Initialisation annulée ou échouée

- **WHEN** l'utilisateur exécute un commit pour un projet sans dépôt Git local
- **AND WHEN** l'initialisation du dépôt est annulée ou échoue
- **THEN** DIU échoue avec un code de retour non nul
- **AND THEN** aucune opération de commit Git n'est exécutée

#### Scenario: Commit sans message explicite

- **WHEN** l'utilisateur exécute `rid projects git commit diu`
- **THEN** DIU crée les valeurs par défaut de nom et de tag de commit selon le
  comportement existant

#### Scenario: Rejet de la commande historique

- **WHEN** l'utilisateur exécute `rid projects gitc diu publication`
- **THEN** DIU échoue avec un code de retour non nul
- **AND THEN** aucune opération de commit Git n'est exécutée
