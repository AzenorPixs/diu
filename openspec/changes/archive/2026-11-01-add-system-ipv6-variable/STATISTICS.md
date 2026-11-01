# Statistiques — add-system-ipv6-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-ipv6-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_IPV6`, `STATIC`, `ENABLE`, scope `system`.
- À la première initialisation, sysctl `disable_ipv6=0` produit et persiste
  `SYSTEM_IPV6=1`; `disable_ipv6=1` produit et persiste `SYSTEM_IPV6=0`.
  Toute erreur ou valeur invalide bloque l’initialisation sans export.
- La dernière valeur littérale historique `IPv6=0|1` est migrée sans altération
  si `SYSTEM_IPV6` n’est pas déjà configurée.
- Archivage réussi sous `2026-11-01-add-system-ipv6-variable`. Les specs étaient
  déjà synchronisées; la commande d’archive a signalé `specsUpdated: false`.
- Suite complète DIU avec Python 3.14.10 : 717 tests réussis, 2 ignorés,
  aucun échec.
- La publication du paquet et la relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

17 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_ipv6.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_ipv6.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `openspec/specs/system-ipv6/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`,
  `openspec/specs/root-shellcheck/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les trois specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_ipv6 test_config_cleanup` : 27 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 717 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_ipv6.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_ipv6.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_ipv6.py` : réussi.
- Validations strictes OpenSpec du change, de `system-ipv6`, `legacy-variable-cleanup` et `root-shellcheck` : réussies.
- Validation OpenSpec stricte globale avant archivage : 63/80 valides; 17 avertissements préexistants dans d’autres changes/specs.
- `openspec archive add-system-ipv6-variable --yes --json` : réussi; aucune mise à jour canonique additionnelle nécessaire.
- `openspec validate --archived --json --no-interactive` : 114/126 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.
- `dpkg --audit` dans CISMP après l’interruption d’une tentative d’installation : aucune anomalie restante.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_IPV6` est déclaré statique avec initialisation depuis l’état sysctl
effectif en l’absence de valeur configurée. La migration conserve exactement
la dernière valeur historique simple et respecte la priorité du nouveau nom.
Le consommateur garde le traitement sysctl existant. Tests, contrôles shell et
validations OpenSpec ciblées réussissent; le change est archivé. Une tentative
ponctuelle précédente ayant fourni `IPv6=1` a été arrêtée pendant la
configuration interactive de `keyboard-configuration` et `console-setup`;
leur configuration a été terminée en mode non interactif, puis `dpkg --audit`
a confirmé une base de paquets saine. La publication et la relance DIU dans
CISMP restent à faire. Le `STATISTICS.md` général à la racine est absent; le
prompt SGS devra être mandaté pour le générer.
