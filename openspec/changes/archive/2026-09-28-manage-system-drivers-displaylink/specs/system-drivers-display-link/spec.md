## REMOVED Requirements

### Requirement: Consommateur historique préservé
**Reason**: Remplacement validé par les commandes explicites.
**Migration**: Employer rid system drivers install displaylink ou rid system drivers remove displaylink.

## ADDED Requirements

### Requirement: Commandes explicites DisplayLink
Le module system SHALL exposer system_drivers_install_displaylink et system_drivers_remove_displaylink dans drivers.sh via respectivement rid system drivers install displaylink et rid system drivers remove displaylink. Les arguments supplémentaires ou inconnus SHALL être refusés. Le bloc automatique du monolithe SHALL être supprimé. La découverte statique SHALL rester sans installation automatique.

#### Scenario: Commande valide
- **WHEN** une commande DisplayLink exacte est appelée
- **THEN** seule la fonction correspondante est exécutée

#### Scenario: Commande invalide
- **WHEN** un argument manque, est inconnu ou supplémentaire
- **THEN** le routeur retourne 2 sans opération système

### Requirement: Installation contrôlée
L'installation SHALL être autorisée seulement en PHYSICAL ou PROXMOX, indépendamment de la valeur statique. Elle SHALL installer ou réparer displaylink-driver, evdi-dkms, dkms et libevdi-dev avec les headers du noyau courant. Elle SHALL vérifier les paquets configurés, la bibliothèque libevdi.so accessible, DKMS installé pour le noyau courant, le module chargé et le service actif avant de persister puis exporter 1. Un module déjà chargé obsolète SHALL être rechargé ou signalé en erreur. Aucun écran connecté SHALL être requis. Une installation saine SHALL ne pas réinstaller les paquets ni redémarrer inutilement le service.

#### Scenario: Environnement interdit
- **WHEN** l'environnement n'est ni PHYSICAL ni PROXMOX
- **THEN** l'installation échoue avant toute mutation

#### Scenario: Installation saine
- **WHEN** tous les contrôles réussissent déjà
- **THEN** aucun paquet n'est réinstallé et la valeur finale vaut 1

#### Scenario: Échec partiel
- **WHEN** APT, DKMS, chargement, bibliothèque, service ou persistance échoue
- **THEN** la commande retourne un échec explicite, sans nouvelle valeur exportée ou fausse réussite
- **AND** les mutations système déjà effectuées ne sont pas présentées comme annulées

### Requirement: EVDI pour Linux 7
Pour un noyau 7.x, EVDI SHALL être au minimum 1.15.1. Une version suffisante installée ou disponible dans les dépôts configurés SHALL être préférée. Sinon le paquet officiel Debian evdi-dkms_1.15.1+dfsg-1_all.deb SHALL être téléchargé en HTTPS et validé par SHA256 fixé ainsi que ses métadonnées avant APT. Aucun dépôt testing ou sid SHALL être ajouté. Les headers SHALL correspondre au noyau Debian ou Proxmox. La compatibilité SHALL être établie par compilation et chargement, sans garantie générale pour les futurs 7.x.

#### Scenario: Dépôt trop ancien
- **WHEN** le noyau est 7.x et ni la version installée ni le candidat APT ne suffisent
- **THEN** le paquet Debian vérifié est utilisé dans la transaction APT avec les dépendances

#### Scenario: Téléchargement invalide
- **WHEN** le téléchargement, le hash ou les métadonnées échouent
- **THEN** APT n'est pas exécuté et la valeur statique est préservée

### Requirement: Désinstallation contrôlée
La suppression SHALL être disponible dans tous les environnements. Elle SHALL arrêter le service si présent, supprimer uniquement displaylink-driver et evdi-dkms sans autoremove, puis vérifier leur absence et le déchargement du module avant de persister et exporter 0. DKMS, headers et bibliothèques partagées SHALL être conservés. Un état déjà absent SHALL réussir sans transaction APT. Les erreurs de découverte SHALL être distinguées de l'absence. Une erreur SHALL préserver la valeur statique antérieure.

#### Scenario: Suppression réussie
- **WHEN** les deux paquets sont supprimés et le module déchargé
- **THEN** la valeur persistée et exportée vaut 0

#### Scenario: Déjà absent
- **WHEN** les paquets et le module sont absents et le service inactif
- **THEN** aucune suppression APT n'est exécutée et la valeur vaut 0

#### Scenario: Échec de suppression
- **WHEN** le service ne peut être arrêté, APT échoue, un paquet reste présent ou le module reste chargé
- **THEN** la commande échoue et ne persiste pas 0
