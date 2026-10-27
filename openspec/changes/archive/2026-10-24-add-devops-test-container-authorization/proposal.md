## Why

Le développeur autorise explicitement les agents de codage et les orchestrateurs
à préparer, exécuter, répéter et nettoyer les tests du projet dans les conteneurs
de test, avec droits root si nécessaire, sans approbation supplémentaire.
Cette autorisation doit figurer dans les deux rubriques DevOps générées.

## What Changes

- Ajouter comme dernière puce de chaque rubrique activée la formulation exacte
  validée par le développeur, limitée au conteneur et aux ressources de test.
- Conserver les conditions ENV_DEVOPS_TESTS_DOCKER=1 et ENV_DEVOPS_TESTS_LXC=1,
  l'ordre des sections, les sondes et le format documentaire 0.7.
- Adapter le générateur commun, les assertions existantes et la documentation.
- Ne modifier ni les règles de permissions des outils ou plateformes, ni les
  identifiants, services, conteneurs ou configurations réels.

## Capabilities

### Modified Capabilities

- `projects-template-devops` : dernière puce commune d'autorisation des tests.

## Impact

Sources : modules/projects/template.sh et tests/test_projects_template_devops.py.
Documentation : TECHNICAL.md, README.md et CHANGELOG.md.
Cycle OpenSpec : delta, synchronisation, archivage du seul change et rapport.
Aucun déploiement, effet Git ou mise à jour manuelle du DEVOPS.md réel.
