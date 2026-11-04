## ADDED Requirements

### Requirement: DBA-01 Fichier public optionnel par projet

Après ses contrôles existants, `projects_docker_build` MUST permettre le
fichier public optionnel `build/docker-build.args` à la racine du projet.
Son absence ou contenu vide MUST conserver l'appel Docker sans argument
supplémentaire, les chemins, le tag et l'utilisateur existants.

#### Scenario: Fichier absent
- **WHEN** le projet est Dockerisé et les fichiers requis existent sans fichier d'arguments
- **THEN** la commande Docker reste identique au parcours existant

#### Scenario: Fichier vide
- **WHEN** le fichier est vide ou ne contient que commentaires et blancs
- **THEN** aucun build-arg supplémentaire n'est transmis

### Requirement: DBA-02 Format explicite et clés uniques

Chaque ligne utile MUST suivre `NOM=VALEUR`, avec NOM conforme à
`[A-Za-z_][A-Za-z0-9_]*`. Clés dupliquées ou invalides et lignes sans =
MUST être refusées avant Docker. Lignes blanches et commentaires # après
indentation MUST être ignorés ; une valeur vide MUST rester explicite.

#### Scenario: Clé répétée après une ligne valide
- **WHEN** une clé apparaît deux fois
- **THEN** la validation échoue sans Docker ni tableau partiel publié

#### Scenario: Valeur vide
- **WHEN** une ligne utile vaut OPTION=
- **THEN** Docker reçoit OPTION= sans substitution de défaut

### Requirement: DBA-03 Valeurs littérales et frontières préservées

Le lecteur MUST transmettre chaque ligne utile dans un argument distinct
précédé de `--build-arg`. Il MUST préserver espaces, quotes, dollars,
antislashs, Unicode, # et = de la valeur. Il MUST NOT sourcer le fichier,
utiliser eval, développer des variables ou exécuter ses expressions.

#### Scenario: Expression de shell dans une valeur
- **WHEN** une valeur contient substitution de commande, dollar ou antislash
- **THEN** ses octets restent littéraux et aucune commande n'est exécutée

### Requirement: DBA-04 Ressource régulière et lecture bornée

Un fichier présent MUST être régulier, lisible, non symbolique, avec un
répertoire build non symbolique et une taille maximale de 65 536 octets.
Une ressource incompatible ou erreur de lecture MUST bloquer Docker. Le
lecteur MUST fermer son descripteur et MUST NOT modifier le fichier.

#### Scenario: Fichier symbolique ou trop grand
- **WHEN** la ressource ou son répertoire build est symbolique, non régulière ou hors limite
- **THEN** elle est refusée sans Docker ni modification de cible

### Requirement: DBA-05 Contrôles des octets et fin de fichier

Les octets NUL et CR MUST être refusés avant Docker. Une dernière ligne utile
sans LF final MUST rester traitée. La lecture MUST conserver les frontières
de lignes et MUST NOT ignorer silencieusement un octet NUL.

#### Scenario: Octet NUL après une ligne valide
- **WHEN** le fichier contient NUL ou CR, même dans un commentaire
- **THEN** la validation échoue sans construire avec un fichier tronqué

#### Scenario: Dernière ligne sans LF
- **WHEN** une ligne conforme termine le fichier sans LF
- **THEN** cette ligne est transmise intégralement

### Requirement: DBA-06 Diagnostics et erreurs sans valeurs

Les diagnostics MUST indiquer une cause sûre et éventuellement un numéro de
ligne, sans clé libre, valeur ou contenu du fichier. Un refus MUST retourner
non nul avant Docker. L'échec Docker MUST conserver le comportement non nul
existant sans annoncer une construction réussie.

#### Scenario: Entrée invalide avec marqueur fictif
- **WHEN** une ligne invalide contient un marqueur fictif sensible
- **THEN** le marqueur est absent des sorties et Docker n'est pas appelé

#### Scenario: Docker échoue
- **WHEN** Docker retourne non nul après validation
- **THEN** la fonction retourne non nul sans message de succès

### Requirement: DBA-07 Agnosticisme et priorités conservées

DIU MUST NOT contenir de sélection applicative, version métier, URL d'artefact
ou appel de helper de projet pour ce mécanisme. Il MUST conserver la priorité
des contrôles de Dockerisation et fichiers requis. Les valeurs et leur
concordance avec les références MUST rester dans chaque projet.

#### Scenario: Projet non Dockerisé et fichier invalide
- **WHEN** un projet non Dockerisé possède un fichier d'arguments invalide
- **THEN** le refus de Dockerisation précède la lecture des arguments

### Requirement: DBA-08 Configuration non sensible et tests isolés

Le fichier MUST être documenté public, réservé aux paramètres non sensibles.
Le lecteur MUST NOT charger d'autres configurations ou déduire une valeur
de l'environnement. Les tests MUST utiliser des fixtures contrôlées et
MUST NOT lancer commit, push, déploiement ou publication.

#### Scenario: Référence à une variable d'environnement
- **WHEN** une valeur contient une référence à une variable existante
- **THEN** cette référence reste littérale sans lecture de la variable
