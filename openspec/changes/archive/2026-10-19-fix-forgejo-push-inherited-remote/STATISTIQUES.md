# STATISTIQUES — Push Forgejo après changement de dépôt

## 1. Identification et périmètre

Projet : Debian Installeur Unifié (`diu`).
Date : 19 octobre 2026, Europe/Paris.
Session : SCM directe, correction du push après copie ou changement de dépôt.
Change : `fix-forgejo-push-inherited-remote`.
Archive : `2026-10-19-fix-forgejo-push-inherited-remote`.

Le périmètre couvre le réalignement des URL du remote Forgejo configuré, le
premier push malgré une référence de suivi héritée, les tests locaux, les
documents concernés et le cycle OpenSpec complet avec ce rapport. Les seules
valeurs non secrètes PROJECT_NAME et PROJECT_ID sont extraites localement de
project.env ; le fichier réel n'est ni affiché ni modifié.

Pendant SCM, aucun état Git du dépôt réel n'est inspecté. Les commits, tags,
références et pushes nécessaires aux tests concernent exclusivement des
dépôts temporaires locaux. Aucun projet réel, dont `prompts`, ni installation
DIU n'est modifié ou publié.

## 2. Mesures disponibles

| Mesure | Résultat |
| --- | ---: |
| Exécutions des suites de tests | 2 |
| Nouveaux tests exécutés et réussis | 14 |
| Tests existants exécutés et réussis | 100 |
| Total de tests exécutés et réussis | 114 |
| Échecs, erreurs et tests ignorés | 0 |
| Durée de la nouvelle suite | 2.491 s |
| Durée des suites existantes regroupées | 15.053 s |
| Durée cumulée des tests | 17.544 s |
| Diagnostics ShellCheck complets préexistants | 3 |
| Nouveaux diagnostics ShellCheck | 0 |
| Agents délégués | 0 |
| Dépendances ajoutées | 0 |
| Archivages exécutés | 1 |

Durée globale : N/A, absence de chronométrage continu de la session.
Tokens, coût et comptes exhaustifs des messages, outils et lectures : N/A,
absence de télémétrie de pilotage en SCM ; la compétence de statistiques de
pilotage n'est pas invoquée. Statistiques Git du dépôt réel : N/A,
inspection Git exclue pendant SCM. Inventaire global des changements
antérieurs ou concurrents : N/A, absence de relevé global autorisé.

## 3. Fichiers et contrat livré

Six fichiers préexistants sont modifiés :

- `modules/projects/git.sh` : helper de réalignement et lease du premier push ;
- `tests/test_rid_help.py` : assertion supplémentaire sur le lease explicite ;
- `TECHNICAL.md`, `README.md`, `CHANGELOG.md` : comportement et compatibilité ;
- `openspec/specs/implement-projects-forgejo-push/spec.md` : deux exigences.

Un fichier de tests est créé : `tests/test_projects_forgejo_push.py`.
Six artefacts sont créés puis archivés : `.openspec.yaml`, `proposal.md`,
`design.md`, `tasks.md`, `review.md` et le delta
`specs/implement-projects-forgejo-push/spec.md`. Ce rapport complète l'archive,
soit sept fichiers archivés et quatorze fichiers de livraison distincts au
total. Les déplacements d'archivage ne sont pas comptés comme de nouvelles
créations.

Le remote Forgejo configuré utilise la destination déclarée dans project.env
pour toutes ses URL de récupération et de publication. Les anciennes URL ne
sont pas affichées ; les autres remotes sont préservés. Une réexécution
conforme n'écrit pas la configuration. Une erreur bloque le push sans faux
succès et une correction partielle peut être reprise.

Pour un dépôt annoncé absent, le premier push explicite utilise
`--force-with-lease=refs/heads/<branche>:`. Il ne dépend plus de l'ancienne
référence de suivi et refuse d'écraser une branche créée entre-temps. Aucune
référence locale n'est supprimée. Le fetch des dépôts existants, les tags
sans forçage, les variables et les parcours GitLab/GitHub sont conservés.

## 4. Tests et vérifications

| Contrôle | État et preuve |
| --- | --- |
| Syntaxe Bash | Exécutée et réussie : `bash -n modules/projects/git.sh` |
| Nouvelle suite locale | Exécutée et réussie : 14 tests, 2.491 s |
| Suites existantes ciblées | Exécutées et réussies : 100 tests, 15.053 s |
| Compilation Python | Exécutée et réussie : py_compile des deux fichiers modifiés ou créés, sorties temporaires confinées au projet |
| ShellCheck complet | Exécuté et échoué : SC2034, SC2269, SC2086, tous préexistants et hors des fonctions modifiées |
| Comparaison ShellCheck avant/après | Exécutée et réussie : mêmes trois codes, niveaux et messages, aucun nouveau diagnostic |
| ShellCheck des fonctions modifiées | Exécuté et réussi : aucun diagnostic sur `_git_push_provider` et `forgejo_remote_ensure` extraites |
| Validation stricte du change | Exécutée et réussie avant le code puis avant archivage |
| Validation stricte de la spécification synchronisée | Exécutée et réussie après condensation des deux descriptions modifiées |
| Périmètre du code et du test existant | Reconstruction du SHA-256 initial du Bash et retrait du seul ajout d'assertion pour retrouver l'empreinte initiale du test |
| UTF-8/LF, absence de NUL et LF final | Contrôlés sur les fichiers livrés, y compris l'archive et ce rapport |
| Serveur Forgejo réel et installation | Non exécutés : hors périmètre, aucune publication ni installation |

La nouvelle suite est lancée par :

```sh
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_forgejo_push.py -v
```

Les suites `test_rid_help.py`, `test_projects_provider_unavailable.py` et
`test_projects.py` sont regroupées avec `unittest.defaultTestLoader.discover`
dans une seule exécution du même Python DevOps. Leur TMPDIR est un répertoire
temporaire sous la racine du projet, ensuite nettoyé ; l'écriture des caches
Python est désactivée. Les nouveaux tests imposent `GIT_ALLOW_PROTOCOL=file`
et isolent les configurations Git globales et système. Les appels API et
credentials sont simulés ; les opérations Git testées utilisent Git réel.

Le scénario complet reproduit le remote hérité, son réalignement, la
référence de suivi périmée, puis la publication de la branche et du tag.
Un autre scénario crée la branche distante entre vérification et push : le
lease refuse la publication, conserve cette branche et ne publie aucun tag.
Les URL multiples, pushurl distinctes, erreurs, reprise, idempotence et
destination nommée avec branche différente sont également vérifiées.

Le Bash initial est reconstruit dans une copie temporaire avec l'empreinte
`ea62e5b1c7d5d6a1adad40a85582e034fa29e397cbb0d71847d68d38cac891aa`.
Les trois diagnostics identiques sont comparés avant et après. La suite
entière du dépôt n'est pas exécutée : les quatre modules de tests ciblés
couvrent les fonctions et fournisseurs concernés.

## 5. Cohérence et archivage

L'archivage officiel est exécuté une seule fois :

```sh
/home/devops/.local/npm/bin/openspec archive fix-forgejo-push-inherited-remote --json --yes
```

Résultat : `specsUpdated=true`, deux exigences modifiées, aucune ajoutée,
supprimée ou renommée. Les neuf tâches préalables sont cochées. Aucun autre
change actif n'est repris ni archivé.

La première validation du delta échoue sur deux noms de scénarios omis.
Les noms existants sont conservés et la validation stricte réussit avant le
code. Après archivage, la validation stricte de la spécification principale
signale deux descriptions trop longues, toutes deux dans les exigences
modifiées. Les descriptions sont condensées avec les détails conservés dans
les scénarios, à l'identique dans le delta archivé et la spécification
principale ; la validation stricte réussit ensuite. Aucun réarchivage ni
changement de code après ses tests n'est effectué.

| Élément SCM | État et justification |
| --- | --- |
| Projet réel | Sources corrigées, 114 tests ciblés réussis ; DIU installé et dépôt prompts réel inchangés |
| AGENTS.md | Inchangé : sections 5, 6, 7, 13 et 21 appliquées pour périmètre, validation, OpenSpec et rapport |
| PROJECT.md | Inchangé : module projects, architecture et technologies conservés |
| TECHNICAL.md | Mis à jour : configuration des fournisseurs, publication Git et compatibilité |
| BUILD.md | Inchangé : construction Debian et chaîne de packaging non concernées |
| DEVOPS.md | Inchangé : outils existants utilisés, aucune dépendance ni génération d'inventaire |
| README.md | Mis à jour : publication Forgejo, réalignement, premier push et limites serveur |
| CHANGELOG.md | Mis à jour : entrée Unreleased sans version ni publication inventée |
| openspec/specs/ | Deux exigences synchronisées, validation stricte réussie et égalité avec les blocs du delta archivé |
| openspec/config.yaml | Inchangé : schéma spec-driven conservé |

Les empreintes initiales d'AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et
openspec/config.yaml sont conservées. Le contrôle final vérifie les fichiers
livrés, l'absence du change actif, la présence de l'archive, les neuf tâches
cochées, les six sections de ce rapport et les totaux. Le fichier `review.md`
fournit les preuves détaillées et la correspondance entre critères et tests.

## 6. Limites et suites

La correction est livrée dans les sources de développement. Le DIU installé
n'est pas remplacé ; le comportement de `rid` ne changera qu'après sa mise à
jour par le processus habituel. Aucun push réel n'est exécuté pour confirmer
la publication du projet prompts.

La création effective d'un dépôt absent dépend toujours de l'activation
push-to-create sur Forgejo. Les réécritures Git d'URL qui empêchent d'obtenir
la destination déclarée provoquent un échec explicite ; elles ne sont pas
modifiées. Une erreur intermédiaire de configuration peut laisser un
réalignement partiel, repris à la réexécution. Le repli consiste à rétablir
le code précédent ; les URL déjà réalignées ne sont pas restaurées
automatiquement.

Les trois diagnostics ShellCheck préexistants restent signalés et hors du
périmètre. Aucun nouveau diagnostic ni échec de test ne subsiste. Le contrôle
de périmètre est limité aux fichiers examinés et aux écritures effectuées ;
il ne prétend pas établir l'état global du dépôt sans inspection Git.
