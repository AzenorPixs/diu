# Conception — Déclaration système FSTAB

## Décisions

- Ajouter six déclarations unitaires sous
  `modules/diu/variables/system/` : `SYSTEM_FSTAB` et
  `SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG5`.
- Utiliser `STATIC`, `ENABLE`, scope `system`; défaut `0` pour le drapeau et
  `NONE` pour chacune des cinq lignes.
- Renommer le consommateur du drapeau et les huit références aux cinq
  variables de configuration. Un drapeau absent utilise `0`; une entrée
  absente utilise `NONE`.
- Migrer dans `config_cleanup` les affectations simples de `FSTAB=0|1` et
  `FSTAB_CONFIG1` à `FSTAB_CONFIG5`, sauf si leur nouveau nom est déjà déclaré
  dans `system.env`.
- Pour les entrées FSTAB, accepter les valeurs littérales non vides ou vides,
  simples non quotées ou entourées d’une paire de guillemets simples/doubles.
  Refuser les expansions ou syntaxes shell ambiguës sans mutation ni affichage.
- Persister toutes les nouvelles valeurs avant de supprimer les anciennes
  lignes. Une panne intermédiaire conserve les anciennes affectations; les
  valeurs déjà persistées permettent une reprise idempotente.

## Effets et risque

Le défaut `SYSTEM_FSTAB=0` évite l’activation implicite du bloc explicite.
Une ancienne valeur `FSTAB=1` est conservée et peut donc maintenir les écritures
existantes dans `/etc/fstab`. Les valeurs `FSTAB_CONFIG1` à `FSTAB_CONFIG5`
restent des données littérales de configuration et ne sont jamais affichées
par le nettoyage.
