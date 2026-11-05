# diu-command-links Specification

## Purpose
Définir les commandes de production et de développement, leur création conditionnelle et la résolution du point d’entrée réel.

## Requirements

### Requirement: Commande de production
Le paquet issu du constructeur historique MUST vérifier `/usr/local/bin/diu` lors de sa configuration et créer le lien vers `/root/diu/root-install-debian.sh` si le nom est libre. Toute entrée existante, y compris un lien pendant, MUST être conservée. Une erreur de création MUST être signalée. Le constructeur générique ne fournit pas ce script de configuration ; la vérification au démarrage couvre aussi son paquet.

#### Scenario: Répétition de la configuration
- **WHEN** la configuration du paquet historique est exécutée plusieurs fois
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
Le point d'entrée MUST charger ses bibliothèques depuis le répertoire de son fichier réel lorsqu'il est appelé par lien symbolique. Les alias générés MUST utiliser les noms `diu` et `diut` ; les anciens noms ne sont plus générés.

#### Scenario: Aide par lien
- **WHEN** le point d'entrée est appelé par lien avec `help`
- **THEN** il charge son aide depuis son installation ou son dépôt cible.

#### Scenario: Alias générés
- **WHEN** les alias de commande DIU sont générés
- **THEN** `diu` appelle le point d’entrée installé et `diut` appelle le point d’entrée de développement.

### Requirement: Vérification du lien au démarrage installé
Le script `/root/diu/root-install-debian.sh` exécuté en root MUST vérifier `/usr/local/bin/diu` à chaque démarrage avant l’aide. Si le chemin est libre, il MUST créer un lien vers ce script. Toute entrée existante, y compris un lien pendant, MUST être conservée. Toute erreur de création MUST être signalée.

#### Scenario: Lien absent
- **WHEN** le script installé démarre en root et que le nom est libre
- **THEN** il crée le lien de production.

#### Scenario: Nom occupé
- **WHEN** le nom existe déjà, y compris comme lien pendant
- **THEN** il reste inchangé.

#### Scenario: Exécution de développement
- **WHEN** le script du dépôt de développement est exécuté
- **THEN** cette vérification ne crée pas le lien de production.

#### Scenario: Affichage de l’aide
- **WHEN** le script installé est exécuté en root avec `help`
- **THEN** il vérifie le lien avant d’afficher l’aide.
