# system-drivers-display-link Specification

## Purpose
Initialiser et conserver l'état des paquets DisplayLink dans la configuration
statique du module system.

## Requirements

### Requirement: Déclaration statique DisplayLink

Le DIU SHALL déclarer SYSTEM_DRIVERS_DISPLAY_LINK dans
modules/diu/variables/system/system_drivers_display_link.sh avec config STATIC,
state ENABLE, scope system et une fonction variable_generator. Les seules
valeurs acceptées SHALL être 0, 1 et UNSET. Le chargeur existant SHALL rester inchangé.

#### Scenario: Initialisation absente
- **WHEN** la variable est absente
- **THEN** sa valeur est générée, persistée dans /root/diu/config/system.env et exportée

#### Scenario: Valeur conservée
- **WHEN** la variable vaut déjà 0, 1 ou UNSET
- **THEN** elle est conservée sans détection ni nouvelle écriture

#### Scenario: Valeur invalide
- **WHEN** une valeur existante est différente de 0, 1 et UNSET, y compris vide
- **THEN** le chargement échoue explicitement sans détection ni écriture

#### Scenario: Persistance impossible
- **WHEN** la création du répertoire ou l'écriture de configuration échoue
- **THEN** un diagnostic stderr et un code non nul sont retournés
- **AND** aucune valeur nouvellement détectée n'est exportée comme initialisée

### Requirement: Détection des paquets

variable_generator SHALL utiliser dpkg-query pour déterminer l'état de
chaque paquet displaylink-driver et evdi-dkms. La valeur 1 SHALL exiger deux
paquets en état installed. La valeur 0 SHALL représenter un paquet absent ou
partiellement installé sans erreur de découverte. UNSET SHALL représenter
un outil absent, une erreur ou une réponse inexploitable, et SHALL primer
sur un résultat partiel 0. UNSET SHALL être accompagné d'un diagnostic.

#### Scenario: Installation complète
- **WHEN** les deux paquets sont installés et configurés
- **THEN** le résultat est 1

#### Scenario: Absence ou installation partielle
- **WHEN** un paquet est absent, dépaqueté, partiellement configuré ou dans un autre état incomplet reconnu
- **AND** les deux interrogations sont interprétables
- **THEN** le résultat est 0

#### Scenario: Découverte impossible
- **WHEN** dpkg-query manque ou une interrogation échoue de manière inattendue ou retourne un état inconnu
- **THEN** le résultat est UNSET, même si l'autre paquet est absent

### Requirement: Commandes explicites DisplayLink
Le module system SHALL exposer system_drivers_install_displaylink et system_drivers_remove_displaylink dans drivers.sh via respectivement rid system drivers install displaylink et rid system drivers remove displaylink. Les arguments supplémentaires ou inconnus SHALL être refusés. Le bloc automatique du monolithe SHALL être supprimé. La découverte statique SHALL rester sans installation automatique.

#### Scenario: Commande valide
- **WHEN** une commande DisplayLink exacte est appelée
- **THEN** seule la fonction correspondante est exécutée

#### Scenario: Commande invalide
- **WHEN** un argument manque, est inconnu ou supplémentaire
- **THEN** le routeur retourne 2 sans opération système

### Requirement: Installation contrôlée

L’installation DisplayLink SHALL respecter les environnements admis, préparer ses dépendances et vérifier le fonctionnement avant de persister l’état, sans écran requis ni réinstallation inutile.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

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

#### Scenario: Conditions et contrôles de l’installation DisplayLink

- **WHEN** une installation ou réparation DisplayLink est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

L'installation SHALL être autorisée seulement en PHYSICAL ou PROXMOX, indépendamment de la valeur statique. Elle SHALL installer ou réparer displaylink-driver, evdi-dkms, dkms et libevdi-dev avec les headers du noyau courant. Elle SHALL vérifier les paquets configurés, la bibliothèque libevdi.so accessible, DKMS installé pour le noyau courant, le module chargé et le service actif avant de persister puis exporter 1. Un module déjà chargé obsolète SHALL être rechargé ou signalé en erreur. Aucun écran connecté SHALL être requis. Une installation saine SHALL ne pas réinstaller les paquets ni redémarrer inutilement le service.

### Requirement: EVDI pour Linux 7

Pour Linux 7.x, EVDI SHALL respecter la version minimale, les choix de provenance, les vérifications et les limites de compatibilité décrits ci-dessous, sans ajouter de dépôt testing ou sid.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Dépôt trop ancien
- **WHEN** le noyau est 7.x et ni la version installée ni le candidat APT ne suffisent
- **THEN** le paquet Debian vérifié est utilisé dans la transaction APT avec les dépendances

#### Scenario: Téléchargement invalide
- **WHEN** le téléchargement, le hash ou les métadonnées échouent
- **THEN** APT n'est pas exécuté et la valeur statique est préservée

#### Scenario: Provenance et validation EVDI pour Linux 7

- **WHEN** DIU prépare EVDI pour un noyau Linux 7.x
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

Pour un noyau 7.x, EVDI SHALL être au minimum 1.15.1. Une version suffisante installée ou disponible dans les dépôts configurés SHALL être préférée. Sinon le paquet officiel Debian evdi-dkms_1.15.1+dfsg-1_all.deb SHALL être téléchargé en HTTPS et validé par SHA256 fixé ainsi que ses métadonnées avant APT. Aucun dépôt testing ou sid SHALL être ajouté. Les headers SHALL correspondre au noyau Debian ou Proxmox. La compatibilité SHALL être établie par compilation et chargement, sans garantie générale pour les futurs 7.x.

### Requirement: Désinstallation contrôlée

La suppression DisplayLink SHALL respecter les contrôles et la conservation des dépendances décrits ci-dessous, réussir sans transaction si déjà absent et préserver l’état antérieur en cas d’erreur.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Suppression réussie
- **WHEN** les deux paquets sont supprimés et le module déchargé
- **THEN** la valeur persistée et exportée vaut 0

#### Scenario: Déjà absent
- **WHEN** les paquets et le module sont absents et le service inactif
- **THEN** aucune suppression APT n'est exécutée et la valeur vaut 0

#### Scenario: Échec de suppression
- **WHEN** le service ne peut être arrêté, APT échoue, un paquet reste présent ou le module reste chargé
- **THEN** la commande échoue et ne persiste pas 0

#### Scenario: Suppression DisplayLink et préservation de l’état

- **WHEN** une désinstallation DisplayLink est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La suppression SHALL être disponible dans tous les environnements. Elle SHALL arrêter le service si présent, supprimer uniquement displaylink-driver et evdi-dkms sans autoremove, puis vérifier leur absence et le déchargement du module avant de persister et exporter 0. DKMS, headers et bibliothèques partagées SHALL être conservés. Un état déjà absent SHALL réussir sans transaction APT. Les erreurs de découverte SHALL être distinguées de l'absence. Une erreur SHALL préserver la valeur statique antérieure.

