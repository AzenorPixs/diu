# Ajout de SYSTEM_FSTAB_CONFIG6

## Why

Le change archivé `add-system-fstab-configuration` a déclaré
`SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG5`. Le développeur a confirmé que
la sixième variable historique s’appelle `FSTAB_CONFIG6` et a demandé son
ajout à la même série.

## What Changes

- Déclarer `SYSTEM_FSTAB_CONFIG6` avec le même contrat que les cinq entrées
  précédentes : `STATIC`, `ENABLE`, scope `system`, défaut `NONE`.
- Quand `SYSTEM_FSTAB=1`, ajouter cette sixième entrée après
  `SYSTEM_FSTAB_CONFIG5` dans le bloc explicite qui écrit `/etc/fstab`.
- Migrer l’ancienne affectation littérale `FSTAB_CONFIG6` vers son nouveau
  nom si celui-ci n’est pas déjà configuré.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Les cinq entrées précédentes et leur historique archivé ne sont pas modifiés.
La nouvelle entrée n’est écrite que lorsque `SYSTEM_FSTAB` vaut `1` et sa
valeur n’est pas `NONE`. Le changement de version du paquet sur hvp1 reste
dans l’étape de livraison suivante.

## Critères d’acceptation

1. `SYSTEM_FSTAB_CONFIG6` est déclarée selon le contrat approuvé.
2. La valeur non `NONE` est écrite après `SYSTEM_FSTAB_CONFIG5` uniquement
   lorsque `SYSTEM_FSTAB=1`.
3. L’ancienne valeur littérale est migrée sans exécuter ni afficher
   `variables.sh`; une forme ambiguë bloque le nettoyage sans mutation.
4. Les cinq entrées existantes et les autres opérations FSTAB sont préservées.
5. Les tests ciblés, contrôles shell et validations OpenSpec réussissent.
