# Statistiques — add-system-fstab-configuration

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-fstab-configuration`, code de lot non attribué.
- Décisions validées : `SYSTEM_FSTAB` en `STATIC`, `ENABLE`, scope `system`,
  défaut `0`; `SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG5` avec les mêmes
  attributs et défaut `NONE`.
- Les anciennes affectations littérales simples sont migrées vers les nouveaux
  noms si ceux-ci ne sont pas déjà configurés. Les syntaxes qui nécessitent une
  interprétation shell bloquent le nettoyage sans mutation ni affichage.
- Le comportement FSTAB activé et l’usage de `SYSTEM_FSTAB_CONFIG1` par
  FILES2RAM sont préservés. Une ancienne valeur `FSTAB=1` continue d’autoriser
  les écritures existantes dans `/etc/fstab`.
- Suite complète : 694 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-fstab-configuration`.
- La nouvelle version du paquet et sa validation d’exécution dans CISMP
  restent en attente du prochain changement de version sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

23 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_fstab.sh`,
  `system_fstab_config1.sh` à `system_fstab_config5.sh`.
- Tests : `tests/test_system_fstab.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-fstab/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-fstab/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/diu/variables/system/system_fstab.sh modules/diu/variables/system/system_fstab_config1.sh modules/diu/variables/system/system_fstab_config2.sh modules/diu/variables/system/system_fstab_config3.sh modules/diu/variables/system/system_fstab_config4.sh modules/diu/variables/system/system_fstab_config5.sh modules/system/variables-cleanup.sh` : réussi.
- `shellcheck` sur le point d’entrée, les six déclarations et le nettoyage :
  réussi.
- `python3 -m py_compile tests/test_system_fstab.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_fstab.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 14 tests réussis.
- `python3 -B -m unittest discover -s tests` : 694 tests réussis, 2 ignorés.
- `openspec validate add-system-fstab-configuration --strict` : réussi avant
  archivage.
- `openspec validate system-fstab --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-fstab-configuration --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Les six déclarations, le drapeau FSTAB, les cinq variables de configuration
et leur migration historique sont archivés. La suite complète, les tests
ciblés, les contrôles shell et OpenSpec réussissent. La prochaine version du
paquet et l’exécution runtime dans CISMP restent à effectuer après le
changement de version sur hvp1. Le commit et les publications Git sont
rapportés dans la synthèse SCM, hors des statistiques de réalisation. Le
`STATISTICS.md` global de la racine est absent ; il n’a pas été créé ici et le
prompt SGS devra être mandaté pour le générer.
