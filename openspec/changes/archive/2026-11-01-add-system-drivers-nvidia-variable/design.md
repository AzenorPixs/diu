# Conception — SYSTEM_DRIVERS_NVIDIA

## Décisions

- Ajouter `modules/diu/variables/system/system_drivers_nvidia.sh` avec
  `config=STATIC`, `state=ENABLE`, `scope=system` et `default_value=0`.
- Remplacer les six références de la variable booléenne exacte par
  `SYSTEM_DRIVERS_NVIDIA` avec un repli désactivé lorsque la variable est
  absente. Ne pas renommer d’autres options NVIDIA, dont `SYSTEM_APT_NVIDIA`.
- Étendre `config_cleanup` pour transférer la dernière affectation simple
  littérale `DRIVERS_NVIDIA=0|1` vers `/root/diu/config/system.env` avant de
  retirer l’affectation historique. Une déclaration `SYSTEM_DRIVERS_NVIDIA`
  déjà présente prévaut.
- Une affectation historique non littérale ou ambiguë bloque le nettoyage
  sans exposer son contenu ni modifier les fichiers.
- Une migration est réversible : la valeur persistée dans `system.env` permet
  de restaurer l’affectation historique, ou l’opérateur peut modifier la
  valeur persistée avant la prochaine exécution.

## Risques

La migration d’une ancienne valeur `1` conserve l’activation des traitements
NVIDIA existants, qui peuvent installer des paquets et configurer DKMS, des
modules noyau ou Docker. Une absence d’ancienne valeur utilise le défaut `0`.
