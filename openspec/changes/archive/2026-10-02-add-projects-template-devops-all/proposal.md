# DEV02 — Génération DevOps groupée

## Why

La génération DevOps par projet existe, mais nécessite une commande pour
chaque projet. Le développeur demande un traitement groupé des projets dont
project.env contient les cinq variables générales indiquées.

## What Changes

- Ajouter projects_template_devops_all et rid projects template all devops.
- Parcourir les dossiers directs de la même racine que la génération individuelle.
- Sélectionner les affectations littérales non vides PROJECT_ID, PROJECT_NAME,
  PROJECT_TYPE, PROJECT_DOCKERED et PROJECT_DEBIAN_PACKAGE, avec un ID conforme au dossier.
- Appeler la génération existante une fois par projet éligible, template inclus.
- Continuer après un échec et rendre un bilan avec code d'échec si nécessaire.
- Compléter toutes les aides et les tests ciblés.

## Capabilities

### Modified Capabilities

- projects-template-devops : sélection et génération groupée.
- rid-help : présentation de all et critères de sélection.

## Impact

modules/projects/template.sh, root-install-debian.sh, lib/rid-help.sh,
tests/test_projects_template_devops.py et tests/test_rid_help.py. Les appels
individuels et de création restent inchangés. all devient le sélecteur groupé
dans la commande publique. Aucun autre change, aucune opération Git, aucune
nouvelle dépendance ni installation.
