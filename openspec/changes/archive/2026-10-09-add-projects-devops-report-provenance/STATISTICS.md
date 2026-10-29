# STATISTIQUES — add-projects-devops-report-provenance

Session SCM directe sur DIU, sans pilotage OpenCode/CAB ni compétence coding-session-statistics. Périmètre : évolution approuvée de la génération DEVOPS.md, version documentaire 0.3, tests, documentation, synchronisation et archivage. La création du change dédié malgré les autres changes actifs et son archivage ont été explicitement validés.

## 1. Statistiques générales et décisions

| Mesure | Valeur |
| --- | --- |
| Début de la fenêtre mesurée UTC | 2026-10-09 06:14:21 UTC |
| Fin de la fenêtre mesurée UTC | 2026-10-09 06:55:10 UTC |
| Début Europe/Paris | 09/10/2026 08:14:21 |
| Fin Europe/Paris | 09/10/2026 08:55:10 |
| Durée mesurée | 00:40:49 |
| Tests finaux réussis | 83 |
| Échecs et tests ignorés des exécutions finales | 0 / 0 |
| Prérequis OpenSpec prouvés et cochés | 6 / 6 |
| Archives réalisées | 1 |
| Exigences canoniques ajoutées / modifiées / retirées | 3 / 2 / 0 |

La fenêtre commence au premier horodatage mesuré après validation du développeur. Elle ne mesure pas l'exploration préalable, l'attente de validation, ni la rédaction et les contrôles de ce rapport. Sa durée inclut outils et attentes ; ce n'est pas un temps de génération active.

Agent unique : Codex. Fournisseur : OpenAI. Modèle exact, version et niveau de raisonnement : N/A, non exposés de façon exploitable. Tokens, coût, TTMT, débit et temps de service : N/A, non mesurés ; aucune télémétrie de pilotage n'a été lancée. Aucun agent orchestrateur distinct ni sous-agent n'est intervenu.

## 2. Messages et outils

Les nombres exhaustifs de messages et d'appels d'outils sont N/A : aucun journal complet de conversation n'a été exporté. Le registre local borné contient 30 invocations de commande suivies : 24 sorties natives 0, 5 sorties natives non nulles et 1 tentative rejetée avant lancement. Il contient également 6 opérations apply_patch. Ces comptes ne sont pas un total exhaustif des lectures et des sondages de processus.

Les cinq sorties non nulles sont les trois contrôles globaux OpenSpec stricts, le premier ShellCheck et le premier passage de la suite DevOps. Le premier contrôle du diff dépassait la limite système des arguments ; il n'a pas été exécuté et a été remplacé par un contrôle limité aux cinq empreintes concernées.

Tests, en comptant les répétitions réellement exécutées : 132 exécutions de méthodes, soit 129 réussies, 1 en échec et 2 ignorées. Le premier passage DevOps comptait 49 méthodes : 46 réussies, 1 échec de fixture et 2 sondes Go ignorées. Après ajout de l'horloge factice au jeu de binaires contenant des espaces et utilisation des chemins runtime déclarés, les 49 méthodes ont toutes réussi. Les régressions ajoutent 17 + 8 + 9 réussites. Les 83 méthodes distinctes des exécutions finales sont réussies.

## 3. Fichiers modifiés

Six fichiers préexistants sont modifiés :

- modules/projects/template.sh : capture UTC bornée, classification contrôlée et en-tête 0.3 ;
- tests/test_projects_template_devops.py : six nouvelles méthodes, horloge déterministe et attentes des trois parcours ;
- TECHNICAL.md : section Traçabilité du document DevOps ;
- README.md : commande de génération et portée de l'inventaire ;
- CHANGELOG.md : entrée Unreleased, sans version de release inventée ;
- openspec/specs/projects-template-devops/spec.md : deux exigences adaptées et trois ajoutées.

Les cinq artefacts créés sous openspec/changes/add-projects-devops-report-provenance ont été déplacés par l'archivage vers openspec/changes/archive/2026-10-09-add-projects-devops-report-provenance : .openspec.yaml, proposal.md, design.md, tasks.md et specs/projects-template-devops/spec.md. Ce STATISTIQUES.md est le sixième fichier de l'archive.

Le contrôle avant archivage a comparé 661 fichiers sources témoins : seules les cinq cibles préexistantes approuvées étaient modifiées, plus les cinq artefacts du change. La synchronisation a ensuite modifié le seul canon autorisé. Aucun DEVOPS.md réel n'a été retouché ou régénéré pendant cette session ; les documents recevront 0.3 lors de leur prochaine génération avec ce code.

## 4. Commandes et validations

Registre borné des commandes suivies, avant rédaction de ce rapport :

| Opération | Code natif ou résultat |
| --- | --- |
| Baseline des sources autorisées et règles locales | 0 |
| OpenSpec global strict avant changement | 1 |
| Création du change ciblé | 0 |
| Écriture des quatre artefacts OpenSpec autorisés | 0 |
| Validation stricte du change avant code | 0 |
| Contrôle des artefacts et des cibles avant code | 0 |
| Tâche de spécification cochée après preuves | 0 |
| Syntaxe Bash du générateur | 0 |
| ShellCheck du générateur | 1 |
| Syntaxe Bash après correction de citation | 0 |
| ShellCheck après correction de citation | 0 |
| py_compile réel avec cache temporaire supprimé | 0 |
| Suite DevOps ciblée | 1 |
| Suite DevOps corrigée avec runtimes déclarés | 0 |
| Compilation Python finale après adaptation du jeu de test | 0 |
| Régression des modèles OpenSpec | 0 |
| Régression de tous les modèles par projet | 0 |
| Régression de la mise à jour générale des projets | 0 |
| Tâches prouvées et séparation des opérations postérieures à l'archivage | 0 |
| Premier contrôle du diff rejeté avant lancement : argument trop long | Non exécutée — rejet système avant lancement |
| Diff sans Git et originaux vérifiés par empreintes | 0 |
| Validation stricte finale du change ciblé | 0 |
| Contrôle global strict avant archivage, diagnostics préexistants identiques | 1 |
| Périmètre, UTF-8/LF et nettoyage contrôlés avant archivage | 0 |
| Options d'archivage vérifiées | 0 |
| Prérequis achevés et preuves consignées avant archivage | 0 |
| Synchronisation canonique et archivage du change ciblé | 0 |
| Validation du canon synchronisé | 0 |
| Contrôle global strict après archivage | 1 |
| Archive, six tâches et cinq blocs canoniques vérifiés | 0 |

Validations fonctionnelles finales :

| Suite unittest | Réussis | Échecs | Ignorés |
| --- | ---: | ---: | ---: |
| test_projects_template_devops.py | 49 | 0 | 0 |
| test_projects_template_openspec.py | 17 | 0 | 0 |
| test_projects_template_all.py | 8 | 0 | 0 |
| test_projects_general_update.py | 9 | 0 | 0 |
| Total final | 83 | 0 | 0 |

Commandes reproductibles, depuis la racine DIU :

```text
bash -n modules/projects/template.sh
shellcheck modules/projects/template.sh
/usr/bin/env DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node DIU_TEST_PYTHON3=/home/devops/python/current/bin/python3 /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_openspec.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_all.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_general_update.py -v
```

py_compile a été réellement exécuté via -m py_compile avec un préfixe de cache temporaire sous la racine, nettoyé après chacun des deux passages. Les contrôles finaux de syntaxe, ShellCheck et compilation réussissent. L'avertissement initial ShellCheck sur une apostrophe Unicode a été corrigé sans désactivation de contrôle.

OpenSpec utilise /home/devops/.local/npm/bin/openspec sous le compte devops, avec le Node déclaré, OPENSPEC_TELEMETRY=0 et DO_NOT_TRACK=1. Le change ciblé passe en strict avant code et en final, sans issue. L'archivage avec --yes --json conserve la validation et synchronise réellement le canon ; aucun --no-validate ni --skip-specs n'a été utilisé.

Le canon synchronisé passe en non strict avec huit avertissements de longueur hérités. Le global strict retourne réellement 1 : trois ERROR préexistants dans add-projects-forgejo-clone et modify-projects-forgejo-push-force-with-lease, 53 WARNING et 1 INFO. Avant travail, les mêmes trois ERROR étaient présents avec 55 WARNING et 1 INFO. Les deux avertissements supprimés concernent seulement les exigences modifiées de ce change. Aucun succès strict global n'est revendiqué.

## 5. Accès web et effets externes

Aucun outil web ni commande de téléchargement, API distante, installation système, publication, Docker, migration de base ou opération Git n'a été lancé. Les transports de la plateforme LLM ne sont pas assimilés à des visites web ; leur comptage est N/A, non exposé.

Les tests emploient des projets et données synthétiques sous la racine DIU, avec des doubles pour les sondes serveur et les outils des documents. Les tests runtime utilisent les exécutables déclarés et des environnements temporaires. Aucun serveur PostgreSQL réel ni navigateur de test n'est requis par cette évolution. Les temporaires test/compilation étaient absents au contrôle préalable à l'archivage.

## 6. Synthèse globale et cohérence documentaire

L'objectif approuvé est réalisé dans les sources : en-tête 0.3, provenance DIU, début UTC capturé une seule fois, contexte fermé et légende d'interprétation. Le contenu technique reste stable hors horodatage. Une capture impossible conserve l'ancien document ; les droits, propriétaires, sondes et interfaces sont préservés. Les cinq blocs approuvés sont identiques dans le delta archivé et le canon de 14 exigences.

| Document / élément | État et justification |
| --- | --- |
| Projet réel | Générateur et tests mis à jour ; 83 méthodes finales réussies. |
| AGENTS.md | Inchangé : règles de sécurité, racine et autorisations respectées. |
| PROJECT.md | Inchangé : la responsabilité du module projects est conservée. |
| TECHNICAL.md | Mis à jour : section Traçabilité du document DevOps. |
| BUILD.md | Inchangé : module déjà inclus dans la liste blanche, aucune dépendance ajoutée ; écarts de packaging déjà documentés hors périmètre. |
| DEVOPS.md | Inchangé : inventaire généré antérieurement, pas de retouche manuelle ni génération sur un projet réel. |
| README.md | Mis à jour : génération et limites du relevé. |
| CHANGELOG.md | Mis à jour : entrée Unreleased pour le format documentaire 0.3. |
| OpenSpec | Canon synchronisé, change archivé, six prérequis cochés après preuves. |

Totaux vérifiables : 49 + 17 + 8 + 9 = 83 tests finaux ; 46 + 83 = 129 réussites sur 132 exécutions, avec 1 échec initial et 2 ignorés initiaux ; 24 + 5 + 1 = 30 invocations suivies. Un archivage, aucune exigence retirée ou renommée. Aucun token, coût ou quota estimé.

Limites restantes : les erreurs globales et avertissements hérités hors périmètre sont conservés et signalés. Aucun déploiement ou build de paquet n'a été réalisé. La cohérence et la validation annoncées concernent cette évolution ciblée, pas une qualification globale du dépôt ni une qualification de production.
