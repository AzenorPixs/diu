# Proposition

## Why

Une reprise CI/CD avec une version déjà publiée échoue alors qu'aucune nouvelle publication ne devrait être nécessaire. Les versions horodatées peuvent également masquer les versions stables dans les sélections de DIU.

## What Changes

- Accepter une version stable facultative pour le CI/CD et mettre à jour PROJECT_VERSION avant le traitement.
- Rendre les reprises et publications idempotentes, sans déplacer de tag ni écraser un artefact.
- Donner priorité aux versions stables dans les sélections DIU, sans epoch Debian.
- Sauvegarder puis retirer les tags et releases DIU horodatés en 2026 du périmètre autorisé.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `project-version`: sélection et idempotence des versions.
- `projects-cicd`: version facultative et reprise du flux.
- `diu-package-update`: priorité des versions stables lors de la sélection.
- `forgejo-release`: reprise d'une publication Debian existante.
- `projects-github-debian-release`: reprise d'une publication Debian existante.
- `implement-projects-gitlab-release`: reprise d'une publication existante.
- `projects-debian-build`: priorité des tags stables pour la construction générique.
- `deb-package`: priorité des tags stables pour la construction historique.

## Impact

Modules projets et mise à jour DIU, aides, tests, documentation, spécifications et références Git et releases DIU locales et distantes. La comparaison native dpkg/APT reste inchangée.
