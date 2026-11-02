# Priorité de PROJECT_VERSION pour les artefacts et Git

Code de lot : code non attribué ; attribution ultérieure par ACL.

## Why

Les commits, tags, builds et publications choisissent actuellement des versions
par des mécanismes indépendants. PROJECT_VERSION doit devenir la source prioritaire
optionnelle, sans modifier les comportements des projets qui ne la déclarent pas.

## What Changes

- Lire PROJECT_VERSION littéralement et isolément dans project.env, format x.y.z.
- Donner priorité à cette version pour Git, Debian, Docker et leurs publications.
- Conserver intégralement les mécanismes précédents lorsque la clé est absente.
- Refuser une valeur présente invalide et les collisions de tags sans forçage.
- Livrer le DIU sous 1.0.0, déjà déclaré, et documenter les aides.

## Capabilities

### New Capabilities

- `project-version`: lecture, priorité, conventions et cohérence transversale.

### Modified Capabilities

- `deb-package`: priorité sur les tags pour le constructeur historique.
- `projects-debian-build`: priorité sur la version de recette et les tags.
- `forgejo-release`: cohérence de la version du paquet et de sa publication.
- `modify-projects-docker-build`: image versionnée et latest.
- `rid-help`: version optionnelle et règles de repli.

## Impact

Librairie partagée, routage, modules Git/Debian/Docker et release, tests isolés,
documentation et maintenance ciblée de navigation. Plan SCM-PROJECT-VERSION-20261102-R1
validé le 2 novembre 2026. Aucun déploiement système ni migration d'autres projets.
