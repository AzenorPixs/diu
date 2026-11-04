# Publication Debian GitHub selon les conditions Forgejo

Code de lot : code non attribué ; attribution ultérieure par ACL.

## Why

La CI/CD construit et publie le paquet Debian sur Forgejo mais ignore GitHub
sans Docker. La commande github release doit publier les artefacts activés
avec les mêmes conditions de publication Debian que Forgejo.

## What Changes

- Ajouter la publication du .deb dans une release GitHub, activation Yes/YES/1.
- Partager la sélection de version existante, sans déplacer les tags ni remplacer une release.
- Exposer Docker, Debian et les deux via projects_github_release et la CLI existante.
- Intégrer Debian seul et le parcours mixte à l'étape 5 et au bilan CI/CD.
- Conserver la publication GHCR existante dans un helper Docker dédié.
- Livrer 1.0.3, avec écriture filtrée de PROJECT_VERSION uniquement.

## Capabilities

### New Capabilities

- `projects-github-debian-release`: contrôles, création de release et upload binaire.

### Modified Capabilities

- `implement-projects-github-release`: sélection Docker/Debian et compatibilité GHCR.
- `projects-cicd`: publication GitHub Debian à l'étape 5.
- `rid-help`: aides Docker et Debian.

## Impact

Module Git, nouveau module de publication, transport GitHub, chargement et aides,
tests, cinq documents de référence, cartographie et registre ciblés.
Plan SCM-GITHUB-DEBIAN-20261102-R1 validé le 2026-11-02, version 1.0.3.
Le Purpose du canon GitHub sera élargi lors de la synchronisation autorisée.
Aucune publication réelle d'artefact pendant les validations.
