# STATISTIQUES — inventory-project-javascript-dependencies-in-devops

Évolution DIU 0.5 exécutée directement par Codex après validation du développeur, mise en pause à sa demande, puis reprise et finalisée à sa demande. Aucun pilotage OpenCode/CAB ni sous-agent. Le périmètre reste le générateur DIU ; Pixs sert d'exemple et de vérification en lecture seule.

## 1. Statistiques générales et décisions

| Mesure | Valeur |
| --- | --- |
| Repère de la première phase UTC | 2026-10-09 09:38:30 UTC |
| Début mesuré de la reprise UTC | 2026-10-09 14:05:19 UTC |
| Fin mesurée de la reprise UTC | 2026-10-09 14:09:07 UTC |
| Début / fin de reprise Europe/Paris | 09/10/2026 16:05:19 / 16:09:07 (UTC+02:00) |
| Fenêtre de reprise mesurée | 00:03:48 |
| Durée active totale hors pause | N/A — instants de pause et temps de génération active non instrumentés |
| Tests distincts des suites finales | 122 |
| Échecs / ignorés finaux | 0 / 0 |
| Nouvelles méthodes JavaScript | 25 |
| Tâches achevées après preuves | 6 / 6 |
| Archives réalisées | 1 |
| Exigences ajoutées / modifiées / retirées / renommées | 19 / 2 / 0 / 0 |
| Exigences canoniques après synchronisation | 37 |

La fenêtre de reprise inclut lectures, commandes et attentes jusqu'à la validation OpenSpec finale. Elle exclut la rédaction et les contrôles de ce rapport. Elle ne représente pas un temps de génération active. Le repère initial ne permet pas de calculer une durée de travail excluant la pause.

Agent unique : Codex, fournisseur OpenAI. Modèle exact, version, effort, tokens, coût, TTMT, débit, temps de service et quotas : N/A, sans télémétrie exploitable. Ces valeurs ne sont pas estimées.

## 2. Messages et outils

Nombre exhaustif de messages, outils, commandes et approbations : N/A — aucun export complet de conversation ni registre instrumenté continu. La validation initiale du périmètre, la pause et la reprise sont explicites dans la conversation.

Les commandes de test observées exécutent 289 méthodes avec répétitions :
1 contrôle initial de structure, 22 tests JavaScript au premier passage, 22 au deuxième, puis 88 + 17 + 8 + 9 avant la pause et les mêmes quatre suites à la reprise.
Le premier passage JavaScript présente 7 échecs d'assertions concernant les échappements Markdown et un diagnostic de chemin ; les assertions sont corrigées et les passages suivants réussissent. Total : 282 réussites et 7 échecs initiaux, avec 122 tests distincts tous réussis en final.

La première validation stricte du delta signalait six exigences ajoutées trop longues ; elles ont été décomposées en exigences ciblées sans changer le périmètre. Un avertissement ShellCheck sur une apostrophe Unicode a été corrigé en préservant la chaîne affichée. Des erreurs de préparation de commandes ou de patch ont été corrigées avant l'application correspondante ; leur comptage exhaustif est N/A.

## 3. Fichiers modifiés

Six fichiers préexistants concernés par l'évolution complète :

- modules/projects/template.sh : collecteur JavaScript passif, inventaires NPM/OpenCode et format 0.5 ;
- tests/test_projects_template_devops.py : 25 nouvelles méthodes et adaptations des parcours existants ;
- TECHNICAL.md : découverte, sources, workspaces, verrous, installations locales et limites ;
- README.md : présentation du format 0.5 et des trois états de dépendance ;
- CHANGELOG.md : entrée Unreleased 0.5, historique conservé ;
- openspec/specs/projects-template-devops/spec.md : 19 ajouts, deux exigences adaptées et objet documentaire actualisé.

Les cinq artefacts du change ont été déplacés dans
openspec/changes/archive/2026-10-09-inventory-project-javascript-dependencies-in-devops :
.openspec.yaml, proposal.md, design.md, tasks.md et specs/projects-template-devops/spec.md.
Le présent STATISTIQUES.md est le sixième fichier de l'archive.

Le contrôle de reprise porte sur 603 fichiers témoins. Les cinq fichiers de code/tests/documentation étaient déjà modifiés avant la pause et restent inchangés pendant la finalisation. Les écritures de reprise concernent le delta, les tâches, le canon et ce rapport, avec le déplacement ciblé du change vers son archive. Les autres évolutions et archives sont préservées.

## 4. Commandes et validations

| Vérification finale | Résultat |
| --- | --- |
| bash -n modules/projects/template.sh | Code 0 |
| shellcheck modules/projects/template.sh | Code 0 |
| python -m py_compile du fichier de tests | Code 0, cache temporaire sous DIU puis nettoyé |
| Compilation sans exécution des programmes Python embarqués | Cinq programmes et la sonde venv compilés |
| Validation stricte du change | Code 0, aucune issue |
| Archivage normal --yes --json | Code 0, specsUpdated=true |
| Validation du canon synchronisé | Code 0, huit avertissements de longueur hérités |
| Comparaison du delta et du canon | 21 blocs conformes ; 37 exigences au total |
| Contrôle UTF-8/LF | Réussi sur les fichiers concernés |

| Suite finale relancée après la reprise | Réussis | Échecs | Ignorés |
| --- | ---: | ---: | ---: |
| test_projects_template_devops.py | 88 | 0 | 0 |
| test_projects_template_openspec.py | 17 | 0 | 0 |
| test_projects_template_all.py | 8 | 0 | 0 |
| test_projects_general_update.py | 9 | 0 | 0 |
| Total final | 122 | 0 | 0 |

Commandes reproductibles depuis /home/devops/datas/diu :

~~~text
bash -n modules/projects/template.sh
shellcheck modules/projects/template.sh
/usr/bin/env DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node DIU_TEST_PYTHON3=/home/devops/python/current/bin/python3 /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_openspec.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_all.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_general_update.py
~~~

Les tests couvrent les deux manifestes Pixs, les quatre catégories, les déclarations de moteurs et gestionnaire, workspaces, héritage des verrous, installations proches et partagées, alias, liens internes/pnpm/extérieurs, fichiers symboliques, JSON invalide/dupliqué, références privées, permissions, FIFO, limites, absence d'exécution et stabilité des générations. Les parcours individuel, groupé et de création sont exercés.

Avant la pause, le collecteur a aussi été exécuté seul sous devops sur Pixs, sans génération documentaire ni lecture de project.env : les quatre dépendances frontend et @opencode-ai/plugin ont été observées avec leurs versions verrouillées et chemins locaux.

OpenSpec est lancé sous devops avec OPENSPEC_TELEMETRY=0 et DO_NOT_TRACK=1. L'archivage conserve la validation et la synchronisation normales, sans skip-specs ni no-validate. La dernière tâche de synchronisation a été cochée après observation du canon et de sa validation.

Le global strict retourne 1 avant et après archivage avec les mêmes diagnostics : trois ERROR, 53 WARNING et un INFO. Les erreurs concernent add-projects-forgejo-clone et modify-projects-forgejo-push-force-with-lease, hors périmètre. Le nombre d'items passe de 67 à 66 après retrait du change actif ; aucun succès strict global n'est revendiqué.

## 5. Accès web et effets externes

Aucun accès web n'est lancé pendant l'implémentation ou sa reprise. L'analyse préalable à la validation a consulté les documentations officielles npm package.json, package-lock.json et OpenCode plugins ; ces sources fondent la proposition, pas une installation. Le comptage exhaustif des requêtes de cette analyse est N/A.

Aucune installation, opération Git, publication, déploiement, opération Docker ou migration de base n'est réalisée pour cette évolution. Les tests utilisent des fixtures régénérables sous la racine DIU. Le collecteur ne lance aucun gestionnaire ni code de paquet et n'effectue aucune requête réseau. Aucun fichier sensible réel n'est ouvert ; la vérification réelle Pixs reste limitée aux métadonnées désignées.

## 6. Synthèse globale et cohérence documentaire

Le format 0.5 distingue déclaration, verrou npm et observation locale. Les dépendances des composants apparaissent sous NPM, celles de .opencode/package.json sous OpenCode. La recherche est bornée et confinée au projet ; les états inconnus ne deviennent pas des absences certaines. Les formats de verrou autres que npm 2/3 sont signalés sans analyse de version. Les contraintes SemVer, la qualification fonctionnelle et le chargement des plugins restent hors de l'inventaire.

| Document / élément | État |
| --- | --- |
| Projet réel | Collecteur 0.5 implémenté ; 122 tests finaux réussis |
| AGENTS.md / PROJECT.md | Inchangés |
| TECHNICAL.md | Comportement et limites 0.5 documentés |
| BUILD.md | Inchangé ; aucune dépendance nouvelle |
| DEVOPS.md existants | Relevés antérieurs conservés ; format 0.5 à la prochaine génération avec ce code |
| README.md / CHANGELOG.md | Format et évolution 0.5 documentés |
| OpenSpec | 37 exigences canoniques, 21 blocs du delta conformes, six tâches achevées, archive unique |
| Autres changes et archives | Préservés par le contrôle de périmètre |

Totaux : 88 + 17 + 8 + 9 = 122 tests finaux ; 1 + 22 + 22 + 88 + 17 + 8 + 9 + 88 + 17 + 8 + 9 = 289 exécutions ; 282 + 7 = 289 ; 18 + 19 = 37 exigences canoniques. Aucune mesure de coût ou de tokens n'est estimée.
