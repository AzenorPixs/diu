# software-flatpak Specification

## Purpose
Permettre à DIU de gérer de façon sûre et idempotente les applications Flatpak
installées au niveau système, sans modifier le moteur Flatpak du module system.

## Requirements

### Requirement: Commandes de gestion des applications Flatpak
DIU SHALL accepter `diu softwares install flatpak <SOFTWARE>`, `diu softwares remove flatpak <SOFTWARE>` et `diu softwares update flatpak [SOFTWARE]`. Les commandes ciblées SHALL exiger un identifiant valide et SHALL refuser options et arguments supplémentaires avant toute commande Flatpak.

#### Scenario: Installation ciblée
- **WHEN** l'utilisateur invoque `diu softwares install flatpak org.example.App`
- **THEN** DIU route l'installation vers le moteur Flatpak du module `softwares`

#### Scenario: Syntaxe invalide
- **WHEN** une commande Flatpak ciblée comporte un identifiant absent, invalide ou un argument supplémentaire
- **THEN** DIU retourne une erreur sans mutation système

### Requirement: Préparation explicite du moteur Flatpak

Le moteur d'applications Flatpak SHALL exiger un client Flatpak utilisable et
le remote système `flathub`. Il SHALL NOT installer ou retirer le paquet Debian
`flatpak`, écrire `SYSTEM_FLATPAK_ENGINE`, ni créer, modifier ou supprimer un remote.
Une préparation absente SHALL être signalée explicitement sans action
implicite.

#### Scenario: Client Flatpak absent

- **WHEN** une commande d'application Flatpak est invoquée sans client Flatpak utilisable
- **THEN** DIU échoue sans appeler APT et indique la préparation système requise

#### Scenario: Flathub absent

- **WHEN** une installation d'application Flatpak est invoquée sans remote `flathub`
- **THEN** DIU échoue sans créer de remote

### Requirement: Opérations d'application idempotentes
Le moteur Flatpak SHALL installer et retirer exclusivement des applications à portée système. Une installation déjà présente et une suppression déjà absente SHALL signaler cet état sans mutation inattendue. Une suppression SHALL préserver le moteur Flatpak, les remotes et les applications non ciblées. Tout échec Flatpak SHALL être propagé avec un code non nul.

#### Scenario: Installation répétée
- **WHEN** une application Flatpak système déjà installée est demandée à l'installation
- **THEN** DIU la signale comme déjà installée sans réinstallation

#### Scenario: Désinstallation répétée
- **WHEN** une application Flatpak système absente est demandée à la suppression
- **THEN** DIU la signale comme déjà absente sans mutation

### Requirement: Mise à jour globale des applications Flatpak
`diu softwares update flatpak [SOFTWARE]` SHALL converger l'état désiré d'une application ou de toutes les applications gérées, sans mettre à jour leurs versions. L'ancienne syntaxe `diu softwares flatpak update` SHALL NOT exécuter de mise à jour de versions.

#### Scenario: Mise à jour des applications installées
- **WHEN** l'utilisateur invoque `diu softwares update flatpak`
- **THEN** DIU converge chaque application Flatpak gérée vers son état désiré

#### Scenario: Aucune application installée
- **WHEN** aucune application Flatpak n'est gérée
- **THEN** DIU signale qu'aucune convergence n'est applicable sans installer d'application

### Requirement: Aide contextuelle Flatpak
L'aide hiérarchique SHALL décrire les commandes d'installation, de suppression et de convergence Flatpak dans les contextes pertinents et SHALL distinguer la mise à jour de versions système.

#### Scenario: Aide du moteur Flatpak
- **WHEN** l'utilisateur demande l'aide des commandes softwares Flatpak
- **THEN** l'aide affiche `diu softwares update flatpak [SOFTWARE]` et sa description de convergence

### Requirement: Reprise initiale des applications Flatpak système
Lors de la première convergence globale Flatpak, DIU SHALL initialiser les applications système présentes depuis leur état réel sans installer ni supprimer d'application pendant cette initialisation. Un marqueur persistant SHALL empêcher une nouvelle adoption automatique.

#### Scenario: Première initialisation
- **WHEN** aucune initialisation Flatpak n'a été achevée et que la liste système est accessible
- **THEN** DIU conserve les états désirés existants, initialise les nouvelles entrées et enregistre le marqueur après succès

#### Scenario: Échec d'initialisation
- **WHEN** la liste ou l'état d'une application ne peut pas être vérifié
- **THEN** DIU ne marque pas l'initialisation comme achevée et signale l'erreur
