# ART07 — Orchestration CI/CD des projets

## Why

Les publications d'un projet nécessitent aujourd'hui plusieurs commandes et
peuvent déclencher une reconfiguration interactive lorsque la configuration
d'un fournisseur est incomplète. Une commande unique doit enchaîner le commit,
les publications configurées, la construction Docker et les releases sans
demander de configuration au cours du flux.

## What Changes

- Ajouter `rid projects cicd <ID PROJECT>` et sa fonction d'orchestration.
- Exécuter le commit, puis les pushes Forgejo, GitLab et GitHub uniquement
  lorsque leur configuration distante est complète.
- Construire l'image Docker seulement lorsque `PROJECT_DOCKERED=Yes`.
- Publier les releases Forgejo, GitLab et GitHub uniquement lorsque la
  configuration correspondante est complète et que le projet est Dockerisé.
- Ajouter la release GitHub : elle publie l'image locale déjà construite vers
  `ghcr.io/<REMOTE_GITHUB_OWNER>/<REMOTE_GITHUB_REPOSITORY>` ; elle ne lance
  jamais elle-même une construction Docker.
- Documenter la commande et la release GitHub dans les aides contextuelles.

## Capabilities

### New Capabilities

- `projects-cicd`: orchestration conditionnelle de la CI/CD d'un projet.
- `implement-projects-github-release`: publication Docker vers GitHub
  Container Registry.

### Modified Capabilities

- `implement-projects-github-push`: aide de la release GitHub.

## Impact

- `modules/projects/git.sh` et `root-install-debian.sh` pour le flux et le
  routage.
- `lib/rid-help.sh` pour les aides.
- `tests/test_projects.py` et `tests/test_rid_help.py` pour les scénarios
  isolés.
