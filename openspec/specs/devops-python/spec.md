# devops-python Specification

## Purpose

Définir la préparation Python DevOps et le lancement OpenCode sans gestion
automatique de Psycopg, dont les dépendances relèvent des projets concernés.

## Requirements

### Requirement: Préparation Python sans gestion Psycopg

Lorsque le bloc Python du monolithe est activé par `ENV_DEVOPS=1` et
`PYTHON=1`, DIU SHALL préserver la préparation de Python, pip, leurs liens,
le profil Python et la gestion des droits du domicile DevOps. DIU SHALL NOT
installer, mettre à jour, réinstaller ou désinstaller Psycopg ou son
implémentation binaire dans ce bloc. Les projets sont responsables de leurs
dépendances Psycopg. Le code de gestion Psycopg désactivé SHALL être conservé
en commentaires, avec la raison de sa désactivation.

#### Scenario: Python déjà à jour sans Psycopg

- **WHEN** le bloc Python est activé, Python est déjà à jour et Psycopg est absent
- **THEN** DIU prépare les liens et le profil Python sans installer Psycopg
- **AND** aucun contrôle de métadonnées ou d'import ni message de succès Psycopg n'est exécuté

#### Scenario: Psycopg déjà installé

- **WHEN** le bloc est exécuté deux fois sans remplacement du préfixe Python
- **THEN** DIU n'effectue aucune opération spécifique à Psycopg ou son extra binaire
- **AND** les paquets existants restent inchangés même si une version plus récente est disponible

#### Scenario: Bloc désactivé

- **WHEN** ENV_DEVOPS ou PYTHON ne vaut pas 1
- **THEN** le bloc ne prépare pas le profil Python et n'effectue aucune opération Psycopg

### Requirement: Aucun contrôle Psycopg dans le bloc Python

DIU SHALL NOT lire la version installée de Psycopg, vérifier son import,
afficher un succès Psycopg ou bloquer le profil Python sur l'échec d'un tel
contrôle. La préparation Python SHALL se poursuivre lorsque Psycopg est
absent ou inutilisable, sous réserve des erreurs propres à Python.

#### Scenario: Contrôles Psycopg indisponibles

- **WHEN** les opérations pip, métadonnées ou import Psycopg échoueraient
- **THEN** DIU ne les appelle pas
- **AND** la préparation du profil Python se termine si ses propres étapes réussissent

### Requirement: Lancement OpenCode sans installation Psycopg

`launch_ocrw` SHALL NOT installer Psycopg dans le conteneur OpenCode.
L'ancienne commande pip SHALL être conservée en commentaire Bash hors de la
chaîne exécutée. Les autres outils installés par apk, le lancement par
`setpriv`, les arguments OpenCode, les montages et les protections du
conteneur SHALL être préservés.

#### Scenario: Lancement du conteneur en écriture

- **WHEN** `launch_ocrw` prépare la commande de lancement d'un projet valide
- **THEN** la chaîne interne prépare les outils apk puis lance OpenCode par setpriv
- **AND** aucune commande pip ou Psycopg ne figure dans la chaîne exécutée
