# STATISTIQUES — Autorisation des tests dans les conteneurs Docker et LXC

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 24 octobre 2026 ; fuseau utilisateur Europe/Paris.
- Session SCM directe, sans pilotage OpenCode/CAB ni compétence de télémétrie SCMP.
- Change : `add-devops-test-container-authorization`.
- Archive : `2026-10-24-add-devops-test-container-authorization`.
- Autorisation : le développeur valide explicitement la formulation proposée
  et le périmètre autonome, puis demande de poursuivre jusqu'à l'archivage et au rapport.
- Objectif : ajouter une dernière puce commune d'autorisation des tests dans
  les rubriques Docker et LXC générées lorsqu'elles sont activées.
- Preuves : sorties des commandes de cette session, [proposition](proposal.md),
  [conception](design.md), [tâches](tasks.md),
  [delta](specs/projects-template-devops/spec.md) et
  [spécification canonique](../../../specs/projects-template-devops/spec.md).

La formulation validée est :

> Les agents de codage et les agents orchestrateurs sont autorisés à préparer, exécuter, répéter et nettoyer les tests du projet dans ce conteneur, y compris avec les droits root, sans demander d’approbation supplémentaire. Cette autorisation couvre le conteneur et les ressources dédiées aux tests.

Le périmètre comprend le générateur, ses assertions de test, trois documents,
la spécification correspondante et le cycle OpenSpec complet. Aucun document
DevOps réel n'est régénéré dans cette session. Les tests utilisent des données
synthétiques temporaires sous la racine du projet.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Fenêtre mesurée de réalisation avant rapport | 489 s, du 24 octobre 2026 à 14:09:24 UTC à 14:17:33 UTC ; hors exploration précédente, attente de validation et rédaction du rapport |
| Suite du générateur | 88,195 s selon la sortie unittest de cette session |
| Durée globale complète | N/A : pas de chronométrage couvrant toute la conversation et la validation du développeur |
| Tokens et coût | N/A : pas de mesure instrumentée disponible pour ce change |
| CPU et mémoire | N/A : pas de collecte dédiée |
| Messages et appels d'outils exhaustifs | N/A : pas d'export de télémétrie |
| Approbations CAB | N/A : session SCM directe, protocole non applicable |

Les sous-tests ne sont pas comptés comme méthodes supplémentaires.
Les résultats du change précédent ne sont pas recyclés comme résultats actuels.

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
emplacement final. Les cinq artefacts du change sont déplacés par OpenSpec vers
l'archive ; le rapport est créé ensuite. Aucun autre fichier préexistant n'est
supprimé ou renommé.

La fonction commune projects_template_devops_test_authorization émet la puce
exacte validée. Docker la reçoit après debian:stable-slim et comporte cinq puces.
LXC la reçoit après « Accès TPM OK » et comporte quatre puces. La formulation
est commune aux deux agents et aux trois parcours de génération.

Les indicateurs ENV_DEVOPS_TESTS_DOCKER et ENV_DEVOPS_TESTS_LXC conservent leur
activation indépendante par la seule valeur exacte 1. Une rubrique désactivée
n'émet pas d'autorisation orpheline ; aucune autre rubrique ne reçoit cette puce.
Les diagnostics Docker indisponible sont conservés et suivis de l'autorisation
si la rubrique est activée. Un échec d'écriture de la puce est propagé et
préserve le document existant.

L'ordre des rubriques, les sondes existantes, Docker-Compose et le format 0.7
restent inchangés. Les documents existants adoptent cette puce à leur prochaine
génération normale utilisant les nouvelles sources.

## 4. Tests et vérifications

| Suite | Méthodes recensées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| tests/test_projects_template_devops.py | 121 | 119 | 0 | 0 | 2 |

Commande réellement exécutée :

```bash
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
```

Le Python DevOps est celui indiqué dans le DEVOPS.md observé. Les deux tests
réels utilisant Go sont ignorés car Go n'est pas disponible dans le PATH et
DIU_TEST_GO n'est pas défini ; ce constat a été vérifié dans cette session.
L'UID effectif est non root. Aucun test de permissions ordinaires n'est
ignoré en raison d'un lancement sous root.

Les assertions communes sont renforcées pour vérifier le texte intégral,
sa dernière position, exactement cinq puces Docker et quatre puces LXC,
ainsi que son nombre d'occurrences selon les indicateurs. Les scénarios
existants couvrent les quatre combinaisons d'activation, les valeurs absentes,
vides ou invalides, les répétitions et les parcours individuel, groupé et
final de création. Les deux observations Docker indisponible conservent aussi
l'autorisation en dernière position.

Le test de conservation du document en cas d'échec reçoit deux nouveaux cas :
échec d'écriture de l'autorisation dans Docker et dans LXC seul. Ils vérifient
le code non nul, la conservation de l'ancien document et le nettoyage du
candidat temporaire. Aucune méthode supplémentaire n'est comptée pour ces
nouveaux cas.

| Contrôle | État et résultat observé |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi après la dernière modification du code |
| shellcheck modules/projects/template.sh | Exécuté et réussi, aucun diagnostic final |
| Compilation du test Python | Exécutée et réussie avec le Python DevOps, py_compile.compile et cfile temporaire sous le projet, puis nettoyage |
| Change OpenSpec strict avant code | Exécuté et réussi |
| Change OpenSpec strict avant archivage | Exécuté et réussi |
| Canon projects-template-devops standard final | Exécuté et réussi avec huit avertissements de longueur préexistants |
| Global OpenSpec strict initial | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec |
| Global OpenSpec strict final | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec ; éléments et diagnostics identiques au relevé initial |
| Global OpenSpec standard final | Exécuté et échoué : 68 éléments, 66 valides, deux changes Forgejo préexistants en échec |
| Concordance delta/canon | Exécutée et réussie : six blocs d'exigences et treize scénarios, hors normalisation des lignes vides par OpenSpec |
| Texte validé | Exécuté et réussi : texte identique dans le générateur, la constante de test, TECHNICAL.md, README.md et l'exigence canonique |
| Empreintes d'archivage | Exécutées et réussies : les dix fichiers qualifiés, dont les cinq artefacts déplacés, conservent leurs SHA-256 |
| Références hors modification | Exécutées et réussies : douze fichiers de référence conservent leur empreinte initiale, dont les six fichiers de l'archive précédente |
| UTF-8/LF sans BOM | Exécuté et réussi sur les onze fichiers précédant le rapport ; contrôle final portant sur les douze fichiers avec le rapport |
| Temporaires | Exécuté et réussi : aucun résidu des préfixes de génération, runtime et compilation contrôlés |
| Suite complète du dépôt | Non exécutée : seule la suite directement concernée du générateur est retenue |
| Installation et tests réels Docker/LXC | Non exécutés : hors périmètre |

La première passe ShellCheck a signalé SC1112 sur l'apostrophe typographique
du texte validé à l'intérieur d'une chaîne entre apostrophes simples.
La chaîne est passée entre guillemets doubles, sans changer le texte et sans
désactiver de diagnostic. ShellCheck et la syntaxe ont été relancés avec succès.

Un premier contrôle auxiliaire de concordance exigeait une identité des lignes
vides entre le delta et le canon. Il a échoué car OpenSpec a supprimé une ligne
vide redondante avant un scénario Docker. Le diagnostic ciblé a confirmé cette
seule différence. Le contrôle suivant normalise uniquement les lignes vides ;
les exigences et scénarios sont identiques. Aucun artefact n'est modifié pour
ce contrôle et aucun second archivage n'a eu lieu.

Les commandes OpenSpec utilisent OPENSPEC_TELEMETRY=0, le binaire explicite
/home/devops/.local/npm/bin/openspec, --no-interactive pour les validations,
--all --strict --json pour les relevés stricts globaux et --all --json pour
le relevé standard global. Le mode standard ciblé utilise
validate projects-template-devops --type spec --no-interactive.
Les échecs globaux ne sont pas présentés comme des réussites.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Fonction commune intégrée ; 119 tests réussis et deux tests Go ignorés |
| AGENTS.md | Inchangé, empreinte conservée ; règles de périmètre, autorisation et rapport appliquées |
| PROJECT.md | Inchangé, empreinte conservée ; architecture du module projects préservée |
| TECHNICAL.md | Mis à jour dans Traçabilité du document DevOps : dernière puce, texte exact, nombre de puces, erreurs d'écriture et portée documentaire |
| BUILD.md | Inchangé, empreinte conservée ; packaging non concerné |
| DEVOPS.md | Inchangé dans cette session, empreinte conservée ; inventaire actuel comprenant déjà Docker et LXC, utilisé pour les chemins des outils |
| README.md | Mis à jour dans la description des rubriques du générateur : formulation validée, position, nombres de puces et contrôles techniques |
| CHANGELOG.md | Entrée ajoutée sous Unreleased, sans version ni date de publication inventée |
| openspec/specs/ | projects-template-devops synchronisé : quatre exigences modifiées et deux ajoutées ; configuration OpenSpec et devops-tests-environment-flags inchangés, empreintes conservées |

Commande d'archivage réellement exécutée :

```bash
OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive add-devops-test-container-authorization --yes
```

Retour zéro, tâches complètes, deux exigences ajoutées, quatre modifiées et
archive ciblée confirmée, sans avertissement de proposition.
Le change actif est absent ; les cinq artefacts déplacés sont présents dans
l'archive et conservent leurs empreintes. L'archive précédente
2026-10-24-condition-devops-test-container-sections est intégralement préservée
pour les six fichiers contrôlés.

| Résultat | Nombre |
| --- | ---: |
| Tâches de spécification, réalisation et qualification terminées | 7 sur 7 |
| Exigences ajoutées | 2 |
| Exigences modifiées | 4 |
| Exigences supprimées ou renommées | 0 |
| Scénarios dans le delta final | 13 |
| Changes archivés | 1 |
| Fichiers finaux dans l'archive, rapport inclus | 6 |

Empreintes SHA-256 des sources et du test qualifiés :

| Fichier | SHA-256 |
| --- | --- |
| modules/projects/template.sh | f365358ddf283c4e4eb54f55fcdb11fff53d46e5f85cb545be68d9393007a780 |
| tests/test_projects_template_devops.py | dc03a5021d33912e298081e9ced35176e49cbc01fa0930ccb332c3b0ca7de4b3 |

Le contrôle final du rapport vérifie ses six sections, liens locaux, encodage
et totaux. Les égalités sont 12 = 1 + 1 + 3 + 1 + 6 = 6 + 6 et
121 = 119 + 0 + 0 + 2. Les opérations de clôture sont documentées après
exécution et ne sont pas cochées par anticipation dans les tâches.

## 6. Limites et état terminal

L'objectif source est réalisé et vérifié : la formulation validée est ajoutée
en dernière puce aux deux rubriques activées, les tests et la documentation
sont adaptés, la spécification est synchronisée, le change est archivé et
le rapport est produit. Aucun blocage propre à ce change ne subsiste.

La validation globale standard reste en échec sur
modify-projects-forgejo-push-force-with-lease et restore-forgejo-push-to-create :
leurs deltas omettent deux scénarios du canon Forgejo actuel.
Le global strict reste en échec sur ces deux changes, un change d'architecture
avec avertissement et dix-neuf spécifications avec avertissements.
Les vingt-deux éléments et leurs diagnostics sont identiques au relevé initial.
Le canon ciblé est valide en mode standard ; ses huit avertissements de
longueur préexistants empêchent une réussite stricte.

La génération n'active aucun conteneur ni test réel et ne change aucun contrôle
technique de permissions des outils ou plateformes. L'autorisation exprimée
est celle explicitement validée par le développeur, dans le conteneur et les
ressources dédiées aux tests. Aucun identifiant d'accès réel n'est consulté.

Il n'y a ni déploiement, migration, changement d'infrastructure ni modification
de configuration réelle. Le DEVOPS.md actuel reste conservé ; il adoptera la
nouvelle puce lors de sa prochaine génération avec ces sources.
Aucun état Git n'est inspecté et aucun commit, push, branche, tag ou release
n'est créé ou préparé. Aucun processus OpenCode ni service partagé n'est lancé,
arrêté ou redémarré.

