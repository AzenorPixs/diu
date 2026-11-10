# STATISTIQUES — add-project-orchestrated-coding

Session SCM directe sur DIU. Périmètre proposé puis explicitement validé par
le développeur avec « Je valide » : spécification, implémentation, tests,
documentation, synchronisation, archivage et présent rapport. Le nom définitif
`PROJECT_ORCHESTRATED_CODING` a été corrigé par le développeur avant écriture.
Aucune compétence ni télémétrie de session pilotée n'a été invoquée.

## 1. Statistiques générales et décisions

| Mesure | Valeur |
| --- | ---: |
| Tests distincts des exécutions finales | 69 |
| Tests finaux réussis / échoués / ignorés | 69 / 0 / 0 |
| Exécutions de méthodes, répétitions comprises | 85 |
| Exécutions réussies / échouées / ignorées | 85 / 0 / 0 |
| Tâches du change prouvées et cochées | 6 / 6 |
| Archives réalisées | 1 |
| Exigences ajoutées / modifiées / retirées / renommées | 5 / 2 / 0 / 0 |
| Fichiers préexistants modifiés dans le périmètre | 7 |
| Fichiers nouveaux livrés, rapport compris | 8 |
| Total des fichiers livrés | 15 |

Agent unique : Codex ; aucun sous-agent ni agent orchestrateur distinct.
Durée totale, temps actif, tokens, coût, quotas, modèle exact et niveau de
raisonnement : N/A, absence de chronométrage initial et de télémétrie
exploitable. Aucun chiffre de performance n'est estimé.

## 2. Messages et outils

Comptages exhaustifs des messages et appels d'outils : N/A, aucun journal
exhaustif exporté. Les preuves de validations sont les résultats natifs des
commandes exécutées dans cette session. Les écritures ont utilisé apply_patch ;
les contrôles de périmètre ont comparé des contenus témoins en mémoire sans Git.

La première suite ciblée comportait 16 méthodes réussies. Après ajout du cas
de fichier illisible et restriction des commentaires accolés à une valeur,
la suite finale comportait 17 méthodes réussies. Les trois suites de
non-régression ajoutent 26, 9 et 17 réussites. Aucun test n'a été affaibli.

## 3. Fichiers modifiés

Sept fichiers préexistants sont modifiés :

- `modules/projects/projects.sh` : lecteur littéral, questionnaire partagé et
  intégration à `update_projects`, déjà utilisé par la création ;
- `modules/projects/git.sh` : conservation et questionnement dans
  `git_update_legacy`, résumé et persistance ;
- `TECHNICAL.md` : section Projets et configuration Git / Métadonnées générales ;
- `README.md` : présentation du mode et des commandes de configuration ;
- `CHANGELOG.md` : entrée Unreleased ;
- `openspec/specs/implement-projects-update/spec.md` : un bloc modifié et cinq
  exigences ajoutées, sept exigences canoniques au total ;
- `openspec/specs/projects-general-update/spec.md` : questionnaire ciblé
  adapté, exigence générale non ciblée conservée, deux exigences au total.

Huit fichiers nouveaux livrés : `tests/test_projects_orchestrated_coding.py`
et les sept fichiers de cette archive : `.openspec.yaml`, `proposal.md`,
`design.md`, `tasks.md`, les deux deltas `specs/*/spec.md` et `STATISTIQUES.md`.
Les six artefacts du change ont été déplacés par OpenSpec ; aucun second change
n'a été créé et aucun autre change actif n'a été archivé.

Le contrôle initial a conservé quatorze témoins ciblés. Avant synchronisation,
cinq différaient et neuf étaient identiques ; après synchronisation, sept
diffèrent et sept restent identiques. Dans les scripts, seuls les quatre
corps de fonctions prévus ont changé. Les trois documents ne comportent que
des insertions. Les exigences canoniques non ciblées sont conservées.
Ce contrôle porte sur ces témoins, sans prétendre inventorier tout le dépôt.

## 4. Commandes et validations

| Validation | État et preuve |
| --- | --- |
| `bash -n modules/projects/projects.sh` | Exécutée et réussie |
| `bash -n modules/projects/git.sh` | Exécutée et réussie |
| `python3 -m py_compile tests/test_projects_orchestrated_coding.py` | Exécutée et réussie avec le Python DevOps et un cache temporaire sous la racine, supprimé ensuite |
| ShellCheck des quatre fonctions modifiées | Exécutée et réussie, aucun diagnostic, sans exclusion de règle |
| ShellCheck des deux fichiers complets | Exécutée et échouée, mêmes quatre diagnostics préexistants avant/après |
| Change OpenSpec strict avant code et avant archive | Exécutée et réussie après découpage initial des exigences longues |
| Archivage avec synchronisation des canons | Exécutée et réussie, `specsUpdated: true` |
| Canon implement-projects-update strict après archive | Exécutée et réussie |
| Canon projects-general-update strict avant/après | Exécutée et échouée avec le même avertissement préexistant sur requirements[0] |
| Canon projects-general-update non strict après archive | Exécutée et réussie, avec cet avertissement signalé |
| Périmètre, cohérence documentaire et UTF-8/LF | Contrôlés sur les fichiers ciblés |
| Construction, déploiement, navigateur, base réelle | Non exécutés, non pertinents pour cette métadonnée Bash |

Diagnostics hérités ShellCheck, conservés hors périmètre : SC2004 sur
`keys[${index}]`, SC2034 sur `link_http_code`, SC2269 sur l'auto-affectation
`local_api_url`, SC2086 sur `mkdir -p ${project_path}`. Le décalage de ligne
du dernier diagnostic correspond à l'insertion dans le parcours historique.
Les fonctions contrôlées séparément sont `project_orchestrated_coding_get`,
`project_orchestrated_coding_prompt`, `update_projects` et `git_update_legacy`.

Le premier contrôle du change strict a retourné 1 pour deux exigences de plus
de 500 caractères, corrigées avant code. Les sept blocs ajoutés ou modifiés
ont finalement des textes de 290 à 459 caractères. L'avertissement canonique
restant concerne la première exigence inchangée de projects-general-update ;
aucune validation stricte globale du dépôt n'est revendiquée.

| Suite finale unittest | Réussis | Échecs | Ignorés |
| --- | ---: | ---: | ---: |
| test_projects_orchestrated_coding.py | 17 | 0 | 0 |
| test_projects.py | 26 | 0 | 0 |
| test_projects_general_update.py | 9 | 0 | 0 |
| test_projects_template_openspec.py | 17 | 0 | 0 |
| Total | 69 | 0 | 0 |

Commandes reproductibles depuis la racine DIU :

```text
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_orchestrated_coding.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_general_update.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_openspec.py -v
```

OpenSpec a utilisé les binaires déclarés dans DEVOPS.md, avec
`OPENSPEC_TELEMETRY=0` et `DO_NOT_TRACK=1` :

```text
/home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec validate add-project-orchestrated-coding --type change --strict
/home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive add-project-orchestrated-coding --yes --json
/home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec validate implement-projects-update --type spec --strict
/home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec validate projects-general-update --type spec --strict
/home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec validate projects-general-update --type spec
```

L'archivage autorisé a conservé la validation et la synchronisation ; aucune
option `--skip-specs` ou `--no-validate` n'a été employée. Aucun changement de
compte utilisateur n'est revendiqué : les binaires déclarés ont été exécutés
dans le contexte effectif fourni par la plateforme.

## 5. Accès web et effets externes

Aucun accès web, appel API distant, téléchargement, installation système,
publication, activation OpenCode/CAB, migration ou modification d'un
`project.env` réel n'a été réalisé. Les tests utilisent des configurations
synthétiques et des doubles des opérations externes. Les nouvelles fixtures
et le cache de compilation résident sous la racine ; les suites existantes
utilisent leurs temporaires habituels et les nettoient.

Écart de protocole : une inspection initiale `git status --short` a été
exécutée avant lecture de l'interdiction SCM. Elle n'a pas été répétée ; aucune
écriture Git, préparation de commit, branche, commit ou push n'a été effectué.
Les contrôles ultérieurs se sont limités à des comparaisons sans Git. Les
modifications préexistantes des cadrages ont été préservées.

## 6. Synthèse globale et cohérence documentaire

L'objectif validé est livré dans les sources : question à la création et à la
configuration, défaut No, conservation de Yes, rejet des autres valeurs,
lecture sans exécution ni héritage d'un autre projet, préservation des autres
variables et des parcours Git locaux. Les projets historiques restent valides
et seront enrichis lors de leur prochaine configuration interactive.

| Élément | État et preuve |
| --- | --- |
| Projet réel | Deux scripts adaptés ; 69 tests finaux réussis sur projets synthétiques, sans déploiement |
| AGENTS.md | Inchangé par cette session, témoin identique ; règles générales conservées |
| PROJECT.md | Inchangé, témoin identique ; Architecture fonctionnelle / Module projects couvre cette responsabilité |
| TECHNICAL.md | Mis à jour, Projets et configuration Git / Métadonnées générales décrit variable, défaut et lecteur |
| BUILD.md | Inchangé, témoin identique ; Objet et périmètre reste la construction du paquet, aucune dépendance ni chaîne de build changée |
| DEVOPS.md | Inchangé par cette session, témoin identique ; inventaire généré et chemins des runtimes conservés |
| README.md | Mis à jour avec création, mise à jour et signification Yes/No |
| CHANGELOG.md | Mis à jour dans Unreleased, sans inventer de version de publication |
| OpenSpec | Deux canons synchronisés, sept blocs du delta concordants, six tâches cochées et une archive |
| ancien protocole local | Inchangé, témoin identique ; cette session directe ne nécessite pas son activation |

Totaux : 17 + 26 + 9 + 17 = 69 tests finaux ; 16 + 69 = 85 exécutions
réussies ; 7 fichiers préexistants + 8 nouveaux = 15 fichiers livrés ;
5 exigences ajoutées + 2 modifiées, aucune retirée ni renommée.
Les six sections, l'encodage UTF-8, les fins de ligne LF, les tâches, la
concordance des deltas avec les canons et ces totaux font l'objet du contrôle
final du rapport et de l'archive.

Limites : diagnostics hérités signalés et conservés, absence de qualification
globale ou de production, aucune migration massive de fichiers locaux. Ces
limites ne remettent pas en cause la validation ciblée de l'évolution.
