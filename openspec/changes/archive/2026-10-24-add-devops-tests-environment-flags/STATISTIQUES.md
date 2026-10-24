# STATISTIQUES — Indicateurs de tests DevOps Docker et LXC

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 24 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, sans pilotage OpenCode/CAB ni compétence de
  télémétrie SCMP.
- Change : `add-devops-tests-environment-flags`.
- Archive : `2026-10-24-add-devops-tests-environment-flags`.
- Objectif : initialiser indépendamment `ENV_DEVOPS_TESTS_DOCKER` et
  `ENV_DEVOPS_TESTS_LXC` à `0` lorsqu'elles sont absentes, avec persistance
  dans `/root/diu/config/environnements.env`, puis export.
- Autorisation : validation explicite du développeur du périmètre autonome,
  incluant le cycle OpenSpec complet et le rapport d'archive, puis demande
  de poursuivre via SCM jusqu'à la fin.
- Preuves : commandes et sorties de la session, [proposal.md](proposal.md),
  [design.md](design.md), [tasks.md](tasks.md),
  [delta](specs/devops-tests-environment-flags/spec.md) et
  [spécification canonique](../../../specs/devops-tests-environment-flags/spec.md).

Les écritures sont limitées aux sources, tests, trois documents et au cycle
OpenSpec approuvés. Le fichier de configuration réel n'a pas été lu ou
modifié. Les tests utilisent uniquement des configurations synthétiques
temporaires sous la racine du projet, avec nettoyage automatique.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Durée des neuf méthodes unittest | 0,254 s selon la sortie unittest |
| Durée globale complète | N/A : absence de chronométrage global incluant exploration et validation du développeur |
| Tokens et coût | N/A : absence de mesure instrumentée pour ce change |
| CPU et mémoire | N/A : absence de collecte dédiée |
| Messages et appels d'outils exhaustifs | N/A : absence d'export de télémétrie |
| Approbations CAB | N/A : session SCM directe, protocole non applicable |

Les sous-tests ne sont pas comptés comme méthodes unittest supplémentaires.
Aucune valeur historique de test ou de quota n'est réutilisée comme mesure
de cette session.

## 3. Fichiers et comportement livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code créé | 2 | modules/diu/variables/environnements/env_devops_tests_docker.sh ; env_devops_tests_lxc.sh |
| Tests créés | 1 | tests/test_env_devops_tests.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique créée | 1 | openspec/specs/devops-tests-environment-flags/spec.md |
| Documents de l'archive créée | 5 | proposal.md ; design.md ; tasks.md ; specs/devops-tests-environment-flags/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **12** | **2 + 1 + 3 + 1 + 5** |

Le périmètre final comprend trois fichiers préexistants modifiés et neuf
nouveaux fichiers. Les quatre artefacts du change actif sont déplacés par
OpenSpec vers l'archive ; le rapport est ensuite créé. Aucun autre fichier
préexistant n'est supprimé ou renommé.

Les deux déclarations sont `STATIC`, `ENABLE`, scope `environnements`, avec
`default_value=0`. Chaque variable absente est persistée puis exportée.
Une variable déjà définie, même vide, conserve sa valeur et est exportée sans
réécriture. La génération répétée avec rechargement ne crée aucun doublon.
Les autres lignes et scopes sont conservés.

La création du répertoire et l'écriture sont contrôlées explicitement : un
échec produit un diagnostic stderr et un statut non nul sans définir la
variable absente concernée. Une autre variable déjà persistée n'est pas
annulée. La branche déclarative `DISABLE` retire uniquement sa variable et
sa ligne persistante exacte ; son échec de suppression est explicite.

Le chargeur et le point d'entrée restent inchangés. Aucun consommateur des
indicateurs, test réel Docker/LXC, installation ou changement d'infrastructure
n'est ajouté.

## 4. Tests et vérifications

| Suite unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| tests/test_env_devops_tests.py | 9 | 9 | 0 | 0 | 0 |

Commande réellement exécutée :

```bash
python3 -B -m unittest discover -s tests -p test_env_devops_tests.py -v
```

Les tests couvrent la découverte par le chargeur, la création du fichier,
l'export aux processus enfants, les générations et rechargements répétés,
les valeurs déjà définies (`0`, `1`, vide et valeur personnalisée), les deux
configurations partielles, les lignes voisines, les erreurs de création et
d'écriture, et la désactivation limitée avec son erreur de suppression.
Les chemins temporaires contiennent des espaces. Les appels Docker et LXC
usuels sont remplacés par des fonctions en échec ; aucun environnement réel
n'est lancé. Les erreurs d'écriture attendues sont vérifiées par les tests et
ne constituent pas des échecs de la suite.

| Contrôle | État et résultat réellement observé |
| --- | --- |
| bash -n de chaque nouvelle déclaration | Exécuté et réussi, deux commandes distinctes |
| ShellCheck des deux déclarations | Exécuté et réussi, aucun diagnostic |
| python3 -m py_compile tests/test_env_devops_tests.py | Exécuté et réussi via subprocess, avec PYTHONPYCACHEPREFIX dans un répertoire temporaire sous le projet, puis nettoyage |
| Change OpenSpec strict avant code et tests | Exécuté et réussi |
| Change OpenSpec strict avant archivage | Exécuté et réussi |
| Spécification canonique stricte après archivage | Exécutée et réussie, aucun diagnostic |
| OpenSpec global strict initial | Exécuté et échoué : 67 éléments, 45 valides, 22 en échec |
| OpenSpec global strict avant archivage | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec ; diagnostics en échec identiques à l'état initial |
| OpenSpec global strict final | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec ; diagnostics en échec identiques à l'état initial |
| OpenSpec global standard final | Exécuté et échoué : 68 éléments, 66 valides, deux changes Forgejo préexistants en échec |
| Concordance delta/canon | Exécutée et réussie : six exigences et neuf scénarios intégralement identiques |
| Empreintes avant/après archivage | Exécutées et réussies : dix fichiers du périmètre inchangés par le déplacement et l'archivage |
| Références préexistantes | Exécutées et réussies : trois modifications documentaires attendues et sept empreintes inchangées parmi les dix références relevées |
| UTF-8/LF sans BOM | Exécuté et réussi avant archivage et sur les onze fichiers précédant le rapport ; contrôle final incluant le douzième fichier |
| Temporaires de tests et compilation | Contrôle réussi : aucun résidu des préfixes tests devops et compile devops |
| Suite complète du dépôt | Non exécutée : validation limitée aux déclarations et au chargeur concernés |
| Installation réelle et tests Docker/LXC réels | Non exécutés : hors périmètre |

Les commandes OpenSpec utilisent `OPENSPEC_TELEMETRY=0` et le chemin explicite
`/home/devops/.local/npm/bin/openspec`, relevé dans `DEVOPS.md`.
Les validations globales emploient `validate --all --strict --json
--no-interactive` et `validate --all --json --no-interactive`.
La cible finale est validée avec `validate devops-tests-environment-flags
--type spec --strict --no-interactive`.

Un relevé auxiliaire initial trop volumineux a été tronqué et n'a pas pu être
décodé en JSON. Il a été remplacé avant toute écriture par un relevé compact
des seules empreintes nécessaires. Cet échec n'a modifié aucun fichier et
n'est pas utilisé comme preuve de contrôle réussi.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Deux déclarations découvertes par le chargeur existant ; neuf tests ciblés réussis |
| AGENTS.md | Inchangé, empreinte conservée ; règles d'autorisation, de périmètre et de rapport appliquées |
| PROJECT.md | Inchangé, empreinte conservée ; rôle de gestion des variables du module diu préservé dans Architecture fonctionnelle |
| TECHNICAL.md | Mis à jour dans Configuration et variables, sous Indicateurs de tests DevOps : destination, défaut, conservation, erreurs et absence de consommateur |
| BUILD.md | Inchangé, empreinte conservée ; Contenu du paquet exclut config/ et prévoit sa génération à l'exécution |
| DEVOPS.md | Inchangé, empreinte conservée ; inventaire des outils utilisé pour OpenSpec ; aucune modification d'outillage nécessaire |
| README.md | Mis à jour après la présentation : initialisation, conservation, erreurs et application lors de la prochaine exécution normale |
| CHANGELOG.md | Entrée ajoutée sous Unreleased, sans invention de version ou de date de publication |
| openspec/specs/ | Nouvelle spécification devops-tests-environment-flags, six exigences et neuf scénarios ; Purpose généré par OpenSpec remplacé par la description effective de la capacité |

Commande d'archivage réellement exécutée :

```bash
OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive add-devops-tests-environment-flags --yes
```

La commande retourne zéro, constate les tâches complètes, crée la
spécification canonique avec six exigences, puis confirme l'archive ciblée.
L'absence du change actif et l'intégrité des quatre artefacts déplacés sont
contrôlées. Le corps des exigences de la spécification canonique correspond
exactement au delta archivé. La description Purpose a été complétée dans le
cadre de la finalisation de la nouvelle spécification ; aucune exigence n'a
été modifiée après archivage.

| Résultat | Nombre |
| --- | ---: |
| Tâches de spécification, réalisation et qualification terminées | 8 sur 8 |
| Exigences créées | 6 |
| Exigences préexistantes modifiées, supprimées ou renommées | 0 |
| Scénarios créés | 9 |
| Changes archivés | 1 |
| Documents finaux dans l'archive | 5 |

Empreintes SHA-256 des sources et du test qualifiés :

| Fichier | SHA-256 |
| --- | --- |
| env_devops_tests_docker.sh | f7a696c10fa52cdfe76be7ed45088ad207e6c65b87ec3b49507f06eace80ec75 |
| env_devops_tests_lxc.sh | a06f8f85a61abe065804d6da39851f40ccbee1ef972c4b0750c85e84464adf46 |
| test_env_devops_tests.py | cb1502b1d9158c06cf75b96acbbae81841cc8a355c499dd8e2d00cbb88b8fd09 |

Le contrôle final du rapport porte sur ses six sections, ses liens locaux,
l'encodage, les totaux de fichiers, de tâches, d'exigences, de scénarios et de
tests. Les égalités attendues sont 12 = 2 + 1 + 3 + 1 + 5 = 3 + 9 et
9 = 9 + 0 + 0 + 0. Aucune opération d'archivage ou de livraison future n'a
été cochée par anticipation dans les tâches.

## 6. Limites et état terminal

L'objectif source est réalisé : déclarations implémentées, neuf tests
ciblés réussis, documentation mise à jour, spécification synchronisée et
change archivé avec son rapport. Aucun blocage propre à ce change ne subsiste.

La validation OpenSpec globale standard reste en échec sur
`modify-projects-forgejo-push-force-with-lease` et
`restore-forgejo-push-to-create`, car leurs deltas omettent deux scénarios du
canon actuel. La validation globale stricte reste en échec sur ces deux
changes, un change d'architecture avec avertissement et 19 spécifications
avec avertissements. Les 22 éléments concernés et leurs diagnostics sont
identiques avant et après ce travail ; ils ne sont pas corrigés dans ce
périmètre. La nouvelle spécification est valide en mode strict.

Les valeurs seront générées dans la configuration réelle à la prochaine
exécution normale du DIU utilisant ces sources. Cette session n'installe ni
ne déploie le DIU et ne modifie pas `/root/diu/config/environnements.env`.
Les indicateurs ne sont raccordés à aucun consommateur nouveau. Il n'y a pas
de migration, de validation nouvelle des valeurs existantes, de transaction
globale entre variables ni de gestion supplémentaire des écritures
concurrentes.

Aucun état Git n'est inspecté ; aucun commit, push, branche, tag ou release
n'est préparé ou créé. Aucun fichier sensible réel n'est consulté, hormis
l'extraction filtrée autorisée de l'identité non secrète du projet pendant
l'exploration. Aucun processus OpenCode ni service partagé n'est lancé,
arrêté ou redémarré.
