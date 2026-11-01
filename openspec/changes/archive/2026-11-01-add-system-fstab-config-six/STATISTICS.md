# Statistiques — add-system-fstab-config-six

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-fstab-config-six`, code de lot non attribué.
- Décision confirmée : `SYSTEM_FSTAB_CONFIG6`, `STATIC`, `ENABLE`, scope
  `system`, défaut `NONE`, dans le même style que les cinq déclarations
  FSTAB précédentes.
- Quand `SYSTEM_FSTAB=1`, l’entrée 6 est ajoutée après l’entrée 5.
- La dernière affectation littérale historique `FSTAB_CONFIG6` est migrée si
  sa nouvelle déclaration n’existe pas déjà. Une syntaxe nécessitant une
  interprétation shell bloque le nettoyage sans mutation ni affichage.
- Suite complète : 694 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-fstab-config-six`.
- La nouvelle version du paquet et sa validation d’exécution dans CISMP
  attendent le prochain changement de version sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_fstab_config6.sh`.
- Tests : `tests/test_system_fstab.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-fstab/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-fstab/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n` sur le point d’entrée, le nettoyage et les six déclarations FSTAB :
  réussi.
- `shellcheck` sur ces mêmes scripts : réussi.
- `python3 -m py_compile tests/test_system_fstab.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_fstab.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 14 tests réussis.
- `python3 -B -m unittest discover -s tests` : 694 tests réussis, 2 ignorés.
- `openspec validate add-system-fstab-config-six --strict` : réussi avant
  archivage.
- `openspec validate system-fstab --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-fstab-config-six --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La sixième déclaration FSTAB, son ajout après CONFIG5 et la migration de
l’ancienne affectation sont testés et archivés. Les tests ciblés, la suite
complète, les contrôles shell et OpenSpec réussissent. La prochaine version
du paquet et la validation runtime dans CISMP restent à faire après le
changement de version sur hvp1. Le commit et les publications Git sont
rapportés dans la synthèse SCM, hors de ces statistiques. Le
`STATISTICS.md` global à la racine est absent ; il n’a pas été créé ici et le
prompt SGS devra être mandaté pour le générer.
