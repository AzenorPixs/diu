# STATISTIQUES — Déclaration modulaire de SYSTEM_PROXY_CA

## Statistiques générales et décisions

- Projet : Debian Installeur Unifié, racine `/home/devops/datas/diu`.
- Change : `add-system-proxy-ca`, archivé sous `2026-11-01-add-system-proxy-ca`.
- Session : codage direct SCM par Codex. Nom de session et RUN : N/A, aucun identifiant n’a été fourni.
- Date de clôture technique : 2026-11-01. Durée précise : N/A, les horodatages de début et de fin ne sont pas disponibles.
- Périmètre validé par le développeur : migration de `PROXY_CA` vers `SYSTEM_PROXY_CA`, configuration `STATIC`, état `ENABLE`, scope `system`, défaut `0` ; spécification, code, tests, documentation, archivage, commit et publications SCM.
- Décision de migration : l’ancienne valeur n’est pas transférée. Si `PROXY_CA` valait `1`, l’activation doit être reportée explicitement dans `SYSTEM_PROXY_CA`.
- Code de lot : non attribué. Le code n’a pas été inventé ; l’attribution ultérieure relève d’ACL.
- Première exécution LXC : conteneur `100`, Debian 13, paquet `2026.10.30.08.00`. `/root/diu/root-install-debian.sh` exécuté sous root ; code de sortie `1`, erreur `PROXY_CA: unbound variable` à la ligne 1843.
- Suite finale : 672 tests réussis, 2 ignorés. La qualification dans le LXC avec le nouveau paquet reste en attente du changement de version hôte et de sa disponibilité.
- Rapport global : `STATISTICS.md` absent à la racine. Selon SGS, mandater le prompt SGS.md pour générer ce rapport ; il n’a pas été créé ici.

## Types de messages et d’outils

- Mode direct SCM ; aucun agent délégué ou pilote OpenCode n’est intervenu.
- Appels d’outils natifs par catégorie : N/A, aucun décompte télémétrique exhaustif n’a été collecté pour cette session directe.
- Messages par rôle : N/A, aucune télémétrie de messages exploitable n’est disponible.
- Décisions du développeur observées : paramètres de la variable confirmés et périmètre SCM explicitement validé. Aucun mandat CAB n’a été utilisé.

## Fichiers modifiés

- Code : `root-install-debian.sh`, `modules/diu/variables/system/system_proxy_ca.sh`, `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_proxy_ca.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-proxy-ca/spec.md` (créée), `openspec/specs/legacy-variable-cleanup/spec.md` (mise à jour).
- Archive : `openspec/changes/archive/2026-11-01-add-system-proxy-ca/.openspec.yaml`, `design.md`, `proposal.md`, `tasks.md`, `specs/system-proxy-ca/spec.md`, `specs/legacy-variable-cleanup/spec.md`, `STATISTICS.md`.
- `README.md`, `PROJECT.md`, `BUILD.md` et `DEVOPS.md` : inchangés, leur contenu n’est pas rendu inexact par cette migration ciblée.

## Commandes

| Contrôle ou opération | Résultat |
|---|---|
| Exécution initiale de `/root/diu/root-install-debian.sh` dans le LXC 100 | Échec attendu de diagnostic : code 1, `PROXY_CA` non définie à la ligne 1843. |
| `python3 -B -m unittest discover -s tests -p 'test_system_proxy_ca.py' -v` | 5 tests réussis. |
| `python3 -B -m unittest discover -s tests -p 'test_config_cleanup.py' -v` | 7 tests réussis. |
| `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p 'test_*.py'` | 672 tests réussis, 2 ignorés. |
| `bash -n root-install-debian.sh modules/diu/variables/system/system_proxy_ca.sh modules/system/variables-cleanup.sh` | Réussi. |
| `shellcheck root-install-debian.sh modules/diu/variables/system/system_proxy_ca.sh modules/system/variables-cleanup.sh` | Réussi, aucun diagnostic. |
| `python3 -B -m py_compile tests/test_system_proxy_ca.py tests/test_config_cleanup.py` | Réussi. |
| `openspec validate add-system-proxy-ca --type change --strict --no-interactive` | Réussi après correction du titre de delta. |
| `openspec archive add-system-proxy-ca --yes --json` | Réussi ; archive créée et spécifications canoniques mises à jour. |

La première suite globale avec `/usr/bin/python3` 3.13.5 a échoué sur 26 fixtures de venv ; le test témoin passe avec Python 3.14.10 documenté dans `DEVOPS.md`. Une première suite sous Python 3.14.10 a rencontré un échec de construction Debian isolé ; le fichier `test_diu_packaging.py` a ensuite réussi (11/11) et la dernière suite globale a réussi (672, 2 ignorés). La télémétrie totale de commandes et leurs durées : N/A.

## Accès web

- Aucun appel de recherche ou de consultation web pendant cette session SCM.
- Total d’appels web observé : 0.

## Synthèse globale

La déclaration statique `SYSTEM_PROXY_CA` initialise le défaut `0` dans le scope `system`. Le point d’entrée utilise le nouveau nom avec un repli sûr à `0`, et `config_cleanup` retire l’ancienne affectation avant le chargement historique sans transférer sa valeur. Les tests ciblés, ShellCheck, la syntaxe Bash, la compilation Python et la validation OpenSpec stricte ont réussi ; la suite finale a réussi avec 672 tests et 2 ignorés. L’archivage est effectué. Le commit et les publications Git sont les étapes SCM suivantes. L’installation de la nouvelle version dans le LXC et le cycle suivant restent en attente du changement de version sur l’hôte et de la disponibilité du paquet.
