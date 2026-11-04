# diu-command-links Specification

## Purpose
Définir les commandes de production et de développement, leur création conditionnelle et la résolution du point d’entrée réel.

## Requirements

### Requirement: Commande de production
La configuration du paquet DIU MUST créer `/usr/local/bin/diu` comme lien symbolique vers `/root/diu/root-install-debian.sh` si ce chemin est libre. Elle MUST préserver toute entrée existante, y compris un lien pendant. Une erreur de création MUST être signalée.

#### Scenario: Répétition de la configuration
- **WHEN** la configuration du paquet est exécutée plusieurs fois
- **THEN** le lien existant reste inchangé.

### Requirement: Commande de développement
Après chargement de la configuration et vérification des droits, DIU MUST créer `/usr/local/bin/diut` vers `${ENV_DEVOPS_PROJECTS_ROOT}/diu/root-install-debian.sh` si cette cible existe et si le nom est libre. Il MUST préserver toute entrée existante, y compris un lien pendant, et signaler une erreur de création.

#### Scenario: Source absente
- **WHEN** le fichier de développement est absent
- **THEN** aucun lien `diut` n'est créé.

#### Scenario: Racine personnalisée
- **WHEN** la racine configurée contient le fichier de développement
- **THEN** le lien créé pointe vers ce fichier dans cette racine.

### Requirement: Résolution du point d'entrée
Le point d'entrée MUST charger ses bibliothèques depuis le répertoire de son fichier réel lorsqu'il est appelé par lien symbolique. Les alias historiques MUST rester disponibles.

#### Scenario: Aide par lien
- **WHEN** le point d'entrée est appelé par lien avec `help`
- **THEN** il charge son aide depuis son installation ou son dépôt cible.
