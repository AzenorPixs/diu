# STATISTIQUES — Rubriques conditionnelles Docker et LXC du document DevOps

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 24 octobre 2026 ; fuseau utilisateur Europe/Paris.
- Session SCM directe, sans pilotage OpenCode/CAB ni télémétrie SCMP.
- Change : `condition-devops-test-container-sections`.
- Archive : `2026-10-24-condition-devops-test-container-sections`.
- Autorisation : réponse « je valide » au périmètre autonome proposé,
  comprenant spécification, code, tests, documentation, archivage et rapport.
- Objectif : rendre les rubriques Docker et LXC indépendamment conditionnelles
  à la valeur exacte `1` de leurs indicateurs existants.
- Preuves : sorties des commandes de cette session, [proposition](proposal.md),
  [conception](design.md), [tâches](tasks.md),
  [delta](specs/projects-template-devops/spec.md) et
  [canon](../../../specs/projects-template-devops/spec.md).

Les écritures sont limitées au périmètre approuvé. Les configurations et
documents de test sont synthétiques et temporaires sous la racine du projet.
Aucun document DevOps réel n'est régénéré ; aucun conteneur de test n'est lancé.
L'extraction filtrée de l'identité non secrète a été effectuée pendant
l'exploration précédente, sans restitution des autres variables de project.env.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Fenêtre mesurée de réalisation avant rapport | 610 s, de 13:50:18 à 14:00:28 UTC ; hors exploration, attente de validation et rédaction finale du rapport |
| Suite du générateur, Python système | 87,119 s selon unittest |
| Suite du générateur, Python DevOps | 86,870 s selon unittest |
| Tests des déclarations, Python DevOps | 0,144 s selon unittest |
| Durée globale complète de la session | N/A : pas de chronométrage couvrant l'exploration et la validation du développeur |
| Tokens et coût | N/A : pas de mesure instrumentée disponible pour ce change |
| CPU et mémoire | N/A : pas de collecte dédiée |
| Messages et appels d'outils exhaustifs | N/A : pas d'export de télémétrie |
| Approbations CAB | N/A : session SCM directe, protocole non applicable |

Les sous-tests ne sont pas comptés comme des méthodes supplémentaires.
Les tentatives successives de la même suite ne sont pas additionnées pour
mesurer la couverture finale. Aucune mesure historique n'est recyclée.

## 3. Fichiers et comportement livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique modifiée | 1 | openspec/specs/projects-template-devops/spec.md |
| Fichiers de la nouvelle archive | 6 | .openspec.yaml ; proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **12** | **1 + 1 + 3 + 1 + 6** |

Six fichiers préexistants sont modifiés et six fichiers sont nouveaux à leur
emplacement final. Les cinq artefacts du change sont déplacés par OpenSpec
vers l'archive ; le rapport est créé ensuite. Aucun autre fichier préexistant
n'est supprimé ou renommé.

La rubrique « Conteneur Docker, pour tests nécessitant des droits root »
apparaît uniquement pour ENV_DEVOPS_TESTS_DOCKER égal à la chaîne exacte `1`.
Elle conserve la version détectée ou son diagnostic, le chemin du binaire ou
son diagnostic, puis /var/run/docker.sock et debian:stable-slim.
Lorsqu'elle est désactivée, sa résolution de binaire et sa sonde sont omises.

La rubrique « Conteneur LXC, pour tests nécessitant des droits root »
apparaît uniquement pour ENV_DEVOPS_TESTS_LXC égal à la chaîne exacte `1`,
indépendamment de Docker. Elle suit Docker lorsqu'il est présent, sinon
Matériel, et précède Docker-Compose. Ses puces exactes sont :
« Variables d'accès disponible dans project.env », « Debian 13 », « Accès TPM OK ».
Ces mentions sont déclaratives ; le générateur n'ouvre aucun accès LXC
et n'effectue aucune qualification TPM distante pour cette rubrique.

Une variable absente, vide ou différente de `1` omet la rubrique concernée.
Le format 0.7, Docker-Compose, les autres rubriques, les déclarations des
indicateurs et les parcours individuel, groupé et final de création sont préservés.
Les documents existants prennent ce comportement à leur prochaine génération normale.

## 4. Tests et vérifications

| Tentative ou suite | Méthodes recensées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Générateur avec Python système 3.13.5 | 121 | 110 | 0 | 9 | 2 |
| Générateur avec Python DevOps 3.14.9, résultat final | 121 | 119 | 0 | 0 | 2 |
| Déclarations des indicateurs, résultat final | 9 | 9 | 0 | 0 | 0 |
| **Couverture finale, deux suites distinctes** | **130** | **128** | **0** | **0** | **2** |

Le premier lancement utilisait python3, résolu vers /usr/bin/python3 3.13.5.
Neuf méthodes ont rencontré StopIteration dans la préparation des fixtures
project_venv : aucun chemin renvoyé par site.getsitepackages n'était un dossier
existant. Ces erreurs précédaient les assertions de génération de ces méthodes.
La même suite passe avec le Python DevOps explicitement déclaré dans DEVOPS.md,
sans correction ni affaiblissement des fixtures concernées.

Les deux méthodes réelles utilisant Go sont ignorées car Go n'est pas disponible
dans le PATH de cette session et DIU_TEST_GO n'est pas défini. L'UID effectif est
1000 ; les contrôles de permissions ordinaires ne sont pas ignorés pour root.

Commandes des suites réellement exécutées :

```bash
python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_env_devops_tests.py -v
```

Deux méthodes sont ajoutées au générateur. Elles couvrent les quatre combinaisons,
l'absence, la valeur vide, zéro, 01, true, un espace final et une valeur contenant
une substitution shell qui ne doit pas être exécutée. Elles vérifient les titres,
puces, ordre, suppression des sections lors des mises à jour, répétabilité et
absence de résolution/sonde Docker désactivée. Des fonctions sentinelles refusent
les commandes LXC usuelles. Les tests existants de génération groupée et finale
de création vérifient aussi les deux rubriques actives.

| Contrôle | État et résultat |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi |
| shellcheck modules/projects/template.sh | Exécuté et réussi, aucun diagnostic |
| Compilation du test Python | Exécutée et réussie avec Python système puis Python DevOps ; py_compile.compile avec cfile temporaire sous le projet, nettoyé |
| Change OpenSpec strict avant code | Exécuté et réussi après découpage d'une exigence LXC initialement trop longue |
| Change OpenSpec strict avant archivage | Exécuté et réussi |
| Canon projects-template-devops standard final | Exécuté et réussi avec huit avertissements de longueur préexistants |
| Global OpenSpec strict avant synchronisation | Exécuté et échoué : 69 éléments, 47 valides, 22 en échec |
| Global OpenSpec strict final | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec ; liste et diagnostics des échecs identiques au relevé avant synchronisation |
| Global OpenSpec standard final | Exécuté et échoué : 68 éléments, 66 valides, deux changes Forgejo préexistants en échec |
| Concordance delta/canon | Exécutée et réussie : les huit blocs d'exigences du delta correspondent exactement au canon |
| Tâches et scénarios | Exécuté et réussi : sept tâches cochées, huit exigences dans le delta, seize scénarios |
| Empreintes | Exécuté et réussi : code, tests et documentation conservés pendant l'archivage ; cinq références hors modification demeurent identiques |
| Encodage | Exécuté et réussi sur les onze fichiers précédant le rapport ; contrôle final du rapport et des douze fichiers |
| Temporaires | Exécuté et réussi : aucun résidu des préfixes contrôlés de génération, runtime et compilation |
| Suite complète du dépôt | Non exécutée : les deux suites directement concernées sont retenues |
| Installation, tests réels Docker/LXC et qualification TPM distante | Non exécutés : hors périmètre |

Après l'archivage, le contrôle strict du canon a détecté un avertissement de
longueur supplémentaire dans le paragraphe de structure. Une phrase redondante
a été retirée du canon et du delta archivé, en conservant le scénario d'ordre
conditionnel et les exigences dédiées. Le contrôle strict global a été relancé :
aucun diagnostic supplémentaire ne subsiste. Cette correction est documentaire ;
les sources et tests qualifiés n'ont pas changé. Aucun second archivage n'a eu lieu.

Les commandes OpenSpec utilisent le binaire explicite
/home/devops/.local/npm/bin/openspec. Les commandes finales emploient
OPENSPEC_TELEMETRY=0 et --no-interactive pour les validations.
Le résultat strict global n'est pas présenté comme une réussite.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Rendu commun modifié ; 128 méthodes réussies et deux ignorées dans les deux suites finales |
| AGENTS.md | Inchangé, empreinte conservée ; règles de périmètre, d'autorisation et de rapport appliquées |
| PROJECT.md | Inchangé, empreinte conservée ; architecture du module projects préservée |
| TECHNICAL.md | Mis à jour dans Traçabilité du document DevOps et Indicateurs de tests DevOps : conditions, ordre, consommation documentaire et portée déclarative |
| BUILD.md | Inchangé, empreinte conservée ; packaging sans modification |
| DEVOPS.md | Inchangé, empreinte conservée ; inventaire historique utilisé pour les chemins OpenSpec et Python, sans retouche manuelle |
| README.md | Mis à jour dans la description du générateur : indicateurs, ordre, contenu et limites |
| CHANGELOG.md | Entrée ajoutée sous Unreleased, sans nouvelle version ni date de publication inventée |
| openspec/specs/ | projects-template-devops synchronisé ; quatre exigences modifiées et quatre ajoutées ; devops-tests-environment-flags inchangé, empreinte conservée |

Commande d'archivage réellement exécutée :

```bash
OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive condition-devops-test-container-sections --yes
```

Retour zéro : tâches complètes, quatre exigences ajoutées, quatre modifiées,
spécification synchronisée et archive ciblée confirmée.
Le change actif est absent et les cinq artefacts sont présents dans l'archive.
Les cinq empreintes des sources, tests et documents modifiés sont conservées.
Les artefacts déplacés conservent leurs empreintes, sauf le delta ayant reçu la
correction documentaire décrite en section 4 ; sa concordance avec le canon
est vérifiée après correction.

OpenSpec a émis à l'archivage un avertissement non bloquant sur les titres français
« Pourquoi » et « Changements » de la proposition, son analyseur attendant
« Why » et « What Changes ». Les deux sections et le contenu de la proposition
existent ; cette sortie n'est pas masquée et aucun archivage supplémentaire
n'est effectué.

| Résultat | Nombre |
| --- | ---: |
| Tâches de spécification, réalisation et qualification terminées | 7 sur 7 |
| Exigences ajoutées | 4 |
| Exigences modifiées | 4 |
| Exigences supprimées ou renommées | 0 |
| Scénarios dans le delta final | 16 |
| Changes archivés | 1 |
| Fichiers finaux dans l'archive, rapport inclus | 6 |

Empreintes SHA-256 des sources et du test qualifiés :

| Fichier | SHA-256 |
| --- | --- |
| modules/projects/template.sh | f937c3a2b47ff5b2e2a59f1f0cc7f08ee85253b33352da73e58d10d9da1c47bf |
| tests/test_projects_template_devops.py | 966fecc5d9ca5d0db1ae21f42cca5f9430d9acf69997bace1684156f22405dd8 |

Le contrôle final vérifie les six sections, les liens locaux, l'encodage et les
totaux. Les égalités sont 12 = 1 + 1 + 3 + 1 + 6 = 6 + 6 et
130 = 121 + 9 = 128 + 0 + 0 + 2. Les opérations de clôture sont documentées
ici après leur exécution ; elles n'ont pas été cochées par anticipation.

## 6. Limites et état terminal

L'objectif source est réalisé et vérifié : rubriques conditionnelles indépendantes,
titres et contenu conformes au périmètre approuvé, documentation à jour,
spécification synchronisée, change archivé et rapport produit.
Aucun blocage propre au comportement modifié ne subsiste.

La validation globale standard reste en échec sur
modify-projects-forgejo-push-force-with-lease et restore-forgejo-push-to-create :
leurs deltas omettent deux scénarios du canon Forgejo actuel.
Le global strict reste en échec sur ces deux changes, un change d'architecture
avec avertissement et dix-neuf spécifications avec avertissements.
Les vingt-deux éléments et les diagnostics sont identiques au relevé avant
synchronisation. Le canon ciblé est valide en mode standard ; ses huit
avertissements de longueur préexistants empêchent une réussite stricte globale.

Aucun déploiement, migration, changement d'infrastructure ou modification de
configuration réelle n'a lieu. Le DEVOPS.md actuel est conservé ; la nouvelle
sortie sera adoptée lors d'une génération normale utilisant ces sources.
« Accès TPM OK » reste une mention demandée, sans vérification distante.

Aucun état Git n'est inspecté. Aucun commit, push, branche, tag ou release
n'est créé ou préparé. Aucun processus OpenCode ni service partagé n'est
lancé, arrêté ou redémarré.

