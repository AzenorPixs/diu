# Conception — SYSTEM_FSTAB_CONFIG6

## Décisions

- Ajouter `modules/diu/variables/system/system_fstab_config6.sh`,
  `STATIC`, `ENABLE`, scope `system`, défaut `NONE`.
- Ajouter un seul bloc append dans le point d’entrée, immédiatement après le
  traitement `SYSTEM_FSTAB_CONFIG5`, sous le garde `SYSTEM_FSTAB=1`.
- Étendre le parseur de migration existant pour accepter le littéral
  `FSTAB_CONFIG6` et persister `SYSTEM_FSTAB_CONFIG6` avant de supprimer
  l’affectation historique.
- Une déclaration `SYSTEM_FSTAB_CONFIG6` déjà présente dans `system.env`
  prévaut. Une valeur historique non littérale bloque sans affichage ni
  modification des fichiers.

## Effets et repli

Avec `SYSTEM_FSTAB=0`, cette entrée n’est pas écrite. Avec `SYSTEM_FSTAB=1`,
elle est ajoutée après les cinq entrées connues; l’ancien et le nouveau
comportement restent ainsi ordonnés. La migration est réversible en restaurant
la valeur dans `variables.sh` ou en supprimant sa déclaration de `system.env`.
