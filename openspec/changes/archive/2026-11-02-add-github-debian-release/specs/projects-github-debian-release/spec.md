# Publication Debian GitHub

## Purpose

Publier les paquets Debian de projets dans GitHub Releases selon les mêmes
conditions de sélection, cohérence et protection que le parcours Forgejo.

## ADDED Requirements

### Requirement: Activation et sélection du paquet
La publication SHALL être activée uniquement pour PROJECT_DEBIAN_PACKAGE=Yes/YES/1. Elle SHALL exiger un unique .deb régulier dans dist, avec Package égal à l'identifiant projet et nom <ID>_<VERSION>_all.deb cohérent avec ses métadonnées, comme Forgejo.

#### Scenario: Paquet absent ou ambigu
- **WHEN** aucun paquet ou plusieurs paquets sont présents
- **THEN** la publication échoue sans création de release ni upload

#### Scenario: Métadonnées incohérentes
- **WHEN** le nom du paquet, sa version ou son nom de fichier est incohérent
- **THEN** la publication échoue avant écriture distante

### Requirement: Cohérence de version et de Git
La publication SHALL appliquer le helper de version commun avec Forgejo. Le remote SHALL correspondre à la configuration, la branche locale attendue SHALL être courante et HEAD SHALL égaler la branche distante récupérée. Le tag existant SHALL désigner ce même HEAD et SHALL NOT être déplacé.

#### Scenario: Version prioritaire
- **WHEN** PROJECT_VERSION est déclarée
- **THEN** le paquet et le tag local attendu doivent lui correspondre

#### Scenario: Dépôt non synchronisé
- **WHEN** HEAD diffère de la branche distante ou le tag distant désigne un autre commit
- **THEN** aucune release ni aucun asset n'est créé

### Requirement: Protection des releases existantes
Une release existante SHALL provoquer un refus, sans remplacement d'asset, suppression ni modification de cette release. Un tag absent MAY être créé sur HEAD après vérification des conditions, comme Forgejo.

#### Scenario: Release déjà présente
- **WHEN** une release existe pour le tag de version
- **THEN** la commande échoue sans POST de release ou d'asset

#### Scenario: Tag absent
- **WHEN** le tag distant est absent et HEAD est synchronisé
- **THEN** le tag puis la release sont créés sur ce HEAD, sans écrasement concurrent

### Requirement: Upload authentifié et résultat vérifié
Le .deb SHALL être envoyé en binaire à upload_url après validation de son origine et de son chemin. Les credentials SHALL rester hors des arguments et journaux. Le succès SHALL exiger transport, HTTP et JSON valides et un asset concordant. Les temporaires SHALL être nettoyés.

#### Scenario: Succès
- **WHEN** la release est créée et l'upload retourne un asset valide du bon nom
- **THEN** la publication indique le lien de téléchargement et réussit

#### Scenario: Échec partiel
- **WHEN** l'upload échoue après création de release
- **THEN** la commande échoue et signale la release incomplète sans rollback automatique
