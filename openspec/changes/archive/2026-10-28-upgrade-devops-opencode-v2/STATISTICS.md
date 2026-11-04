# STATISTIQUES — Installation OpenCode V2 dans l'environnement DevOps

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`), racine `/home/devops/datas/diu`.
- Session SCM directe, version 0.2 ; change `upgrade-devops-opencode-v2` ; date : 28 octobre 2026.
- Archive : `2026-10-28-upgrade-devops-opencode-v2`.
- Périmètre autonome explicitement validé : détection de la dernière release stable OpenCode V2, comparaison numérique, installation V2 ciblée, tests isolés, cadrage technique, changelog, synchronisation et archivage de ce change.
- Aucun pilotage OpenCode, CAB ou sous-agent ; aucun suivi statistique de session pilotée invoqué, conformément à SCM.
- La release V2 officielle observée pendant la préparation était `v2.2.0`, publiée le 27 octobre 2026. La documentation officielle présente `https://opencode.ai/v2/install` et les options `--version` et `--no-modify-path`.

## 2. Durées et mesures disponibles

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée totale de la session | N/A | Pas de chronométrage complet fiable |
| Tests ciblés OpenCode | 9 réussis, 0,056 s | Sortie unittest observée |
| Tests Node.js connexes | 5 réussis, 0,029 s | Sortie unittest observée |
| Tests ShellCheck du monolithe | 9 réussis, 5,242 s | Sortie unittest observée |
| Suite complète | 628 exécutés, 2 ignorés, 7 échoués, 143,859 s | Sortie unittest observée ; les échecs hors périmètre sont détaillés en section 4 |
| Commandes web | 5 appels dans la conversation : deux pour vérifier la release V2 et trois pour vérifier l'installateur V2 | Docs OpenCode et source GitHub consultées ; un lien brut GitHub a été refusé par l'outil |
| Approbations/refus CAB | Non applicable | Session SCM directe |
| Modèle, jetons et coût | N/A | Pas de télémétrie qualifiée pour une session SCM |

## 3. Fichiers et comportement livré

Douze fichiers du projet ont été créés ou modifiés : cinq sources et documents existants/nouveaux de l'implémentation, six fichiers d'archive générés par OpenSpec, et ce rapport.

| Fichier | Résultat |
| --- | --- |
| `root-install-debian.sh` | Recherche les releases GitHub par pages, sélectionne un tag stable `v2.x.y`, compare les versions avec `sort -V` et appelle l'installateur V2 avec la version exacte seulement si le binaire est absent ou plus ancien. |
| `tests/test_devops_opencode.py` | Neuf tests déterministes couvrent V1 vers V2, pagination, versions stables et préliminaires, comparaison numérique, binaire absent, égalité, version locale supérieure, erreurs réseau et désactivation. Aucun réseau ni installateur réel. |
| `TECHNICAL.md` | Décrit la sélection, les délais réseau, la comparaison et l'installateur officiel. |
| `CHANGELOG.md` | Entrée `Unreleased` ajoutée pour l'installation DevOps V2. |
| `openspec/specs/devops-opencode/spec.md` | Nouvelle spécification canonique, synchronisée par archivage avec quatre exigences ajoutées. |
| `openspec/changes/archive/2026-10-28-upgrade-devops-opencode-v2/` | `README.md`, `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`, delta de spécification et ce rapport. |

Le chemin DevOps, l'activation `OPENCODE=1`, l'absence de modification du PATH et le nettoyage du profil historique sont préservés. Une version V1 valide telle que `1.19.4` est admissible comme version installée et sera remplacée par une V2 plus récente. Une version locale égale ou supérieure n'est pas remplacée. Les versions préliminaires ne sont pas sélectionnées.

La modification préexistante de `DEVOPS.md` a été préservée sans édition. Aucun autre change ou archive OpenSpec n'a été modifié par cette évolution.

## 4. Tests et vérifications

| Contrôle | État final et résultat |
| --- | --- |
| `/home/devops/python/current/bin/python3 -B tests/test_devops_opencode.py -v` | Exécuté et réussi : 9 tests |
| `/home/devops/python/current/bin/python3 -B tests/test_devops_nodejs.py -v` | Exécuté et réussi : 5 tests connexes |
| `/home/devops/python/current/bin/python3 -B tests/test_root_shellcheck.py -v` | Exécuté et réussi : 9 tests |
| `bash -n root-install-debian.sh` | Exécuté et réussi |
| `shellcheck root-install-debian.sh` | Exécuté et réussi, aucun diagnostic |
| `/home/devops/python/current/bin/python3 -m py_compile tests/test_devops_opencode.py` | Exécuté et réussi |
| Vérification UTF-8/LF | Exécutée et réussie pour les huit fichiers pré-archivage ; le présent rapport est vérifié séparément |
| `openspec validate upgrade-devops-opencode-v2 --strict --no-interactive` | Exécuté et réussi avant code, après implémentation et après synchronisation des tâches |
| `openspec validate devops-opencode --type spec --strict --no-interactive` | Exécuté et réussi après archivage |
| Suite complète `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` | Échec : 628 tests, 2 ignorés, 7 échecs. Un test Git échoue faute de permission d'écriture à `/etc/gitconfig`. Six tests de mise à jour échouent car `system_update` est introuvable. Ces fichiers et fonctions ne sont pas dans les chemins modifiés ; aucune correction hors périmètre n'a été tentée. |
| `openspec validate --all --strict --no-interactive` | Échec global : 47 éléments valides, 22 échecs sur 69. Les diagnostics portent sur d'autres spécifications et deux changes Forgejo actifs omettant des scénarios ; le change ciblé et sa spécification canonique passent en strict. Aucun de ces autres éléments n'a été modifié. |

## 5. Cohérence documentaire et archivage

| Élément | État final et preuve |
| --- | --- |
| Projet réel | Bloc d'installation DevOps et tests isolés concernés ; aucun binaire réel installé |
| `AGENTS.md` | Inchangé ; règles Bash, OpenSpec, documentation et validation appliquées |
| `PROJECT.md` | Inchangé ; l'architecture DIU et le point d'entrée restent exacts |
| `TECHNICAL.md` | Mis à jour ; décrit la détection et l'installation OpenCode V2 |
| `BUILD.md` | Inchangé ; le packaging Debian n'est pas affecté |
| `DEVOPS.md` | Non modifié ; rapport généré préexistant et modification locale préservés |
| `README.md` | Inchangé ; ne documente pas le mécanisme d'installation OpenCode |
| `CHANGELOG.md` | Mis à jour dans `Unreleased`, sans inventer de version de livraison |
| `openspec/config.yaml` | Inchangé ; schéma `spec-driven` conservé |
| `openspec/specs/devops-opencode/spec.md` | Nouvelle capacité synchronisée ; validation stricte réussie |
| Change OpenSpec | Archivé sous `2026-10-28-upgrade-devops-opencode-v2`, `specsUpdated=true`, quatre exigences ajoutées, aucune modifiée, supprimée ou renommée |

L'archivage a réussi avec le chemin explicite du projet. L'archive contient les artefacts OpenSpec et le rapport à six sections. Les 12 fichiers déclarés, les totaux de tests et les résultats sont vérifiés à partir des sorties observées ; aucun décompte de lignes Git n'est produit dans ce rapport.

## 6. Limites et clôture

L'évolution est implémentée, ses contrôles ciblés réussissent et le change est archivé. La suite complète de tests et la validation OpenSpec stricte globale échouent sur des éléments hors des fichiers de ce change ; ces résultats restent visibles et ne sont pas présentés comme des succès. Aucun déploiement ou installation OpenCode réelle n'a été effectué.

L'étape de commit local SCM est bloquée : les prérequis non secrets étaient valides et `main` correspond à `LOCAL_DEFAULT_BRANCH`, mais `git status --short` montre aussi le chemin préexistant `DEVOPS.md` modifié. La procédure impose `git add .`, ce qui inclurait ce fichier hors périmètre. Aucun `git config`, staging, commit, tag ou push n'a été exécuté. Forgejo, GitHub et GitLab n'ont pas été sollicités faute de commit local vérifié.
