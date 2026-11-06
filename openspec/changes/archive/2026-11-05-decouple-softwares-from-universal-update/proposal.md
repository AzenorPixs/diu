# Dissocier la mise à jour des logiciels du parcours général

## Pourquoi
`diu update` lance actuellement `diu softwares update`, ce qui couple deux opérations que le développeur souhaite indépendantes.

## Changements
Retirer le module logiciels du parcours général, préserver sa commande directe et les phases système, notamment Codex CLI, et adapter aides, documentation et tests.

## Capacités modifiées
- `universal-update` : ordre et codes de retour sans logiciels.
- `software-management` : commande directe préservée et parcours général corrigé.
- `system-update-engines` : Codex CLI exécuté dans la phase système.
- `diu-help` : aides des deux parcours.

## Impact
Les mises à jour propres aux logiciels ne sont plus déclenchées par `diu update`. La phase système conserve ses opérations propres. Aucun changement de configuration ou migration.
