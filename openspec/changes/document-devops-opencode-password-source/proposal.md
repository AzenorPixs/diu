# Indication de la source du mot de passe API OpenCode

## Why

La génération de DEVOPS.md ne précise pas la provenance de la variable du mot de passe API OpenCode, alors que cette information est attendue dans la rubrique OpenCode.

## What Changes

- Ajouter après le chemin du binaire la puce exacte : « La variable OPENCODE_PASSWORD pour l'API est chargée depuis project.env ».
- Émettre ce texte statique sans consulter la variable ni lire project.env pour cet ajout.
- Conserver le format 0.7, les versions sondées, les chemins et les inventaires existants.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `projects-template-devops` : précision documentaire dans la rubrique OpenCode.

## Impact

Rendu commun dans modules/projects/template.sh, test isolé existant, TECHNICAL.md et CHANGELOG.md. Les parcours individuel, groupé et de création partagent ce rendu. Aucun chargement de mot de passe ni changement d'authentification ; les documents existants adoptent la puce à leur prochaine génération normale. Le DEVOPS.md local contient déjà la phrase et reste préservé.

Périmètre autonome validé : spécification, implémentation, tests, documentation, synchronisation, archivage et rapport, puis clôture Git conditionnelle SCM. Aucun autre change n'est concerné.
