# Déclaration modulaire de SYSTEM_JOURNALD_MAX_USE

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`JOURNALD_MAX_USE: unbound variable`. Cette limite contrôle les tailles
maximales des journaux persistants et volatils.

## What Changes

- Déclarer `SYSTEM_JOURNALD_MAX_USE` en `STATIC`, `ENABLE`, scope `system`,
  défaut `500M`.
- Remplacer ses deux usages dans `SystemMaxUse` et `RuntimeMaxUse`.
- Migrer une ancienne valeur littérale simple `JOURNALD_MAX_USE` sans
  altération si la nouvelle variable n’est pas déjà configurée.
- Refuser les formes qui nécessitent une interprétation shell.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

`JOURNALD_KEEP_FREE` et les traitements existants de `journald.conf` ne sont
pas modifiés. Le défaut explicite de `500M` remplace l’absence de limite
configurée dans l’ancienne configuration DIU.

## Critères d’acceptation

1. La valeur absente persiste et exporte `SYSTEM_JOURNALD_MAX_USE=500M`.
2. Une valeur existante valide est conservée; une valeur invalide est refusée.
3. Une ancienne valeur littérale valide est transférée exactement et la
   nouvelle déclaration garde la priorité.
4. Les deux paramètres journald utilisent `SYSTEM_JOURNALD_MAX_USE`.
5. Tests, contrôles shell et validations OpenSpec réussissent.
