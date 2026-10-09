## Why

Le relevé DevOps ignore les dépendances JavaScript propres aux projets. Pixs possède un frontend et un manifeste OpenCode distincts ; les versions des outils Node/npm/OpenCode ne décrivent pas ces paquets.

## What Changes

- Produire le format documentaire 0.5 avec inventaires par manifeste sous NPM et OpenCode.
- Découvrir les manifestes de sources et workspaces, avec exception ciblée .opencode/package.json et exclusions des ressources générées.
- Distinguer contraintes déclarées, verrous npm 2/3 et métadonnées d'installation confinées au projet.
- Conserver des diagnostics explicites et une collecte passive, bornée et sans divulgation de références sensibles.

## Capabilities

### Modified Capabilities

- projects-template-devops : inventaire JavaScript par composant et provenance des trois états.

## Impact

Fichiers concernés : modules/projects/template.sh, tests/test_projects_template_devops.py, TECHNICAL.md, README.md, CHANGELOG.md et spécification projects-template-devops. Les projets gérés recevront le format lors de leur prochaine génération normale.

## Non-goals

Aucune installation, mise à niveau, modification de Pixs, configuration OpenCode, import de paquet, résolution SemVer ou qualification fonctionnelle. Les formats de verrou autres que npm 2/3 sont identifiés sans analyse de leurs versions.
