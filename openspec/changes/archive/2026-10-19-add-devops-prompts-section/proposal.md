## Why

Le document DevOps ne donne pas l'emplacement des prompts communs ni de leur
index. Ces deux chemins doivent suivre le compte défini par ENV_DEVOPS_USER.

## What Changes

- Ajouter une rubrique Prompts avant les tests navigateurs, avec le dossier
  /home/${ENV_DEVOPS_USER}/datas/prompts et son fichier INDEX.md.
- Passer la version documentaire de 0.5 à 0.6.
- Conserver les sondes, les interfaces, les permissions et l'ordre relatif
  des rubriques existantes. Ne pas lire ni créer les ressources Prompts.

## Capabilities

### Modified Capabilities

- `projects-template-devops`: rubrique Prompts et version documentaire 0.6.

## Impact

Le générateur commun modules/projects/template.sh, ses tests ciblés,
TECHNICAL.md, README.md et CHANGELOG.md sont concernés. Aucun ajout de
dépendance, migration, accès réseau ou changement Git n'est nécessaire.
Les documents existants adoptent le nouveau format à leur prochaine génération.
