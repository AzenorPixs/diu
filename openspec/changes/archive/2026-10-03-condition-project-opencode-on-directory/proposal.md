## Why

`projects_template_openspec` initialise actuellement l'intégration OpenCode
dès que `OPENCODE=1`, même lorsque le projet ne contient pas de dossier
`.opencode`. Le développeur demande que l'absence de ce dossier équivaille
à `OPENCODE=0` pour le seul projet traité.

## What Changes

- Conditionner l'intégration d'initialisation à la présence du dossier
  `.opencode` et à `OPENCODE=1`.
- Utiliser une valeur effective locale : sans dossier `.opencode`, elle vaut
  0 même si la valeur configurée est absente ou invalide.
- Conserver `openspec update` pour un dossier OpenSpec existant, les contrôles
  de prérequis et l'exécution sous le compte DevOps.
- Couvrir les appels individuels et groupés ainsi que les aides `help` et `?`.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `projects-template-openspec`: Condition locale de présence du dossier OpenCode.

## Impact

`modules/projects/template.sh`, `lib/rid-help.sh`, `TECHNICAL.md`,
`tests/test_projects_template_openspec.py`, `tests/test_projects_template_all.py`
et `tests/test_rid_help.py` sont concernés. Les appelants existants, notamment
la création et les mises à jour groupées, bénéficient de la règle individuelle.
Aucune dépendance, migration, configuration persistante, opération Git ou
modification du traitement OpenSpec du domicile DevOps n'est prévue.

## Authorization

Le développeur a validé explicitement le périmètre autonome présenté dans la
conversation le 3 octobre 2026 : spécification préalable, implémentation,
tests, documentation, synchronisation et archivage du seul change ciblé.
