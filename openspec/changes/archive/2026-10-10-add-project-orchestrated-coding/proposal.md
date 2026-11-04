# PRJ12 — Déclaration du mode de codage des projets

## Why

Les projets DIU ne déclarent pas leur mode de développement. Les fonctions
qui en ont besoin doivent pouvoir distinguer le codage autonome du codage
piloté par un orchestrateur, sans invalider les configurations existantes.

## What Changes

- Ajouter `PROJECT_ORCHESTRATED_CODING=Yes|No` aux variables générales.
- Demander cette valeur à la création et à la mise à jour ciblée, ainsi que
  dans le parcours historique de configuration du clonage distant.
- Proposer la valeur enregistrée, sinon `No`, et refuser les autres valeurs.
- Fournir un lecteur commun avec défaut `No` lorsque la variable est absente,
  sans exécuter le fichier de configuration ni hériter d'un autre projet.
- Préserver cette variable lors des réécritures historiques de configuration.

## Capabilities

### Modified Capabilities

- `implement-projects-update`: mode de développement, questionnement,
  persistance et lecture rétrocompatible.
- `projects-general-update`: autoriser la nouvelle question dans la mise à
  jour ciblée tout en conservant le routage et le traitement général.

## Impact

Périmètre validé par le développeur : `modules/projects/projects.sh`,
`modules/projects/git.sh`, `tests/test_projects_orchestrated_coding.py`,
`TECHNICAL.md`, `README.md`, `CHANGELOG.md`, les deux spécifications concernées
et ce change jusqu'à son archivage et son rapport `STATISTIQUES.md`.
Aucune dépendance, migration globale, opération Git, activation de service ou
modification des fichiers locaux réels des projets. Les anciens projets
reçoivent l'affectation lors de leur prochaine mise à jour interactive.
