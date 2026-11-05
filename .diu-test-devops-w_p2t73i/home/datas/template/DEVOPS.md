# DEVOPS.md — Template

Version : 0.8

Généré automatiquement par Debian Installeur Unifié (DIU).
Début du relevé (UTC) : 2026-10-09T06:30:00Z
Environnement d'exécution DIU : UNSET

## Configuration locale — project.env

Le fichier `project.env`, situé à la racine du projet, est une configuration
locale protégée. Sa consultation par les agents relève des sections 9 et 10
d’AGENTS.md.

Pour le travail autorisé, l’agent peut extraire localement les variables
non secrètes nécessaires, notamment `PROJECT_*`, `LOCAL_DEFAULT_BRANCH`,
`GIT_*` et `REMOTE_*`, sans limitation à ces familles. Seul un processus
local parcourt le fichier et restitue les noms et valeurs validés comme
non secrets.

La lecture brute, l’exécution du fichier et son chargement dans
l’environnement par l’agent sont interdits. L’agent ne doit ni créer,
ni modifier, ni régénérer ce fichier. Aucun secret ne doit être restitué,
affiché, journalisé ou transmis au modèle.

Les mentions de chargement de variables dans cet inventaire décrivent
leur utilisation par les outils locaux. Elles n’accordent aucun droit
supplémentaire de consultation à l’agent, notamment pour les variables
d’authentification SSH, OpenCode ou PostgreSQL.

Les sondes système concernent le contexte d'exécution DIU.
Les outils DevOps sont interrogés avec les binaires indiqués dans leurs rubriques.
Les dépendances Python sont recherchées en priorité dans les venv du projet, puis dans le Python DevOps en repli explicite.
Dans l’inventaire Python, la flèche indique le Python sondé ; Installation indique le chemin observé dans les métadonnées.
Les dépendances Python attendues proviennent de [project].dependencies dans pyproject.toml.
Les outils de compilation Python éventuellement affichés proviennent de [build-system].requires et sont recherchés uniquement dans les venv du projet.
Les dépendances JavaScript sont regroupées par manifeste et catégorie sous NPM et OpenCode.
Leurs déclarations, versions verrouillées npm et métadonnées locales sont distinctes ; un verrou ne prouve pas une installation.
Les contraintes JavaScript ne sont pas résolues et cet inventaire ne prouve pas le chargement de plugins OpenCode.
Un inventaire multi-environnements ne valide pas un environnement Python unique.
Cet inventaire ne constitue pas une qualification fonctionnelle ni une preuve de réussite des tests du projet.

# Système d'exploitation

  * Debian GNU/Linux 13 (trixie)
  * hvp1.pixs.fr


# Matériel

## TPM

  * Chemin : indisponible (aucun périphérique TPM visible)
  * Version : indisponible (aucun périphérique TPM visible)
  * Fabricant : indisponible (aucun périphérique TPM visible)
  * Identifiant fournisseur : indisponible (aucun périphérique TPM visible)
  * Révision de spécification : indisponible (aucun périphérique TPM visible)
  * Registres PCR : indisponible (aucun périphérique TPM visible)


# Conteneur Docker, pour tests nécessitant des droits root

  * 29.1.2
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/docker
  * /var/run/docker.sock
  * debian:stable-slim
  * Accès TPM OK
  * Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests.


# OpenSSH & SSHPASS

  * 10.0p2
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/ssh
  * 1.10
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/sshpass


# Docker-Compose

  * 5.2.3
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/docker-compose


# Git

  * 2.47.9
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/git


# Go

  * 1.25.3
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/go/current/bin/go


# Node

  * 24.3.1
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/node/current/bin/node


# NPM

  * 11.5.2
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/node/current/bin/npm


# OpenCode

  * 1.2.8
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/.opencode/bin/opencode
  * La variable OPENCODE_PASSWORD pour l'API est chargée depuis project.env


# OpenSpec

  * 1.3.9
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/.local/npm/bin/openspec


# OpenSSL

  * 3.5.3
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/openssl


# PostgreSQL Client

  * 17.6
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/psql


# PostgreSQL Serveur

  * 16.4
  * database.example.test:5544
  * Les variables PostgreSQL sont chargées depuis project.env
  * PG_HOST PG_PORT PG_DATABASE PG_USERNAME PG_PASSWORD


# Python

  * 3.13.9
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/python/current/bin/python3
  * venv: disponible


# Python - Dépendances du projet - Source de vérité `pyproject.toml`

  * Recherche ou sonde des venv du projet non vérifiable : inventaire partiel.
  * missing-fixture : non vérifiable --> /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/python/current/bin/python3
    * Environnement : Python DevOps (repli)
    * Installation : non observée
  * global-fixture : 3.0 --> /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/python/current/bin/python3
    * Environnement : Python DevOps (repli)
    * Installation : /home/devops/datas/diu/.diu-test-devops-w_p2t73i/python-packages


# Python - Gestionnaire de paquets

  * 25.3.7
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/python/current/bin/pip3


# Prompts

  * Dossier des prompts : /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/datas/prompts
  * Index des prompts : /home/devops/datas/diu/.diu-test-devops-w_p2t73i/home/datas/prompts/INDEX.md


# Tests navigateurs extérieurs en mode headless

La détection ne vérifie pas le fonctionnement du mode headless.

## Chromium

  * 134.0.6998.88
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/chromium
  * Mode headless : --headless


## Firefox

  * 140.0.4esr
  * /home/devops/datas/diu/.diu-test-devops-w_p2t73i/host-bin/firefox
  * Mode headless : --headless
