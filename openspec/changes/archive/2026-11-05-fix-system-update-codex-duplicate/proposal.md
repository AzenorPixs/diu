# Supprimer le doublon Codex CLI du bilan système

Code non attribué ; attribution ultérieure par ACL.

## Why
La recette GitHub et le bilan système affichent tous deux le résultat de Codex CLI, créant une ligne redondante.

## What Changes
Dans `diu system update`, conserver une seule ligne par logiciel avec sa version actuelle ou ses versions avant et après, et restituer les diagnostics en cas d'échec. Les commandes logicielles directes gardent leurs sorties.

## Capabilities
- `system-update-report` : une ligne de bilan Codex CLI sans perte des diagnostics.
