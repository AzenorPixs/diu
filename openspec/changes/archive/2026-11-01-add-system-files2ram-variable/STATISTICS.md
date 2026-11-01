# Statistiques — add-system-files2ram-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-files2ram-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_FILES2RAM`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- Une ancienne valeur littérale `FILES2RAM=0|1` est migrée si le nouveau nom
  n’est pas déjà défini. Une ancienne valeur `1` conserve le traitement
  existant, qui peut supprimer `/var/log/*` lorsque
  `/etc/tmpfiles.d/var2log.conf` est absent.
- Suite complète : 701 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-files2ram-variable`.
- La nouvelle version du paquet et sa validation d’exécution dans CISMP
  restent en attente de la prochaine publication sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_files2ram.sh`.
- Tests : `tests/test_system_files2ram.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-files2ram/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-files2ram/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_files2ram.sh` : réussi.
- `shellcheck` sur ces trois scripts : réussi.
- `python3 -m py_compile tests/test_system_files2ram.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_files2ram.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 16 tests réussis.
- `python3 -B -m unittest discover -s tests` : 701 tests réussis, 2 ignorés.
- `openspec validate add-system-files2ram-variable --strict` : réussi avant
  archivage.
- `openspec validate system-files2ram --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-files2ram-variable --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration `SYSTEM_FILES2RAM`, son consommateur et la migration historique
sont archivés. Les tests ciblés, la suite complète, les contrôles shell et
OpenSpec réussissent. La publication du nouveau paquet et l’exécution runtime
dans CISMP restent à effectuer après le changement de version sur hvp1. Le
commit et les publications Git sont rapportés dans la synthèse SCM, hors des
statistiques de réalisation. Le `STATISTICS.md` global de la racine est absent;
il n’a pas été créé ici et le prompt SGS devra être mandaté pour le générer.
