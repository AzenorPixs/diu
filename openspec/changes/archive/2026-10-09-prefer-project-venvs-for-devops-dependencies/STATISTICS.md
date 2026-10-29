# STATISTIQUES — prefer-project-venvs-for-devops-dependencies

Session SCM directe, sans pilotage OpenCode/CAB ni compétence coding-session-statistics. Le développeur a validé le correctif, son change dédié, son implémentation, ses validations et son archivage, puis demandé explicitement le format documentaire 0.4. Aucun autre change n'a été repris.

## 1. Statistiques générales et décisions

| Mesure | Valeur |
| --- | --- |
| Début mesuré UTC | 2026-10-09 07:37:07 UTC |
| Fin mesurée UTC | 2026-10-09 08:33:18 UTC |
| Début Europe/Paris | 09/10/2026 09:37:07 |
| Fin Europe/Paris | 09/10/2026 10:33:18 |
| Durée de la fenêtre mesurée | 00:56:11 |
| Tests distincts des exécutions finales | 97 |
| Échecs / ignorés finaux | 0 / 0 |
| Nouvelles méthodes de test | 14 |
| Prérequis cochés après preuves | 6 / 6 |
| Archives réalisées | 1 |
| Exigences ajoutées / modifiées / retirées / renommées | 4 / 3 / 0 / 0 |

Cette fenêtre commence après validation du périmètre et inclut outils et attentes. Elle exclut l'exploration préalable, l'attente du développeur, ainsi que la rédaction et les contrôles du présent rapport. Ce n'est pas un temps de génération active.

Agent unique : Codex, fournisseur OpenAI ; modèle exact, version, niveau de raisonnement, tokens, coût, TTMT, débit et temps de service : N/A, non exposés ou non mesurés. Aucun sous-agent ni orchestrateur distinct. Aucune sonde de télémétrie de pilotage n'a été lancée.

## 2. Messages et outils

Nombre exhaustif de messages et d'outils : N/A, aucun export complet de conversation. Le registre local borné contient 22 invocations suivies : 18 codes natifs 0, 3 codes non nuls et 1 tentative rejetée avant lancement pour taille d'argument. Les lectures, éditions et sondages de processus ne sont pas comptés exhaustivement.

La comparaison des tests a été reprise en mémoire après ce rejet, sans écriture persistante ni appel Git. Une première construction de patch a également échoué en mémoire avant tout outil ou écriture ; sa correction n'a modifié aucun fichier hors périmètre.

Les validations fonctionnelles ont exécuté 170 méthodes avec répétitions : 11 tests venv ciblés, 62 méthodes du premier passage complet, 17 + 8 + 9 régressions, puis 63 méthodes du passage final après ajout de la protection site-packages manquant. Toutes ces exécutions ont réussi, sans échec ni test ignoré.

## 3. Fichiers modifiés

Six fichiers préexistants modifiés :

- modules/projects/template.sh : priorité des venv, sondes isolées/bornées, chemins observés, repli et diagnostics, format 0.4 ;
- tests/test_projects_template_devops.py : quatorze nouvelles méthodes et adaptations du format/protocole de test ;
- TECHNICAL.md : portée 0.4 et section Dépendances Python des environnements du projet ;
- README.md : priorité et provenance des dépendances ;
- CHANGELOG.md : nouvelle entrée Unreleased, conservation de l'entrée 0.3 ;
- openspec/specs/projects-template-devops/spec.md : quatre exigences ajoutées et trois adaptées.

Les cinq artefacts créés sous openspec/changes/prefer-project-venvs-for-devops-dependencies ont été déplacés vers openspec/changes/archive/2026-10-09-prefer-project-venvs-for-devops-dependencies : .openspec.yaml, proposal.md, design.md, tasks.md et specs/projects-template-devops/spec.md. Ce STATISTIQUES.md est le sixième fichier de l'archive.

Le contrôle avant archivage comparait 667 fichiers témoins : cinq modifications préexistantes et les cinq artefacts nouveaux seulement. Le canon a ensuite été synchronisé par OpenSpec. Les documents DEVOPS.md réels et les environnements de Pixs n'ont pas été modifiés ou sondés pendant cette session.

## 4. Commandes et validations

Registre borné avant rédaction de ce rapport :

| Action | Code natif ou statut |
| --- | --- |
| OpenSpec global strict initial | 1 |
| Création du change ciblé | 0 |
| Artefacts OpenSpec approuvés créés | 0 |
| Validation stricte avant code | 0 |
| Syntaxe Bash | 0 |
| ShellCheck | 0 |
| Tests ciblés venv | 0 |
| Syntaxe Bash finale | 0 |
| ShellCheck final | 0 |
| py_compile et deux programmes Python intégrés | 0 |
| Suite DevOps complète avec runtimes déclarés | 0 |
| Régression modèles OpenSpec | 0 |
| Régression tous modèles | 0 |
| Régression mise à jour générale | 0 |
| Compilation finale test et deux programmes Python | 0 |
| Suite DevOps finale après revue | 0 |
| Diff des tests : tentative rejetée avant lancement pour taille d'argument | Rejetée avant exécution |
| Validation stricte finale du change | 0 |
| Global strict avant archivage | 1 |
| Synchronisation canonique et archivage | 0 |
| Validation du canon synchronisé | 0 |
| Global strict final, diagnostics hérités identiques | 1 |

| Suite finale | Réussis | Échecs | Ignorés |
| --- | ---: | ---: | ---: |
| test_projects_template_devops.py | 63 | 0 | 0 |
| test_projects_template_openspec.py | 17 | 0 | 0 |
| test_projects_template_all.py | 8 | 0 | 0 |
| test_projects_general_update.py | 9 | 0 | 0 |
| Total final | 97 | 0 | 0 |

Commandes reproductibles depuis la racine :

```text
bash -n modules/projects/template.sh
shellcheck modules/projects/template.sh
/usr/bin/env DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node DIU_TEST_PYTHON3=/home/devops/python/current/bin/python3 /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_openspec.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_all.py -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_general_update.py -v
```

py_compile a réellement été exécuté via -m py_compile, avec cache temporaire sous la racine puis nettoyé. Le coordinateur Python et son programme de sonde ont aussi été compilés sans exécution. Syntaxe Bash et ShellCheck finaux : code 0.

Les tests utilisent des venv réels synthétiques créés sans pip sous la racine de test et des distributions factices. Ils vérifient le cas Pixs à quatre dépendances, priorité racine/sous-dossiers, environnements multiples, repli, Python DevOps absent, chemins avec espaces et alias Python, absence d'import/.pth, erreurs, métadonnées ambiguës, sites manquants, recherche incomplète et arrêt des descendants après délai.

OpenSpec est exécuté sous devops, au chemin déclaré, avec OPENSPEC_TELEMETRY=0 et DO_NOT_TRACK=1. Le change strict avant code et en final passe sans issue. L'archivage --yes --json conserve la validation et synchronise le canon : quatre ajouts, trois modifications, aucun retrait ou renommage. Le canon passe en non strict avec huit avertissements de longueur hérités.

Le global strict retourne réellement 1, avant et après : trois ERROR, 53 WARNING et 1 INFO identiques. Les ERROR concernent add-projects-forgejo-clone et modify-projects-forgejo-push-force-with-lease, hors de cette évolution. Aucun succès strict global n'est revendiqué.

## 5. Accès web et effets externes

Aucun outil web, téléchargement, API distante, installation système, opération Git, déploiement, Docker ou migration de base n'a été lancé. Les transports de la plateforme LLM ne sont pas assimilés à des visites web ; leur comptage est N/A.

Les environnements et métadonnées utilisés pour la validation sont synthétiques et isolés. Aucun script d'activation ou paquet applicatif n'est importé pour les sondes locales, et le test .pth vérifie l'absence d'effet. Aucun fichier sensible réel n'a été ouvert. Les temporaires test/compilation étaient absents au contrôle préalable à l'archivage.

## 6. Synthèse globale et cohérence documentaire

Le correctif validé est réalisé dans les sources. Chaque distribution observée localement prime sur le repli DevOps et indique son interpréteur, son environnement et son installation issue des métadonnées. Une recherche impossible ne devient pas une absence certaine. Le Python système sert éventuellement d'analyseur, sans fournir de paquets de repli. Les rubriques d'outillage, horodatage, droits, propriétaire et interfaces existantes sont préservés.

| Document / élément | État et justification |
| --- | --- |
| Projet réel | Générateur 0.4 et tests implémentés ; 97 méthodes finales réussies. |
| AGENTS.md | Inchangé : règles générales préservées, contrôles isolés sous la racine. |
| PROJECT.md | Inchangé : responsabilité du module projects conservée. |
| TECHNICAL.md | Mis à jour : priorité, chemins, isolement, bornes et portée du relevé. |
| BUILD.md | Inchangé : module déjà distribué, aucune nouvelle dépendance ; écarts de packaging préexistants hors périmètre. |
| DEVOPS.md | Inchangé : snapshot généré antérieurement ; aucune retouche manuelle ni génération réelle. |
| README.md | Mis à jour : document 0.4, priorité et provenance par dépendance. |
| CHANGELOG.md | Mis à jour : entrée Unreleased 0.4, historique 0.3 préservé. |
| OpenSpec | Sept blocs approuvés identiques au canon de 18 exigences ; six prérequis achevés, change archivé. |

Totaux : 63 + 17 + 8 + 9 = 97 méthodes finales ; 11 + 62 + 17 + 8 + 9 + 63 = 170 exécutions réussies avec répétitions ; 18 + 3 + 1 = 22 invocations suivies. Aucune mesure de coût, token ou quota n'est estimée.

Limites : versions et contraintes sont rapportées sans résolution ou qualification fonctionnelle ; plusieurs environnements ne constituent pas un environnement unique validé. Les erreurs et avertissements globaux hérités restent hors périmètre. Les documents prendront 0.4 à leur prochaine génération avec ce code ; aucune publication ni installation du DIU n'a été effectuée.
