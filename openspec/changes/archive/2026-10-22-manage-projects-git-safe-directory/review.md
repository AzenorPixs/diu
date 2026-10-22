# Validation — safe.directory système des projets

Date : 22 octobre 2026. Projet : Debian Installeur Unifié (`diu`).

## Résultat et périmètre

Les commandes `rid projects git init` et `update` enregistrent une exception
système exacte pour le chemin canonique du projet. L'opération est
idempotente et préserve les autres règles. Le statut affiche la présence ou
l'absence de l'entrée système sans l'ajouter, même si sa configuration
locale nécessite un repli. L'initialisation réussie reste silencieuse.

L'évolution porte sur `modules/projects/git.sh`, `lib/rid-help.sh`,
`tests/test_rid_help.py`, le nouveau test
`tests/test_projects_git_safe_directory.py`, trois documents et les quatre
spécifications concernées. Aucun changement de propriétaire, dépendance,
installation, migration globale, commit ou push du dépôt de travail.
Les signatures publiques restent inchangées.

La revue des ajouts ne contient que des clés Git publiques, des messages et
des fixtures synthétiques (`git@example.test`). Aucun fichier de secrets ou
configuration réelle des projets n'a été ouvert pour l'implémentation.

## Vérifications exécutées

| Vérification | Résultat observé |
| --- | --- |
| `bash -n modules/projects/git.sh` | Exécutée et réussie |
| `bash -n lib/rid-help.sh` | Exécutée et réussie |
| `shellcheck lib/rid-help.sh` | Exécutée et réussie |
| ShellCheck des sept fonctions concernées, extraites sur stdin | Exécutée et réussie, zéro diagnostic |
| `shellcheck modules/projects/git.sh lib/rid-help.sh` | Exécutée et échouée : trois diagnostics préexistants hors périmètre, détaillés ci-dessous |
| `python3 -m py_compile` sur les deux tests modifiés ou créés | Exécutée et réussie, caches isolés puis supprimés |
| Suite Python isolée des quatre modules ci-dessous | Exécutée et réussie : 118 tests, zéro échec, erreur ou test ignoré |
| `openspec validate manage-projects-git-safe-directory --strict` | Exécutée et réussie avant toute écriture de code ou test, puis après revue |
| Contrôle UTF-8/LF | Exécuté et réussi sur les 14 fichiers du périmètre avant cette revue ; vérification finale étendue après archivage |
| Empreintes des cadrages inchangés et du change actif voisin | Exécutée et réussie, voir bilan documentaire |
| Test d'installation système ou publication distante | Non pertinent pour cette évolution ; non exécuté |

Les sept fonctions contrôlées par ShellCheck sont
`_git_safe_directory_project_path`, `_git_safe_directory_system_state`,
`git_safe_directory_system_ensure`, `git_safe_directory_system_status`,
`git_init`, `git_status` et `git_update`.

### Régression Python

| Module | Tests réussis lors de la dernière exécution groupée |
| --- | ---: |
| `tests/test_projects_git_safe_directory.py` | 26 |
| `tests/test_rid_help.py` | 56 |
| `tests/test_projects_general_update.py` | 9 |
| `tests/test_projects.py` | 27 |
| **Total** | **118** |

La suite est exécutée avec `python3 -B` et `unittest`, dans un répertoire
temporaire `.diu-test-git-regression-*` à la racine du projet. HOME,
XDG_CONFIG_HOME, TMPDIR, GIT_CONFIG_GLOBAL et GIT_CONFIG_SYSTEM sont isolés ;
les variables GIT héritées sont écartées et les caches Python désactivés.
Les fixtures du nouveau module restent également dans la racine du projet.
Les artefacts temporaires ont été supprimés par leurs gestionnaires de
contexte. La configuration système réelle n'a pas été modifiée.

Les tests établissent notamment : ajout et réexécution sans doublon ;
conservation d'autres règles ; valeurs vides et multiligne ; includes et
réinitialisations ; chemins avec espaces et liens symboliques ; refus d'un
chemin dont la représentation serait un joker ; erreurs de lecture et
d'écriture ; initialisation nouvelle ou existante ; conservation des
variables locales ; absence d'écriture par status, y compris ses replis.

Le refus `dubious ownership` puis son déblocage sont reproduits avec Git
réel et `GIT_TEST_ASSUME_DIFFERENT_OWNER=1` sur une fixture isolée. Un autre
test montre qu'une réinitialisation globale peut continuer à bloquer Git
malgré la présence de l'entrée système : le statut ne promet pas l'inverse.

### Diagnostics ShellCheck antérieurs

Le contrôle intégral retrouve SC2034 (`link_http_code` inutilisé), SC2269
(`local_api_url` affecté à lui-même) et SC2086 (`mkdir -p ${project_path}`
dans le clonage historique). Ces trois portions ne sont pas modifiées.

La reconstruction en mémoire du fichier initial par retrait des seuls
changements de cette session retrouve exactement l'empreinte SHA-256
`77799f8d0db82df8a13d398884be33e28f42ba85fb90e89e5bed4692d98bd078`.
ShellCheck appliqué à cette reconstruction retourne les mêmes trois codes.
Ce contrôle complet reste en échec ; le contrôle du périmètre livré réussit.
Aucune règle ShellCheck ni aucun test n'a été désactivé pour masquer ces
diagnostics. Leur correction est laissée hors de cette évolution.

La première validation OpenSpec stricte a signalé deux exigences trop
longues ; elles ont été scindées avant l'implémentation. La première série de
22 tests dédiés a révélé un cas réel d'include prioritaire et deux attentes
de test incorrectes : sortie d'initialisation déjà redirigée par le code
existant, et diagnostic Git générique précédant la lecture système.
L'include est désormais traité explicitement, le diagnostic est placé avant
les autres appels Git et le test d'initialisation observe un marqueur de
fixture plutôt qu'une sortie volontairement silencieuse. La suite dédiée
suivante de 24 tests, puis la suite finale de 118 tests avec 26 dédiés,
réussissent. Aucun échec fonctionnel connu ne subsiste dans le périmètre.

## Bilan documentaire et cohérence

| Élément | État et preuve |
| --- | --- |
| Projet réel | Sept fichiers de code, tests et documentation concernés ; signatures publiques et questionnaire conservés, prouvés par la suite ciblée |
| `AGENTS.md` | Inchangé, empreinte identique ; sections 6, 12, 13 et 21 respectées : OpenSpec ciblé, aucun commit/push, validations applicables |
| `PROJECT.md` | Inchangé, empreinte identique ; architecture fonctionnelle, module projects, cohérente avec l'extension des commandes Git existantes |
| `TECHNICAL.md` | Mis à jour dans la configuration Git locale : séparation git_update_local/git_update, portée système, erreurs, includes, diagnostic et repli |
| `BUILD.md` | Inchangé, empreinte identique ; construction Debian non concernée, aucune dépendance ou ressource de paquet supplémentaire |
| `DEVOPS.md` | Inchangé, empreinte identique ; Git et Python existants réutilisés, source SCM résolue depuis la rubrique Prompts |
| `README.md` | Mis à jour dans les paragraphes Git : commandes, exception exacte, droits système et limite des règles globales |
| `CHANGELOG.md` | Entrée ajoutée sous Unreleased, sans version ni date de publication inventée |
| `openspec/specs/` | Quatre deltas additifs validés et synchronisés par l'archivage ciblé : projects-git-init, implement-projects-git-update, projects-git-status et rid-help ; six exigences ajoutées, aucune supprimée ou modifiée |
| Change voisin `ensure-projects-git-commit-init` | Proposition et tâches inchangées, empreintes identiques ; comportement silencieux conservé par la régression |

La responsabilité exclusive de `git_update_local` sur les variables est
conservée. Le point d'entrée public `git_update` reçoit l'effet système
explicitement défini par cette évolution. La cohérence documentaire est
établie pour ce périmètre. Les exigences antérieures des quatre documents
sont préservées : leurs préfixes avant les ajouts retrouvent les empreintes
SHA-256 initiales, après prise en compte du séparateur de fin de document.

## Contrôles après archivage

`openspec archive manage-projects-git-safe-directory --yes` a réussi avec
les tâches complètes et la synchronisation de quatre spécifications.
Résultat : six exigences ajoutées, zéro modifiée, supprimée ou renommée.
Le change est archivé dans
`openspec/changes/archive/2026-10-22-manage-projects-git-safe-directory`.

Les validations `openspec validate <capacité> --type spec --strict` ont
réussi pour `projects-git-init`, `implement-projects-git-update` et
`projects-git-status`. Celle de `rid-help` reste en échec avec cinq
avertissements de longueur sur les exigences antérieures d'indices 3, 8, 9,
10 et 11. Le nouveau delta d'aide est valide en mode strict.

La reconstruction du document rid-help initial retrouve l'empreinte
`0a74a76c1887ef4e81ccf4170ef4455e724d3686715b5e8ba8dd8f35f87047b2`.
Sa validation dans une racine OpenSpec temporaire isolée reproduit
exactement les mêmes cinq avertissements. Ils ne résultent donc pas de cette
évolution et restent hors périmètre, comme les trois diagnostics ShellCheck
antérieurs. La conformité stricte de tout le document d'aide n'est pas
déclarée acquise.

## Limites et clôture

Les règles globales prioritaires peuvent neutraliser l'exception système.
Un include système qui la neutralise provoque un échec explicite ; il n'est
ni réordonné ni supprimé. Une première tentative peut avoir ajouté une entrée
inactive avant ce constat ; les relances ne la dupliquent pas.
Les écritures déjà réalisées en cas d'erreur ne sont pas annulées.

Aucun déploiement sur l'installation DIU en production et aucune migration
automatique des dépôts existants n'ont été exécutés. La révocation éventuelle
d'une exception installée reste une opération administrative distincte.
L'archivage de ce seul change a réussi. Le rapport à six sections et ses
contrôles finaux sont consignés dans STATISTIQUES.md, sans réarchivage.
