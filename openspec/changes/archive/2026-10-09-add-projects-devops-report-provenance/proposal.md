# DEV06 — Provenance et horodatage du relevé DevOps

## Why

DEVOPS.md est régénéré sans origine explicite, horodatage ni classification de son contexte. Un inventaire actuel peut être confondu avec une qualification historique ou avec un autre environnement Python.

## What Changes

- Produire la version documentaire 0.3, avec provenance DIU, début du relevé UTC et classification SYSTEM_DEBIAN_ENVIRONNEMENT.
- Ajouter une légende distinguant sondes hôte/DevOps, dépendances attendues et qualification fonctionnelle.
- Capturer l'horodatage une seule fois sous une borne de 15 secondes ; conserver l'ancien document si cette préparation échoue.
- Conserver le contenu technique à observations identiques hors horodatage, les interfaces, rubriques, droits, propriétaires et sondes existantes.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- projects-template-devops : métadonnées, portée informative et version documentaire 0.3.

## Impact

Code : modules/projects/template.sh. Tests : tests/test_projects_template_devops.py. Documentation : TECHNICAL.md, README.md et CHANGELOG.md. Aucune nouvelle dépendance, configuration, installation, commande Git ou génération sur un projet réel. Les documents prennent le nouveau format à leur prochaine génération normale. Synchroniser puis archiver ce change après les preuves ; produire STATISTIQUES.md avec les mesures observées et N/A motivé pour les mesures indisponibles.

## Autorisation

Le développeur a validé le périmètre SCM, la création de ce change dédié malgré les changes actifs préexistants, son implémentation, ses validations et son archivage. Il a demandé explicitement Version : 0.3. Les autres changes restent hors périmètre.
