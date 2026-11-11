## MODIFIED Requirements

### Requirement: Routage du cycle de vie des logiciels

DIU SHALL refuser explicitement le moteur logiciel `deb` pour les commandes d'installation, de suppression et de mise à jour. Les moteurs logiciels restants et les commandes de construction de paquets Debian SHALL conserver leurs comportements.

#### Scenario: Installation ciblée

- **WHEN** `diu softwares install apt chatgpt` est invoqué
- **THEN** DIU délègue l'installation à la recette APT existante

#### Scenario: Désinstallation sans logiciel

- **WHEN** `diu softwares remove apt` est invoqué
- **THEN** DIU retourne une erreur de syntaxe

#### Scenario: Moteur inconnu

- **WHEN** une commande désigne un moteur inconnu
- **THEN** DIU retourne une erreur sans exécuter d'opération de remplacement

#### Scenario: Ancienne commande du moteur deb

- **WHEN** une commande logicielle désigne le moteur `deb`
- **THEN** DIU SHALL retourner une erreur sans exécuter d'opération sur les paquets


### Requirement: Logiciels tiers avec dépôt

Le moteur `apt` SHALL déterminer, à partir de la définition du logiciel, si
l'installation dépend d'un dépôt. Si oui, il SHALL déléguer la préparation de
ce dépôt au moteur de dépôts DIU avant d'installer le paquet.
Il SHALL NOT reproduire localement un moteur de dépôts de remplacement.
La désinstallation et la mise à jour SHALL cibler les paquets du logiciel tiers.

#### Scenario: Dépôt requis

- **WHEN** `diu softwares install apt <SOFTWARE>` cible un logiciel nécessitant un dépôt
- **THEN** DIU fait préparer le dépôt par son moteur de dépôts
- **AND** il installe le paquet uniquement après le succès de cette préparation

#### Scenario: Moteur de dépôts indisponible

- **WHEN** l'installation requiert un dépôt et que son moteur DIU n'est pas disponible
- **THEN** DIU signale la fonctionnalité indisponible et retourne un code non nul
- **AND** il ne tente pas l'installation du logiciel


### Requirement: Logiciels tiers sans dépôt

Pour un logiciel tiers sans dépôt, le moteur `apt` SHALL appeler les opérations génériques alimentées par sa déclaration GLOBAL, ses résolveurs d’artefact/version et ses hooks spécifiques. Il SHALL NOT construire une commande arbitraire à partir de
l'identifiant fourni par l'utilisateur.

#### Scenario: Installation sans dépôt

- **WHEN** `diu softwares install apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle l’opération générique d’installation avec sa recette GLOBAL
- **AND** il n'active aucun dépôt tiers non déclaré par la recette

#### Scenario: Désinstallation sans dépôt

- **WHEN** `diu softwares remove apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle l’opération générique de désinstallation

#### Scenario: Mise à jour sans dépôt

- **WHEN** `diu system engine apt update` examine un logiciel déclaré sans dépôt, activé et installé
- **THEN** DIU résout l’artefact par sa déclaration et applique la comparaison de versions générique

#### Scenario: Fonction indisponible

- **WHEN** une action requiert une métadonnée ou un traitement manquant dans la déclaration
- **THEN** DIU signale l'action non prise en charge et retourne un code non nul


### Requirement: Mise à jour de tous les logiciels tiers

`diu system engine apt update` SHALL traiter les logiciels tiers installés et reconnus par DIU, selon leur mode avec dépôt ou sans dépôt, sans installer de logiciel absent.

#### Scenario: Mise à jour du moteur apt

- **WHEN** `diu system engine apt update` est invoqué et le moteur est disponible
- **THEN** DIU exécute les mises à jour des logiciels tiers installés reconnus
- **AND** il utilise les résolveurs propres aux paquets directs et les opérations communes

