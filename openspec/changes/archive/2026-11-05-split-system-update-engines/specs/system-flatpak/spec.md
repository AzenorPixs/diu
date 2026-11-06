## MODIFIED Requirements

### Requirement: Commandes ciblées Flatpak
DIU SHALL exposer les commandes d'activation, de désactivation et de vérification ciblée Flatpak. L'activation SHALL persister `1` après succès, la désactivation SHALL persister `0` sans retirer les dépendances. `diu system flatpak update` SHALL vérifier les dépendances et Flathub si le moteur est actif, sans lancer `flatpak update`.

#### Scenario: Installation ciblée
- **WHEN** `diu system engine install flatpak` réussit
- **THEN** l'état activé est persisté après configuration de Flathub.

#### Scenario: Mise à jour ciblée absente
- **WHEN** `diu system flatpak update` est exécuté avec moteur actif
- **THEN** les dépendances et Flathub sont vérifiés sans mettre à jour les applications.

#### Scenario: Actions Flatpak ciblées et persistance
- **WHEN** le moteur est activé ou désactivé
- **THEN** son état est persisté seulement après succès et les dépendances sont conservées à la désactivation.

#### Scenario: Aide des commandes
- **WHEN** l'aide des commandes Flatpak est demandée
- **THEN** elle présente les commandes actuelles du moteur.
