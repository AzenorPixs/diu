## Why

La génération DevOps ne cible actuellement que le modèle template. Chaque
projet doit pouvoir actualiser sa propre documentation, y compris à la fin
de sa création.

## What Changes

- Remplacer la commande par rid projects template <ID PROJECT> devops.
- Cibler le projet sous DEVOPS_PROJECTS_ROOT, avec repli vers le domicile DevOps/datas.
- Utiliser ses fichiers project.env et pyproject.toml ; adapter le titre.
- Créer le manifeste Python minimal absent uniquement pour PROJECT_TYPE=PYTHON.
- Compléter les deux dernières lignes de référence PostgreSQL.
- Appeler la génération à la fin de create_project et gérer son échec.
- Adapter les aides et tests, puis synchroniser et archiver ce seul change.

## Capabilities

### Modified Capabilities

- projects-template-devops : génération par projet et intégration à la création.
- rid-help : syntaxe avec identifiant et aides de création.

## Impact

modules/projects/template.sh, modules/projects/projects.sh, root-install-debian.sh,
lib/rid-help.sh, tests/test_projects_template_devops.py, tests/test_rid_help.py
et les tests de création dans tests/test_projects.py. Ancienne syntaxe rejetée.
Aucune nouvelle dépendance ou opération Git. Les autres changes actifs restent
hors périmètre.
