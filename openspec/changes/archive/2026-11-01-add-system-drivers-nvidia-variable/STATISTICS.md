# Statistiques — add-system-drivers-nvidia-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-drivers-nvidia-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_DRIVERS_NVIDIA`, `STATIC`, `ENABLE`, scope
  `system`, défaut `0`.
- Les consommateurs utilisent le nouveau nom et désactivent les traitements
  si la variable est absente ou vaut `0`.
- La migration conserve la dernière affectation littérale historique
  `DRIVERS_NVIDIA=0|1` si la nouvelle variable n’est pas déjà configurée.
  Une ancienne valeur `1` conserve les traitements NVIDIA existants, qui
  peuvent installer des paquets et configurer DKMS, des modules noyau et
  Docker.
- Suite complète : 686 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-drivers-nvidia-variable`.
- Le paquet Debian n’a pas été reconstruit ici. L’installation/runtime CISMP
  avec cette version attend le prochain changement de version sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_drivers_nvidia.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_drivers_nvidia.py`,
  `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-drivers-nvidia/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-drivers-nvidia/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/diu/variables/system/system_drivers_nvidia.sh modules/system/variables-cleanup.sh` : réussi.
- `shellcheck root-install-debian.sh modules/diu/variables/system/system_drivers_nvidia.sh modules/system/variables-cleanup.sh` : réussi.
- `python3 -m py_compile tests/test_system_drivers_nvidia.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_drivers_nvidia.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 11 tests réussis.
- `python3 -B -m unittest discover -s tests` : 686 tests réussis, 2 ignorés.
- `openspec validate add-system-drivers-nvidia-variable --strict` : réussi
  avant archivage.
- `openspec validate system-drivers-nvidia --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-drivers-nvidia-variable --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration statique, les six consommateurs et la migration historique
sont implémentés, testés et archivés. La suite complète, les contrôles Bash,
ShellCheck et OpenSpec réussissent. La prochaine version du paquet et sa
validation d’exécution dans CISMP restent à faire après le changement de
version sur hvp1. Le commit et les publications Git sont rapportés dans la
synthèse SCM, hors des statistiques de réalisation. Le `STATISTICS.md` global
de la racine est absent ; il n’a pas été créé ici et le prompt SGS devra être
mandaté pour le générer.
