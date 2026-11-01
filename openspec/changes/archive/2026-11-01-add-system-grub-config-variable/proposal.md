# Déclaration modulaire de SYSTEM_GRUB_CONFIG

## Why

L’exécution de `root-install-debian.sh` dans CISMP échoue sur
`GRUB_CONFIG: unbound variable`. Le contrôle GRUB historique n’est pas encore
déclaré dans le système modulaire de variables.

## What Changes

- Déclarer `SYSTEM_GRUB_CONFIG` en `STATIC`, `ENABLE`, scope `system`, défaut
  `0`.
- Remplacer le consommateur historique dans le point d’entrée.
- Migrer la dernière valeur littérale `GRUB_CONFIG=0|1` vers le nouveau nom
  avant de supprimer l’affectation historique, sauf si le nouveau nom est déjà
  configuré.
- Bloquer le nettoyage si une ancienne affectation nécessite une interprétation
  shell.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Le traitement existant de `GRUB_CMDLINE_LINUX_DEFAULT`, `sed` et
`update-grub` n’est pas modifié. Aucune nouvelle option de noyau n’est ajoutée.

## Critères d’acceptation

1. La déclaration persiste et exporte `SYSTEM_GRUB_CONFIG=0` lorsqu’aucune
   valeur n’existe.
2. Une valeur historique simple, y compris `1`, est transférée sans être
   exécutée ni affichée ; le nouveau nom déjà déclaré reste prioritaire.
3. Une affectation ambiguë bloque sans mutation ni exposition de son contenu.
4. Le consommateur utilise `SYSTEM_GRUB_CONFIG` avec un repli désactivé.
5. Les tests ciblés, contrôles shell et validations OpenSpec réussissent.
