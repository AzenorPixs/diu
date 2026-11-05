## MODIFIED Requirements

### Requirement: Commande de production
Le paquet issu du constructeur historique MUST vérifier `/usr/local/bin/diu` lors de sa configuration et créer le lien vers `/root/diu/root-install-debian.sh` si le nom est libre. Toute entrée existante, y compris un lien pendant, MUST être conservée. Une erreur de création MUST être signalée. Le constructeur générique ne fournit pas ce script de configuration ; la vérification au démarrage couvre aussi son paquet.

#### Scenario: Répétition de la configuration
- **WHEN** la configuration du paquet historique est exécutée plusieurs fois
- **THEN** le lien existant reste inchangé.

## ADDED Requirements

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
