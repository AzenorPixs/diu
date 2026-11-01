# Statistiques — add-system-crowdsec-agent-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-crowdsec-agent-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_CROWDSEC_AGENT`, `STATIC`, `ENABLE`, scope
  `system`, défaut `0`.
- La dernière valeur historique littérale `CROWDSEC_AGENT=0|1` est transférée
  exactement vers `system.env` si le nouveau nom n’y est pas déjà configuré.
- Une valeur `1` conserve le parcours existant d’installation et de
  configuration de l’agent CrowdSec et du bouncer.
- Archivage réussi sous
  `2026-11-01-add-system-crowdsec-agent-variable`. La spec canonique était déjà
  synchronisée; aucune mise à jour additionnelle n’a été nécessaire.
- Suite complète DIU avec Python 3.14.10 : 777 tests réussis, 2 ignorés,
  aucun échec.
- Publication du paquet et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

15 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_crowdsec_agent.sh`.
- Tests : `tests/test_system_crowdsec_agent.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Specs canoniques : `openspec/specs/system-crowdsec-agent/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_crowdsec_agent test_config_cleanup` : 38 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 777 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_crowdsec_agent.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_crowdsec_agent.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_crowdsec_agent.py` : réussi.
- Validations strictes OpenSpec du change, de `system-crowdsec-agent` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 71/88 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-crowdsec-agent-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 122/134 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_CROWDSEC_AGENT` est déclaré en `STATIC`, `ENABLE`, scope `system`,
défaut `0`. La migration transfère exactement l’ancienne valeur littérale et
donne priorité au nouveau nom. Le consommateur garde le parcours existant pour
la valeur `1`. Le change est archivé; tests, contrôles shell et validations
OpenSpec ciblées réussissent. Publication et relance DIU dans CISMP restent à
faire. Le `STATISTICS.md` général à la racine est absent; le prompt SGS devra
être mandaté pour le générer.
