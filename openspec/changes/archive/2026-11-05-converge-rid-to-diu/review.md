# Revue de convergence DIU — 2026-11-05

## Périmètre
Convergence locale des commandes de production et développement, des alias générés, des fonctions d’aide, des diagnostics, des tests et des spécifications courantes. Le routage et les arguments métier sont conservés. Les fichiers protégés de configuration, les installations et les sessions shell existantes ne sont pas migrés. Aucun commit, tag, push, installation ou CI/CD.

La réalisation est un lot indivisible : le renommage de la bibliothèque, de ses fonctions, des appels, des tests et des capacités courantes doit être cohérent pour conserver une aide utilisable.

## Interfaces livrées

| Usage | Interface |
|---|---|
| Production | `diu` |
| Développement | `diut` |
| Ouverture | `diuo` → `diu projects ocrw` |
| Mise à jour | `diuu` → `diu update` |
| Édition | `ndiu` → `nano /root/diu/root-install-debian.sh` |
| Bibliothèque d’aide | `lib/diu-help.sh` |
| Fonctions d’aide | `diu_help_line`, `diu_display_help_context`, `diu_display_command_error` |
| Capacité courante d’aide | `openspec/specs/diu-help/spec.md` |
| Tests d’aide | `tests/test_diu_help.py` |

Les raccourcis `rcicddiu` et `rcicddr` conservent leur nom et appellent `diut`. L’alias Docker `drid` reste identique et ne désigne pas DIU. Les anciens alias DIU ne sont plus générés. Aucun mécanisme de suppression d’alias dans un shell existant n’est ajouté.

## Validation et limites
- Syntaxe : `bash -n` sur les 11 fichiers Bash modifiés ; compilation des 10 tests Python modifiés.
- ShellCheck : contrôle réussi sur les 11 fichiers Bash et les deux dépendances explicites `lib/project-version.sh` et `modules/projects/diu-packaging.sh`. Le premier appel sans ces deux entrées signalait SC1091 ; aucune suppression de diagnostic n’a été ajoutée.
- Tests ciblés : 311 cas exécutés avec le Python système 3.13.5, 283 réussis, 2 ignorés, 26 erreurs `StopIteration` dans la préparation des fixtures venv. Les 26 cas passent lors de leur reprise avec `/home/devops/python/current/bin/python3` 3.14.10, déclaré dans `DEVOPS.md`. Aucun test n’a été désactivé pour contourner cette erreur d’environnement.
- Tests des fichiers partagés après retrait concurrent du moteur `deb` : 108 cas réussis. Le premier lancement global, commencé avant ce retrait, a exécuté 1 189 cas avec 45 échecs et 2 ignorés : 44 échecs proviennent des anciens tests logiciels encore chargés en mémoire ; le dernier vérifiait l’ancienne empreinte Zsh. La comparaison avant/après du contenu rendu ne montre que les sept lignes d’alias attendues ; cette empreinte a été actualisée. Ce lancement est conservé comme essai intermédiaire et ne constitue pas la qualification finale.
- Les deux nouveaux tests vérifient les alias et leurs cibles, la préservation de `drid`, l’absence des anciens alias et des anciens identifiants dans les sources exécutables concernées.
- OpenSpec : le change et la capacité d’aide passent le contrôle strict. Le contrôle global strict comporte 47 échecs préexistants : les diagnostics sont identiques à ceux d’une copie isolée des spécifications et changes actifs de l’état initial. Aucun nouvel échec. Exemples de diagnostics antérieurs : scénarios sans WHEN/THEN, Purpose provisoires et exigences trop longues. Ils restent hors de cette convergence.
- Archives préexistantes : comparaison SHA-256 de 1 196 fichiers, tous identiques.
- Encodage : fichiers modifiés contrôlés en UTF-8/LF ; chemins courants d’aide vérifiés.

## Matrice documentaire

| Document | État | Preuve et justification |
|---|---|---|
| `AGENTS.md` | Inchangé | Les règles ne dépendent pas du nom des commandes ; aucune nouvelle règle nécessaire. |
| `PROJECT.md` | Mis à jour | Exemple de construction Debian sous `diu projects build debian`. |
| `TECHNICAL.md` | Mis à jour | Commandes, interfaces d’aide et alias générés ; limite de migration des shells existants. |
| `BUILD.md` | Mis à jour | Exemples de construction et distinction `diu`/`diut`. |
| `DEVOPS.md` | Inchangé par cette session | Comparaison octet par octet avec l’état à la reprise ; modification locale antérieure préservée. Le Python DevOps déclaré est utilisé pour la qualification globale. |
| `DEVELOPMENT_MAP.md` | Mis à jour | Références courantes d’aide et entrée provisoire du change ; aucune attribution de code. |
| `README.md` | Mis à jour | Commandes et alias publics, absence de migration automatique des fichiers et shells déjà installés. |
| `CHANGELOG.md` | Mis à jour | Entrée `Unreleased`, impacts de compatibilité des alias et préservation des archives. |
| `openspec/specs/` | Mis à jour | Convergence mécanique des commandes, capacité `diu-help`, contrats de convergence et des liens. Les diagnostics stricts préexistants restent signalés. |
| `openspec/BATCH_CODES.md` | Mis à jour | Entrée provisoire du change et références courantes ; codes existants conservés. |
| `openspec/changes/archive/` préexistant | Inchangé | Comparaison SHA-256 ; identifiants, chemins et preuves historiques préservés. |
| `STATISTICS.md` global | Absent | Aucun fichier global créé ; mandater ultérieurement SGS pour sa génération. |

## Coexistence des sessions

Une autre session a retiré le moteur logiciel `deb` dans les fichiers partagés. Ces modifications ont été constatées et conservées ; elles ne sont pas attribuées à la convergence. La qualification finale est relancée sur l’état partagé courant, avec comparaison des empreintes des sources avant/après son exécution. Aucune modification supplémentaire des fichiers partagés n’est effectuée pour rétablir les anciennes commandes `deb`. Le change parallèle `remove-software-deb-engine` est archivé et sa spécification `software-management` synchronisée ; cet état partagé est préservé.

## Traçabilité
Le change `converge-rid-to-diu` reste sans code attribué. Exécuter ultérieurement ACL pour son attribution et la normalisation définitive des sous-lots ; aucune allocation n’est inventée pendant cette session.

Qualification globale : 1 177 tests exécutés avec le Python DevOps déclaré, 1 175 réussis et 2 ignorés, aucun échec ni erreur ; sources identiques avant/après le lancement (262,911 s). Archivage réussi le 2026-11-05 : `2026-11-05-converge-rid-to-diu`, spécifications synchronisées ; rapport à six sections vérifié.

## Fichiers de la convergence

96 fichiers existants concernés : 11 Bash, 10 Python et 75 fichiers de spécification ou documentation. Les contributions parallèles au retrait de `deb` ne sont pas comptabilisées comme des écritures de cette convergence.

- `BUILD.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `PROJECT.md`
- `README.md`
- `TECHNICAL.md`
- `lib/diu-help.sh`
- `modules/diu/update.sh`
- `modules/projects/debian-build.sh`
- `modules/projects/github-release.sh`
- `modules/projects/projects.sh`
- `modules/projects/template.sh`
- `modules/softwares/apt.sh`
- `modules/softwares/flatpak.sh`
- `modules/softwares/software.sh`
- `modules/system/apt.sh`
- `openspec/BATCH_CODES.md`
- `openspec/changes/add-projects-forgejo-clone/design.md`
- `openspec/changes/add-projects-forgejo-clone/proposal.md`
- `openspec/changes/add-projects-forgejo-clone/specs/diu-help/spec.md`
- `openspec/changes/add-projects-forgejo-clone/specs/projects-forgejo-clone/spec.md`
- `openspec/changes/add-projects-forgejo-clone/tasks.md`
- `openspec/changes/configure-gitlab-container-registry/specs/add-projects-gitlab-update/spec.md`
- `openspec/changes/define-modular-architecture/specs/modular-architecture/spec.md`
- `openspec/changes/ensure-projects-git-commit-init/proposal.md`
- `openspec/changes/ensure-projects-git-commit-init/specs/projects-git-commit-all/spec.md`
- `openspec/changes/ensure-projects-git-commit-init/specs/projects-git-commit/spec.md`
- `openspec/changes/ensure-projects-git-commit-init/specs/projects-git-init/spec.md`
- `openspec/changes/fix-forgejo-repository-identity/proposal.md`
- `openspec/changes/modify-projects-forgejo-push-force-with-lease/proposal.md`
- `openspec/changes/modify-projects-forgejo-push-force-with-lease/specs/implement-projects-forgejo-push/spec.md`
- `openspec/changes/modify-projects-forgejo-push-force-with-lease/specs/implement-projects-github-push/spec.md`
- `openspec/changes/modify-projects-forgejo-push-force-with-lease/specs/implement-projects-gitlab-push/spec.md`
- `openspec/changes/reconcile-cicd-git-publication/specs/implement-projects-forgejo-push/spec.md`
- `openspec/changes/reconcile-diu-deb-packaging-contract/proposal.md`
- `openspec/changes/reconcile-diu-deb-packaging-contract/specs/deb-package/spec.md`
- `openspec/changes/reconcile-diu-deb-packaging-contract/specs/diu-help/spec.md`
- `openspec/changes/restore-forgejo-push-to-create/specs/implement-projects-forgejo-push/spec.md`
- `openspec/specs/add-gitlab-remote-ensure/spec.md`
- `openspec/specs/add-projects-gitlab-update/spec.md`
- `openspec/specs/allow-gitlab-self-signed-tls/spec.md`
- `openspec/specs/deb-package/spec.md`
- `openspec/specs/diu-command-links/spec.md`
- `openspec/specs/diu-help/spec.md`
- `openspec/specs/diu-package-update/spec.md`
- `openspec/specs/forgejo-release/spec.md`
- `openspec/specs/idelete-projects-gitp/spec.md`
- `openspec/specs/implement-projects-forgejo-push/spec.md`
- `openspec/specs/implement-projects-forgejo-update/spec.md`
- `openspec/specs/implement-projects-git-update/spec.md`
- `openspec/specs/implement-projects-github-push/spec.md`
- `openspec/specs/implement-projects-github-release/spec.md`
- `openspec/specs/implement-projects-github-update/spec.md`
- `openspec/specs/implement-projects-gitlab-push/spec.md`
- `openspec/specs/implement-projects-gitlab-release/spec.md`
- `openspec/specs/implement-projects-update/spec.md`
- `openspec/specs/modify-projects-docker-build/spec.md`
- `openspec/specs/modify-projects-gitpdi/spec.md`
- `openspec/specs/module-infos/spec.md`
- `openspec/specs/projects-cicd/spec.md`
- `openspec/specs/projects-clone/spec.md`
- `openspec/specs/projects-debian-build/spec.md`
- `openspec/specs/projects-forgejo-push-all/spec.md`
- `openspec/specs/projects-general-update/spec.md`
- `openspec/specs/projects-git-analyse/spec.md`
- `openspec/specs/projects-git-commit-all/spec.md`
- `openspec/specs/projects-git-commit/spec.md`
- `openspec/specs/projects-git-init/spec.md`
- `openspec/specs/projects-git-status/spec.md`
- `openspec/specs/projects-github-clone/spec.md`
- `openspec/specs/projects-gitlab-clone/spec.md`
- `openspec/specs/projects-sync-all/spec.md`
- `openspec/specs/projects-sync/spec.md`
- `openspec/specs/projects-template-all/spec.md`
- `openspec/specs/projects-template-devops/spec.md`
- `openspec/specs/projects-template-openspec/spec.md`
- `openspec/specs/refine-projects-gitlab-push-config/spec.md`
- `openspec/specs/root-shellcheck/spec.md`
- `openspec/specs/software-flatpak/spec.md`
- `openspec/specs/software-management/spec.md`
- `openspec/specs/system-debian-apt/spec.md`
- `openspec/specs/system-drivers-display-link/spec.md`
- `openspec/specs/system-flatpak/spec.md`
- `openspec/specs/system-network-hosts/spec.md`
- `openspec/specs/universal-update/spec.md`
- `root-install-debian.sh`
- `tests/test_diu_command_links.py`
- `tests/test_diu_help.py`
- `tests/test_module_infos.py`
- `tests/test_projects_build_deb.py`
- `tests/test_projects_general_update.py`
- `tests/test_projects_git_safe_directory.py`
- `tests/test_projects_template_devops.py`
- `tests/test_root_shellcheck.py`
- `tests/test_software_flatpak.py`
- `tests/test_system_network_hosts.py`
