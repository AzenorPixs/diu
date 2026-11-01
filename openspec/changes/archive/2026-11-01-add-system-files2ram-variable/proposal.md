# Déclaration modulaire de SYSTEM_FILES2RAM

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`FILES2RAM: unbound variable`. Ce drapeau active la configuration des
journaux en mémoire et le traitement FSTAB correspondant.

## What Changes

- Déclarer `SYSTEM_FILES2RAM` en `STATIC`, `ENABLE`, scope `system`, défaut `0`.
- Remplacer le consommateur exact de `FILES2RAM` dans le point d’entrée.
- Migrer une ancienne affectation littérale `FILES2RAM=0|1` si le nouveau nom
  n’est pas déjà configuré.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Les traitements existants sous la valeur `1` ne sont pas réorganisés. Ils
peuvent supprimer le contenu de `/var/log/*` lorsque
`/etc/tmpfiles.d/var2log.conf` est absent, puis configurer les journaux en
mémoire. La construction/version du paquet sur hvp1 reste une étape de
livraison ultérieure.

## Critères d’acceptation

1. La déclaration persiste et exporte `SYSTEM_FILES2RAM=0` par défaut.
2. Le consommateur traite une variable absente comme désactivée, sans erreur.
3. Une ancienne valeur littérale `0` ou `1` est migrée sans afficher ni
   exécuter `variables.sh`; une forme ambiguë bloque sans mutation.
4. Les traitements existants pour la valeur `1` sont conservés.
5. Les tests ciblés, contrôles shell et validations OpenSpec réussissent.
