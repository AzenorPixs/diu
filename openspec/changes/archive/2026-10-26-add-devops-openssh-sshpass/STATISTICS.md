# STATISTIQUES — OpenSSH et SSHPASS dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`), racine `/home/devops/datas/diu`.
- Session : SCM directe, version 0.1, ajout OpenSSH/SSHPASS, date de clôture technique : 26 octobre 2026.
- Change : `add-devops-openssh-sshpass` ; archive : `2026-10-26-add-devops-openssh-sshpass`.
- Demande initiale : ajouter quatre puces après LXC ; périmètre proposé puis explicitement validé par « je valide ».
- Périmètre validé : rubrique permanente avant Docker-Compose, sondes locales -V, gestion des erreurs, tests, documentation, cycle OpenSpec et statistiques. Les étapes Git conditionnelles du prompt suivent la clôture technique.
- Aucun pilotage OpenCode, mandat CAB ou sous-agent ; la compétence de statistiques pilotées n’a pas été invoquée conformément à SCM.

## 2. Durées et mesures disponibles

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée totale de session | N/A | Aucun chronométrage complet fiable enregistré |
| Première exécution ciblée SSH | 4 tests, 2,753 s | Sortie unittest, succès |
| Exécution ciblée SSH finale | 5 tests, 2,889 s | Sortie unittest, succès |
| Suite complète du générateur | 126 cas, 88,647 s | 124 réussites, 2 ignorés faute de Go dans PATH |
| Complément des deux cas ignorés | 2 tests, 0,035 s | Chemin Go déclaré fourni explicitement ; succès |
| Cas uniques couverts avec succès | 126 | Les deux cas complètent ceux ignorés ; pas d’addition artificielle à 128 |
| Nouveaux cas uniques SSH | 5 | Inclus dans la suite de 126 |
| Exécutions de cas cumulées | 137 | 4 + 5 + 126 + 2 ; dont 135 succès et 2 ignorés |
| Modèle, jetons et coût | N/A | Pas de télémétrie complète accessible et qualifiée |
| Messages, outils et commandes totaux | N/A | Pas de compteur exhaustif fiable ; ne pas déduire du nombre de commandes listées |
| Approbations/refus CAB | Non applicable | Session SCM directe |
| Accès web de l’agent | 0 | Aucun outil de recherche web utilisé pour cette amélioration |

## 3. Fichiers et comportement livré

Six fichiers existants modifiés et cinq fichiers dans la nouvelle archive, rapport inclus : onze fichiers au total. Aucun autre change actif modifié. Les différences ci-dessous sont calculées sur les sauvegardes ciblées prises avant écriture, sans attribution des travaux antérieurs du dépôt.

| Fichier existant | Lignes ajoutées | Lignes retirées |
| --- | ---: | ---: |
| modules/projects/template.sh | 49 | 2 |
| tests/test_projects_template_devops.py | 96 | 4 |
| TECHNICAL.md | 13 | 1 |
| README.md | 13 | 1 |
| CHANGELOG.md | 7 | 0 |
| openspec/specs/projects-template-devops/spec.md | 36 | 5 |

L’archive contient `proposal.md`, `design.md`, `tasks.md`, `specs/projects-template-devops/spec.md` et ce `STATISTIQUES.md`.

La rubrique contient exactement version OpenSSH, chemin ssh, version sshpass et chemin sshpass. Elle suit LXC lorsque présent et précède Docker-Compose même sans conteneurs. Le helper capture stderr pour OpenSSH et ne retient que la version de la première ligne reconnue. Les chemins sont résolus par le PATH système contrôlé existant. Aucun numéro de version n’est codé en dur dans le générateur. Les sondes restent locales, sans hôte cible ni identifiant, avec une limite de 15 secondes par outil.

Observation réelle du helper : `10.0p2`, `/usr/bin/ssh`, `1.10`, `/usr/bin/sshpass`. Les documents déjà générés ne sont pas régénérés pendant cette session ; le nouveau rendu sera appliqué à leur prochaine génération normale. Format 0.7 conservé.

## 4. Tests et vérifications

| Contrôle | État et résultat |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi |
| Compilation Python du fichier de tests | Exécutée et réussie avec `/home/devops/python/current/bin/python3 -m py_compile`, cache isolé dans le dossier temporaire de session |
| `python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_ssh` | Exécuté et réussi : 5 tests finaux |
| Suite complète du même fichier sans filtre | Exécutée et réussie : 126 cas, dont deux ignorés initialement |
| Complément avec `DIU_TEST_GO=/home/devops/go/current/bin/go`, filtres `real_go` et `runuser_execution` | Exécuté et réussi : 2 tests |
| Sonde réelle des deux binaires SSH | Exécutée et réussie ; quatre lignes vérifiées, sans connexion |
| Change OpenSpec strict, avant code puis avant archivage | Exécuté et réussi |
| Canon OpenSpec standard après archivage | Exécuté et réussi avec les huit avertissements de longueur préexistants |
| Validation stricte globale initiale | Exécutée et échouée : 46 valides, 22 échecs préexistants sur 68 éléments |
| Validation stricte globale avant archive | Exécutée et échouée : 47 valides, mêmes 22 échecs sur 69 éléments ; change ciblé valide |
| Validation stricte globale après archive | Exécutée et échouée : 46 valides, mêmes 22 échecs sur 68 éléments ; issues comparées exactement à celles précédant l’archive |
| Construction de paquet, installation et tests SSH distants | Non pertinents : rendu documentaire local, aucune modification de packaging ou transport |

Les tests couvrent les versions sur stderr et stdout, leur actualisation, la licence sshpass non publiée, les chemins avec espaces, les absences, sorties vides/mal formées, codes d’échec, fichier non exécutable sans chmod et expirations sans publication de sortie partielle. Les assertions d’ordre existantes sont adaptées au nouveau contrat et conservent les contrôles Docker/LXC. Les parcours individuel, groupé et final de création sont vérifiés par la suite existante.

## 5. Cohérence documentaire et archivage

| Élément | État final et preuve |
| --- | --- |
| Projet réel | Helper et quatre puces observés ; suite de rendu et régression réussie |
| AGENTS.md | Inchangé, règles de sécurité et modifications minimales applicables ; comparaison octet pour octet |
| PROJECT.md | Inchangé, module projects et architecture générale préservés ; comparaison octet pour octet ; SCM direct explicitement demandé |
| TECHNICAL.md | Mis à jour dans Traçabilité du document DevOps : ordre, sondes et limites |
| BUILD.md | Inchangé, construction du paquet hors périmètre ; comparaison octet pour octet |
| DEVOPS.md | Inchangé, inventaire daté au format 0.7 ; prochaine génération normale requise ; comparaison octet pour octet |
| README.md | Mis à jour dans la description de l’inventaire DevOps |
| CHANGELOG.md | Entrée concise ajoutée sous Unreleased, sans version de publication inventée |
| openspec/config.yaml | Inchangé, comparaison octet pour octet |
| openspec/specs/projects-template-devops/spec.md | Synchronisé : deux exigences ajoutées, trois modifiées, aucune supprimée ni renommée ; cinq blocs du delta retrouvés dans le canon |

Archivage effectué sous devops par `openspec archive add-devops-openssh-sshpass --yes --json`, code 0 et `specsUpdated=true`. Dossier d’archive présent et dossier actif absent. Les tâches de réalisation et de validation sont cochées sur preuves. Aucune autre archive n’a été modifiée.

Le présent rapport comporte six sections, utilise UTF-8/LF et ses totaux sont vérifiés. Aucun bilan `BLOCKER.md` ou `BLOCKERS.md` n’est présent dans cette archive ; aucun nettoyage de bilan n’est nécessaire.

## 6. Limites et clôture

L’amélioration est réalisée, testée et archivée. La validation globale stricte OpenSpec reste en échec pour les 22 éléments préexistants : avertissements de longueur/structure et deux deltas Forgejo omettant des scénarios. Ils ne sont pas corrigés dans ce périmètre. Les huit avertissements du canon concerné restent préexistants.

Aucun accès distant SSH, lecture d’identifiants SSH, installation, changement de permissions SSH, modification d’infrastructure ou régénération de DEVOPS.md n’a été effectué. Les sauvegardes et caches temporaires de session sont retirés avant les opérations Git ; leurs contenus n’entrent pas dans le commit.

Les étapes conditionnelles de commit local, Forgejo, GitHub et GitLab sont distinctes de l’archivage. Elles sont effectuées après ce rapport selon les variables autorisées de project.env ; leurs résultats réels et les éventuels blocages sont restitués dans le bilan final de session, sans prétendre ici qu’une publication a déjà réussi.
