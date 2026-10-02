## Why

Le fichier DEVOPS.md du modèle contient des versions saisies manuellement,
parfois différentes de celles des outils réellement disponibles. Une commande
dédiée doit vérifier ces informations et distinguer les outils hôte des outils
installés dans l'environnement de l'utilisateur DevOps.

## What Changes

- Ajouter `projects_template_devops`, appelée par `rid projects template devops`.
- Générer ou actualiser uniquement `/home/${ENV_DEVOPS_USER}/datas/template/DEVOPS.md`.
- Reprendre la structure du modèle et sa version documentaire 0.2.
- Relever versions, chemins des exécutables, disponibilité de venv et
  dépendances déclarées dans pyproject.toml.
- Vérifier la version du serveur PostgreSQL configuré par project.env sans
  publier les valeurs sensibles de cette configuration.
- Signaler explicitement les informations indisponibles et le dossier absent.
- Ajouter les aides contextuelles correspondantes.

## Capabilities

### New Capabilities

- `projects-template-devops`: Génération vérifiée de la documentation DevOps du modèle.

### Modified Capabilities

- `rid-help`: Aide de la nouvelle commande et de son contexte template.

## Impact

Nouveau module `modules/projects/template.sh`, chargement et routage dans
root-install-debian.sh, aide dans lib/rid-help.sh et tests ciblés. Aucun projet
existant, outil installé, dépôt Git ou autre change actif n'est modifié.
