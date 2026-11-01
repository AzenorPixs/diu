# Statistiques — add-system-grub-config-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-grub-config-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_GRUB_CONFIG`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- La dernière valeur littérale historique `GRUB_CONFIG=0|1` est transférée
  vers `SYSTEM_GRUB_CONFIG`, sauf si cette dernière est déjà déclarée. Une
  ancienne valeur `1` reste `1`; une valeur ambiguë bloque le nettoyage sans
  modification ni affichage de son contenu.
- Archivage OpenSpec réussi sous
  `2026-11-01-add-system-grub-config-variable`; une spec ajoutée et une
  modifiée.
- Suite complète avec Python DIU 3.14.10 : 708 tests réussis, 2 ignorés,
  aucun échec.
- La publication du paquet puis sa mise à jour et l’exécution dans CISMP
  restent à faire selon le cycle demandé.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

16 fichiers liés au changement, au cadrage et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_grub_config.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_grub_config.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`.
- Fichier généré déjà modifié avant ce change et inclus au commit complet du
  projet conformément au mandat : `DEVOPS.md`.
- Spécifications canoniques : `openspec/specs/system-grub-config/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_grub_config test_config_cleanup` : 23 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 708 tests réussis, 2 ignorés.
- Essai complet initial avec `python3 -m pytest -q` sous Python système 3.13.5 : 680 réussis, 2 ignorés, 26 échecs dans les tests de venv DevOps (`StopIteration` lors de la recherche d’un `site-packages` existant). Le Python de référence déclaré dans `DEVOPS.md` (3.14.10) a été utilisé ensuite et la suite complète a réussi.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_grub_config.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_grub_config.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_grub_config.py` : réussi.
- Validations strictes OpenSpec du change, de `system-grub-config` et de `legacy-variable-cleanup` : réussies.
- `git diff --check` : réussi.
- Archivage avec `openspec archive add-system-grub-config-variable --yes --json` : réussi; 1 spec ajoutée, 1 modifiée.
- `openspec validate --archived --json --no-interactive` : 113/125 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide (toutes les tâches terminées, aucun diagnostic).
- Validation stricte globale OpenSpec après archivage : 61/78 valides; 17 éléments existants hors de ce change portent des avertissements de scénarios incomplets.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_GRUB_CONFIG` est déclaré et le consommateur GRUB utilise le nouveau
nom avec un repli désactivé. Le nettoyage migre la dernière valeur historique
littérale avant de supprimer l’ancien nom, conserve `1` et préserve une
configuration nouvelle déjà présente. Le change et les specs ciblées sont
valides et archivés; la suite DIU de référence passe. La publication du paquet
et le cycle CISMP restent à effectuer. Le `STATISTICS.md` général à la racine
est absent ; le prompt SGS devra être mandaté pour le générer.
