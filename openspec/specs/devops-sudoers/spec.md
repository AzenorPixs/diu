# devops-sudoers Specification

## Purpose
Configurer un accès sudo sans mot de passe des comptes humains locaux au
compte ENV_DEVOPS_USER, avec sélection explicite, validation du fragment
sudoers et publication atomique dans l'environnement DevOps activé.

## Requirements

### Requirement: Activation de la génération DevOps
DIU SHALL appeler la génération sudoers à la fin du bloc `ENV_DEVOPS=1` dans
`root-install-debian.sh`. DIU SHALL générer des règles uniquement si le compte
désigné par `ENV_DEVOPS_USER` existe. DIU SHALL conserver le comportement des
autres parties du bloc.

#### Scenario: Environnement activé et compte présent
- **WHEN** ENV_DEVOPS vaut 1 et ENV_DEVOPS_USER existe
- **THEN** la génération est appelée après la configuration du profil DevOps

#### Scenario: Compte absent
- **WHEN** le compte ENV_DEVOPS_USER n'existe pas au moment de la génération
- **THEN** aucun fichier sudoers n'est créé ou remplacé
- **AND** un diagnostic indique que la génération est ignorée

#### Scenario: Environnement désactivé
- **WHEN** ENV_DEVOPS ne vaut pas 1
- **THEN** la génération n'est pas appelée
- **AND** les éventuelles règles déjà installées ne sont pas révoquées

### Requirement: Sélection des comptes humains locaux

DIU SHALL sélectionner les comptes humains locaux selon les bornes UID et le shell, appliquer les exclusions définies et échouer explicitement si les sources ou les bornes sont invalides.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Compte humain dans la plage
- **WHEN** un compte local satisfait les critères de sélection
- **THEN** une règle est générée pour ce compte

#### Scenario: Compte exclu
- **WHEN** le compte est technique configuré, root, hors plage ou sans shell de connexion utilisable
- **THEN** aucune règle n'est générée pour ce compte

#### Scenario: Configuration UID invalide
- **WHEN** une borne manque, n'est pas numérique, n'est pas positive ou les bornes sont inversées
- **THEN** la génération échoue avec un diagnostic
- **AND** le fragment précédemment installé est préservé

#### Scenario: Critères exacts de sélection des comptes humains

- **WHEN** DIU sélectionne les comptes humains locaux pour sudoers
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

DIU SHALL lire `/etc/passwd` et sélectionner les comptes dont l'UID numérique
est compris entre UID_MIN et UID_MAX inclus de `/etc/login.defs`. Les bornes
SHALL être numériques, positives et ordonnées. Les comptes sélectionnés
SHALL posséder un shell existant et exécutable. DIU SHALL NOT sélectionner
root, les shells vides, nologin ou false, ni les comptes configurés dans
ENV_DEVOPS_USER, ENV_DOCKER_USER et ENV_IA_USER. DIU SHALL signaler une erreur
de lecture ou des bornes invalides et retourner un statut non nul.

### Requirement: Politique sudoers limitée au compte DevOps

DIU SHALL limiter le fragment géré et les règles au compte DevOps, traiter la sélection vide et refuser les noms incompatibles avec la syntaxe sudoers.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Exécution comme DevOps
- **WHEN** la règle générée est appliquée par sudo sans règle contradictoire ultérieure
- **THEN** le compte sélectionné peut exécuter sudo -u et sudo -iu comme ENV_DEVOPS_USER sans mot de passe

#### Scenario: Aucun compte sélectionné
- **WHEN** aucun compte local ne satisfait les critères
- **THEN** le fragment géré ne contient aucune autorisation

#### Scenario: Nom incompatible avec la génération
- **WHEN** un nom cible ou sélectionné contient un caractère non autorisé
- **THEN** la génération échoue avec un diagnostic et préserve le fragment précédent

#### Scenario: Règles et noms admissibles du fragment DevOps

- **WHEN** DIU prépare le contenu de la politique sudoers DevOps
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

DIU SHALL gérer uniquement `/etc/sudoers.d/99-diu-devops`. Pour chaque compte
sélectionné, DIU SHALL produire `compte ALL=(ENV_DEVOPS_USER) NOPASSWD: ALL`,
avec substitution des noms réels. DIU SHALL NOT accorder par cette règle un
droit direct comme root ou un autre utilisateur, ni modifier PAM pour su.
Une sélection vide SHALL produire un fragment commenté sans règle.
Les noms SHALL commencer par un caractère alphanumérique ou un underscore,
continuer par des caractères alphanumériques, underscores, points ou tirets,
et MAY se terminer par un dollar. Tout autre nom cible ou sélectionné SHALL
provoquer une erreur sans remplacement, afin de ne pas interpréter un nom
comme une liste ou une expression sudoers.

### Requirement: Publication validée et reproductible

DIU SHALL valider puis publier atomiquement le fragment sudoers avec les attributs requis, préserver le précédent avant publication en cas d’échec et garantir une réexécution sans doublon.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Publication réussie
- **WHEN** la préparation, la validation, les permissions et le remplacement réussissent
- **THEN** le fragment contient les règles attendues avec mode 0440 et propriétaire root:root

#### Scenario: Validation ou préparation échouée
- **WHEN** une opération avant publication échoue
- **THEN** le fragment précédent est préservé et l'erreur est signalée
- **AND** le candidat temporaire est nettoyé

#### Scenario: Réexécution
- **WHEN** la génération est répétée avec les mêmes comptes et configuration
- **THEN** le fragment généré est identique et ne contient aucun doublon

#### Scenario: Validation et publication du fragment sudoers

- **WHEN** DIU prépare ou publie le fragment sudoers DevOps, avec succès ou échec
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

DIU SHALL préparer un candidat caché dans le répertoire sudoers, valider sa
syntaxe avec `visudo -cf`, appliquer `root:root` et `0440`, puis publier par
remplacement atomique du fragment géré. DIU SHALL préserver le fragment
précédent en cas d'échec avant publication et nettoyer le candidat avec un
diagnostic et un statut non nul. DIU SHALL NOT modifier les autres fragments.
Une répétition avec les mêmes entrées SHALL produire le même contenu sans
doublon. Aucun nouvel outil ou paquet SHALL être installé par cette fonction.

### Requirement: Compte rendu des autorisations publiées
Après publication réussie, DIU SHALL afficher `Sudoers DevOps configuré pour
humain1 humain2.` avec les noms réellement inscrits dans le candidat validé,
séparés par un espace, dans l'ordre des règles et sans espace final. Une
sélection vide SHALL produire `Sudoers DevOps : aucun compte humain retenu.`.
Un échec ou un compte cible absent SHALL NOT produire de message de succès.
Un préfixe visuel MAY précéder ces messages.

#### Scenario: Plusieurs comptes autorisés
- **WHEN** le fragment est publié avec les règles pour alice puis bob
- **THEN** le message est Sudoers DevOps configuré pour alice bob.
- **AND** les comptes exclus ne sont pas affichés

#### Scenario: Aucun compte sélectionné
- **WHEN** le fragment commenté est publié sans autorisation
- **THEN** le message indique aucun compte humain retenu

#### Scenario: Publication impossible ou cible absente
- **WHEN** la génération échoue ou le compte cible est absent
- **THEN** le diagnostic correspondant est affiché sans message de succès
