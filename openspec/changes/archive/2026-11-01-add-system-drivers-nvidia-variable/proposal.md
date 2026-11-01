# Déclaration modulaire de SYSTEM_DRIVERS_NVIDIA

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`DRIVERS_NVIDIA: unbound variable` à la ligne 2102. Le drapeau est aussi
consommé dans cinq blocs du point d’entrée pour le pilote, les modules noyau,
les fichiers temporaires et le runtime Docker.

## What Changes

- Déclarer `SYSTEM_DRIVERS_NVIDIA` en `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- Renommer les six références exactes au drapeau historique dans le point
  d’entrée, en préservant les comportements activés lorsque sa valeur vaut
  `1` et en ignorant ces traitements lorsque la valeur vaut `0` ou est absente.
- Migrer les anciennes valeurs littérales `DRIVERS_NVIDIA=0|1` vers
  `SYSTEM_DRIVERS_NVIDIA` si cette dernière n’est pas déjà configurée.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Le change ne modifie ni l’installation NVIDIA activée par la valeur `1`, ni
les choix de dépôts et de noyau, ni le runtime Docker hors du drapeau. La
construction et le changement de version du paquet sur hvp1 restent dans
l’étape de livraison ultérieure.

## Critères d’acceptation

1. La déclaration persiste et exporte `SYSTEM_DRIVERS_NVIDIA=0` par défaut.
2. Les six consommateurs ne référencent plus directement `DRIVERS_NVIDIA`.
3. Une ancienne valeur littérale est migrée sans exécuter ni afficher
   `variables.sh`; une valeur ambiguë bloque avant mutation.
4. Les traitements existants sous la valeur `1` et les autres options de
   configuration sont préservés.
5. Les tests ciblés, contrôles shell et validation OpenSpec réussissent.
