# Préparer les droits d'exécution des outils DevOps

## Why

Un outil DevOps présent sans droit d'exécution est actuellement affiché comme
« binaire absent ». Une perte de ces droits, notamment sur OpenCode, empêche
le relevé de sa version et peut aussi empêcher les inventaires Python.

## What Changes

- Préparer les sept chemins DevOps connus avant les inventaires et les sondes.
- Ajouter les seuls droits d'exécution manquants aux fichiers présents.
- Accepter les liens dont la cible reste dans le domicile DevOps et refuser
  les cibles externes ou les objets non ordinaires.
- Préserver le document précédent si la préparation échoue ; distinguer
  absence du fichier et absence de droit d'exécution dans les sondes.
- Conserver les outils hôte, les autres fichiers et les interfaces existantes.

## Impact

- Capacité concernée : `projects-template-devops`.
- Code : `modules/projects/template.sh` ; tests isolés dans le dépôt.
- Documentation : `TECHNICAL.md`, `README.md`, `CHANGELOG.md`.
- Aucun déploiement, installation, changement Git ou modification des outils
  réellement installés pendant cette session SCM.
- À l'exécution future, les droits déjà ajoutés ne sont pas annulés si une
  étape suivante échoue. Aucune modification des propriétaires ni des droits
  de lecture et d'écriture n'est prévue.
