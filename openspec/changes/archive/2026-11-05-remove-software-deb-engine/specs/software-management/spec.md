## REMOVED Requirements

### Requirement: Mise à jour globale des paquets Debian
**Reason**: Retrait du moteur logiciel deb demandé.
**Migration**: Utiliser les parcours APT existants selon leurs capacités.

### Requirement: Paquets officiels Debian
**Reason**: Retrait du moteur logiciel deb demandé.
**Migration**: Utiliser les parcours APT existants selon leurs capacités.

### Requirement: Portée des mises à jour du moteur deb
**Reason**: Retrait du moteur logiciel deb demandé.
**Migration**: Utiliser les parcours APT existants selon leurs capacités.

### Requirement: Isolation des sources officielles dans la première étape
**Reason**: Retrait du moteur logiciel deb demandé.
**Migration**: Le filtrage spécifique est supprimé avec ce moteur.

## MODIFIED Requirements

### Requirement: Routage du cycle de vie des logiciels

DIU SHALL refuser explicitement le moteur logiciel `deb` pour les commandes d'installation, de suppression et de mise à jour. Les moteurs logiciels restants et les commandes de construction de paquets Debian SHALL conserver leurs comportements.

#### Scenario: Installation ciblée

- **WHEN** `diu install apt chatgpt` est invoqué
- **THEN** DIU délègue l'installation à la recette APT existante

#### Scenario: Désinstallation sans logiciel

- **WHEN** `diu remove apt` est invoqué
- **THEN** DIU retourne une erreur de syntaxe

#### Scenario: Moteur inconnu

- **WHEN** une commande désigne un moteur inconnu
- **THEN** DIU retourne une erreur sans exécuter d'opération de remplacement

#### Scenario: Ancienne commande du moteur deb

- **WHEN** une commande logicielle désigne le moteur `deb`
- **THEN** DIU SHALL retourner une erreur sans exécuter d'opération sur les paquets

### Requirement: Mise à jour de tous les logiciels tiers

`diu update apt` SHALL traiter les logiciels tiers installés et reconnus par DIU, selon leur mode avec dépôt ou sans dépôt, sans installer de logiciel absent.

#### Scenario: Mise à jour du moteur apt

- **WHEN** `diu update apt` est invoqué et le moteur est disponible
- **THEN** DIU exécute les mises à jour des logiciels tiers installés reconnus
- **AND** il utilise les fonctions propres aux logiciels sans dépôt
