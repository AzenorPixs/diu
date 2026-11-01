# Déclaration modulaire de FSTAB et de ses entrées

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`FSTAB: unbound variable` à la ligne 2288. Le point d’entrée utilise aussi
`FSTAB_CONFIG1` à `FSTAB_CONFIG5` pour ses entrées de montage, dont le
traitement FILES2RAM.

## What Changes

- Déclarer `SYSTEM_FSTAB` en `STATIC`, `ENABLE`, scope `system`, défaut `0`.
- Déclarer `SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG5` en `STATIC`,
  `ENABLE`, scope `system`, défaut `NONE`.
- Renommer les consommateurs exacts en préservant leurs effets lorsque le
  drapeau est activé.
- Migrer les anciennes affectations littérales simples vers leurs nouveaux
  noms lorsque ceux-ci ne sont pas déjà configurés.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Le change ne réorganise pas les opérations FSTAB ni FILES2RAM. Une valeur
historique `FSTAB=1` peut toujours déclencher les écritures existantes dans
`/etc/fstab`. La construction et le changement de version du paquet sur hvp1
restent dans l’étape de livraison ultérieure.

## Critères d’acceptation

1. Les six variables ont leurs déclarations statiques et valeurs par défaut
   validées.
2. Les consommateurs exacts utilisent les nouveaux noms et restent sans
   erreur de variable non définie en cas d’absence.
3. Les valeurs historiques littérales sont migrées sans exécuter ni afficher
   `variables.sh`; les formes ambiguës bloquent sans mutation.
4. Les effets FSTAB et FILES2RAM existants restent inchangés pour des valeurs
   configurées équivalentes.
5. Les tests ciblés, contrôles shell et validation OpenSpec réussissent.
