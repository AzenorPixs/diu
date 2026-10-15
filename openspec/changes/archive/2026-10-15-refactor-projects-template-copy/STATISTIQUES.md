# STATISTIQUES — refactor-projects-template-copy

Session SCM directe du 15 octobre 2026 sur Debian Installeur Unifié.
L'exclusion porte uniquement sur l'entrée `.git` à la racine du modèle.

## 1. Statistiques générales et décisions

| Mesure | Valeur |
| --- | ---: |
| Méthodes de test distinctes couvertes | 141 |
| Méthodes finalement réussies / échouées / ignorées | 141 / 0 / 0 |
| Exécutions de méthodes, répétitions comprises | 144 |
| Exécutions réussies / échouées / ignorées | 141 / 1 / 2 |
| Tâches du change cochées | 3 / 3 |
| Archives réalisées | 1 |
| Exigences ajoutées / modifiées / retirées / renommées | 1 / 0 / 0 / 0 |
| Fichiers préexistants modifiés et conservés en place | 5 |
| Fichiers du change déplacés dans l'archive | 6 |
| Nouveaux fichiers : canon et rapport | 2 |
| Total des fichiers livrés aux chemins finaux | 13 |

Agent unique : Codex ; aucun sous-agent. Durée globale, tokens, coût et quotas :
N/A, aucune télémétrie de session exportée. Les durées ci-dessous proviennent
uniquement des sorties unittest. Aucune compétence de statistiques de pilotage
ni aucun service OpenCode/CAB n'a été utilisé.

## 2. Messages et outils

Comptages exhaustifs des messages et appels d'outils : N/A, aucun journal
exhaustif exporté. Les écritures utilisent apply_patch ; les validations
utilisent les outils natifs du projet.

Le test de régression a d'abord échoué sur la présence du `.git` copié,
avant la correction : 1 méthode, 1 échec, 0,075 s. Les suites après correction
ont ensuite réussi. Deux méthodes Go ignorées dans la première exécution
DevOps ont été relancées avec le binaire déclaré dans DEVOPS.md et ont réussi.
Aucun test n'a été affaibli pour obtenir un succès.

## 3. Fichiers modifiés

Cinq fichiers modifiés et conservés en place :

- `modules/projects/projects.sh` : ajout de `! -name .git` dans la sélection
  de premier niveau du modèle par create_project ;
- `tests/test_projects.py` : modèle contenant un `.git` factice et un
  `.gitignore`, assertions d'exclusion et de préservation du modèle, témoin
  signalant tout appel Git inattendu ;
- `TECHNICAL.md` : sélection de copie et limite aux métadonnées racine ;
- `README.md` : comportement de création et portée de l'exclusion ;
- `CHANGELOG.md` : entrée Unreleased, sans nouvelle version de publication.

Les six fichiers du change sont déplacés par OpenSpec : `.openspec.yaml`,
`README.md`, `proposal.md`, `design.md`, `tasks.md` et
`specs/projects-template-creation/spec.md`. Seul tasks.md est modifié avant
ce déplacement, avec trois tâches cochées. Le canon
`openspec/specs/projects-template-creation/spec.md` et ce rapport sont créés.
Aucun fichier métier n'est supprimé.

Le contrôle repose sur les empreintes initiales de 19 fichiers ciblés, puis
sur la comparaison des contenus après retrait en mémoire des seuls ajouts
attendus. Il couvre les cadrages, le code concerné, les témoins template.sh
et git.sh, le test et les six artefacts du change. Il ne constitue pas un
inventaire exhaustif du dépôt. Les modifications préexistantes des cadrages
sont préservées.

## 4. Commandes et validations

Les suites utilisent `/home/devops/python/current/bin/python3 -B` :

| Suite | Méthodes | Résultat | Durée unittest |
| --- | ---: | --- | ---: |
| `tests/test_projects.py` | 26 | 26 réussites | 2,992 s |
| `tests/test_projects_orchestrated_copy.py` | 10 | 10 réussites | 1,645 s |
| `tests/test_projects_template_openspec.py` | 17 | 17 réussites | 2,442 s |
| `tests/test_projects_template_devops.py` | 88 | 86 réussites, 2 ignorées initialement | 99,517 s |
| Deux méthodes Go de la suite DevOps | 2 | 2 réussites à la relance | 0,113 s |

Relance exacte des deux méthodes ignorées, avec le binaire Go déclaré :

```bash
env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py -v ProjectsTemplateDevopsRuntimeTests.test_real_go_version_from_inaccessible_caller_directory ProjectsTemplateDevopsRuntimeTests.test_runuser_execution_envelope_preserves_arguments_and_changes_child_directory
```

| Validation | État et preuve |
| --- | --- |
| `bash -n modules/projects/projects.sh` | Exécutée et réussie |
| `shellcheck modules/projects/projects.sh` | Exécutée et réussie, fichier complet |
| Compilation Python de tests/test_projects.py | Exécutée et réussie par py_compile.compile avec doraise=True ; cache temporaire nettoyé |
| Change strict avant code et avant archive | Exécutée et réussie deux fois |
| Archivage avec synchronisation | Exécutée et réussie ; specsUpdated=true, 1 exigence ajoutée |
| Canon projects-template-creation strict | Exécutée et réussie |
| Concordance canon/delta archivé | Bloc d'exigence identique, vérifié à la clôture |
| UTF-8/LF, tâches, six sections et totaux | Contrôlés à la clôture |
| Build Debian, navigateur et déploiement | Non exécutés, non pertinents pour cette sélection de fichiers |

OpenSpec utilise `/home/devops/.local/npm/bin/openspec`, avec
OPENSPEC_TELEMETRY=0 et DO_NOT_TRACK=1 :

```text
openspec validate refactor-projects-template-copy --type change --strict
openspec archive refactor-projects-template-copy --yes --json
openspec validate projects-template-creation --type spec --strict
```

Aucune validation globale de toutes les capacités OpenSpec n'est revendiquée.

## 5. Accès web et effets externes

Aucun accès web, appel API métier, installation, publication ou déploiement.
Les tests utilisent leurs fixtures temporaires habituelles ; les opérations
de création testées simulent notamment les droits et les étapes externes.
Les caches de compilation sont temporaires et nettoyés. Aucun projet réel,
ni le modèle réel, ni le projet test déjà créé n'est modifié.

Écart de protocole : git status --short a été exécuté au début de la reprise,
avant lecture du prompt SCM et de son interdiction d'inspection Git. Cet écart
a été signalé et l'inspection n'a pas été répétée. Les contrôles suivants
utilisent des empreintes ciblées. Aucune écriture Git, préparation de commit,
branche, commit ou push n'a été réalisée.

## 6. Synthèse globale et cohérence documentaire

La copie exclut `.git` avant tout transfert de son contenu. Le test démontre
l'absence de cette entrée dans le projet créé, la préservation du marqueur
dans le modèle et la copie de `.gitignore`. Les assertions antérieures de
personnalisation Markdown et de préservation de project.env restent actives.
Les suites de copie conditionnelle et de génération DevOps couvrent les règles
existantes de ORCHESTRATED_CODING.md et pyproject.toml, ainsi que des créations
depuis des modèles sans dépôt Git.

| Élément | État et preuve |
| --- | --- |
| Projet réel | Modification locale du code, 141 méthodes finalement réussies ; aucune création réelle ni installation |
| AGENTS.md | Inchangé durant la session, empreinte initiale préservée ; règles SCM et périmètre appliqués |
| PROJECT.md | Inchangé, empreinte préservée ; Architecture fonctionnelle / Module projects reste exact |
| TECHNICAL.md | Mis à jour dans Projets et configuration Git / Métadonnées générales |
| BUILD.md | Inchangé, empreinte préservée ; Objet limité à la construction du paquet, non affectée |
| DEVOPS.md | Inchangé, empreinte préservée ; chemins Python, Go et OpenSpec réutilisés |
| README.md | Mis à jour après la description de copie conditionnelle du modèle |
| CHANGELOG.md | Entrée Unreleased ajoutée |
| OpenSpec | 3 tâches cochées, 1 exigence synchronisée, 1 archive ; canon validé strictement |

Totaux : 26 + 10 + 17 + 88 = 141 méthodes distinctes. Les exécutions comptent
141 + 1 régression initiale + 2 relances Go = 144 ; 141 réussites + 1 échec
initial + 2 ignorées initiales = 144. Fichiers finaux : 5 conservés en place
+ 6 déplacés + 2 créés = 13, dont 7 dans cette archive.

Limites : les `.git` imbriqués restent copiés ; les projets existants ne sont
pas nettoyés ; la correction locale n'est pas déployée dans l'installation rid.
La cohérence attestée concerne uniquement le périmètre de cette évolution.
