# devops-python Specification

## Purpose

Définir l'installation, la mise à jour idempotente et le contrôle de Psycopg 3
dans le Python DevOps préparé par le monolithe DIU.

## Requirements

### Requirement: Installation dans le Python DevOps

Lorsque le bloc Python du monolithe est activé par `ENV_DEVOPS=1` et
`PYTHON=1`, DIU SHALL installer `psycopg[binary]>=3.2,<4` au moyen de
`/home/${ENV_DEVOPS_USER}/python/current/bin/python3 -m pip install --upgrade --no-user`,
après la préparation des liens Python/pip. DIU SHALL utiliser ce préfixe
DevOps et SHALL NOT installer cette dépendance dans le Python système ou le
site utilisateur de root. DIU SHALL préserver la préparation existante de
Python et la gestion des droits du domicile DevOps.

#### Scenario: Première installation de Psycopg

- **WHEN** le bloc est activé et Psycopg n'est pas installé dans le Python DevOps
- **THEN** pip installe Psycopg et l'extra binaire compatibles avec la contrainte
- **AND** DIU vérifie l'import et affiche la version avant de poursuivre

#### Scenario: Bloc désactivé

- **WHEN** ENV_DEVOPS ou PYTHON ne vaut pas 1
- **THEN** cette installation et son contrôle d'import ne sont pas exécutés

### Requirement: Mise à jour idempotente à chaque passage

DIU SHALL exécuter la recherche de mise à jour pip à chaque passage activé,
y compris lorsque Python est déjà à jour. Pip SHALL sélectionner la version
la plus récente compatible avec Python, la contrainte et l'index configuré.
Lorsque les versions installées satisfont déjà cet état, DIU SHALL NOT forcer
leur réinstallation. DIU SHALL NOT utiliser `--force-reinstall`.

#### Scenario: Versions déjà à jour

- **WHEN** le bloc est exécuté deux fois avec un index inchangé et des versions à jour
- **THEN** pip est appelé à chaque passage avec --upgrade
- **AND** les versions et fichiers des paquets restent inchangés au second passage

#### Scenario: Version plus récente compatible

- **WHEN** l'index fournit une version plus récente compatible de Psycopg
- **THEN** le passage suivant met à jour Psycopg et son implémentation binaire
- **AND** cette mise à jour est exécutée même si Python n'est pas recompilé

### Requirement: Échecs explicites et version vérifiée

DIU SHALL vérifier `import psycopg` avec le même Python DevOps après la réussite
de pip, et SHALL afficher `psycopg.__version__` seulement après réussite du
contrôle. Un échec de pip ou de l'import SHALL produire un diagnostic explicite
et un code de sortie non nul, sans continuer la préparation du profil Python.
Ce contrôle SHALL NOT déclencher de connexion PostgreSQL.

#### Scenario: Échec de pip

- **WHEN** pip échoue, notamment pour un index inaccessible ou un paquet indisponible
- **THEN** DIU signale l'échec de l'installation ou mise à jour de Psycopg
- **AND** le bloc s'arrête sans contrôle d'import ni succès annoncé

#### Scenario: Échec de l'import

- **WHEN** pip réussit mais l'import de psycopg échoue
- **THEN** DIU signale l'échec du contrôle de Psycopg et s'arrête
- **AND** aucune version validée ni succès n'est annoncé
