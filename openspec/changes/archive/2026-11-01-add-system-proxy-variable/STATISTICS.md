# Statistiques — add-system-proxy-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-proxy-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_PROXY`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- La migration historique ne transfère que les affectations littérales
  `PROXY=0|1`, respecte une déclaration `SYSTEM_PROXY` déjà présente et
  bloque les formes ambiguës sans les afficher.
- Tests de la suite complète : 679 réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-proxy-variable`.
- L’archivage a émis un avertissement non bloquant : `proposal.md` ne reprend
  pas les en-têtes `Why` et `What Changes` du modèle. Les deltas et
  spécifications canoniques sont valides ; les deux validations strictes
  canoniques réussissent.
- Le paquet Debian n’a pas été reconstruit dans cette session. L’exécution
  CISMP avec la version précédente a révélé `PROXY: unbound variable` à la
  ligne 1854 ; la recette avec la nouvelle version attend le changement de
  version sur l’hôte.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour produire ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_proxy.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_proxy.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-proxy/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-proxy/spec.md`, `specs/legacy-variable-cleanup/spec.md` et
  `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/diu/variables/system/system_proxy.sh modules/system/variables-cleanup.sh` : réussi.
- `shellcheck root-install-debian.sh modules/diu/variables/system/system_proxy.sh modules/system/variables-cleanup.sh` : réussi.
- `python3 -m py_compile tests/test_system_proxy.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_proxy.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 9 tests réussis.
- `python3 -B -m unittest discover -s tests` : 679 tests réussis, 2 ignorés.
- `openspec validate add-system-proxy-variable --strict` : réussi avant
  archivage.
- `openspec validate system-proxy --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-proxy-variable --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Les tests ciblés, la suite complète, ShellCheck, Bash et OpenSpec valident le
changement source et documentaire. La déclaration statique, les deux
consommateurs et la migration de configuration sont archivés. Le changement
de version et la nouvelle exécution dans CISMP restent à effectuer après la
mise à jour du paquet sur l’hôte. Les résultats de commit et de publication
SCM sont fournis dans la synthèse de clôture, hors de ces statistiques de
réalisation. Le `STATISTICS.md` global de la racine est absent ; il n’a pas
été créé ici et le prompt SGS devra être mandaté pour le générer.
