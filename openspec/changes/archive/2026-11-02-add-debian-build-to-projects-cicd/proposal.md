# Construction Debian dans la CI/CD générique

Code de lot : code non attribué ; attribution ultérieure par ACL.

## Why

Le flux générique ne construit pas de paquet Debian et quitte après les pushes
pour un projet sans Docker. Les publications doivent disposer du paquet construit
pour le projet lorsque PROJECT_DEBIAN_PACKAGE l'active.

## What Changes

- Afficher six étapes : commit, pushes, build Docker, build Debian, publications, bilan.
- Construire Debian uniquement pour Yes/YES/1, indépendamment de Docker.
- Ajouter la syntaxe build debian en conservant build deb comme alias.
- Réutiliser le builder déclaratif, la recette et la priorité PROJECT_VERSION.
- Conserver les capacités de publication existantes et les règles d'indisponibilité.
- Livrer sous 1.0.2 après qualification et archivage.

## Capabilities

### Modified Capabilities

- `projects-cicd`: orchestration, activation indépendante et bilan des deux builds.
- `projects-debian-build`: syntaxe debian et compatibilité deb.
- `rid-help`: aides des syntaxes et des six étapes.

## Impact

Routage, aides, orchestration/bilan, diagnostics du builder, tests et documentation.
Plan SCM-CICD-DEBIAN-20261102-R1 validé avec version 1.0.2 le 2026-11-02.
Aucune CI/CD réelle ni installation pendant les validations.
