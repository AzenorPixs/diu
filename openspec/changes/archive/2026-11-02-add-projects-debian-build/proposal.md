# Construction Debian générique par recette de projet

Code de lot : code non attribué ; attribution ultérieure par ACL.

## Why

Le constructeur historique impose le nom diu et les sources propres au DIU.
Les autres projets ont besoin d'une recette publique qui définit leur paquet.

## What Changes

- Ajouter `rid projects build deb <ID PROJECT>` et son aide avant bootstrap.
- Lire uniquement PROJECT_DEBIAN_PACKAGE dans project.env, sans exécution.
- Construire depuis build/debian-package.json, sans embarquer la recette.
- Livrer une recette DIU équivalente au constructeur historique.
- Préserver projects deb et cicddiu, sans migration des autres projets.

## Capabilities

### New Capabilities

- `projects-debian-build`: construction générique à partir de métadonnées et de copies déclaratives.

### Modified Capabilities

- `rid-help`: aide et syntaxe de projects build deb.

## Impact

Routage, aide, nouveau moteur Bash utilisant jq déjà requis, recette DIU,
tests isolés, documentation et maintenance ciblée de la cartographie.
Plan SCM-PROJECTS-BUILD-DEB-20261102-R1 validé le 2 novembre 2026.
