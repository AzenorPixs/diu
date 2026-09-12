## Purpose

Permettre à DIU de gérer de façon sûre et idempotente les applications Flatpak
installées au niveau système, sans modifier le moteur Flatpak du module system.

## ADDED Requirements

### Requirement: Commandes de gestion des applications Flatpak

DIU SHALL accepter `rid softwares install flatpak <SOFTWARE>`, `rid softwares
remove flatpak <SOFTWARE>` et `rid softwares flatpak update`. Les deux
premières commandes SHALL exiger exactement un identifiant d'application
Flatpak valide ; les options, arguments supplémentaires et identifiants
invalides SHALL échouer avant toute commande Flatpak.

#### Scenario: Installation ciblée

- **WHEN** l'utilisateur invoque `rid softwares install flatpak org.example.App`
- **THEN** DIU route l'installation vers le moteur Flatpak du module `softwares`

#### Scenario: Syntaxe invalide

- **WHEN** une commande Flatpak comporte un identifiant absent, invalide ou un argument supplémentaire
- **THEN** DIU retourne une erreur sans mutation système

### Requirement: Préparation explicite du moteur Flatpak

Le moteur d'applications Flatpak SHALL exiger un client Flatpak utilisable et
le remote système `flathub`. Il SHALL NOT installer ou retirer le paquet Debian
`flatpak`, écrire `SYSTEM_FLATPAK`, ni créer, modifier ou supprimer un remote.
Une préparation absente SHALL être signalée explicitement sans action
implicite.

#### Scenario: Client Flatpak absent

- **WHEN** une commande d'application Flatpak est invoquée sans client Flatpak utilisable
- **THEN** DIU échoue sans appeler APT et indique la préparation système requise

#### Scenario: Flathub absent

- **WHEN** une installation d'application Flatpak est invoquée sans remote `flathub`
- **THEN** DIU échoue sans créer de remote

### Requirement: Opérations d'application idempotentes

Le moteur Flatpak SHALL installer, retirer et mettre à jour exclusivement des
applications à portée système. Une installation déjà présente et une
suppression déjà absente SHALL signaler cet état sans mutation inattendue. Une
suppression SHALL préserver le moteur Flatpak, les remotes et les applications
non ciblées. Tout échec Flatpak SHALL être propagé avec un code non nul.

#### Scenario: Installation répétée

- **WHEN** une application Flatpak système déjà installée est demandée à l'installation
- **THEN** DIU la signale comme déjà installée sans réinstallation

#### Scenario: Désinstallation répétée

- **WHEN** une application Flatpak système absente est demandée à la suppression
- **THEN** DIU la signale comme déjà absente sans mutation

### Requirement: Mise à jour globale des applications Flatpak

`rid softwares flatpak update` SHALL exécuter la mise à jour des applications
Flatpak installées à portée système. Elle SHALL NOT installer une application
absente, appeler APT, ni appeler les opérations d'installation ou de
suppression du moteur. L'absence d'application ou de mise à jour SHALL être
signalée sans erreur de mutation ; un échec réel de Flatpak SHALL être propagé.

#### Scenario: Mise à jour des applications installées

- **WHEN** l'utilisateur invoque `rid softwares flatpak update`
- **THEN** DIU demande à Flatpak de mettre à jour les applications système installées

#### Scenario: Aucune application installée

- **WHEN** aucune application Flatpak système n'est installée
- **THEN** DIU signale qu'aucune mise à jour n'est applicable sans installer d'application

### Requirement: Aide contextuelle Flatpak

L'aide hiérarchique SHALL décrire les commandes d'installation, de suppression
et de mise à jour Flatpak aux contextes `rid softwares`, `rid softwares
install`, `rid softwares remove`, `rid softwares flatpak` et aux chemins
terminaux correspondants.

#### Scenario: Aide du moteur Flatpak

- **WHEN** l'utilisateur demande `rid softwares flatpak help`
- **THEN** l'aide affiche `rid softwares flatpak update` et sa description
