# docker-sudoers Specification

## Purpose
Configurer l'accès sudo sans mot de passe des comptes humains locaux au compte
ENV_DOCKER_USER, avec sélection explicite et publication validée et atomique,
tout en préservant la politique DevOps et l'indépendance des deux fragments.

## Requirements

### Requirement: Activation de la génération Docker

DIU SHALL déclarer `ENVIRONMENT_DOCKER` dans le scope `environnements` et
appeler `configure_docker_sudoers` en fin de branche active du bloc
`ENVIRONMENT_DOCKER=1` de `root-install-debian.sh`, avant son else externe. La
génération SHALL agir uniquement si `ENV_DOCKER_USER` existe et SHALL préserver
les autres comportements du bloc.

#### Scenario: Environnement actif et compte présent

- **WHEN** `ENVIRONMENT_DOCKER` vaut 1 et `ENV_DOCKER_USER` existe
- **THEN** la génération est appelée en dernière instruction de la branche active, avant le else de désactivation

#### Scenario: Environnement désactivé

- **WHEN** `ENVIRONMENT_DOCKER` ne vaut pas 1
- **THEN** aucune génération n'est appelée et les règles existantes ne sont pas révoquées

#### Scenario: Compte cible absent

- **WHEN** `ENV_DOCKER_USER` n'existe pas au moment de la génération
- **THEN** aucun fragment n'est créé ou remplacé et un diagnostic signale l'omission

### Requirement: Sélection UID locale
DIU SHALL sélectionner dans `/etc/passwd` les comptes dont l'UID numérique
est compris entre UID_MIN et UID_MAX inclus de `/etc/login.defs`. Les bornes
SHALL être numériques, positives et ordonnées. Une erreur de lecture ou des
bornes invalides SHALL provoquer un diagnostic et un retour non nul sans
remplacement du fragment précédent.

#### Scenario: UID dans la plage
- **WHEN** un compte local possède un UID dans la plage configurée
- **THEN** il est candidat à la sélection selon son shell et les exclusions

#### Scenario: Entrées invalides ou illisibles
- **WHEN** un fichier d'entrée est illisible ou les bornes UID sont invalides
- **THEN** la génération échoue et préserve le fragment précédent

### Requirement: Shell et exclusions des comptes techniques
Les comptes retenus SHALL avoir un shell existant et exécutable. DIU SHALL NOT
retenir root, un shell vide, nologin ou false, ni les comptes configurés dans
ENV_DEVOPS_USER, ENV_DOCKER_USER et ENV_IA_USER. Ces exclusions SHALL rester
identiques aux critères DevOps.

#### Scenario: Compte humain admissible
- **WHEN** un compte candidat possède un shell admissible et n'est pas exclu
- **THEN** une règle est générée pour lui

#### Scenario: Compte technique ou shell inutilisable
- **WHEN** le compte est exclu ou son shell est inutilisable
- **THEN** aucune règle n'est générée pour lui

### Requirement: Identités sudoers simples
Les noms cible et sélectionnés SHALL commencer par un caractère alphanumérique
ou underscore, puis contenir des caractères alphanumériques, underscores,
points ou tirets et MAY finir par un dollar. Tout autre nom SHALL provoquer
une erreur sans remplacement afin de préserver son identité sudoers exacte.

#### Scenario: Caractère de syntaxe sudoers
- **WHEN** un nom cible ou sélectionné contient un caractère non autorisé
- **THEN** la génération échoue avec un diagnostic et préserve le fragment précédent

### Requirement: Politique limitée au compte Docker
DIU SHALL gérer uniquement `/etc/sudoers.d/99-diu-docker` pour Docker et y
produire `compte ALL=(ENV_DOCKER_USER) NOPASSWD: ALL` avec les noms réels.
Une sélection vide SHALL produire un fragment commenté sans règle. La
génération SHALL NOT modifier PAM ou accorder par ces règles un accès direct
comme root ou un autre compte.

#### Scenario: Commandes comme Docker
- **WHEN** sudo applique la règle sans politique ultérieure contradictoire
- **THEN** le compte retenu peut utiliser sudo -u et sudo -iu comme ENV_DOCKER_USER sans mot de passe

#### Scenario: Sélection vide
- **WHEN** aucun compte n'est retenu
- **THEN** le fragment géré contient un commentaire et aucune autorisation

### Requirement: Publication validée et reproductible
DIU SHALL valider un candidat caché avec `visudo -cf`, appliquer root:root et
0440, puis remplacer atomiquement le fragment géré. Une erreur préalable
SHALL préserver le fragment précédent, nettoyer le candidat et retourner un
statut non nul avec diagnostic. Une répétition SHALL produire le même contenu
sans doublon. La fonction SHALL NOT installer de dépendance.

#### Scenario: Publication réussie
- **WHEN** toutes les étapes de préparation et publication réussissent
- **THEN** le fragment contient les règles attendues avec propriétaire root:root et mode 0440

#### Scenario: Échec avant publication
- **WHEN** une étape échoue avant remplacement
- **THEN** le fragment précédent est préservé et le candidat nettoyé avec diagnostic d'erreur

#### Scenario: Réexécution
- **WHEN** les entrées sont inchangées lors d'une nouvelle exécution
- **THEN** le contenu est identique sans doublon

### Requirement: Coexistence avec DevOps
DIU SHALL partager le mécanisme interne pour les seuls scopes fixes devops et
docker, conserver `configure_devops_sudoers` et sa politique existante, et
utiliser deux fragments et candidats indépendants. Un scope inconnu SHALL
être refusé avant toute écriture. Les autres fragments SHALL rester inchangés.

#### Scenario: Génération des deux environnements
- **WHEN** DevOps et Docker sont configurés successivement
- **THEN** les deux fragments existent avec leurs cibles respectives et sans écrasement mutuel

#### Scenario: Scope inconnu
- **WHEN** le mécanisme commun reçoit un autre scope
- **THEN** il échoue avec diagnostic avant toute écriture

### Requirement: Compte rendu des autorisations publiées
Après publication réussie, DIU SHALL afficher `Sudoers Docker configuré pour
humain1 humain2.` avec les noms réellement inscrits dans le candidat validé,
séparés par un espace, dans l'ordre des règles et sans espace final. Une
sélection vide SHALL produire `Sudoers Docker : aucun compte humain retenu.`.
Un échec ou un compte cible absent SHALL NOT produire de message de succès.
Un préfixe visuel MAY précéder ces messages.

#### Scenario: Plusieurs comptes autorisés
- **WHEN** le fragment est publié avec les règles pour alice puis bob
- **THEN** le message est Sudoers Docker configuré pour alice bob.
- **AND** les comptes exclus ne sont pas affichés

#### Scenario: Aucun compte sélectionné
- **WHEN** le fragment commenté est publié sans autorisation
- **THEN** le message indique aucun compte humain retenu

#### Scenario: Publication impossible ou cible absente
- **WHEN** la génération échoue ou le compte cible est absent
- **THEN** le diagnostic correspondant est affiché sans message de succès
