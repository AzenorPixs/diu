# Déclaration modulaire de SYSTEM_JOURNALD_KEEP_FREE

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`JOURNALD_KEEP_FREE: unbound variable`. Cette limite détermine l’espace libre
que journald doit laisser sur le système de fichiers.

## What Changes

- Déclarer `SYSTEM_JOURNALD_KEEP_FREE` en `STATIC`, `ENABLE`, scope `system`,
  défaut `1G`.
- Remplacer ses deux usages dans `SystemKeepFree` et `RuntimeKeepFree`.
- Migrer une ancienne valeur littérale simple `JOURNALD_KEEP_FREE` sans
  altération si la nouvelle variable n’est pas déjà configurée.
- Refuser les formes qui nécessitent une interprétation shell.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

`JOURNALD_MAX_USE` et les autres traitements journald ne sont pas modifiés.
Le défaut statique explicite est `1G`.

## Critères d’acceptation

1. La valeur absente persiste et exporte `SYSTEM_JOURNALD_KEEP_FREE=1G`.
2. Une valeur existante valide est conservée; une valeur invalide est refusée.
3. Une ancienne valeur littérale valide est transférée exactement et la
   nouvelle déclaration garde la priorité.
4. Les directives `SystemKeepFree` et `RuntimeKeepFree` utilisent le nouveau
   nom.
5. Tests, contrôles shell et validations OpenSpec réussissent.
