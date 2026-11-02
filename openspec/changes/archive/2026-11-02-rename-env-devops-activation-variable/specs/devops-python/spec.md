## MODIFIED Requirements

### Requirement: Préparation Python sans gestion Psycopg

Lorsque le bloc Python du monolithe est activé par
`ENVIRONMENTS_DEVOPS=1` et `PYTHON=1`, DIU SHALL préserver la préparation de
Python, pip, leurs liens, le profil Python et la gestion des droits du domicile
DevOps. DIU SHALL NOT installer, mettre à jour, réinstaller ou désinstaller
Psycopg ou son implémentation binaire dans ce bloc. Les projets sont
responsables de leurs dépendances Psycopg. Le code de gestion Psycopg
désactivé SHALL être conservé en commentaires, avec la raison de sa
désactivation.

#### Scenario: Python déjà à jour sans Psycopg

- **WHEN** le bloc Python est activé, Python est déjà à jour et Psycopg est absent
- **THEN** DIU prépare les liens et le profil Python sans installer Psycopg
- **AND** aucun contrôle de métadonnées ou d'import ni message de succès Psycopg n'est exécuté

#### Scenario: Psycopg déjà installé

- **WHEN** le bloc est exécuté deux fois sans remplacement du préfixe Python
- **THEN** DIU n'effectue aucune opération spécifique à Psycopg ou son extra binaire
- **AND** les paquets existants restent inchangés même si une version plus récente est disponible

#### Scenario: Bloc désactivé

- **WHEN** `ENVIRONMENTS_DEVOPS` ou `PYTHON` ne vaut pas `1`
- **THEN** le bloc ne prépare pas le profil Python et n'effectue aucune opération Psycopg
