# Statistiques du projet — diu

Concaténation des sources locales des changes, sans somme de compteurs partagés.


## Change `add-debian-build-to-projects-cicd` — openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/STATISTICS.md


# Statistiques — build Debian dans la CI/CD générique

## 1. Statistiques générales et décisions

Session directe SCM du 2026-11-02, plan SCM-CICD-DEBIAN-20261102-R1 validé avec
version de livraison 1.0.2. Un agent Codex, sans délégation, CAB ni OpenCode.
Le change add-debian-build-to-projects-cicd est archivé sous
2026-11-02-add-debian-build-to-projects-cicd ; quatre tâches validées, une exigence
ajoutée et six modifiées dans trois capacités synchronisées.
Code non attribué : aucune allocation ACL ni sous-lot définitif inventé.
Durée totale de session, coûts, tokens et quotas : N/A, mesures non collectées.

## 2. Types de messages et d'outils

Exploration, proposition, validation explicite du périmètre et de la version,
suivi et restitution. Outils de recherche/lecture, résolution du prompt SCM,
patches et exécutions locales. Totaux exhaustifs des appels et messages : N/A,
aucune instrumentation de pilotage. Les opérations Git conditionnelles suivent
ce rapport ; leurs résultats seront distingués dans le bilan final de session.
Aucune compétence ou sonde réservée à SCMP n'est invoquée.

## 3. Fichiers modifiés

Vingt-quatre livrables publics, rapport inclus, et une configuration locale :
25 ressources traitées. L'archivage ne compte pas deux fois ses fichiers.
Les modifications préexistantes ou concurrentes ne sont pas attribuées à ce total.

- `root-install-debian.sh`
- `lib/rid-help.sh`
- `modules/projects/git.sh`
- `modules/projects/debian-build.sh`
- `tests/test_projects_cicd_debian.py`
- `tests/test_projects_build_deb.py`
- `tests/test_projects.py`
- `PROJECT.md`
- `TECHNICAL.md`
- `BUILD.md`
- `README.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `openspec/BATCH_CODES.md`
- `openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/design.md`
- `openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/proposal.md`
- `openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/specs/projects-cicd/spec.md`
- `openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/specs/projects-debian-build/spec.md`
- `openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/tasks.md`
- `openspec/specs/projects-cicd/spec.md`
- `openspec/specs/projects-debian-build/spec.md`
- `openspec/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-debian-build-to-projects-cicd/STATISTICS.md`

- Configuration locale `project.env` : seule PROJECT_VERSION passe de 1.0.1 à
  1.0.2, soit un octet modifié ; autres octets, inode, permissions et propriétaire
  préservés. Aucun contenu privé n'est transmis ni ajouté au rapport.

lib/project-version.sh, les modules Docker, packaging historique et release,
et la recette DIU conservent leurs empreintes initiales. AGENTS.md a changé au
contrôle final après archivage, sans édition de ce plan : règles relues et contenu
conservé. DEVOPS.md a été
régénéré pendant les validations ; il est relu et conservé sans édition par ce
plan. Son contenu et les modifications préexistantes peuvent être inclus dans
le commit complet prévu par SCM, sans être comptés comme livrables de ce change.
L'état Git de clôture contient aussi les suppressions préexistantes de
ancien protocole local et de DEVOPS.sync-conflict-20261102-205614-EWHSA4J.md.
Elles sont conservées dans le snapshot complet SCM, sans suppression exécutée
par ce plan ni attribution à la fonctionnalité livrée. Une consultation en
lecture seule des métadonnées de chats n'a pas identifié de coordination liée.

## 4. Commandes et validations

| Contrôle réellement exécuté | Résultat |
|---|---|
| Commandes, aides et packaging | 81 tests réussis en 8,474 s |
| Sept suites ciblées CI/CD, projets, indisponibilité, Docker, version, build et aide | 165 tests réussis en 30,974 s |
| Suite complète avec DIU_TEST_GO déclaré | 1 049 tests réussis en 319,997 s, aucun échec, erreur ou saut |
| bash -n sur quatre fichiers Bash modifiés | Réussi |
| ShellCheck avec lib/project-version.sh comme dépendance explicite | Réussi sans diagnostic sur les quatre fichiers modifiés |
| Compilation des trois fichiers Python modifiés | Réussie |
| OpenSpec du change strict | Réussi, scénarios historiques conservés |
| OpenSpec global standard avant/après archivage | 118/118 puis 117/117 valides |
| OpenSpec global strict avant/après archivage | 71 puis 70 valides et mêmes 47 refus historiques |
| Canons projects-cicd, projects-debian-build et rid-help après synchronisation | Trois validations strictes réussies |
| openspec archive add-debian-build-to-projects-cicd --yes | Réussi, une exigence ajoutée et six modifiées |
| Contrôles documentaires avant archivage | 20 fichiers publics UTF-8/LF, nouvelles cibles de liens présentes |

Les nombres 81 et 165 sont des sous-ensembles ou répétitions et ne sont pas
additionnés aux 1 049 tests uniques. Les 15 nouvelles méthodes vérifient les
six étapes, les deux activations indépendantes, les erreurs et les fournisseurs.
Le passage de validation OpenSpec initial a signalé des scénarios omis : ils ont
été conservés et précisés avant toute implémentation. ShellCheck exigeait la
librairie de version comme entrée : l'invocation a été complétée sans suppression
de diagnostic ni changement du code protégé.

Un paquet réel de fixture est construit et inspecté avant ses publications
simulées ; une recette absente préserve l'ancien artefact et bloque les releases.
Les transports et publications sont simulés, aucune CI/CD réelle ni installation
n'est lancée. Les anciens appels de bilan à onze paramètres restent acceptés ;
le statut Debian est un douzième paramètre facultatif.

## 5. Accès web

Aucune recherche web pour la réalisation. Les vérifications du plugin GitHub et
les publications Git conditionnelles, après ce rapport, relèvent du bilan final.
Elles ne sont pas anticipées comme réussies ici. Aucun accès réseau réel ni
secret utilisateur n'est nécessaire aux validations sur fixtures.

## 6. Synthèse globale

Le flux générique présente six étapes ; le build Debian de l'étape 4 utilise
le même moteur que build debian et son alias deb. Il est activé uniquement par
Yes/YES/1, indépendamment de Docker. Les publications suivent en étape 5 et le
bilan des deux builds en étape 6. Un échec bloque les releases ; les pushes déjà
réalisés restent publiés. Debian seul utilise les capacités Forgejo/GitLab
existantes ; aucune publication Debian GitHub n'est créée.

PROJECT, TECHNICAL, BUILD, README et CHANGELOG sont mis à jour ; les aides,
la carte, le registre et trois capacités sont réconciliés. La matrice détaillée
figure dans tasks.md. Les cinq sources produit protégées gardent leurs empreintes ;
AGENTS modifié pendant la clôture est relu et conservé ; DEVOPS régénéré est relu (chemins Python/OpenSpec/prompts inchangés).
L'installation du DIU reste hors périmètre : ridt utilise les sources du dépôt,
alors que rid utilise la version installée.

La conformité stricte globale n'est pas revendiquée : mêmes 47 éléments en échec
hors du périmètre des trois canons validés. Le lien historique README vers
openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTIQUES.md
reste absent et hors périmètre. Les nouveaux liens sont présents.
Aucun BLOCKER.md/BLOCKERS.md dans l'archive : aucun nettoyage nécessaire.
STATISTICS.md global absent : mandater SGS.md pour sa génération initiale.
Le code de lot et les sous-lots définitifs restent à attribuer via ACL.


## Change `add-deb-packaging` — openspec/changes/archive/2026-08-12-add-deb-packaging/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-devops-cython-detection` — openspec/changes/archive/2026-10-26-add-devops-cython-detection/STATISTICS.md


# STATISTIQUES — Détection conditionnelle de Cython dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`), racine `/home/devops/datas/diu`.
- Session : SCM directe, version 0.1, détection Cython, 26 octobre 2026.
- Change : `add-devops-cython-detection` ; archive : `2026-10-26-add-devops-cython-detection`.
- Le développeur a explicitement validé la proposition puis demandé le lancement SCM : détecter Cython dans `[build-system].requires`, sonder seulement après déclaration et omettre la rubrique sans déclaration.
- Périmètre : générateur, tests, spécifications, documentation, archivage et présent rapport. Les étapes Git conditionnelles du prompt suivent le rapport.
- Aucun pilotage OpenCode, mandat CAB ni sous-agent. La compétence de statistiques pilotées n’a pas été invoquée conformément à SCM.

## 2. Durées et mesures disponibles

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée totale de session | N/A | Aucun chronométrage global fiable |
| Premier passage Cython | 12 tests, 9,242 s ; échec | Deux méthodes en échec, six enregistrements d’échec dont cinq sous-cas ; fixtures d’appel et de remplacement corrigées |
| Deuxième passage Cython | 12 tests réussis, 8,811 s | Sortie unittest observée |
| Passage Cython final | 14 tests réussis, 9,818 s | Ajout des contrôles groupé et de rejet de sortie partielle |
| Suite complète finale | 140 tests réussis, 105,113 s | Aucun cas ignoré, avec le chemin Go déclaré |
| Nouveaux cas uniques Cython | 14 | Inclus dans les 140, plus enrichissement du cas existant de création |
| Exécutions de méthodes de test | 178 | 12 + 12 + 14 + 140 ; les sous-cas ne sont pas ajoutés comme méthodes |
| Cas uniques validés | 140 | La suite finale couvre les passages ciblés |
| Modèle, jetons et coût | N/A | Aucune télémétrie qualifiée disponible |
| Messages, outils et commandes totaux | N/A | Aucun compteur exhaustif qualifié |
| Approbations/refus CAB | Non applicable | SCM directe |
| Outils de recherche web utilisés | 0 | Aucune recherche web nécessaire à cette implémentation |

## 3. Fichiers et comportement livré

Six fichiers existants modifiés et cinq fichiers dans l’archive, rapport inclus : onze fichiers. Les écarts ci-dessous sont calculés par comparaison aux sauvegardes ciblées initiales, sans inspection Git pendant l’implémentation et sans attribution des travaux antérieurs du dépôt.

| Fichier existant | Lignes ajoutées | Lignes retirées |
| --- | ---: | ---: |
| modules/projects/template.sh | 69 | 11 |
| tests/test_projects_template_devops.py | 212 | 1 |
| TECHNICAL.md | 30 | 2 |
| README.md | 10 | 0 |
| CHANGELOG.md | 8 | 0 |
| openspec/specs/projects-template-devops/spec.md | 59 | 3 |
| Total | 388 | 17 |

L’archive contient proposal.md, design.md, tasks.md, specs/projects-template-devops/spec.md et ce STATISTIQUES.md.

Le mode interne Cython du helper existant lit le TOML avant toute découverte de venv. Une déclaration dans `[build-system].requires` produit la rubrique après pip et avant Prompts. L’absence de déclaration, y compris lorsque Cython apparaît seulement dans un commentaire ou une autre table, ne lance aucune découverte ni sonde Cython. Les autres outils de compilation ne sont pas ajoutés par cette évolution.

Une installation observée indique version, interpréteur, environnement et emplacement issus des métadonnées. Une absence établie dans les venv sondés indique non installé avec les environnements vérifiés. Une absence de venv ou une vérification impossible/incomplète indique installation non vérifiable. Aucun paquet global ne sert de repli Cython ; l’inventaire d’exécution conserve son comportement et son repli existants.

Les sondes réutilisent l’ordre .venv, venv, env puis autres chemins triés et les limites de 3 secondes par sonde et 12 secondes pour recherche/sondes. Aucun import Cython, chargement de .pth, installation, compilation ou modification de manifeste. Les contraintes restent déclaratives ; aucune conformité de version ni utilisation effective pour compiler n’est déduite.

## 4. Tests et vérifications

| Contrôle | État final et résultat |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi |
| shellcheck modules/projects/template.sh | Exécuté et réussi |
| py_compile du fichier de tests | Exécuté et réussi avec Python DevOps ; cache isolé dans le temporaire de session |
| Tests Cython ciblés | Exécutés et réussis : 14 méthodes |
| Suite complète test_projects_template_devops.py | Exécutée et réussie : 140 méthodes, aucun cas ignoré |
| Change OpenSpec strict | Exécuté et réussi avant code puis avant archive, sans diagnostic après correction des contrats trop longs |
| Canon OpenSpec standard après synchronisation | Exécuté et réussi, huit avertissements préexistants |
| Stricte globale initiale | Exécutée et échouée : 46 valides, 22 échecs, 68 éléments |
| Stricte globale avant archive | Exécutée et échouée : 47 valides, mêmes 22 échecs et diagnostics, 69 éléments |
| Stricte globale finale | Exécutée et échouée : 46 valides, mêmes 22 échecs et diagnostics initiaux, 68 éléments |
| Contrôle de synchronisation | Six blocs du delta final retrouvés exactement dans le canon |
| UTF-8/LF et périmètre | Vérifiés par lecture et comparaison aux sauvegardes ciblées |
| Construction de paquet, installation et compilation Pixs | Non pertinentes : génération documentaire DIU uniquement |

Commandes principales :

```bash
bash -n modules/projects/template.sh
shellcheck modules/projects/template.sh
env PYTHONPYCACHEPREFIX=<temporaire-de-session>/pycache /home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_cython
env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate add-devops-cython-detection --type change --strict --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate projects-template-devops --type spec --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate --all --strict --json
```

Les tests vérifient casse, contraintes et marqueurs, commentaires et autres tables, absence de toute découverte Cython sans déclaration, installation globale ignorée, venv sans paquet, venv absent, manifeste invalide, analyse système sans Python DevOps, priorité et chemins avec espaces, import et .pth non exécutés, métadonnées dupliquées, erreurs, budgets, arrêt des descendants, références directes masquées, sortie partielle rejetée et parcours groupé. Le test existant de création vérifie aussi la rubrique pour un modèle Python déclarant Cython et son omission pour les autres créations.

Après synchronisation, un nouveau diagnostic de longueur du paragraphe de provenance a été détecté et corrigé dans le canon et le delta archivé à contenu équivalent, sans réarchivage. La comparaison finale des diagnostics est identique à l’état initial. Aucune modification de code ni de tests n’a suivi la suite finale.

## 5. Cohérence documentaire et archivage

| Élément | État final et preuve |
| --- | --- |
| Projet réel | Générateur et 140 tests validés ; aucun document de projet réel régénéré |
| AGENTS.md | Inchangé, comparaison octet pour octet ; règles générales conservées |
| PROJECT.md | Inchangé, comparaison octet pour octet ; module projects et architecture conservés |
| TECHNICAL.md | Mis à jour : provenance, placement de Prompts et section Outils de compilation Python : Cython déclaré |
| BUILD.md | Inchangé, comparaison octet pour octet ; packaging hors périmètre |
| DEVOPS.md | Inchangé, comparaison octet pour octet ; inventaire daté au format 0.7, prochaine génération normale nécessaire |
| README.md | Mis à jour : déclenchement, états, limites et prochaine génération |
| CHANGELOG.md | Entrée Unreleased ajoutée, sans version de publication inventée |
| openspec/config.yaml | Inchangé, comparaison octet pour octet |
| openspec/specs/projects-template-devops/spec.md | Synchronisé : trois exigences ajoutées et trois modifiées ; six blocs retrouvés dans le canon |

Archivage réussi sous le compte devops : `openspec archive add-devops-cython-detection --yes --json`, code 0, specsUpdated=true. Dossier actif absent, dossier d’archive présent, six tâches cochées sur preuves. Aucun autre change ni archive modifié dans cette session. Le premier contrôle de correspondance utilisait une expression de recherche trop large ; sa correction a permis de comparer exactement les six blocs.

Le rapport possède six sections, en UTF-8/LF. Les totaux de fichiers, lignes et méthodes sont vérifiés. Aucun fichier BLOCKER.md ou BLOCKERS.md ni lien caduc ne se trouve dans l’archive ; aucun nettoyage de bilan nécessaire.

## 6. Limites et clôture

L’évolution est réalisée, testée et archivée. La stricte globale OpenSpec conserve les 22 échecs préexistants ; ils restent hors périmètre et ne constituent pas une validation globale réussie. Le canon concerné passe en mode standard avec ses huit avertissements préexistants.

La livraison concerne les sources DIU. Aucun déploiement, régénération de DEVOPS.md de Pixs ou modification de son pyproject.toml n’a été effectué. Le format documentaire 0.7 reste conservé.

Les sauvegardes et caches temporaires sont supprimés après leurs derniers contrôles, avant l’étape Git. Les étapes conditionnelles de commit local puis publication Forgejo, GitHub et GitLab sont distinctes de l’archivage : leurs résultats réels ou motifs de non-application sont restitués dans le bilan final, après ce rapport, sans préjuger ici de leur succès.


## Change `add-devops-development-hostname` — openspec/changes/archive/2026-10-23-add-devops-development-hostname/STATISTICS.md


# STATISTIQUES — Nom d'hôte de développement et format DEVOPS.md 0.7

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 23 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe ; le développeur a validé le périmètre proposé et
  demandé explicitement la version documentaire 0.7.
- Change : `add-devops-development-hostname`.
- Archive : `2026-10-23-add-devops-development-hostname`.
- Objet : afficher le résultat dynamique de hostname -f après l'OS, comme
  deuxième puce de Système d'exploitation.
- Preuves : commandes et sorties de cette session,
  [tasks.md](tasks.md), [design.md](design.md) et
  [delta OpenSpec](specs/projects-template-devops/spec.md).

SCM est exécuté directement, sans compétence de télémétrie SCMP et sans
pilotage CAB/OpenCode. Le cycle spécification, implémentation, tests,
documentation, synchronisation, archivage et rapport appartient au périmètre
autonome validé.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Capture des références initiales | 2026-10-23T14:30:24.025Z |
| Point de mesure avant le rapport | 2026-10-23T14:36:25.094Z |
| Intervalle partiel mesuré | 361,069 s entre ces points ; hors exploration du tour précédent et contrôles suivants |
| Durée globale complète | N/A : les échanges antérieurs ne sont pas chronométrés globalement |
| Suite unittest complète | 79,678 s selon unittest |
| Tokens, coût, CPU et mémoire | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie |
| Approbations CAB | N/A : SCM directe, protocole non applicable |

## 3. Fichiers et comportement livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 5 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **11** | **1 + 1 + 3 + 1 + 5** |

Six fichiers existants sont modifiés et cinq documents composent l'archive.
OpenSpec a déplacé les quatre artefacts du change actif ; le rapport est
ensuite ajouté. Aucun autre fichier préexistant n'est supprimé ou renommé.

Le rendu produit la version documentaire 0.7. Sous Système d'exploitation,
la première puce reste le nom de l'OS et la deuxième devient le résultat de
`hostname -f`. Le binaire est recherché dans le PATH système contrôlé et
appelé une seule fois par rendu avec le seul argument -f et une borne de
15 secondes. La sortie acceptée est une ligne de 1 à 253 caractères ASCII
alphanumériques, points ou tirets, commençant par un caractère alphanumérique.
Un nom court retourné par la commande est conservé sans suffixe inventé.

Une commande absente, une sonde échouée ou expirée, ou une sortie invalide
produisent un diagnostic fixe dans la deuxième puce. La sortie rejetée et
stderr ne sont pas publiés ; la génération des autres rubriques se poursuit.
Aucun nom n'est codé en dur dans le générateur et aucune configuration du
nom d'hôte ou du réseau n'est modifiée.

Les parcours individuel, groupé et de création conservent le rendu commun.
Leur structure, les autres sondes, la préparation existante des exécutables
DevOps et les règles de publication du document sont préservées.

## 4. Tests et vérifications

| Suite unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Suite complète finale | 119 | 119 | 0 | 0 | 0 |

Les 119 méthodes distinctes comprennent 113 méthodes préexistantes et six
nouvelles. Les sous-tests ne sont pas comptés comme méthodes supplémentaires.
Les nouveaux tests couvrent l'ordre exact OS/nom d'hôte/Matériel, l'argument
-f et l'appel unique, le remplacement d'une ancienne valeur, les noms courts
et la longueur maximale, l'absence et l'échec de commande, les sorties vides,
multilignes, trop longues ou invalides, ainsi que l'expiration. Le test de
délai remplace en mémoire la borne exacte de 15 secondes par 0,05 seconde et
vérifie que le rendu se poursuit. Les tests existants de création et de
génération groupée vérifient aussi la nouvelle puce et le format 0.7.

Commande de suite réellement exécutée :

```bash
env DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node /home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py
```

| Contrôle | État et résultat réellement observé |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, aucun diagnostic |
| Compilation du test Python | Exécutée et réussie avec py_compile.compile et doraise=True ; cfile temporaire sous le dépôt puis nettoyé |
| Change OpenSpec strict | Exécuté et réussi avant toute écriture de code ou test, puis de nouveau avant archivage |
| Canon OpenSpec ordinaire final | Exécuté et réussi, avec huit avertissements de longueur préexistants |
| Contrôle global strict avant archivage | Exécuté et échoué : 46 éléments valides, 22 en échec, total 68 incluant le change actif |
| Contrôle global strict après archivage | Exécuté et échoué : 45 éléments valides, 22 en échec, total 67 ; liste et contenu des diagnostics en échec identiques |
| Concordance delta/canon | Contrôle réussi : une exigence ajoutée, Structure et version documentaire modifiée, 48 exigences préservées |
| Périmètre et empreintes | Contrôle réussi sur 77 fichiers de référence : six modifications prévues, 71 références inchangées ; neuf empreintes figées avant archivage identiques après archivage |
| Binaires réellement installés | Modes, UID, GID et ctime des sept outils DevOps préservés ; aucun rendu réel susceptible de préparer leurs droits n'est lancé |
| Références de version | Code, attentes de tests et documentation courante en 0.7 ; versions de dépendances et anciennes entrées de changelog conservées |
| UTF-8/LF, absence de BOM | Contrôle réussi sur dix fichiers avant le rapport ; contrôle final incluant le onzième |
| Temporaires de tests et compilation | Aucun résidu des préfixes propres à la session |
| Sonde réelle du nom d'hôte | Helper exécuté directement en lecture seule : succès, résultat hvp1.pixs.fr |
| Autres modules, déploiement et génération du DEVOPS.md courant | Non exécutés : hors périmètre |

Le premier audit des métadonnées a échoué sur une comparaison d'entiers ctime
en nanosecondes transférés par JSON/JavaScript. La comparaison a été reprise à
la précision disponible de 256 ns, avec modes et identités comparés exactement :
aucun changement des sept binaires n'est observé. Cet échec du contrôle
auxiliaire ne correspond pas à une modification réelle des fichiers.

Tous les appels OpenSpec utilisent `OPENSPEC_TELEMETRY=0`, le Node explicite
`/home/devops/node/current/bin/node` et le programme
`/home/devops/.local/npm/bin/openspec`.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Helper hostname et rendu commun modifiés ; 119 méthodes distinctes réussies ; sonde réelle hvp1.pixs.fr |
| AGENTS.md | Inchangé, empreinte et mode conservés ; périmètre validé, OpenSpec, rapport et encodage respectés |
| PROJECT.md | Inchangé, empreinte et mode conservés ; responsabilités du module projects et architecture inchangées |
| TECHNICAL.md | Mis à jour dans Traçabilité du document DevOps : version 0.7, deuxième puce, source, validation, délai et diagnostics |
| BUILD.md | Inchangé, empreinte et mode conservés ; aucune modification de construction, dépendance ou installation |
| DEVOPS.md | Inchangé, empreinte et mode conservés ; l'inventaire existant reste à sa version observée 0.6 et adoptera 0.7 à sa prochaine génération normale |
| README.md | Génération documentée en 0.7, avec hostname -f, position et limites de la sonde |
| CHANGELOG.md | Entrée Unreleased ajoutée pour 0.7 ; anciennes entrées historiques préservées |
| openspec/specs/ | projects-template-devops synchronisée : Nom d'hôte dans la rubrique système ajouté et Structure et version documentaire passée à 0.7 |

Commande d'archivage réellement exécutée :

```bash
env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive add-devops-development-hostname --yes
```

La commande retourne zéro, confirme les tâches complètes, synchronise un ajout
et une modification, puis annonce l'archive ciblée. L'absence du change actif,
les quatre artefacts archivés et leur identité avec les empreintes figées
avant archivage sont vérifiées. Aucun autre change n'est archivé.

| Résultat | Nombre |
| --- | ---: |
| Tâches préalables cochées | 6 sur 6 |
| Exigences initiales | 49 |
| Exigences finales | 50 |
| Exigences ajoutées | 1 |
| Exigences modifiées | 1 |
| Exigences préservées | 48 |
| Exigences supprimées ou renommées | 0 |
| Changes archivés | 1 |
| Documents finaux dans l'archive | 5 |

Le rapport est contrôlé après écriture : six sections, 11 fichiers,
119 = 119 + 0 + 0 + 0, 119 = 113 + 6, 50 = 49 + 1 et
49 = 48 + 1, six tâches cochées, UTF-8/LF sans BOM, empreintes témoins et
absence de temporaires. Les opérations de livraison sont prouvées après
exécution, sans avoir été cochées par anticipation.

## 6. Limites et état terminal

L'ajout du nom d'hôte et le passage à la version documentaire 0.7 sont
implémentés, testés, documentés, synchronisés et archivés.

Le contrôle OpenSpec global strict reste en échec sur les mêmes 22 éléments
préexistants : 19 spécifications avec avertissements, un ancien change
d'architecture avec avertissement et deux anciens changes Forgejo incomplets
(`modify-projects-forgejo-push-force-with-lease` et
`restore-forgejo-push-to-create`). Les diagnostics avant/après sont identiques.
Le canon ciblé est valide en mode ordinaire avec ses huit avertissements de
longueur préexistants ; le delta ciblé est valide en mode strict.

Le nom relevé est celui du contexte où DIU s'exécute ; hostname -f utilise les
mécanismes de résolution habituels de ce contexte. Aucun résultat n'est
inventé lorsque la résolution échoue. La lecture réelle isolée du helper
réussit avec hvp1.pixs.fr ; elle ne régénère aucun document.

DEVOPS.md courant n'est pas modifié manuellement ni régénéré ; l'installation
de production n'est pas mise à jour. Les prochaines générations utilisant ces
sources adopteront 0.7. Aucun état Git n'est inspecté ; aucun commit, push,
branche, tag ou release n'est créé. Aucun processus OpenCode ni service
partagé n'est lancé, fermé ou redémarré.



## Change `add-devops-docker-tpm-access` — openspec/changes/archive/2026-11-01-add-devops-docker-tpm-access/STATISTICS.md


# Statistiques — Accès TPM du conteneur Docker de test

## 1. Statistiques générales et décisions

- Session : SCM directe exécutée par Codex ; aucun pilotage CAB/OpenCode ni agent délégué.
- Date de clôture technique : 2026-11-01 (Europe/Paris).
- Début exact et durée : N/A, horodatage initial non collecté.
- Objectif validé : documenter `Accès TPM OK` dans la rubrique Docker générée après test d'accès.
- Décision de lot : aucun code attribué ; ACL demande un rapport et une validation séparés.
- État : change archivé après validation stricte, tests et génération du document.

## 2. Types de messages et d’outils

| Mesure | Valeur |
|---|---|
| Télémétrie exhaustive des messages et appels d'outils | N/A : non collectée dans cette session SCM directe |
| Modèle, jetons, coût et compactions | N/A : données non disponibles |
| Pilotage CAB/OpenCode ou sous-agents | 0 : aucune délégation ni session pilotée |

## 3. Fichiers modifiés

Fichiers du projet touchés :

- `DEVOPS.md`
- `README.md`
- `TECHNICAL.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `openspec/BATCH_CODES.md`
- `openspec/specs/projects-template-devops/spec.md`
- `modules/projects/template.sh`
- `tests/test_projects_template_devops.py`

Artefacts archivés :

- `proposal.md`, `design.md`, `tasks.md`, `.openspec.yaml` et `README.md`
- `specs/projects-template-devops/spec.md`
- ce rapport `STATISTICS.md`

Nombre total de fichiers du change dans l’archive : 7.

## 4. Commandes et validations

| Vérification | Résultat |
|---|---|
| `tpm2_getcap properties-fixed` depuis le compte de développement | Échec : accès direct au périphérique refusé |
| `docker run --rm --device=/dev/tpmrm0 debian:stable-slim ... tpm2_getcap properties-fixed` | Réussie : TPM 2.0, fabricant INTC, révision 1.38 ; outils installés uniquement dans le conteneur éphémère |
| `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p test_projects_template_devops.py` | Réussie : 152 tests, 2 ignorés |
| `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p test_projects_template_all.py` | Réussie : 8 tests |
| `bash -n modules/projects/template.sh` | Réussie |
| `shellcheck modules/projects/template.sh` | Réussie |
| `/home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py` | Réussie |
| Validation stricte OpenSpec du change et de `projects-template-devops` | Réussie après correction des intitulés de scénarios du delta |
| Génération du `DEVOPS.md` par le rendu commun | Réussie ; six puces Docker et inventaire TPM présents |
| Encodage UTF-8 et fins LF des fichiers contrôlés | Réussie |
| Archivage OpenSpec | Réussi : `2026-11-01-add-devops-docker-tpm-access` |
| Validation groupée des changes archivés | Échec global : 106/118 valides ; 12 anciennes archives ont des tâches incomplètes. Ce change est valide dans le résultat (0 problème). |

## 5. Accès web

Accès web : 0. Aucun outil web n'a été utilisé.

## 6. Synthèse globale

Le périphérique TPM de l'hôte a répondu depuis le conteneur Debian lorsque `/dev/tpmrm0` a été transmis explicitement. Le générateur ajoute la mention documentaire demandée après `debian:stable-slim` ; il n'ajoute aucune sonde TPM ni modification du lancement Docker. Les tests ciblés, les parcours de modèle et les validations OpenSpec requis ont réussi. Le change est archivé et reste sans code de lot. Le rapport `STATISTICS.md` global du projet est absent et n'a pas été créé.


## Change `add-devops-hardware-tpm` — openspec/changes/archive/2026-10-23-add-devops-hardware-tpm/STATISTICS.md


# STATISTIQUES — Inventaire matériel TPM dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 23 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, périmètre TPM et cycle OpenSpec complet explicitement
  validés par le développeur après exploration en lecture seule.
- Change : `add-devops-hardware-tpm`.
- Archive : `2026-10-23-add-devops-hardware-tpm`.
- Objet : Matériel après l'OS, puis TPM avec chemin, version, fabricant,
  identifiant fournisseur, révision de spécification et registres PCR.
- Preuves : commandes et résultats de cette session, [tasks.md](tasks.md),
  [design.md](design.md) et delta [specs/projects-template-devops/spec.md](specs/projects-template-devops/spec.md).

SCM est exécuté directement, sans compétence de télémétrie SCMP ni service
CAB/OpenCode. Les autres informations matérielles restent des propositions.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Début de la capture d'empreintes | 2026-10-23T12:27:53.988815Z |
| Point de mesure avant ce rapport | 2026-10-23T12:42:46Z, horloge UTC de session |
| Durée globale complète | N/A : l'exploration du tour précédent et les contrôles après ce point ne sont pas chronométrés globalement |
| Suite TPM initiale | 8,816 s selon unittest |
| Suite complète du générateur | 72,138 s selon unittest |
| Reprise ciblée Go et Node | 0,063 s selon unittest |
| Total des durées unittest | 81,017 s = 8,816 + 72,138 + 0,063 ; hors exploration, édition, lint et OpenSpec |
| Tokens, coût et ressources machine | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie de session |
| Approbations CAB | N/A : SCM directe, protocole CAB non applicable |

## 3. Fichiers et contrat livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 5 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **11** | **1 + 1 + 3 + 1 + 5** |

Six fichiers existants sont modifiés et cinq documents d'archive sont créés.
OpenSpec déplace les quatre artefacts actifs ; ce rapport est ensuite ajouté.
Aucun fichier préexistant n'est supprimé ou renommé par cette session.
Les fichiers témoins AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et
openspec/config.yaml conservent leur empreinte initiale et leur mode.
Les dix empreintes hors canon figées juste avant archivage sont inchangées
après celui-ci. Aucun temporaire de test ou compilation ne subsiste.

La section Matériel suit l'OS et précède Docker, avec une seule sous-rubrique
TPM. Les six puces restent présentes dans l'ordre demandé. Les chemins
tpmrmN sont prioritaires sur tpmN ; la collecte utilise le même indice dans
sysfs. Le fabricant est le code ASCII observé de TPM2_PT_MANUFACTURER et
l'identifiant fournisseur son code hexadécimal, sans nom commercial inventé.
La révision de spécification reste distincte du firmware. Les PCR désignent
les banques et indices alloués, sans lecture de leurs valeurs.

Les requêtes properties-fixed et pcrs utilisent un transport device explicite,
5 secondes de délai et une seconde supplémentaire avant terminaison forcée.
Les réponses de plus de 64 Kio ne sont pas analysées. Les données absentes,
invalides ou ambiguës restent non vérifiables ; les erreurs brutes ne sont
pas publiées. Aucun outil, permission ou état du TPM n'est modifié.
Les rubriques existantes, la version documentaire 0.6, les commandes, les
droits et la publication robuste du document sont conservés.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Suite TPM initiale | 13 | 13 | 0 | 0 | 0 |
| Suite complète du générateur | 103 | 101 | 0 | 0 | 2 |
| Reprise ciblée Go et Node | 2 | 2 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **118** | **116** | **0** | **0** | **2** |

Les 103 méthodes distinctes ont toutes réussi au moins une fois : 89
préexistantes et 14 nouvelles méthodes TPM. Les deux tests réels Go/Node
initialement ignorés ont été repris avec les binaires DevOps explicites et
ont réussi. Les sous-tests ne sont pas comptés comme méthodes supplémentaires.
Les tests utilisent des symlinks vers /dev/null comme périphériques caractères
factices, un sysfs temporaire et un faux tpm2_getcap ; ils ne touchent pas au
TPM réel. Le refus d'accès est simulé à la frontière de contrôle des droits.

Commandes unittest exécutées depuis la racine :

```bash
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k tpm -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
env DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_real_go -k test_real_node -v
```

| Autre contrôle | Résultat observé |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, zéro diagnostic final ; les diagnostics initiaux SC2120/SC2119 ont été corrigés par le passage explicite des racines à la fonction interne |
| Compilation du test modifié | Exécutée et réussie avec le Python DevOps et `-m py_compile`, cache temporaire créé sous la racine puis supprimé |
| Change OpenSpec strict | Deux validations réussies, dont une avant toute écriture de code ou test |
| Canon OpenSpec ordinaire | Exécuté et réussi avant et après synchronisation, avec les mêmes huit avertissements |
| Canon OpenSpec strict | Exécuté et échoué avant et après synchronisation pour les mêmes huit avertissements de longueur, indices 0, 2, 4, 6, 7, 8, 9 et 10 ; comparaison JSON identique |
| Synchronisation canonique ciblée | 40 exigences initiales, 45 finales ; cinq ajoutées, une modifiée, 39 préservées hors séparation finale |
| Empreintes des exigences | Le premier contrôle brut a détecté un saut de ligne séparateur ajouté avant les nouvelles exigences ; la comparaison suivante confirme que seule Structure et version documentaire change de contenu |
| TPM réel en lecture seule | La requête directe initiale échoue pour accès refusé ; le rendu final réussit avec /dev/tpmrm0, version 2.0 issue de sysfs et quatre diagnostics d'accès refusé |
| UTF-8/LF, absence de BOM et modes | Contrôle réussi avant archivage ; rapport et archive contrôlés après écriture |
| Tests des autres modules et qualification complète du TPM réel | Non exécutés : autres modules hors périmètre et accès matériel refusé au compte courant |

Les tests TPM couvrent priorités de chemins et indice sysfs, repli sur tpmN,
famille sans sysfs, absence de périphérique, outil manquant, accès refusé,
TPM 1.2, propriétés partielles/dupliquées, sorties mal formées, PCR invalides,
limites de taille, expiration de chacune des deux sondes et chemins avec
espaces. Les parcours groupé et de création vérifient aussi le rendu TPM.
Aucun test préexistant n'est désactivé ou affaibli ; ses attentes de structure
sont actualisées uniquement pour la rubrique et sous-rubrique ajoutées.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Rendu dans modules/projects/template.sh ; 103 méthodes distinctes validées ; lecture réelle limitée par les droits, explicitée ci-dessus |
| AGENTS.md | Inchangé, empreinte et mode conservés ; sections 5, 6, 7 et 19 respectées : périmètre validé, OpenSpec, rapport d'archive et encodage |
| PROJECT.md | Inchangé, empreinte et mode conservés ; module projects et architecture existants préservés |
| TECHNICAL.md | Mis à jour dans Matériel TPM dans le document DevOps : sources, ordre, diagnostics, délais, PCR et limites |
| BUILD.md | Inchangé, empreinte et mode conservés ; aucune dépendance, construction ou installation modifiée |
| DEVOPS.md | Inchangé, empreinte et mode conservés ; inventaire existant actualisé à sa prochaine génération normale, conformément au périmètre validé |
| README.md | Mis à jour après la présentation de la génération DevOps : rubrique, ordre et limites TPM |
| CHANGELOG.md | Entrée Unreleased ajoutée pour le comportement TPM livré, sans inventer de version de publication |
| openspec/specs/ | projects-template-devops synchronisée : cinq exigences TPM nouvelles et structure complétée ; 39 exigences préservées hors séparateurs |

Tous les appels OpenSpec utilisent le binaire
`/home/devops/.local/npm/bin/openspec`, avec
`PATH=/home/devops/node/current/bin:/usr/local/bin:/usr/bin:/bin` et
`OPENSPEC_TELEMETRY=0`. Les validations utilisent `validate` avec `--type change`
ou `--type spec`, les options `--strict` et `--json` lorsque précisées.
La synchronisation et l'archivage ont été réalisés par :

```bash
env PATH=/home/devops/node/current/bin:/usr/local/bin:/usr/bin:/bin OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive add-devops-hardware-tpm --yes
```

La commande retourne zéro, confirme les tâches complètes, synchronise la
capacité et annonce l'archive ciblée. L'absence du change actif, les quatre
artefacts archivés et les sept tâches cochées sont vérifiés avant création
de ce cinquième document. Aucun autre change n'est archivé.

| Résultat | Nombre |
| --- | ---: |
| Tâches préalables validées | 7 sur 7 |
| Exigences ajoutées | 5 |
| Exigences modifiées | 1 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Changes archivés dans la session | 1 |
| Documents finaux dans l'archive | 5 |

Le contrôle final du présent rapport vérifie les six sections, les 11
fichiers du périmètre, les totaux 118 = 116 + 0 + 0 + 2 et 103 = 89 + 14,
l'encodage UTF-8/LF sans BOM, les sept tâches cochées, les empreintes témoins
et l'absence de temporaires de test ou compilation.

## 6. Limites et suites

L'évolution TPM est implémentée, vérifiée, synchronisée et archivée. Les huit
avertissements canoniques de longueur préexistants restent hors périmètre :
le canon complet échoue toujours en mode strict, tandis que son mode ordinaire
et le delta ciblé sont valides. Aucun nouvel avertissement n'est introduit.

La collecte matérielle complète n'a pas pu être vérifiée sur le TPM réel
avec le compte courant ; aucune élévation de privilèges ou modification des
droits n'est tentée. Les lectures réussies sont validées par fixtures isolées.
Le code ASCII fabricant ne constitue pas un nom commercial déduit. Les
banques/indices PCR décrivent l'allocation, sans qualification d'attestation.

DEVOPS.md existant n'est pas régénéré et la production n'est pas mise à jour.
Les documents adopteront ce rendu à leur prochaine génération normale avec
les sources modifiées. Aucun état Git n'est inspecté, aucun commit, push,
branche, tag ou release n'est créé. Aucun service partagé n'est touché.
CPU, mémoire, GPU et stockage restent à l'état de propositions.


## Change `add-devops-nuitka-detection` — openspec/changes/archive/2026-10-26-add-devops-nuitka-detection/STATISTICS.md


# STATISTIQUES — Détection conditionnelle de Nuitka dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`), racine `/home/devops/datas/diu`.
- Session SCM directe, version 0.1 ; change `add-devops-nuitka-detection` ; date : 26 octobre 2026.
- Archive : `2026-10-26-add-devops-nuitka-detection`.
- Périmètre présenté puis explicitement validé par le développeur : détection Nuitka dans [build-system].requires, rubrique commune avec Cython, tests, documentation, synchronisation OpenSpec, archivage et statistiques.
- Aucun pilotage OpenCode, CAB ni sous-agent ; aucune compétence de statistiques pilotées invoquée, conformément à SCM.
- Les étapes Git conditionnelles prévues par SCM suivent ce rapport et restent distinctes de l’archivage.

## 2. Durées et mesures disponibles

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée totale de session | N/A | Pas de chronométrage complet fiable |
| Premier passage ciblé Cython/Nuitka | 25 tests réussis, 18,752 s | Sortie unittest observée |
| Complément découverte/sonde partagées | 1 test réussi, 0,144 s | Ajouté après le lancement du premier passage |
| Ciblés uniques validés | 26 | 14 existants Cython et 12 nouveaux Nuitka |
| Suite complète finale | 152 tests réussis, 114,953 s | Aucun cas ignoré, chemin Go déclaré fourni |
| Exécutions de méthodes de test | 178, toutes réussies | 25 + 1 + 152 ; les sous-cas ne sont pas additionnés |
| Cas uniques validés | 152 | Les ciblés sont inclus dans la suite finale |
| Nouveaux cas uniques Nuitka | 12 | Plus enrichissement du test existant de création |
| Modèle, jetons et coût | N/A | Aucune télémétrie qualifiée disponible |
| Messages, outils et commandes totaux | N/A | Aucun compteur exhaustif qualifié |
| Approbations/refus CAB | Non applicable | SCM directe |
| Recherche web | 1 appel préparatoire, 0 pendant la reprise de réalisation | Documentation officielle Nuitka consultée pendant l’exploration avant validation |

## 3. Fichiers et comportement livré

Six fichiers existants modifiés et cinq fichiers dans la nouvelle archive, rapport inclus : onze fichiers. Les écarts ci-dessous proviennent des sauvegardes ciblées initiales ; ils n’attribuent pas au change des modifications antérieures du dépôt.

| Fichier existant | Lignes ajoutées | Lignes retirées |
| --- | ---: | ---: |
| modules/projects/template.sh | 34 | 26 |
| tests/test_projects_template_devops.py | 213 | 8 |
| TECHNICAL.md | 24 | 20 |
| README.md | 12 | 9 |
| CHANGELOG.md | 8 | 0 |
| openspec/specs/projects-template-devops/spec.md | 56 | 5 |
| Total | 347 | 68 |

L’archive contient proposal.md, design.md, tasks.md, specs/projects-template-devops/spec.md et ce STATISTIQUES.md. Aucun fichier de l’archive Cython précédente n’a été modifié par cette évolution.

Le mode compilation du helper existant reconnaît seulement les distributions Cython et Nuitka déclarées dans [build-system].requires, sans distinction de casse, avec extras, contraintes et marqueurs déclaratifs. L’alias interne cython est conservé. Le rendu utilise compilation, effectue une seule découverte et demande seulement les noms déclarés encore recherchés aux sondes.

Une seule rubrique suit pip et précède Prompts. Elle affiche Cython puis Nuitka, uniquement s’ils sont déclarés. Sans les deux déclarations, la rubrique et toute découverte/sonde de compilation sont omises. Une autre table ou un commentaire ne déclenche pas cet inventaire.

Les états restent indépendants par outil : version, interpréteur, environnement et installation observés ; non installé avec les venv vérifiés si l’absence est établie ; installation non vérifiable sinon, notamment sans venv. Une ambiguïté de métadonnées pour l’un ne modifie pas une observation valide de l’autre. Aucun paquet global ne sert de repli.

Sondes -I -B -S, mêmes priorités de venv et mêmes bornes de 3 secondes par sonde et 12 secondes pour recherche/sondes. Aucun import de Cython ou Nuitka, chargement de .pth, installation, compilation, modification de manifeste ou de backend. Les références directes sont masquées et les contraintes ne sont pas résolues. Les versions présentes dans les fixtures ne prouvent aucune installation réelle des compilateurs.

## 4. Tests et vérifications

| Contrôle | État final et résultat |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi |
| shellcheck modules/projects/template.sh | Exécuté et réussi |
| py_compile tests/test_projects_template_devops.py | Exécuté et réussi avec Python DevOps, cache isolé dans le temporaire de session |
| Tests ciblés Cython/Nuitka | Exécutés et réussis : 25 méthodes puis un complément, 26 uniques |
| Suite complète du générateur | Exécutée et réussie : 152 méthodes, aucun cas ignoré |
| Change OpenSpec strict | Exécuté et réussi avant code puis après implémentation, sans diagnostic |
| Canon OpenSpec standard après archivage | Exécuté et réussi avec ses huit avertissements préexistants |
| Stricte globale initiale | Exécutée et échouée : 46 valides, 22 échecs sur 68 éléments |
| Stricte globale avant archive | Exécutée et échouée : 47 valides, mêmes 22 échecs et diagnostics sur 69 éléments |
| Stricte globale finale | Exécutée et échouée : 46 valides, mêmes 22 échecs et diagnostics initiaux sur 68 éléments |
| Synchronisation | Six blocs du delta retrouvés exactement dans le canon |
| UTF-8/LF et périmètre | Vérifiés par lecture et comparaison aux sauvegardes ciblées |
| Construction de paquet, installation et compilation applicative | Non pertinentes : génération documentaire DIU uniquement |

Commandes principales réellement exécutées :

```bash
bash -n modules/projects/template.sh
shellcheck modules/projects/template.sh
env PYTHONPYCACHEPREFIX=<temporaire-de-session>/pycache /home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_nuitka -k test_cython
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_nuitka_shared
env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate add-devops-nuitka-detection --type change --strict --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate projects-template-devops --type spec --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate --all --strict --json
```

Couverture : quatre combinaisons de déclaration, ordre et titre unique, casse, extras, marqueurs, contraintes, références masquées, autres tables et commentaires ignorés, noms demandés aux sondes limités aux déclarations, découverte et sonde uniques pour deux outils dans le même venv, états indépendants, métadonnées dupliquées, paquets globaux ignorés, environnements distincts et chemins avec espaces, priorité, non-import et .pth non chargé, absence de venv, échec, budget épuisé, terminaison des descendants expirés, analyse sans Python DevOps, manifeste invalide, génération groupée et création depuis modèle Python déclarant les deux compilateurs. Les tests Cython antérieurs restent exécutés.

Aucun contrôle requis du change n’est en échec. La stricte globale conserve ses diagnostics préexistants ; elle n’est pas présentée comme réussie. Aucune modification de code ni de tests après la suite finale.

## 5. Cohérence documentaire et archivage

| Élément | État final et preuve |
| --- | --- |
| Projet réel | Générateur et 152 tests validés ; pas de génération sur un projet réel |
| AGENTS.md | Inchangé, comparaison octet pour octet ; règles générales respectées |
| PROJECT.md | Inchangé, comparaison octet pour octet ; architecture et module projects préservés |
| TECHNICAL.md | Mis à jour : Outils de compilation Python : Cython et Nuitka déclarés, découverte commune et états indépendants |
| BUILD.md | Inchangé, comparaison octet pour octet ; packaging non concerné |
| DEVOPS.md | Inchangé pendant cette réalisation, comparaison octet pour octet ; relevé daté conservé au format 0.7 |
| README.md | Mis à jour : déclenchement des deux outils, rubrique unique, états et limites |
| CHANGELOG.md | Entrée Unreleased ajoutée sans version de publication inventée |
| openspec/config.yaml | Inchangé, comparaison octet pour octet |
| openspec/specs/projects-template-devops/spec.md | Synchronisé : trois exigences ajoutées, trois modifiées, aucune supprimée ou renommée |

Archivage effectué sous devops par `openspec archive add-devops-nuitka-detection --yes --json`, code 0, specsUpdated=true. Dossier actif absent et archive présente ; six tâches cochées sur preuves. Les six contrats du delta ont une longueur inférieure à 500 caractères ; aucun nouvel avertissement dans le canon.

Ce rapport comporte six sections, en UTF-8/LF ; les totaux de fichiers, lignes et tests sont vérifiés. Aucun BLOCKER.md ou BLOCKERS.md ni lien caduc dans cette archive ; aucun nettoyage de bilan nécessaire. Aucun autre change ni archive modifié dans le cadre de cette évolution.

## 6. Limites et clôture

L’évolution est réalisée, testée et archivée. Les 22 échecs OpenSpec stricts préexistants restent hors périmètre et sont identiques à l’état initial ; le canon concerné passe en mode standard avec huit avertissements préexistants.

La livraison porte sur les sources DIU. Aucun déploiement, régénération de DEVOPS.md de Pixs, modification de son pyproject.toml ni compilation avec Nuitka n’a été effectué. Les documents existants adoptent la rubrique lors de leur prochaine génération avec cette version DIU.

Les sauvegardes et caches temporaires sont retirés après leurs derniers contrôles et avant Git. Les étapes conditionnelles de commit global local puis Forgejo, GitHub et GitLab suivent ce rapport ; leurs résultats vérifiés ou motifs de non-application sont restitués dans le bilan final, sans préjuger ici de leur réussite.


## Change `add-devops-openssh-sshpass` — openspec/changes/archive/2026-10-26-add-devops-openssh-sshpass/STATISTICS.md


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


## Change `add-devops-project-env-guidance` — openspec/changes/archive/2026-11-03-add-devops-project-env-guidance/STATISTICS.md


# Statistiques — add-devops-project-env-guidance

## 1. Statistiques générales et décisions

Session SCM directe du 3 novembre 2026 ; un agent de codage. Change archivé,
code non attribué ; attribution ultérieure à traiter par ACL. Version DIU
1.0.7 vers 1.0.8 ; version documentaire DEVOPS.md 0.7 vers 0.8. Durée et
volumes de jetons : N/A, mesures non disponibles.

## 2. Types de messages et d'outils

Échanges avec le développeur, outils locaux de lecture, édition et validation.
Décomptes exhaustifs : N/A, télémétrie de session non disponible. Aucun agent
de pilotage ni collecte de télémétrie dédiée n'a été lancé.

## 3. Fichiers modifiés

Générateur `modules/projects/template.sh`, tests `tests/test_projects_template_devops.py`,
document local `DEVOPS.md`, valeur ciblée `PROJECT_VERSION` dans `project.env`,
`CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`, capacité
`openspec/specs/projects-template-devops/spec.md` et artefacts de cette archive.
Les données sensibles ne sont pas reproduites.

## 4. Commandes

`bash -n` et ShellCheck sur le générateur : réussis. Test ciblé du contenu :
réussi. Suite ciblée avec Python DevOps : 153 tests, dont 2 ignorés, réussie.
Suite globale avec Python DevOps : 1 105 tests, dont 2 ignorés, réussie.
Une première suite avec Python système a échoué : une attente de titre a été
corrigée et 26 erreurs de création de fixtures Python ont été évitées avec
l'interpréteur DevOps retenu par le projet. Validations OpenSpec strictes du
change et de la capacité : réussies. Archive créée le 2026-11-03.

## 5. Accès web

Aucun accès web effectué pendant la réalisation. Publications Git : résultat
non encore disponible au moment de la rédaction de ce rapport.

## 6. Synthèse globale

Le texte demandé est produit une fois avant la légende des sondes ; les
versions documentaire et DIU sont mises à jour. Les validations citées
ci-dessus établissent le résultat local, sans prouver de déploiement.
Rapport global : absent ; mandater SGS.md pour le générer.


## Change `add-devops-prompts-section` — openspec/changes/archive/2026-10-19-add-devops-prompts-section/STATISTICS.md


# STATISTIQUES — Section Prompts du document DevOps

## 1. Identification et périmètre

Date : 19 octobre 2026, Europe/Paris.
Change : `add-devops-prompts-section`.
Archive : `2026-10-19-add-devops-prompts-section`.

Session SCM directe. Le périmètre couvre la rubrique Prompts du générateur
DevOps, les chemins issus de ENV_DEVOPS_USER, la version documentaire 0.6,
les tests ciblés, la documentation et le cycle OpenSpec jusqu'à l'archivage.
Le périmètre initial a été validé, avec l'incrément de version de 0.1.

Le dossier prompts et son index ne sont ni lus ni créés par cette nouvelle
rubrique. Les lectures initiales de PROMPTS/INDEX.md et PROMPTS/SCM.md
relèvent uniquement du lancement de la session demandé. Aucun fichier de
prompts n'est modifié. Aucun état Git n'est inspecté ; aucun commit, push,
changement de branche, déploiement ou installation n'est exécuté.

## 2. Durées et mesures disponibles

| Exécution de la suite ciblée | Durée, secondes |
| --- | ---: |
| Python système 3.13.5 | 74.471 |
| Python DevOps 3.14.8, Node et Go explicites | 84.497 |
| Total des deux exécutions | 158.968 |

Durée totale de session : N/A, absence de mesure globale continue.
Tokens, coût, comptes exhaustifs des messages et des outils : N/A,
absence de télémétrie de pilotage dans cette session SCM.
Lignes modifiées et état Git global : N/A, inspection Git non autorisée.
Agents délégués : 0. Paquets installés : 0. Archivages exécutés : 1.

## 3. Fichiers et contrat

Six fichiers préexistants sont modifiés dans le périmètre :

- `modules/projects/template.sh` : version 0.6 et rendu de la rubrique Prompts ;
- `tests/test_projects_template_devops.py` : attentes de version, rubrique,
  parcours individuel, groupé et final de création, compte DevOps configurable ;
- `TECHNICAL.md` : section Traçabilité du document DevOps ;
- `README.md` : description du format et des emplacements des prompts ;
- `CHANGELOG.md` : entrée Unreleased ;
- `openspec/specs/projects-template-devops/spec.md` : synchronisation officielle
  d'une exigence modifiée et de deux exigences ajoutées.

Quatre fichiers du change sont créés puis déplacés par l'archivage :
`proposal.md`, `design.md`, `tasks.md` et
`specs/projects-template-devops/spec.md`. Ce rapport est le cinquième fichier
de l'archive, soit onze fichiers de livraison distincts au total. Les créations
et déplacements du même fichier ne sont pas additionnés deux fois.

Le rendu réutilise devops_home, construit par la fonction publique avec
`/home/${ENV_DEVOPS_USER:-}` après validation du compte. Les chemins sont
`${devops_home}/datas/prompts` et `${devops_home}/datas/prompts/INDEX.md`.
Ils ne dépendent ni de DEVOPS_PROJECTS_ROOT ni de l'identifiant du projet.
La rubrique suit le gestionnaire de paquets Python et précède les navigateurs.

La comparaison SHA-256 des blocs d'exigences, avant et après archivage,
confirme 36 exigences antérieures inchangées, une modifiée et deux ajoutées :
39 exigences au total. Les trois blocs concernés correspondent exactement
au delta archivé. Les huit tâches du change sont cochées.

## 4. Tests et vérifications

Commande de la suite initiale :

```bash
python3 -m unittest discover -s tests -p 'test_projects_template_devops.py'
```

Commande de la suite finale, avec les outils référencés par DEVOPS.md :

```bash
env DIU_TEST_NODE=/home/devops/node/current/bin/node DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test_projects_template_devops.py'
```

| Suite | Cas comptés | Réussis | Échecs d'assertion | Erreurs | Ignorés |
| --- | ---: | ---: | ---: | ---: | ---: |
| Initiale, Python système | 89 | 78 | 0 | 9 | 2 |
| Finale, Python DevOps | 89 | 89 | 0 | 0 | 0 |
| Total, répétitions incluses | 178 | 167 | 0 | 9 | 2 |

Résultat final : **89 tests distincts réussis, aucun ignoré**.
Les neuf erreurs initiales sont des StopIteration dans la préparation des
fixtures de venv avec le Python système 3.13.5. La relance avec le Python
DevOps 3.14.8 réussit sans changement de ces fixtures ni affaiblissement des
assertions. Les chemins Node et Go explicites permettent aussi l'exécution
des deux scénarios runtime initialement ignorés.

Le nouveau test conserve le calcul réel du domicile et le rendu ; il simule
les identités et les sondes et écrit uniquement dans sa fixture. Il vérifie
les comptes devops et ci-builder avec une racine de projets séparée. Les
tests de rendu contrôlent l'unicité et l'ordre de la section, les deux chemins
et l'absence de création de prompts. Les parcours groupé et de création
contrôlent aussi la nouvelle rubrique. Les fixtures temporaires sont nettoyées.

| Contrôle | État |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi |
| `python3 -m py_compile tests/test_projects_template_devops.py` | Exécuté et réussi |
| Compilation identique avec `/home/devops/python/current/bin/python3` | Exécutée et réussie |
| Validation stricte du change avant code et tests | Exécutée et réussie après découpage d'une exigence trop longue |
| Validation stricte du change avant archivage | Exécutée et réussie |
| Validation standard de la spécification synchronisée | Exécutée et réussie, huit avertissements préexistants |
| Validation stricte de la spécification complète | Exécutée et échouée sur ces huit avertissements |
| Contrôle UTF-8/LF, absence de NUL et LF final | Exécuté et réussi sur les fichiers du périmètre |
| Comparaison des exigences et vérification des tâches | Exécutées et réussies |
| Suite entière du dépôt et installation réelle | Non exécutées, hors de la validation ciblée nécessaire |

Les commandes OpenSpec utilisent le compte devops par sudo et les chemins
explicites `/home/devops/node/current/bin/node` et
`/home/devops/.local/npm/bin/openspec`. Les validations utilisent
`validate add-devops-prompts-section --type change --strict`, puis
`validate projects-template-devops --type spec` avec et sans `--strict`.

## 5. Résultats, cohérence et archivage

Avec ENV_DEVOPS_USER=devops, la nouvelle rubrique est :

```markdown
# Prompts

  * Dossier des prompts : /home/devops/datas/prompts
  * Index des prompts : /home/devops/datas/prompts/INDEX.md
```

Archivage officiel exécuté une seule fois :

```bash
sudo -n -u devops /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive add-devops-prompts-section --json --yes
```

Résultat : specsUpdated=true, deux exigences ajoutées, une modifiée, aucune
supprimée ni renommée. Le change n'est plus actif ; ses quatre artefacts
sont dans l'archive indiquée, complétés par ce rapport à six sections.

| Élément de la matrice SCM | État et preuve documentaire |
| --- | --- |
| Projet réel | Générateur 0.6, printf Prompts dans projects_template_devops_render et 89 tests ciblés réussis |
| AGENTS.md | Inchangé : sections 6 et 7 appliquées pour OpenSpec et le rapport d'archive ; aucune nouvelle règle d'agent nécessaire |
| PROJECT.md | Inchangé : Architecture fonctionnelle, module projects ; l'ajout reste dans la gestion des projets existante |
| TECHNICAL.md | Mis à jour : Traçabilité du document DevOps, version 0.6 et convention des chemins |
| BUILD.md | Inchangé : Objet et Contenu du paquet ; la construction et son périmètre ne changent pas |
| DEVOPS.md | Inchangé : relevé UTC 2026-10-19T05:35:05Z en version 0.5, conservé comme instantané ; prochain rendu en 0.6, sans régénération du relevé réel dans cette session |
| README.md | Mis à jour : génération de l'inventaire DevOps et rubrique Prompts |
| CHANGELOG.md | Mis à jour : Unreleased, format 0.6 et chemins selon le compte configuré |
| openspec/specs/ | Synchronisé : Structure et version documentaire, Emplacements des prompts communs, Références Prompts passives |
| openspec/config.yaml | Inchangé : schéma spec-driven, aucune configuration supplémentaire |

Le titre, les sondes, leurs diagnostics, les commandes, les permissions et
l'ordre relatif des rubriques existantes sont préservés. Le dernier bloc
reste consacré aux navigateurs. Aucun fichier de cadrage absent n'a dû être
créé. Les autres changes actifs ne sont pas traités.

## 6. Limites et suites

La validation stricte de la spécification complète reste en échec sur huit
avertissements de longueur supérieure à 500 caractères. La comparaison des
empreintes confirme que leurs huit exigences sont intégralement inchangées :
Commande de génération du modèle DevOps ; Distinction entre hôte et
environnement DevOps ; Vérification sûre du serveur PostgreSQL ; Manifeste
Python conditionnel ; Génération finale lors de la création ; Génération
DevOps de tous les projets configurés ; Bilan et poursuite du traitement
groupé ; Navigateurs externes hôte pour le mode headless.

Le change ciblé passe les contrôles stricts et la spécification complète
passe le contrôle standard. Ces avertissements préexistants sont conservés
dans le bilan ; leur réécriture dépasse l'ajout de la section Prompts.

Les chemins indiquent une convention d'emplacement, pas une preuve de présence
ou d'accessibilité des prompts. Aucune nouvelle dépendance, migration ou
sonde n'est introduite. La version installée du DIU et les documents DevOps
déjà générés ne sont pas actualisés par cette session.

Le contrôle de périmètre porte sur les écritures effectuées et les fichiers
explicitement examinés. Il ne constitue pas un inventaire des modifications
antérieures ou concurrentes du dépôt ; aucun état Git ni relevé initial global
du système de fichiers n'est disponible pour établir cet inventaire.

### Correction des chemins — 19 octobre 2026

Les deux chemins utilisent désormais le dossier `prompts` en minuscules :
`/home/${ENV_DEVOPS_USER}/datas/prompts` et
`/home/${ENV_DEVOPS_USER}/datas/prompts/INDEX.md`. La version reste 0.6.
Le générateur, les attentes des tests, les trois documents concernés et les
artefacts OpenSpec existants sont alignés, sans nouvel archivage. Les exemples
et le contrat ci-dessus reflètent cette correction ; les mesures des deux
exécutions initiales sont conservées.

Une exécution supplémentaire avec le Python DevOps 3.14.8 réussit : quatre
tests, zéro échec, zéro erreur, zéro ignoré, en 4.137 secondes. Elle couvre
la structure du document, la génération finale de création, la génération
groupée et les chemins selon le compte configuré avec une racine distincte.
Ces mesures s'ajoutent aux deux exécutions initiales : 182 cas comptés,
171 réussis, neuf erreurs initiales et deux ignorés initiaux, pour 163.105
secondes cumulées de suites.

Bash -n, ShellCheck et la compilation du test avec le Python DevOps sont
exécutés et réussis. La validation standard de la spécification complète
réussit avec les huit avertissements préexistants. Le contrôle ciblé confirme
UTF-8/LF, les trois blocs de spécification synchronisés, les chemins en
minuscules et le nettoyage des fixtures.


## Change `add-devops-test-container-authorization` — openspec/changes/archive/2026-10-24-add-devops-test-container-authorization/STATISTICS.md


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



## Change `add-devops-tests-environment-flags` — openspec/changes/archive/2026-10-24-add-devops-tests-environment-flags/STATISTICS.md


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


## Change `add-docker-stack-devops-variable` — openspec/changes/archive/2026-11-01-add-docker-stack-devops-variable/STATISTICS.md


# Statistiques — add-docker-stack-devops-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-docker-stack-devops-variable`, code de lot non attribué.
- Décision validée : `DOCKER_STACK_DEVOPS`, `STATIC`, `ENABLE`, scope `docker`,
  défaut `0`.
- Le nom existant est conservé. Une valeur déjà fournie par l’environnement ou
  `docker.env` reste prioritaire; le défaut est persisté seulement si la
  variable est absente.
- `DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN` et les consommateurs de stack restent
  inchangés.
- Archivage réussi sous `2026-11-01-add-docker-stack-devops-variable`. La spec
  canonique existait déjà au moment de l’archivage; aucune synchronisation
  additionnelle n’a été nécessaire.
- Suite complète DIU avec Python 3.14.10 : 737 tests réussis, 2 ignorés,
  aucun échec.
- Publication et nouvelle exécution DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

10 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `modules/diu/variables/docker/docker_stack_devops.sh`.
- Tests : `tests/test_docker_stack_devops.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spec canonique : `openspec/specs/docker-stack-devops/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, la spec delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_docker_stack_devops` : 6 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 737 tests réussis, 2 ignorés.
- `bash -n modules/diu/variables/docker/docker_stack_devops.sh` : réussi.
- `shellcheck root-install-debian.sh modules/diu/variables/docker/docker_stack_devops.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_docker_stack_devops.py` : réussi.
- Validations strictes OpenSpec du change et de `docker-stack-devops` : réussies.
- Validation stricte OpenSpec globale avant archivage : 66/83 valides; 17 avertissements existants dans d’autres changes/specs.
- `openspec archive add-docker-stack-devops-variable --yes --json` : réussi; aucun delta canonique additionnel.
- `openspec validate --archived --json --no-interactive` : 117/129 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration statique Docker de `DOCKER_STACK_DEVOPS` est ajoutée avec le
défaut `0`. Le nom et le consommateur existants sont préservés; une valeur
déjà chargée reste prioritaire. Le change est archivé; tests, contrôles shell
et validations OpenSpec ciblées réussissent. Publication et relance DIU dans
CISMP restent à faire. Le `STATISTICS.md` général à la racine est absent; le
prompt SGS devra être mandaté pour le générer.


## Change `add-docker-stack-traefik-dockhand-variable` — openspec/changes/archive/2026-11-01-add-docker-stack-traefik-dockhand-variable/STATISTICS.md


# Statistiques — add-docker-stack-traefik-dockhand-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-docker-stack-traefik-dockhand-variable`, code de lot non
  attribué.
- Décision validée : `DOCKER_STACK_TRAEFIK_DOCKHAND`, `STATIC`, `ENABLE`, scope
  `docker`, défaut `0`.
- Le nom existant est conservé. Une valeur déjà fournie par l’environnement ou
  `docker.env` reste prioritaire; le défaut est persisté seulement si la
  variable est absente.
- `DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN` et
  `DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE` restent distinctes et hors de ce
  change.
- Archivage réussi sous
  `2026-11-01-add-docker-stack-traefik-dockhand-variable`. La spec canonique
  existait déjà au moment de l’archivage; aucune synchronisation additionnelle
  n’a été nécessaire.
- Suite complète DIU avec Python 3.14.10 : 731 tests réussis, 2 ignorés,
  aucun échec.
- Publication et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

10 fichiers liés au changement et à sa clôture documentaire :

- Implémentation :
  `modules/diu/variables/docker/docker_stack_traefik_dockhand.sh`.
- Tests : `tests/test_docker_stack_traefik_dockhand.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spec canonique : `openspec/specs/docker-stack-traefik-dockhand/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, la spec delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_docker_stack_traefik_dockhand` : 6 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 731 tests réussis, 2 ignorés.
- `bash -n modules/diu/variables/docker/docker_stack_traefik_dockhand.sh` : réussi.
- `shellcheck root-install-debian.sh modules/diu/variables/docker/docker_stack_traefik_dockhand.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_docker_stack_traefik_dockhand.py` : réussi.
- Validations strictes OpenSpec du change et de `docker-stack-traefik-dockhand` : réussies.
- Validation stricte OpenSpec globale avant archivage : 65/82 valides; 17 avertissements existants dans d’autres changes/specs.
- `openspec archive add-docker-stack-traefik-dockhand-variable --yes --json` : réussi; aucun delta canonique additionnel.
- `openspec validate --archived --json --no-interactive` : 116/128 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration Docker de `DOCKER_STACK_TRAEFIK_DOCKHAND` est ajoutée en
`STATIC`, `ENABLE`, scope `docker`, défaut `0`. Le nom et les consommateurs
existants sont conservés; toute valeur déjà chargée reste prioritaire. Le
change est archivé; tests, contrôles shell et validations OpenSpec ciblées
réussissent. Publication et nouvelle exécution dans CISMP restent à faire. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.


## Change `add-environment-docker-user-variable` — openspec/changes/archive/2026-11-02-add-environment-docker-user-variable/STATISTICS.md


# Statistiques — add-environment-docker-user-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-environment-docker-user-variable`, code de lot non attribué.
- Contrat validé : `ENVIRONMENT_DOCKER_USER`, `STATIC`, `ENABLE`, scope
  `docker`, défaut `docker`.
- La valeur littérale historique `DOCKER_USER` est transférée exactement vers
  `docker.env`; une nouvelle valeur déjà configurée garde la priorité.
- Les consommateurs du propriétaire des stacks Docker utilisent le nouveau
  nom; `ENV_DOCKER_USER` reste distinct.
- Archivage réussi sous `2026-11-02-add-environment-docker-user-variable`,
  avec deux spécifications ajoutées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 817 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet et nouvel essai CISMP restent à effectuer après ce
  relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/docker/docker_user.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_sudoers.py`,
  `tests/test_docker_user_environment.py`, `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `docker-user` et `legacy-variable-cleanup`.
- Archive : proposition, design, tâches, deux deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  817 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, consommateurs Docker et Sudoers :
  réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/docker/docker_user.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_docker_user_environment.py
  tests/test_config_cleanup.py tests/test_devops_sudoers.py
  tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  add-environment-docker-user-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  add-environment-docker-user-variable --yes --json` : réussi; deux specs
  ajoutées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le propriétaire des stacks Docker est maintenant déclaré comme
`ENVIRONMENT_DOCKER_USER` dans le scope `docker`, avec défaut `docker`. L'ancien
`DOCKER_USER` est migré sans altérer sa valeur; les noms préfixés comme
`ENV_DOCKER_USER` restent distincts. Tests, contrôles Bash, validation OpenSpec
stricte et archivage réussissent. Publication et relance DIU dans CISMP restent
à effectuer. Le rapport général `STATISTICS.md` à la racine est absent; sa
production relève du prompt SGS.


## Change `add-github-debian-release` — openspec/changes/archive/2026-11-02-add-github-debian-release/STATISTICS.md


# Statistiques — publication Debian GitHub

## 1. Statistiques générales et décisions

Session directe SCM du 2026-11-02, plan SCM-GITHUB-DEBIAN-20261102-R1 validé en
version 1.0.3. Un agent Codex, sans délégation, CAB, OpenCode ni télémétrie de
pilotage. Le change add-github-debian-release est archivé sous
2026-11-02-add-github-debian-release ; quatre tâches validées, cinq exigences
ajoutées et quatre modifiées dans quatre capacités synchronisées.
Code non attribué ; aucune allocation de code ou de sous-lot définitif hors ACL.
Durée totale, coûts, tokens et quotas : N/A, sans mesure exhaustive disponible.

## 2. Types de messages et d'outils

Exploration, précisions des conditions Forgejo et de la version, proposition,
validation explicite, suivi et restitution. Outils : recherche/lecture locale,
résolution SCM, patches, exécution locale et consultation de documentation
GitHub officielle. Totaux exhaustifs de messages/appels : N/A, sans journal
instrumenté. Aucune compétence réservée à une session pilotée n'est invoquée.
Les vérifications de connexion et publications Git après ce rapport sont
restituées dans le bilan final, sans anticipation de réussite ici.

## 3. Fichiers modifiés

Vingt-sept livrables publics, rapport inclus, et une configuration locale :
28 ressources traitées. L'archivage ne compte pas deux fois les mêmes fichiers.
Les éventuelles modifications extérieures ne sont pas attribuées à ce total.

- `root-install-debian.sh`
- `lib/rid-help.sh`
- `lib/github-auth.sh`
- `modules/projects/git.sh`
- `modules/projects/github-release.sh`
- `tests/test_projects_github_debian_release.py`
- `tests/test_projects_cicd_debian.py`
- `tests/test_project_version.py`
- `PROJECT.md`
- `TECHNICAL.md`
- `BUILD.md`
- `README.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `openspec/BATCH_CODES.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/design.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/proposal.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/implement-projects-github-release/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/projects-cicd/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/projects-github-debian-release/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/tasks.md`
- `openspec/specs/projects-github-debian-release/spec.md`
- `openspec/specs/implement-projects-github-release/spec.md`
- `openspec/specs/projects-cicd/spec.md`
- `openspec/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/STATISTICS.md`

- Configuration locale `project.env` : seule PROJECT_VERSION passe de 1.0.2 à
  1.0.3, un octet modifié ; autres octets, inode, permissions et propriétaire
  préservés. Aucune autre valeur privée n'est exposée ni copiée dans ce rapport.

AGENTS, DEVOPS, lib/project-version.sh, lib/forgejo-auth.sh, les modules de
release Forgejo, packaging historique et Docker, et la recette DIU conservent
leurs empreintes au contrôle de qualification. Forgejo et GitLab ne sont pas
modifiés. Le corps GHCR est conservé dans un helper dédié ; ses anciens tests
restent exécutés, avec contrôle de casse et absence de build.

## 4. Commandes et validations

| Contrôle réellement exécuté | Résultat |
|---|---|
| Publisher Debian et authentification | 30 tests réussis en 18,787 s |
| Sept suites ciblées publication, CI/CD, projets, version, aide, indisponibilité et credentials | 175 tests réussis en 46,446 s |
| Suite complète avec DIU_TEST_GO déclaré | 1 074 tests réussis en 338,324 s ; aucun échec, erreur ou saut |
| Syntaxe Bash des cinq fichiers modifiés | Réussie |
| ShellCheck avec dépendances explicites | Réussi sans diagnostic |
| Compilation des trois fichiers Python modifiés | Réussie |
| OpenSpec du change strict | Réussi, scénarios historiques conservés |
| openspec archive add-github-debian-release --yes | Réussi, cinq ajouts et quatre modifications |
| OpenSpec global standard avant/après archivage | 118/118 valides |
| OpenSpec global strict avant/après archivage | 71 valides, mêmes 47 éléments historiques en échec |
| Quatre canons concernés après synchronisation | Quatre validations strictes réussies |
| Revue documentaire avant archivage | 22 fichiers UTF-8/LF, nouvelles cibles de liens présentes, huit sources surveillées inchangées |

Les 30 et 175 tests ciblés sont des sous-ensembles/répétitions, pas des nombres
à ajouter aux 1 074 tests uniques. Le nouveau fichier contient 24 méthodes et
la suite CI/CD reçoit un cas supplémentaire ; HTTP, assets, erreurs, choix
Docker/Debian, authentification et anciennes publications GHCR sont vérifiés.
Les premières fixtures héritaient du setgid sur DEBIAN : mode exact 0755 appliqué
avant les constructions réelles. Les quotes et les annotations de portée
dynamique signalées par ShellCheck sont corrigées, sans affaiblissement d'attente.

Paquets Debian réels sur fixtures ; Git, API, upload et Docker simulés. Les
contrôles vérifient HTTP/JSON, refus de release existante, tag absent ou erroné,
version, branche et remote, URL d'upload, id/noms/état/taille des assets,
interruption, nettoyage et confidentialité. Aucun artefact n'est réellement
publié ni installé pendant les tests. Les onze premiers paramètres du bilan
restent compatibles et l'activation Docker de la CI/CD reste exactement Yes.

## 5. Accès web

Recherche technique limitée aux sources GitHub officielles et quatre pages :

- [Releases](https://docs.github.com/en/rest/releases/releases).
- [Assets de release](https://docs.github.com/en/rest/releases/assets).
- [Références Git](https://docs.github.com/en/rest/git/refs).
- [Objets de tag](https://docs.github.com/en/rest/git/tags).

Ces lectures précisent création de release, upload binaire, référence et tag
annoté. Aucun secret ou document privé n'est transmis à la recherche web.
Les tests n'appellent pas les API réelles. Les publications Git conditionnelles
SCM suivent le rapport et sont distinguées dans le bilan final.

## 6. Synthèse globale

La commande github release sélectionne Docker, Debian ou les deux avec
Yes/YES/1. Les paquets suivent les conditions de publication Forgejo : paquet
unique et cohérent, version commune, HEAD synchronisé, tag protégé, release
existante refusée et échec partiel explicite sans rollback automatique.
La CI/CD à six étapes publie désormais Debian GitHub à l'étape 5 sans dépendre
de Docker. Le bilan et les aides sont mis à jour. L'upload vérifie son URL et
ses réponses, et protège les credentials dans des fichiers temporaires 0600.

PROJECT, TECHNICAL, BUILD, README et CHANGELOG sont actualisés ; quatre canons,
carte et registre sont synchronisés, avec Purpose GitHub élargi. AGENTS et DEVOPS
ne nécessitent pas d'édition ; les mêmes outils et runtimes sont utilisés.
La matrice complète figure dans tasks.md. Aucune mise à jour du DIU installé :
ridt utilise les sources du dépôt et rid utilise la version installée.

La conformité stricte globale n'est pas revendiquée : 47 éléments historiques
restent en échec, sans nouveau diagnostic dans les quatre canons concernés.
Un ancien lien README vers
openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTIQUES.md
reste absent et hors périmètre ; les nouveaux liens sont vérifiés.
Aucun BLOCKER.md/BLOCKERS.md dans l'archive : aucun nettoyage nécessaire.
STATISTICS.md global absent : mandater SGS.md pour sa génération initiale.
Le code et les sous-lots définitifs restent à attribuer via ACL.


## Change `add-gitlab-remote-ensure` — openspec/changes/archive/2026-09-07-add-gitlab-remote-ensure/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-libsecret-tools-system-prerequisite` — openspec/changes/archive/2026-09-06-add-libsecret-tools-system-prerequisite/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-module-infos` — openspec/changes/archive/2026-09-28-add-module-infos/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-project-orchestrated-coding` — openspec/changes/archive/2026-10-10-add-project-orchestrated-coding/STATISTICS.md


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


## Change `add-projects-cicd` — openspec/changes/archive/2026-09-23-add-projects-cicd/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-cicd-summary` — openspec/changes/archive/2026-09-23-add-projects-cicd-summary/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-clone` — openspec/changes/archive/2026-09-15-add-projects-clone/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-coding-rules` — openspec/changes/archive/2026-11-11-add-projects-coding-rules/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé SCM-coding-rules-20261111

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé SCM-coding-rules-20261111

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé SCM-coding-rules-20261111

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 2. Types de messages et d’outils

### Relevé SCM-coding-rules-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé SCM-coding-rules-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 4. Commandes

### Relevé SCM-coding-rules-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Tests ciblés | 54 réussis | unittest tests.test_projects tests.test_projects_development_map tests.test_projects_orchestrated_copy |
| Suite globale | 1353 tests, 2 ignorés | unittest discover -s tests |
| Contrôles | bash -n, shellcheck, py_compile et OpenSpec strict réussis | sorties de session |

## 5. Accès web

### Relevé SCM-coding-rules-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 6. Synthèse globale

### Relevé SCM-coding-rules-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |


### Télémétrie native et chronologie des modèles

| Rôle | Agent | Session | Mode |
| --- | --- | --- | --- |
| coder | codex | 01a1ccc1-c953-72b1-bc51-3db658a0cdd9 | direct |

| Mesure | Valeur | Couverture |
| --- | --- | --- |
| command_wall_seconds | 310.494 | native |
| commands | 45 | native |
| commands_failure | 1 | native |
| commands_success | 44 | native |
| duration_seconds | 133.360 | native |
| message_span_seconds | 13.714 | native |
| messages | 12 | native |
| messages_assistant | 12 | native |
| messages_llm | 12 | native |
| reasoning_span_seconds | 33.060 | native |
| tokens_cache_read | 7771264 | native |
| tokens_cache_write | 0 | native |
| tokens_input | 7880228 | native |
| tokens_output | 8598 | native |
| tokens_reasoning | 1506 | native |
| tokens_total | 7888826 | native |
| tool_wall_seconds | 0.0 | native |
| tools | 47 | native |
| tools_llm | 63 | native |

| Début | Fin | Modèle | Fournisseur | Raisonnement |
| --- | --- | --- | --- | --- |
| 2026-11-11T22:38:43.875000+00:00 | 2026-11-11T22:53:39.989000+00:00 | gpt-6.1-terra | openai | medium |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "4": [
          {
            "label": "Tests ciblés",
            "proof": "unittest tests.test_projects tests.test_projects_development_map tests.test_projects_orchestrated_copy",
            "value": "54 réussis"
          },
          {
            "label": "Suite globale",
            "proof": "unittest discover -s tests",
            "value": "1353 tests, 2 ignorés"
          },
          {
            "label": "Contrôles",
            "proof": "sorties de session",
            "value": "bash -n, shellcheck, py_compile et OpenSpec strict réussis"
          }
        ]
      },
      "id": "SCM-coding-rules-20261111",
      "input_sha256": "9b066ce62240625c667ce74e28b1928779bb4238710443786dfd2908c2abbb15",
      "native_telemetry": {
        "format": "cab-native-sgs-1",
        "sessions": [
          {
            "agent": "codex",
            "binding": "codex-ee210a292d3e400ecfc3a5723fcc7518d321ba51b820b7617d6bb80613569dfd",
            "cab_direct": true,
            "change": "add-projects-coding-rules",
            "collector": {
              "source": "codex-native",
              "status": "collecting"
            },
            "coverage": {
              "ccab_claimed": "unavailable",
              "ccab_open": "unavailable",
              "ccab_resolved_retained": "unavailable",
              "ccab_total_retained": "unavailable",
              "command_wall_seconds": "native",
              "commands": "native",
              "commands_api": "unavailable",
              "commands_failure": "native",
              "commands_success": "native",
              "compactions": "unavailable",
              "cost_usd": "unavailable",
              "duration_seconds": "native",
              "files_touched": "unavailable",
              "generation_seconds": "unavailable",
              "message_span_seconds": "native",
              "messages": "native",
              "messages_assistant": "native",
              "messages_llm": "native",
              "messages_user": "unavailable",
              "permissions": "unavailable",
              "preparation_seconds": "unavailable",
              "reasoning_span_seconds": "native",
              "tests": "unavailable",
              "tokens_cache_read": "native",
              "tokens_cache_write": "native",
              "tokens_input": "native",
              "tokens_output": "native",
              "tokens_reasoning": "native",
              "tokens_total": "native",
              "tool_wall_seconds": "native",
              "tools": "native",
              "tools_llm": "native",
              "ttft_seconds": "unavailable",
              "update_cutover_seconds": "unavailable",
              "update_preparation_seconds": "unavailable",
              "wait_seconds": "unavailable",
              "web": "unavailable",
              "web_open": "unavailable",
              "web_search": "unavailable",
              "writes": "unavailable"
            },
            "ended_at": "2026-11-11T22:53:39.989000+00:00",
            "events": 258,
            "host": "hvp1",
            "instance": "codex-01a1ccc1-c953-72b1-bc51-3db658a0cdd9-uid1000",
            "metrics": {
              "command_wall_seconds": "310.494",
              "commands": "45",
              "commands_failure": "1",
              "commands_success": "44",
              "duration_seconds": "133.360",
              "message_span_seconds": "13.714",
              "messages": "12",
              "messages_assistant": "12",
              "messages_llm": "12",
              "reasoning_span_seconds": "33.060",
              "tokens_cache_read": "7771264",
              "tokens_cache_write": "0",
              "tokens_input": "7880228",
              "tokens_output": "8598",
              "tokens_reasoning": "1506",
              "tokens_total": "7888826",
              "tool_wall_seconds": "0.0",
              "tools": "47",
              "tools_llm": "63"
            },
            "mode": "direct",
            "models": [
              {
                "from": "2026-11-11T22:38:43.875000+00:00",
                "model": {
                  "name": "gpt-6.1-terra",
                  "provider": "openai",
                  "reasoning": "medium"
                },
                "source": "codex-native",
                "until": "2026-11-11T22:53:39.989000+00:00"
              }
            ],
            "project": "/home/devops/datas/diu",
            "role": "coder",
            "run": "SCM-coding-rules",
            "session": "01a1ccc1-c953-72b1-bc51-3db658a0cdd9",
            "started_at": "2026-11-11T22:38:43.769Z"
          }
        ]
      },
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `add-projects-debian-build` — openspec/changes/archive/2026-11-02-add-projects-debian-build/STATISTICS.md


# Statistiques — construction Debian générique

## 1. Statistiques générales et décisions

Session directe SCM du 2026-11-02, plan SCM-PROJECTS-BUILD-DEB-20261102-R1.
Un agent Codex ; aucun agent délégué, pilotage, CAB ou télémétrie réservée.
Le change add-projects-debian-build est archivé sous
2026-11-02-add-projects-debian-build ; quatre tâches validées et six exigences
synchronisées (cinq nouvelles, une d'aide). Code non attribué, sans allocation ACL.
Durée totale, tokens, coûts et quotas : N/A, aucune mesure exhaustive disponible.

## 2. Types de messages et d'outils

Échanges de cadrage, validation explicite du périmètre, précision sur la recette
DIU et rappel des aides. Outils utilisés : exécution locale, lecture/recherche,
patches et résolution du prompt SCM. Décompte exhaustif des appels et messages :
N/A, aucun journal instrumenté n'est collecté. Ces catégories ne sont pas des totaux.
Aucun outil de pilotage ou de télémétrie réservé à SCMP n'a été invoqué.

## 3. Fichiers modifiés

Vingt fichiers de livraison dans le périmètre déclaré, rapport inclus.
Les déplacements du dossier par archivage ne sont pas comptés comme de nouveaux
livrables supplémentaires. Les éventuelles modifications préexistantes du projet
ne sont pas attribuées à cette session et ne sont pas incluses dans ce total.

- `root-install-debian.sh`
- `lib/rid-help.sh`
- `modules/projects/debian-build.sh`
- `build/debian-package.json`
- `tests/test_projects_build_deb.py`
- `PROJECT.md`
- `TECHNICAL.md`
- `BUILD.md`
- `README.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `openspec/BATCH_CODES.md`
- `openspec/specs/projects-debian-build/spec.md`
- `openspec/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-projects-debian-build/design.md`
- `openspec/changes/archive/2026-11-02-add-projects-debian-build/proposal.md`
- `openspec/changes/archive/2026-11-02-add-projects-debian-build/specs/projects-debian-build/spec.md`
- `openspec/changes/archive/2026-11-02-add-projects-debian-build/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-projects-debian-build/tasks.md`
- `openspec/changes/archive/2026-11-02-add-projects-debian-build/STATISTICS.md`

Les anciens constructeur diu-packaging.sh, flux cicddiu, AGENTS.md et DEVOPS.md
restent inchangés. Aucune configuration privée ni fichier project.env n'est édité.

## 4. Commandes et validations

| Contrôle exécuté | Résultat |
|---|---|
| Cinq suites concernées, Python DevOps unittest | 120 tests réussis |
| Suite complète avec DIU_TEST_GO déclaré | 1 018 tests réussis en 214,688 s ; aucun échec, erreur ou saut |
| Nouveau moteur après derniers cas de refus et aide générale | 12 tests rejoués, tous réussis en 2,241 s |
| bash -n, chaque fichier Bash modifié | Trois fichiers valides |
| ShellCheck, moteur/aide/point d'entrée | Réussi sans diagnostic |
| Compilation Python du nouveau test | Réussie ; les versions finales sont aussi exécutées par unittest |
| Paquets réels de fixture | Métadonnées, contenu, permissions et propriétaires équivalents pour le DIU ; paquet tiers indépendant réussi |
| OpenSpec global standard avant archivage | 116/116 valides |
| OpenSpec global strict avant archivage | 69 valides, 47 refus hors périmètre sur sources non modifiées |
| Change strict puis deux spécifications canoniques strictes après synchronisation | Réussis |
| openspec archive add-projects-debian-build --yes | Réussi ; six exigences ajoutées et quatre tâches complètes |
| Encodage et nouvelles cibles de liens avant archivage | 17 fichiers UTF-8/LF valides |

Les nombres 120 et 12 sont des sous-ensembles/répétitions : ils ne s'ajoutent pas
aux 1 018 tests de la suite complète pour prétendre un nombre de tests uniques.
Les contrôles de publication Git sont effectués après vérification de ce rapport ;
leur résultat relève du bilan final de session, sans être anticipé ici.
Aucune installation système, release d'artefact ou exécution du bootstrap hôte.

## 5. Accès web

Aucune consultation web effectuée. Les validations de paquets sont locales et
les tests de transports utilisent des fixtures ; elles ne prouvent pas une
publication. Les publications Git éventuelles suivent les étapes conditionnelles
SCM après le rapport et sont distinguées dans le bilan final.

## 6. Synthèse globale

Commande générique, recette DIU, aides et compatibilité historique validées.
Documentation PROJECT, TECHNICAL, BUILD, README et CHANGELOG actualisée ; carte
et registre amendés pour la création, la validation puis l'archivage.
AGENTS et DEVOPS sont inchangés car leurs règles, outils et environnement restent
applicables. Les canons projects-debian-build et rid-help sont synchronisés et
valides en strict. L'activation et l'installation sur la machine restent non vérifiées.

La conformité stricte de tout le dépôt n'est pas revendiquée : 47 diagnostics
hors périmètre persistent. Un ancien lien README vers
openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTIQUES.md
est absent et n'est pas corrigé dans ce change. Les nouveaux liens sont vérifiés.
Aucun BLOCKER.md/BLOCKERS.md n'est présent dans cette archive : aucun nettoyage
n'est nécessaire. Aucun rapport statistique global n'existe à la racine.
Mandater le prompt SGS.md pour générer le fichier STATISTICS.md général à la
racine du projet. L'attribution définitive du code et des sous-lots relève d'ACL.


## Change `add-projects-devops-report-provenance` — openspec/changes/archive/2026-10-09-add-projects-devops-report-provenance/STATISTICS.md


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


## Change `add-projects-forgejo-clone` — openspec/changes/add-projects-forgejo-clone/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `add-projects-forgejo-push-all` — openspec/changes/archive/2026-09-13-add-projects-forgejo-push-all/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-general-update` — openspec/changes/archive/2026-10-02-add-projects-general-update/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-git-commit-all` — openspec/changes/archive/2026-09-15-add-projects-git-commit-all/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-github-clone` — openspec/changes/archive/2026-09-15-add-projects-github-clone/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-github-repository-creation` — openspec/changes/archive/2026-09-11-add-projects-github-repository-creation/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-gitlab-clone` — openspec/changes/archive/2026-09-15-add-projects-gitlab-clone/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-gitlab-update` — openspec/changes/archive/2026-09-07-add-projects-gitlab-update/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-sync` — openspec/changes/archive/2026-09-15-add-projects-sync/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-sync-all` — openspec/changes/archive/2026-09-15-add-projects-sync-all/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-sync-broker` — openspec/changes/archive/2026-10-16-add-projects-sync-broker/STATISTICS.md


# STATISTIQUES — add-projects-sync-broker

Archive : /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker

Conversation source : 01a133bc-a8a2-7b63-be13-34f4a3a860a1. Borne finale : relevé de quota après archivage, avant rédaction du présent rapport.

Périmètre : historique natif de la conversation CGP, tous lots confondus, exposé par read_thread (10 tours, pagination épuisée). Ces agrégats ne sont pas attribués exclusivement à ce change. Les preuves antérieures à cette conversation sont conservées dans tasks.md, mais leurs appels, tokens et coûts ne sont pas reconstitués. Les résultats propres à la reprise d'archivage sont séparés ci-dessous. Le présent rapport, sa création et ses contrôles ultérieurs sont hors de la photographie statistique.

### Agents de codage

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
|---|---|---|---|---|---|---|
| Codex — modèle exact N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
|---|---|---|---|---|---|---|
| Codex — même acteur, rôle de revue | N/A | N/A | N/A | N/A | N/A | N/A |

Un seul acteur Codex est identifié, assurant les corrections directes et la revue. Aucun agent OpenCode piloté ni service CAB n'a été lancé dans le périmètre observé. Les deux tableaux décrivent des rôles du même acteur, sans double comptage. Version, fournisseur, niveau de raisonnement et temps de génération ne sont pas exposés par cette source. TTMT et débit : N/A — sondes périodiques non activées. Relèves prévues/réussies/échouées/manquées : N/A, collecte non activée. Temps de service et son dénominateur cumulé : N/A ; la durée calendaire et les durées d'outils ne sont pas des mesures de génération.

## 1. Statistiques générales et décisions

| Mesure observable | Valeur | Portée |
|---|---|---|
| Tours retournés | 10 | Conversation CGP jusqu’à la borne finale |
| Éléments natifs | 452 (100,0 %) | Messages, raisonnement résumé et opérations |
| Messages textuels | 48 (100,0 %) | 11 développeur + 37 agent |
| Opérations natives | 229 (100,0 %) | Commandes, appels fichiers et outils MCP |
| Approuvées et exécutées avec succès | 217 (94,8 %) | Résultats techniques réussis, pas nombre de confirmations manuelles |
| Refus de permission explicitement observés | 0 (0,0 %) | Aucun refus dans les événements exposés |
| Erreurs techniques | 12 (5,2 %) | 11 validations OpenSpec historiques en échec et 1 appel read_thread avec limite invalide |
| Tokens entrée/sortie/cache | N/A | Télémétrie non fournie |
| Coût et compactions | N/A | Télémétrie non fournie |
| Approbations manuelles ou automatiques détaillées | N/A | Granularité de décision non exposée par les événements natifs |

Convention : « approuvé et exécuté » désigne ici un événement natif autorisé dans le périmètre de travail, terminé avec succès. Cela ne prouve pas une approbation manuelle de chaque appel. Un refus exige une trace explicite ; un code non nul ou un argument invalide est une erreur technique. Les échecs historiques ne sont pas des refus. Les erreurs de scripts d'orchestration antérieures à un événement natif et les appels internes non exposés ne sont pas reconstitués : ces totaux portent uniquement sur la source indiquée.

| Contrôle final de la reprise ciblée | Réussites | Échecs |
|---|---|---|
| Tests projets | 26 (100,0 %) | 0 (0,0 %) |
| Tests aide et parcours projets | 56 (100,0 %) | 0 (0,0 %) |
| Tests copie conditionnelle | 10 (100,0 %) | 0 (0,0 %) |
| Total tests relancés avant archivage | 92 (100,0 %) | 0 (0,0 %) |

Syntaxe Bash et ShellCheck du module projects.sh, compilation des trois fichiers de tests, validations standard et strictes du change et de projects-sync : réussis. L11 passe aussi en standard et strict. Le diagnostic de refus d'archivage a disparu après L12. Tous les contrôles conditionnels finaux ont réussi avant l'archivage. Les 11 échecs OpenSpec agrégés ci-dessus concernent des états historiques avant correction ; l'appel read_thread invalide a été corrigé. Aucun de ces événements ne remplace un contrôle final réussi.

## 2. Types de messages et d’outils

| Type natif | Effectif et part |
|---|---|
| Messages développeur | 11 (2,4 %) |
| Éléments de raisonnement (métadonnées seulement) | 175 (38,7 %) |
| Messages agent | 37 (8,2 %) |
| Exécutions de commandes | 215 (47,6 %) |
| Appels de modification de fichiers | 11 (2,4 %) |
| Appels MCP | 3 (0,7 %) |
| Total | 452 (100,0 %) |

| Phase des messages agent | Effectif et part |
|---|---|
| commentary | 27 (73,0 %) |
| final_answer | 10 (27,0 %) |
| Total | 37 (100,0 %) |

| Type d’opération | Total et part | Succès / taux de ligne | Refus / taux de ligne | Erreur / taux de ligne |
|---|---|---|---|---|
| commandExecution | 215 (93,9 %) | 204 (94,9 %) | 0 (0,0 %) | 11 (5,1 %) |
| fileChange | 11 (4,8 %) | 11 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| mcpToolCall | 3 (1,3 %) | 2 (66,7 %) | 0 (0,0 %) | 1 (33,3 %) |
| Total | 229 (100,0 %) | 217 (94,8 %) | 0 (0,0 %) | 12 (5,2 %) |

Les phases final_answer/commentary sont observables ; les raisons de terminaison API et les types de parties brutes exhaustifs sont N/A. Les éléments de raisonnement sont comptés sans reproduction de leur contenu. Les trois appels MCP dans la photographie sont une lecture d'historique échouée, sa reprise réussie et le relevé de quota réussi ; les lectures statistiques ultérieures sont hors borne.

## 3. Fichiers modifiés

Unité de ce tableau : tentative d'écriture par chemin, issue des événements fileChange. Les 11 appels natifs concernent 27 tentatives sur 17 chemins. Les chemins sont ceux au moment des écritures. Les opérations système internes de l'archivage CLI ne sont pas détaillées en fileChange ; elles sont rapportées séparément après le tableau.

| Chemin absolu complet | Tentatives et part | Approuvées/exécutées et taux | Refusées et taux | Erreurs et taux |
|---|---|---|---|---|
| /home/devops/datas/diu/TECHNICAL.md | 3 (11,1 %) | 3 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/add-projects-sync-broker/specs/projects-sync/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/add-projects-sync-broker/tasks.md | 2 (7,4 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/configure-gitlab-container-registry/specs/implement-projects-gitlab-release/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/configure-gitlab-container-registry/tasks.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/modify-projects-forgejo-push-force-with-lease/specs/forgejo-auth/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/modify-projects-forgejo-push-force-with-lease/specs/implement-projects-forgejo-push/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/restore-forgejo-push-to-create/specs/forgejo-auth/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/restore-forgejo-push-to-create/specs/implement-projects-forgejo-push/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/add-projects-gitlab-update/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/forgejo-auth/spec.md | 4 (14,8 %) | 4 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/git-auth/spec.md | 3 (11,1 %) | 3 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/implement-projects-forgejo-push/spec.md | 2 (7,4 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/implement-projects-gitlab-release/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/projects-sync/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/refine-projects-gitlab-push-config/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/software-management/spec.md | 2 (7,4 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Total | 27 (100,0 %) | 27 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |

Déplacement autorisé : /home/devops/datas/diu/openspec/changes/add-projects-sync-broker vers /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker. Six fichiers sur six conservés par empreinte (100,0 %), zéro altération observée (0,0 %). Fichiers déplacés :

- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/.openspec.yaml
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/README.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/design.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/proposal.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/specs/projects-sync/spec.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/tasks.md

L'archiveur a également mis à jour /home/devops/datas/diu/openspec/specs/projects-sync/spec.md : deux exigences modifiées, aucune ajoutée, supprimée ou renommée. Le nombre d'écritures système internes par fichier est N/A, non exposé par le journal. Le présent STATISTIQUES.md est une création distincte autorisée après la borne statistique ; il ne fait pas partie des 27 tentatives ci-dessus. Les sources et tests liés ont des empreintes inchangées pendant la reprise.

## 4. Commandes

Unité : exécution native de commande, sans compter les interrogations d'un processus comme de nouvelles exécutions. Chaque libellé ci-dessous fait moins de 100 caractères.

| Famille / libellé | Occurrences et part | Succès et taux | Refus et taux | Erreurs et taux |
|---|---|---|---|---|
| Lectures cat | 34 (15,8 %) | 34 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Recherches rg | 20 (9,3 %) | 20 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Lectures sed/tail | 56 (26,0 %) | 56 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Python — lectures et contrôles | 30 (14,0 %) | 30 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| OpenSpec — aide archive | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| OpenSpec — validations | 55 (25,6 %) | 44 (80,0 %) | 0 (0,0 %) | 11 (20,0 %) |
| Syntaxe Bash | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| ShellCheck | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Tests Python directs | 7 (3,3 %) | 7 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Compilation Python | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| OpenSpec — archivage ciblé | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Tests unittest par découverte | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Inventaires find | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Identité et autres lectures | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Autres commandes | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Total | 215 (100,0 %) | 204 (94,9 %) | 0 (0,0 %) | 11 (5,1 %) |

Commandes refusées regroupées : aucune observée, 0/215 (0,0 %). Les 11 erreurs de commandes sont des validations OpenSpec historiques non nulles, pas des refus d'autorisation.

Commande d'archivage exécutée : openspec archive add-projects-sync-broker --yes --json. Une occurrence, succès. Ni --skip-specs ni --no-validate n'ont été utilisés. Parmi les sept invocations Python directes classées dans le journal, une n'exécutait aucun test car le fichier ne possédait pas de lanceur direct ; ses 17 tests ont ensuite été réellement exécutés par découverte unittest. Un code zéro seul n'est donc pas assimilé à une preuve de tests.

## 5. Accès web

| Mesure | Nombre | Part / taux |
|---|---|---|
| Accès de navigation ou recherche web observés | 0 | N/A — dénominateur nul |
| Accès web approuvés et exécutés | 0 | N/A |
| Accès web refusés | 0 | N/A |
| Erreurs d’accès web | 0 | N/A |

Aucune URL effectivement visitée par un outil de navigation/recherche web n'est exposée dans l'historique consulté. Les URL de documentation, de spécifications et de fixtures ne sont pas des accès effectifs. Les lectures MCP de quota et d'historique sont classées parmi les autres outils, sans URL de navigation fournie. Les tests finaux utilisent des données contrôlées et des commandes simulées ; ils ne prouvent aucune publication distante.

## 6. Synthèse globale

| Durée de la session de codage | Valeur |
|---|---|
| Début | 2026-10-13 07:29:26 CEST |
| Fin — après archivage | 2026-10-16 22:35:06 CEST |
| Durée globale (pauses et attentes incluses) | 87 h 05 min 40 s |

Cette durée concerne la conversation CGP mesurée, pas la génération du modèle ni l'ensemble des travaux historiques antérieurs sur le change.

| Mesure du quota Codex sur 7 jours | Horodatage du relevé | Quota utilisé | Réinitialisation |
|---|---|---|---|
| Avant — début de session | N/A — relevé initial absent | N/A | N/A |
| Après — après archivage de la spécification | 2026-10-16 22:35:06 CEST | 10 % | 2026-10-23 20:39:31 CEST |
| Différence après − avant | — | N/A — relevé initial absent | — |

Source : get_usage_limits, limitId=codex, fenêtre de 10080 minutes, compteur utilisé. Aucun relevé initial n'a été recréé rétroactivement. Les quotas sont partagés par le compte ; la valeur finale peut inclure d'autres tâches simultanées. Elle n'est convertie ni en tokens ni en euros, et aucune consommation exclusive de cette tâche n'est déduite.

| Domaine | Opérations et part globale | Succès et taux | Refus et taux | Erreurs et taux |
|---|---|---|---|---|
| Commandes | 215 (93,9 %) | 204 (94,9 %) | 0 (0,0 %) | 11 (5,1 %) |
| Fichiers — appels natifs | 11 (4,8 %) | 11 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Autres outils MCP | 3 (1,3 %) | 2 (66,7 %) | 0 (0,0 %) | 1 (33,3 %) |
| Web | 0 (0,0 %) | 0 (N/A) | 0 (N/A) | 0 (N/A) |
| Total global | 229 (100,0 %) | 217 (94,8 %) | 0 (0,0 %) | 12 (5,2 %) |

Totaux croisés : 215 commandes + 11 appels fichiers + 3 autres outils = 229 opérations ; 217 succès + 0 refus + 12 erreurs = 229. Les 11 appels fichiers couvrent séparément 27 tentatives sur 17 chemins. Les parts sont arrondies à une décimale ; la somme des parts arrondies peut différer légèrement de 100 %, mais les totaux entiers sont vérifiés.

Bilan ciblé : 92/92 tests finaux réussis (100,0 %), six fichiers archivés sans altération (100,0 %), deux exigences principales mises à jour sans extension fonctionnelle. Archivage réussi sous 2026-10-16-add-projects-sync-broker ; contrat principal validé en standard et strict après archivage. Le présent rapport est contrôlé séparément après création : six sections numérotées, UTF-8/LF et cohérence des totaux.

Git : aucune inspection ou modification du dépôt projet exécutée dans cette session CGP ; les éventuelles opérations Git des fixtures restent isolées de ce dépôt. Secrets : aucun fichier réel de secret ou d'identifiant n'a été ouvert ; seules des sources autorisées et fixtures contrôlées ont été utilisées. Aucun déploiement, build, installation, démarrage CAB/OpenCode ou synchronisation de projet réel n'a été réalisé. L'archivage ciblé ne clôt pas la cohérence globale : bootstrap Forgejo, packaging, autres changes et couverture/historique restent soumis aux décisions du développeur.


## Change `add-projects-sync-development-map-if-missing` — openspec/changes/archive/2026-10-28-add-projects-sync-development-map-if-missing/STATISTICS.md


# Statistiques — add-projects-sync-development-map-if-missing

## 1. Statistiques générales et décisions

- Projet : Debian Installeur Unifié (`diu`).
- Date de session : 28 octobre 2026, Europe/Paris.
- Mode : SCM direct ; 1 agent Codex, aucun agent délégué ni pilotage OpenCode.
- Mandat : périmètre proposé puis validation explicite du développeur,
  avec demande de poursuivre jusqu'à la clôture complète du change.
- Objectif : initialiser DEVELOPMENT_MAP.md pendant sync uniquement si absent.
- Change archivé : `2026-10-28-add-projects-sync-development-map-if-missing`.
- Archivage exécuté et réussi ; 2 exigences ajoutées, 1 modifiée, 0 supprimée.
- Durée totale, tokens, coûts et quotas : N/A, aucune télémétrie exhaustive
  disponible ; les durées des tests ci-dessous ne sont pas la durée de session.
- Les étapes conditionnelles de commit et publication suivent ce rapport ;
  leur résultat vérifié est restitué dans le bilan final du chat.

## 2. Types de messages et d'outils

- Messages : demande fonctionnelle, proposition de périmètre, validation
  explicite du développeur, suivis de réalisation et restitution finale.
- Outils utilisés : lecture/recherche ciblée, application de patches, scripts
  Python locaux, exécution Bash, unittest, py_compile, ShellCheck et OpenSpec.
- Git est réservé à l'étape SCM après archivage et vérification de ce rapport.
- Nombre exhaustif de messages, appels et lignes de sortie : N/A, absence
  d'un compteur instrumenté ; aucun total estimé présenté comme mesure.
- Aucune compétence de statistiques de session pilotée invoquée.

## 3. Fichiers modifiés

Inventaire du seul change : 14 fichiers, dont 7 nouveaux et 7 modifiés.
Ce total ne décrit pas d'éventuels autres changements déjà présents dans le
projet et inclus par la règle SCM de commit complet.

| Type | Chemin | Nombre |
| --- | --- | ---: |
| Modifié | modules/projects/projects.sh | 1 |
| Modifiés | tests/test_projects.py ; tests/test_projects_orchestrated_copy.py | 2 |
| Nouveau | tests/test_projects_development_map.py | 1 |
| Modifiés | TECHNICAL.md ; README.md ; CHANGELOG.md | 3 |
| Modifié | openspec/specs/projects-sync/spec.md | 1 |
| Nouveaux, dans cette archive | proposal.md ; design.md ; tasks.md ; review.md ; specs/projects-sync/spec.md ; STATISTICS.md | 6 |
| **Total** | **7 nouveaux + 7 modifiés** | **14** |

L'archivage a déplacé le dossier du change actif vers cette archive ; aucun
fichier existant extérieur au périmètre n'a été supprimé par la réalisation.
Les répertoires temporaires dédiés aux tests ont été nettoyés.
AGENTS.md, PROJECT.md, BUILD.md et DEVOPS.md sont inchangés ; justification
document par document dans [review.md](review.md).

## 4. Commandes et validations

Les chemins d'outils sont ceux de DEVOPS.md : Python DevOps
`/home/devops/python/current/bin/python3` et OpenSpec
`/home/devops/.local/npm/bin/openspec`.

| Contrôle exécuté | Résultat observé |
| --- | --- |
| bash -n modules/projects/projects.sh | Réussi |
| shellcheck modules/projects/projects.sh | Réussi avant et après modification |
| py_compile des 3 fichiers de tests concernés | Réussi, sorties temporaires sous DIU |
| unittest test_projects_development_map.py, passage initial | 8 exécutés, 1 échec de simulation du test de copie |
| unittest test_projects_development_map.py, après correction de la simulation | 8 exécutés, 8 réussis |
| unittest test_projects*.py, premier passage | 322 exécutés en 135,152 s : 319 réussis, 1 échec de droits /etc/gitconfig, 2 ignorés |
| unittest test_*.py, TMPDIR et GIT_CONFIG_SYSTEM isolés sous DIU | 636 exécutés en 157,121 s : 626 réussis, 8 échecs hors périmètre, 2 ignorés |
| Sous-ensemble projets inclus dans ce dernier passage | 322 exécutés : 320 réussis, 0 échec, 2 ignorés |
| OpenSpec change ciblé --strict, avant code puis avant archivage | Réussi |
| OpenSpec --all avant archivage | 68 valides, 2 échecs Forgejo préexistants |
| OpenSpec --all --strict, état initial | 48 valides, 21 échecs préexistants |
| OpenSpec --all --strict avec change actif | 49 valides, mêmes 21 échecs préexistants |
| OpenSpec archive du seul change ciblé | Réussi, +2 exigences et 1 modifiée |
| OpenSpec projects-sync --type spec --strict après archivage | Premier contrôle en échec pour longueur de texte ; formulation condensée à 444 caractères, contrôle suivant réussi |
| OpenSpec --all --strict --report findings après archivage et correction documentaire | 48 valides, mêmes 21 échecs préexistants sur 69 éléments ; aucun nouveau défaut |
| Préservation des scénarios MODIFIED | 6 scénarios existants conservés |
| UTF-8/LF des fichiers du périmètre | Réussi avant archivage ; rapport final vérifié séparément |

Les passages successifs des tests et leurs sous-ensembles se recouvrent :
ne pas les additionner comme tests distincts. Détail des 8 échecs hors périmètre
et preuve de leur indépendance : [review.md](review.md). Aucun test n'a été
désactivé ni assertion affaiblie. Le dépôt global n'est pas déclaré valide.

Nombre exhaustif de commandes : N/A, aucun journal de comptage instrumenté.
Construction de paquet, installation et synchronisation réelle : non
pertinentes pour la validation source de ce change, non exécutées.

## 5. Accès web

Aucun accès web applicatif, recherche internet ou appel fournisseur pour la
réalisation de ce change. Les publications Git conditionnelles SCM sont des
étapes distinctes, avec résultats détaillés dans le bilan final du chat.
Mesures de trafic réseau des outils et des tests : N/A, non instrumentées.

## 6. Synthèse globale

La copie initiale et la préservation de toute entrée destination existante sont
couvertes par les tests, en mode unitaire et groupé. La personnalisation et les
arguments de propriété sont vérifiés ; aucun propriétaire de projet réel ni
effet runtime n'est qualifié par ces tests synthétiques.

Le change ciblé est réalisé, documenté et archivé ; sa spécification courante
passe le contrôle strict. Les défauts globaux indépendants sont conservés et
explicitement signalés. Aucun BLOCKER.md ou BLOCKERS.md n'était présent dans
ce change ; aucun nettoyage de bilan n'est nécessaire.

Totaux vérifiés : 14 fichiers = 7 nouveaux + 7 modifiés ; 636 tests finaux =
626 réussis + 8 échecs hors périmètre + 2 ignorés ; sous-ensemble projets
322 = 320 réussis + 0 échec + 2 ignorés ; 8 nouveaux tests inclus dans ce
sous-ensemble. Voir [review.md](review.md) pour les preuves et limites.


## Change `add-projects-template-all-all` — openspec/changes/archive/2026-10-02-add-projects-template-all-all/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-template-devops` — openspec/changes/archive/2026-10-02-add-projects-template-devops/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-template-devops-all` — openspec/changes/archive/2026-10-02-add-projects-template-devops-all/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-template-devops-headless-browsers` — openspec/changes/archive/2026-10-03-add-projects-template-devops-headless-browsers/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-template-openspec` — openspec/changes/archive/2026-10-02-add-projects-template-openspec/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-projects-template-openspec-all` — openspec/changes/archive/2026-10-02-add-projects-template-openspec-all/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-pytest-system-prerequisite` — openspec/changes/archive/2026-09-05-add-pytest-system-prerequisite/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-rid-contextual-help` — openspec/changes/archive/2026-09-05-add-rid-contextual-help/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-software-apt-apache2-variable` — openspec/changes/archive/2026-11-01-add-software-apt-apache2-variable/STATISTICS.md


# Statistiques — add-software-apt-apache2-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-software-apt-apache2-variable`, code de lot non attribué.
- Décision validée : `SOFTWARES_APT_APACHE2`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière ancienne valeur littérale `APACHE2=0|1` est transférée exactement
  vers `softwares.env` si `SOFTWARES_APT_APACHE2` n’y est pas déjà configurée.
  Une valeur ambiguë bloque avant toute mutation.
- Archivage réussi sous
  `2026-11-01-add-software-apt-apache2-variable`. La spec canonique existait
  déjà au moment de l’archivage; aucune synchronisation additionnelle n’a été
  nécessaire.
- Suite complète DIU avec Python 3.14.10 : 769 tests réussis, 2 ignorés,
  aucun échec.
- Publication et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

15 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_apache2.sh`.
- Tests : `tests/test_software_apt_apache2.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Specs canoniques : `openspec/specs/software-apt-apache2/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_software_apt_apache2 test_config_cleanup` : 36 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 769 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/softwares/software_apt_apache2.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/softwares/software_apt_apache2.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_software_apt_apache2.py` : réussi.
- Validations strictes OpenSpec du change, de `software-apt-apache2` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 70/87 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-software-apt-apache2-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 121/133 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SOFTWARES_APT_APACHE2` est déclaré en `STATIC`, `ENABLE`, scope `softwares`,
défaut `0`. Le nettoyage migre l’ancienne valeur littérale vers le bon fichier
de scope, sans l’exécuter, et préserve une valeur nouvelle déjà configurée. Le
change est archivé; tests, contrôles shell et validations OpenSpec ciblées
réussissent. Publication et relance DIU dans CISMP restent à effectuer. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.


## Change `add-software-apt-desktop-variable` — openspec/changes/archive/2026-11-01-add-software-apt-desktop-variable/STATISTICS.md


# Statistiques — add-software-apt-desktop-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-software-apt-desktop-variable`, code de lot non attribué.
- Décision appliquée : `SOFTWARES_APT_DESKTOP`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `DESKTOP=0|1` est transférée
  exactement vers `softwares.env` si le nouveau nom n'y est pas déjà configuré.
- Les deux consommateurs historiques utilisent le nouveau nom avec repli `0`;
  le comportement du profil de bureau activé est préservé.
- Archivage réussi sous `2026-11-01-add-software-apt-desktop-variable`, avec
  deux spécifications ajoutées et une modifiée.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 797 tests
  réussis, 2 ignorés, aucun échec.
- Le paquet DIU et le prochain essai CISMP restent à publier après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/softwares/infos.sh` et
  `modules/diu/variables/softwares/software_apt_desktop.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_module_infos.py` et
  `tests/test_software_apt_desktop.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `legacy-variable-cleanup`, `module-infos` et
  `software-apt-desktop`.
- Archive : proposition, design, tâches, deux deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  797 tests réussis, 2 ignorés.
- Tests ciblés de déclaration du bureau, migration et informations des
  modules : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/softwares/software_apt_desktop.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_software_apt_desktop.py
  tests/test_config_cleanup.py tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  add-software-apt-desktop-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  add-software-apt-desktop-variable --yes --json` : réussi; deux specs
  ajoutées, une modifiée.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le sélecteur historique `DESKTOP` est maintenant déclaré sous
`SOFTWARES_APT_DESKTOP`, avec un défaut désactivé et transfert exact des
valeurs `0|1`. Le change est archivé; tests, contrôles Bash et validation
OpenSpec stricte réussissent. La publication et la relance du DIU dans CISMP
restent à réaliser. Le rapport général `STATISTICS.md` à la racine est absent;
sa production relève du prompt SGS.


## Change `add-software-management` — openspec/changes/archive/2026-09-05-add-software-management/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-system-crowdsec-agent-variable` — openspec/changes/archive/2026-11-01-add-system-crowdsec-agent-variable/STATISTICS.md


# Statistiques — add-system-crowdsec-agent-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-crowdsec-agent-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_CROWDSEC_AGENT`, `STATIC`, `ENABLE`, scope
  `system`, défaut `0`.
- La dernière valeur historique littérale `CROWDSEC_AGENT=0|1` est transférée
  exactement vers `system.env` si le nouveau nom n’y est pas déjà configuré.
- Une valeur `1` conserve le parcours existant d’installation et de
  configuration de l’agent CrowdSec et du bouncer.
- Archivage réussi sous
  `2026-11-01-add-system-crowdsec-agent-variable`. La spec canonique était déjà
  synchronisée; aucune mise à jour additionnelle n’a été nécessaire.
- Suite complète DIU avec Python 3.14.10 : 777 tests réussis, 2 ignorés,
  aucun échec.
- Publication du paquet et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

15 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_crowdsec_agent.sh`.
- Tests : `tests/test_system_crowdsec_agent.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Specs canoniques : `openspec/specs/system-crowdsec-agent/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_crowdsec_agent test_config_cleanup` : 38 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 777 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_crowdsec_agent.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_crowdsec_agent.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_crowdsec_agent.py` : réussi.
- Validations strictes OpenSpec du change, de `system-crowdsec-agent` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 71/88 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-crowdsec-agent-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 122/134 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_CROWDSEC_AGENT` est déclaré en `STATIC`, `ENABLE`, scope `system`,
défaut `0`. La migration transfère exactement l’ancienne valeur littérale et
donne priorité au nouveau nom. Le consommateur garde le parcours existant pour
la valeur `1`. Le change est archivé; tests, contrôles shell et validations
OpenSpec ciblées réussissent. Publication et relance DIU dans CISMP restent à
faire. Le `STATISTICS.md` général à la racine est absent; le prompt SGS devra
être mandaté pour le générer.


## Change `add-system-debian-apt` — openspec/changes/archive/2026-09-05-add-system-debian-apt/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-system-debian-environnement` — openspec/changes/archive/2026-09-28-add-system-debian-environnement/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-system-debian-release` — openspec/changes/archive/2026-09-05-add-system-debian-release/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-system-drivers-display-link` — openspec/changes/archive/2026-09-28-add-system-drivers-display-link/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-system-drivers-infos` — openspec/changes/archive/2026-09-28-add-system-drivers-infos/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-system-drivers-nvidia-variable` — openspec/changes/archive/2026-11-01-add-system-drivers-nvidia-variable/STATISTICS.md


# Statistiques — add-system-drivers-nvidia-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-drivers-nvidia-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_DRIVERS_NVIDIA`, `STATIC`, `ENABLE`, scope
  `system`, défaut `0`.
- Les consommateurs utilisent le nouveau nom et désactivent les traitements
  si la variable est absente ou vaut `0`.
- La migration conserve la dernière affectation littérale historique
  `DRIVERS_NVIDIA=0|1` si la nouvelle variable n’est pas déjà configurée.
  Une ancienne valeur `1` conserve les traitements NVIDIA existants, qui
  peuvent installer des paquets et configurer DKMS, des modules noyau et
  Docker.
- Suite complète : 686 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-drivers-nvidia-variable`.
- Le paquet Debian n’a pas été reconstruit ici. L’installation/runtime CISMP
  avec cette version attend le prochain changement de version sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_drivers_nvidia.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_drivers_nvidia.py`,
  `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-drivers-nvidia/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-drivers-nvidia/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/diu/variables/system/system_drivers_nvidia.sh modules/system/variables-cleanup.sh` : réussi.
- `shellcheck root-install-debian.sh modules/diu/variables/system/system_drivers_nvidia.sh modules/system/variables-cleanup.sh` : réussi.
- `python3 -m py_compile tests/test_system_drivers_nvidia.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_drivers_nvidia.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 11 tests réussis.
- `python3 -B -m unittest discover -s tests` : 686 tests réussis, 2 ignorés.
- `openspec validate add-system-drivers-nvidia-variable --strict` : réussi
  avant archivage.
- `openspec validate system-drivers-nvidia --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-drivers-nvidia-variable --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration statique, les six consommateurs et la migration historique
sont implémentés, testés et archivés. La suite complète, les contrôles Bash,
ShellCheck et OpenSpec réussissent. La prochaine version du paquet et sa
validation d’exécution dans CISMP restent à faire après le changement de
version sur hvp1. Le commit et les publications Git sont rapportés dans la
synthèse SCM, hors des statistiques de réalisation. Le `STATISTICS.md` global
de la racine est absent ; il n’a pas été créé ici et le prompt SGS devra être
mandaté pour le générer.


## Change `add-system-files2ram-variable` — openspec/changes/archive/2026-11-01-add-system-files2ram-variable/STATISTICS.md


# Statistiques — add-system-files2ram-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-files2ram-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_FILES2RAM`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- Une ancienne valeur littérale `FILES2RAM=0|1` est migrée si le nouveau nom
  n’est pas déjà défini. Une ancienne valeur `1` conserve le traitement
  existant, qui peut supprimer `/var/log/*` lorsque
  `/etc/tmpfiles.d/var2log.conf` est absent.
- Suite complète : 701 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-files2ram-variable`.
- La nouvelle version du paquet et sa validation d’exécution dans CISMP
  restent en attente de la prochaine publication sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_files2ram.sh`.
- Tests : `tests/test_system_files2ram.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-files2ram/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-files2ram/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_files2ram.sh` : réussi.
- `shellcheck` sur ces trois scripts : réussi.
- `python3 -m py_compile tests/test_system_files2ram.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_files2ram.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 16 tests réussis.
- `python3 -B -m unittest discover -s tests` : 701 tests réussis, 2 ignorés.
- `openspec validate add-system-files2ram-variable --strict` : réussi avant
  archivage.
- `openspec validate system-files2ram --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-files2ram-variable --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration `SYSTEM_FILES2RAM`, son consommateur et la migration historique
sont archivés. Les tests ciblés, la suite complète, les contrôles shell et
OpenSpec réussissent. La publication du nouveau paquet et l’exécution runtime
dans CISMP restent à effectuer après le changement de version sur hvp1. Le
commit et les publications Git sont rapportés dans la synthèse SCM, hors des
statistiques de réalisation. Le `STATISTICS.md` global de la racine est absent;
il n’a pas été créé ici et le prompt SGS devra être mandaté pour le générer.


## Change `add-system-fstab-config-six` — openspec/changes/archive/2026-11-01-add-system-fstab-config-six/STATISTICS.md


# Statistiques — add-system-fstab-config-six

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-fstab-config-six`, code de lot non attribué.
- Décision confirmée : `SYSTEM_FSTAB_CONFIG6`, `STATIC`, `ENABLE`, scope
  `system`, défaut `NONE`, dans le même style que les cinq déclarations
  FSTAB précédentes.
- Quand `SYSTEM_FSTAB=1`, l’entrée 6 est ajoutée après l’entrée 5.
- La dernière affectation littérale historique `FSTAB_CONFIG6` est migrée si
  sa nouvelle déclaration n’existe pas déjà. Une syntaxe nécessitant une
  interprétation shell bloque le nettoyage sans mutation ni affichage.
- Suite complète : 694 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-fstab-config-six`.
- La nouvelle version du paquet et sa validation d’exécution dans CISMP
  attendent le prochain changement de version sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_fstab_config6.sh`.
- Tests : `tests/test_system_fstab.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-fstab/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-fstab/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n` sur le point d’entrée, le nettoyage et les six déclarations FSTAB :
  réussi.
- `shellcheck` sur ces mêmes scripts : réussi.
- `python3 -m py_compile tests/test_system_fstab.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_fstab.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 14 tests réussis.
- `python3 -B -m unittest discover -s tests` : 694 tests réussis, 2 ignorés.
- `openspec validate add-system-fstab-config-six --strict` : réussi avant
  archivage.
- `openspec validate system-fstab --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-fstab-config-six --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La sixième déclaration FSTAB, son ajout après CONFIG5 et la migration de
l’ancienne affectation sont testés et archivés. Les tests ciblés, la suite
complète, les contrôles shell et OpenSpec réussissent. La prochaine version
du paquet et la validation runtime dans CISMP restent à faire après le
changement de version sur hvp1. Le commit et les publications Git sont
rapportés dans la synthèse SCM, hors de ces statistiques. Le
`STATISTICS.md` global à la racine est absent ; il n’a pas été créé ici et le
prompt SGS devra être mandaté pour le générer.


## Change `add-system-fstab-configuration` — openspec/changes/archive/2026-11-01-add-system-fstab-configuration/STATISTICS.md


# Statistiques — add-system-fstab-configuration

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-fstab-configuration`, code de lot non attribué.
- Décisions validées : `SYSTEM_FSTAB` en `STATIC`, `ENABLE`, scope `system`,
  défaut `0`; `SYSTEM_FSTAB_CONFIG1` à `SYSTEM_FSTAB_CONFIG5` avec les mêmes
  attributs et défaut `NONE`.
- Les anciennes affectations littérales simples sont migrées vers les nouveaux
  noms si ceux-ci ne sont pas déjà configurés. Les syntaxes qui nécessitent une
  interprétation shell bloquent le nettoyage sans mutation ni affichage.
- Le comportement FSTAB activé et l’usage de `SYSTEM_FSTAB_CONFIG1` par
  FILES2RAM sont préservés. Une ancienne valeur `FSTAB=1` continue d’autoriser
  les écritures existantes dans `/etc/fstab`.
- Suite complète : 694 tests réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-fstab-configuration`.
- La nouvelle version du paquet et sa validation d’exécution dans CISMP
  restent en attente du prochain changement de version sur hvp1.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

23 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_fstab.sh`,
  `system_fstab_config1.sh` à `system_fstab_config5.sh`.
- Tests : `tests/test_system_fstab.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-fstab/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-fstab/spec.md`,
  `specs/legacy-variable-cleanup/spec.md` et `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/diu/variables/system/system_fstab.sh modules/diu/variables/system/system_fstab_config1.sh modules/diu/variables/system/system_fstab_config2.sh modules/diu/variables/system/system_fstab_config3.sh modules/diu/variables/system/system_fstab_config4.sh modules/diu/variables/system/system_fstab_config5.sh modules/system/variables-cleanup.sh` : réussi.
- `shellcheck` sur le point d’entrée, les six déclarations et le nettoyage :
  réussi.
- `python3 -m py_compile tests/test_system_fstab.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_fstab.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 14 tests réussis.
- `python3 -B -m unittest discover -s tests` : 694 tests réussis, 2 ignorés.
- `openspec validate add-system-fstab-configuration --strict` : réussi avant
  archivage.
- `openspec validate system-fstab --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-fstab-configuration --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Les six déclarations, le drapeau FSTAB, les cinq variables de configuration
et leur migration historique sont archivés. La suite complète, les tests
ciblés, les contrôles shell et OpenSpec réussissent. La prochaine version du
paquet et l’exécution runtime dans CISMP restent à effectuer après le
changement de version sur hvp1. Le commit et les publications Git sont
rapportés dans la synthèse SCM, hors des statistiques de réalisation. Le
`STATISTICS.md` global de la racine est absent ; il n’a pas été créé ici et le
prompt SGS devra être mandaté pour le générer.


## Change `add-system-grub-config-variable` — openspec/changes/archive/2026-11-01-add-system-grub-config-variable/STATISTICS.md


# Statistiques — add-system-grub-config-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-grub-config-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_GRUB_CONFIG`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- La dernière valeur littérale historique `GRUB_CONFIG=0|1` est transférée
  vers `SYSTEM_GRUB_CONFIG`, sauf si cette dernière est déjà déclarée. Une
  ancienne valeur `1` reste `1`; une valeur ambiguë bloque le nettoyage sans
  modification ni affichage de son contenu.
- Archivage OpenSpec réussi sous
  `2026-11-01-add-system-grub-config-variable`; une spec ajoutée et une
  modifiée.
- Suite complète avec Python DIU 3.14.10 : 708 tests réussis, 2 ignorés,
  aucun échec.
- La publication du paquet puis sa mise à jour et l’exécution dans CISMP
  restent à faire selon le cycle demandé.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

16 fichiers liés au changement, au cadrage et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_grub_config.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_grub_config.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`.
- Fichier généré déjà modifié avant ce change et inclus au commit complet du
  projet conformément au mandat : `DEVOPS.md`.
- Spécifications canoniques : `openspec/specs/system-grub-config/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_grub_config test_config_cleanup` : 23 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 708 tests réussis, 2 ignorés.
- Essai complet initial avec `python3 -m pytest -q` sous Python système 3.13.5 : 680 réussis, 2 ignorés, 26 échecs dans les tests de venv DevOps (`StopIteration` lors de la recherche d’un `site-packages` existant). Le Python de référence déclaré dans `DEVOPS.md` (3.14.10) a été utilisé ensuite et la suite complète a réussi.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_grub_config.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_grub_config.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_grub_config.py` : réussi.
- Validations strictes OpenSpec du change, de `system-grub-config` et de `legacy-variable-cleanup` : réussies.
- `git diff --check` : réussi.
- Archivage avec `openspec archive add-system-grub-config-variable --yes --json` : réussi; 1 spec ajoutée, 1 modifiée.
- `openspec validate --archived --json --no-interactive` : 113/125 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide (toutes les tâches terminées, aucun diagnostic).
- Validation stricte globale OpenSpec après archivage : 61/78 valides; 17 éléments existants hors de ce change portent des avertissements de scénarios incomplets.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_GRUB_CONFIG` est déclaré et le consommateur GRUB utilise le nouveau
nom avec un repli désactivé. Le nettoyage migre la dernière valeur historique
littérale avant de supprimer l’ancien nom, conserve `1` et préserve une
configuration nouvelle déjà présente. Le change et les specs ciblées sont
valides et archivés; la suite DIU de référence passe. La publication du paquet
et le cycle CISMP restent à effectuer. Le `STATISTICS.md` général à la racine
est absent ; le prompt SGS devra être mandaté pour le générer.


## Change `add-system-ipv6-variable` — openspec/changes/archive/2026-11-01-add-system-ipv6-variable/STATISTICS.md


# Statistiques — add-system-ipv6-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-ipv6-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_IPV6`, `STATIC`, `ENABLE`, scope `system`.
- À la première initialisation, sysctl `disable_ipv6=0` produit et persiste
  `SYSTEM_IPV6=1`; `disable_ipv6=1` produit et persiste `SYSTEM_IPV6=0`.
  Toute erreur ou valeur invalide bloque l’initialisation sans export.
- La dernière valeur littérale historique `IPv6=0|1` est migrée sans altération
  si `SYSTEM_IPV6` n’est pas déjà configurée.
- Archivage réussi sous `2026-11-01-add-system-ipv6-variable`. Les specs étaient
  déjà synchronisées; la commande d’archive a signalé `specsUpdated: false`.
- Suite complète DIU avec Python 3.14.10 : 717 tests réussis, 2 ignorés,
  aucun échec.
- La publication du paquet et la relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

17 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_ipv6.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_ipv6.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `openspec/specs/system-ipv6/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`,
  `openspec/specs/root-shellcheck/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les trois specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_ipv6 test_config_cleanup` : 27 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 717 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_ipv6.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_ipv6.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_ipv6.py` : réussi.
- Validations strictes OpenSpec du change, de `system-ipv6`, `legacy-variable-cleanup` et `root-shellcheck` : réussies.
- Validation OpenSpec stricte globale avant archivage : 63/80 valides; 17 avertissements préexistants dans d’autres changes/specs.
- `openspec archive add-system-ipv6-variable --yes --json` : réussi; aucune mise à jour canonique additionnelle nécessaire.
- `openspec validate --archived --json --no-interactive` : 114/126 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.
- `dpkg --audit` dans CISMP après l’interruption d’une tentative d’installation : aucune anomalie restante.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_IPV6` est déclaré statique avec initialisation depuis l’état sysctl
effectif en l’absence de valeur configurée. La migration conserve exactement
la dernière valeur historique simple et respecte la priorité du nouveau nom.
Le consommateur garde le traitement sysctl existant. Tests, contrôles shell et
validations OpenSpec ciblées réussissent; le change est archivé. Une tentative
ponctuelle précédente ayant fourni `IPv6=1` a été arrêtée pendant la
configuration interactive de `keyboard-configuration` et `console-setup`;
leur configuration a été terminée en mode non interactif, puis `dpkg --audit`
a confirmé une base de paquets saine. La publication et la relance DIU dans
CISMP restent à faire. Le `STATISTICS.md` général à la racine est absent; le
prompt SGS devra être mandaté pour le générer.


## Change `add-system-journald-keep-free-variable` — openspec/changes/archive/2026-11-01-add-system-journald-keep-free-variable/STATISTICS.md


# Statistiques — add-system-journald-keep-free-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-journald-keep-free-variable`, code de lot non
  attribué.
- Décision validée : `SYSTEM_JOURNALD_KEEP_FREE`, `STATIC`, `ENABLE`, scope
  `system`, défaut `1G`.
- Les valeurs acceptées sont un entier, suivi facultativement de `K`, `M`, `G`,
  `T`, `P` ou `E`. Une ancienne valeur littérale valide est migrée exactement
  si la nouvelle variable n’est pas déjà configurée.
- `SystemKeepFree` et `RuntimeKeepFree` utilisent la nouvelle variable.
  `JOURNALD_MAX_USE` reste distinct et hors de ce change.
- Archivage réussi sous
  `2026-11-01-add-system-journald-keep-free-variable`. La spec canonique était
  déjà synchronisée.
- Suite complète DIU avec Python 3.14.10 : 753 tests réussis, 2 ignorés,
  aucun échec.
- Publication et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

15 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_journald_keep_free.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_journald_keep_free.py`,
  `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`.
- Specs canoniques : `openspec/specs/system-journald-keep-free/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_journald_keep_free test_config_cleanup` : 32 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 753 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_journald_keep_free.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_journald_keep_free.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_journald_keep_free.py` : réussi.
- Validations strictes OpenSpec du change, de `system-journald-keep-free` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 68/85 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-journald-keep-free-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 119/131 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_JOURNALD_KEEP_FREE` est déclaré statique avec défaut `1G`; les valeurs
préconfigurées sont validées, et l’ancienne réserve simple est migrée sans
exécution. Les directives `SystemKeepFree` et `RuntimeKeepFree` utilisent le
nouveau nom. Le change est archivé; tests, contrôles shell et validations
OpenSpec ciblées réussissent. Publication et relance DIU dans CISMP restent à
faire. Le `STATISTICS.md` général à la racine est absent; le prompt SGS devra
être mandaté pour le générer.


## Change `add-system-journald-max-use-variable` — openspec/changes/archive/2026-11-01-add-system-journald-max-use-variable/STATISTICS.md


# Statistiques — add-system-journald-max-use-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-journald-max-use-variable`, code de lot non
  attribué.
- Décision validée : `SYSTEM_JOURNALD_MAX_USE`, `STATIC`, `ENABLE`, scope
  `system`, défaut `500M`.
- Les valeurs acceptées sont un entier, suivi facultativement de `K`, `M`, `G`,
  `T`, `P` ou `E`. Une valeur historique simple et valide est migrée sans
  interprétation si le nouveau nom n’est pas déjà configuré.
- `SystemMaxUse` et `RuntimeMaxUse` utilisent la nouvelle variable.
  `JOURNALD_KEEP_FREE` reste distinct et hors de ce change.
- Archivage réussi sous `2026-11-01-add-system-journald-max-use-variable`; la
  spec canonique était déjà synchronisée.
- Suite complète DIU avec Python 3.14.10 : 745 tests réussis, 2 ignorés,
  aucun échec.
- Publication et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

15 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_journald_max_use.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_journald_max_use.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`.
- Specs canoniques : `openspec/specs/system-journald-max-use/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_journald_max_use test_config_cleanup` : 30 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 745 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_journald_max_use.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_journald_max_use.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_journald_max_use.py` : réussi.
- Validations strictes OpenSpec du change, de `system-journald-max-use` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 67/84 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-journald-max-use-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 118/130 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_JOURNALD_MAX_USE` est déclaré statique avec défaut `500M`; les valeurs
préconfigurées sont validées, et l’ancienne limite simple est migrée sans
exécution. Les deux paramètres journald utilisent le nouveau nom. Le change
est archivé; tests, contrôles shell et validations OpenSpec ciblées réussissent.
Publication et relance DIU dans CISMP restent à faire. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.


## Change `add-system-log-rotate-variable` — openspec/changes/archive/2026-11-01-add-system-log-rotate-variable/STATISTICS.md


# Statistiques — add-system-log-rotate-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-log-rotate-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_LOG_ROTATE`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- Une ancienne valeur littérale `LOG_ROTATE=0|1` est migrée exactement si le
  nouveau nom n’est pas déjà configuré. Les formes ambiguës bloquent le
  nettoyage sans mutation ni affichage de leur contenu.
- Le consommateur logrotate utilise le nouveau nom. `LOG_ROTATE_DAILY` et le
  contenu du bloc logrotate restent hors de ce change.
- Archivage réussi sous
  `2026-11-01-add-system-log-rotate-variable`; une spec canonique a été
  modifiée par la synchronisation d’archive.
- Suite complète DIU avec Python 3.14.10 : 725 tests réussis, 2 ignorés,
  aucun échec.
- Publication du paquet et relance de DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

16 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_log_rotate.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_log_rotate.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `openspec/specs/system-log-rotate/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_log_rotate test_config_cleanup` : 28 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 725 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_log_rotate.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_log_rotate.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_log_rotate.py` : réussi.
- Validations strictes OpenSpec du change, de `system-log-rotate` et de `legacy-variable-cleanup` : réussies.
- Validation OpenSpec stricte globale avant archivage : 64/81 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-log-rotate-variable --yes --json` : réussi; une spec canonique modifiée.
- `openspec validate --archived --json --no-interactive` : 115/127 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_LOG_ROTATE` est déclaré en `STATIC`, `ENABLE`, scope `system`, défaut
`0`. La migration conserve exactement l’ancienne valeur littérale et donne la
priorité au nouveau nom. Le consommateur logrotate conserve son comportement
existant, tandis que `LOG_ROTATE_DAILY` reste une variable séparée. Le change
est archivé; tests, contrôles shell et validations OpenSpec ciblées réussissent.
La publication et la relance DIU dans CISMP restent à effectuer. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.


## Change `add-system-no-sleep-variable` — openspec/changes/archive/2026-11-01-add-system-no-sleep-variable/STATISTICS.md


# Statistiques — add-system-no-sleep-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-no-sleep-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_NO_SLEEP`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- La dernière valeur historique littérale `NO_SLEEP=0|1` est transférée
  exactement si `SYSTEM_NO_SLEEP` n’est pas déjà configurée. Une valeur `1`
  conserve les traitements de désactivation de veille; `0` n’efface pas un
  éventuel `nosleep.conf` existant.
- Archivage réussi sous `2026-11-01-add-system-no-sleep-variable`. La spec
  canonique existait déjà; aucune synchronisation additionnelle n’a été
  nécessaire.
- Suite complète DIU avec Python 3.14.10 : 761 tests réussis, 2 ignorés,
  aucun échec.
- Publication et relance DIU dans CISMP restent à effectuer.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

15 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_no_sleep.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_no_sleep.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`.
- Specs canoniques : `openspec/specs/system-no-sleep/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `proposal.md`, `design.md`, `tasks.md`, les deux specs delta et
  `STATISTICS.md`.

## Commandes

- `PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_system_no_sleep test_config_cleanup` : 34 tests réussis.
- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test*.py'` : 761 tests réussis, 2 ignorés.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_no_sleep.sh` : réussi.
- `shellcheck root-install-debian.sh modules/system/variables-cleanup.sh modules/diu/variables/system/system_no_sleep.sh` : réussi, aucun diagnostic.
- `/home/devops/python/current/bin/python3 -m py_compile tests/test_config_cleanup.py tests/test_system_no_sleep.py` : réussi.
- Validations strictes OpenSpec du change, de `system-no-sleep` et de `legacy-variable-cleanup` : réussies.
- Validation stricte OpenSpec globale avant archivage : 69/86 valides; 17 avertissements historiques dans d’autres changes/specs.
- `openspec archive add-system-no-sleep-variable --yes --json` : réussi; aucune synchronisation canonique additionnelle.
- `openspec validate --archived --json --no-interactive` : 120/132 valides; 12 erreurs historiques de tâches incomplètes dans d’autres archives. Cette archive est valide et toutes ses tâches sont terminées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`SYSTEM_NO_SLEEP` est déclaré en `STATIC`, `ENABLE`, scope `system`, défaut
`0`. La migration conserve exactement l’ancienne valeur littérale et donne
priorité au nouveau nom. Le consommateur garde le comportement de
`nosleep.conf`; le défaut désactivé n’efface pas un fichier déjà présent. Le
change est archivé; tests, contrôles shell et validations OpenSpec ciblées
réussissent. Publication et relance DIU dans CISMP restent à faire. Le
`STATISTICS.md` général à la racine est absent; le prompt SGS devra être
mandaté pour le générer.


## Change `add-system-proxy-ca` — openspec/changes/archive/2026-11-01-add-system-proxy-ca/STATISTICS.md


# STATISTIQUES — Déclaration modulaire de SYSTEM_PROXY_CA

## Statistiques générales et décisions

- Projet : Debian Installeur Unifié, racine `/home/devops/datas/diu`.
- Change : `add-system-proxy-ca`, archivé sous `2026-11-01-add-system-proxy-ca`.
- Session : codage direct SCM par Codex. Nom de session et RUN : N/A, aucun identifiant n’a été fourni.
- Date de clôture technique : 2026-11-01. Durée précise : N/A, les horodatages de début et de fin ne sont pas disponibles.
- Périmètre validé par le développeur : migration de `PROXY_CA` vers `SYSTEM_PROXY_CA`, configuration `STATIC`, état `ENABLE`, scope `system`, défaut `0` ; spécification, code, tests, documentation, archivage, commit et publications SCM.
- Décision de migration : l’ancienne valeur n’est pas transférée. Si `PROXY_CA` valait `1`, l’activation doit être reportée explicitement dans `SYSTEM_PROXY_CA`.
- Code de lot : non attribué. Le code n’a pas été inventé ; l’attribution ultérieure relève d’ACL.
- Première exécution LXC : conteneur `100`, Debian 13, paquet `2026.10.30.08.00`. `/root/diu/root-install-debian.sh` exécuté sous root ; code de sortie `1`, erreur `PROXY_CA: unbound variable` à la ligne 1843.
- Suite finale : 672 tests réussis, 2 ignorés. La qualification dans le LXC avec le nouveau paquet reste en attente du changement de version hôte et de sa disponibilité.
- Rapport global : `STATISTICS.md` absent à la racine. Selon SGS, mandater le prompt SGS.md pour générer ce rapport ; il n’a pas été créé ici.

## Types de messages et d’outils

- Mode direct SCM ; aucun agent délégué ou pilote OpenCode n’est intervenu.
- Appels d’outils natifs par catégorie : N/A, aucun décompte télémétrique exhaustif n’a été collecté pour cette session directe.
- Messages par rôle : N/A, aucune télémétrie de messages exploitable n’est disponible.
- Décisions du développeur observées : paramètres de la variable confirmés et périmètre SCM explicitement validé. Aucun mandat CAB n’a été utilisé.

## Fichiers modifiés

- Code : `root-install-debian.sh`, `modules/diu/variables/system/system_proxy_ca.sh`, `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_proxy_ca.py`, `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-proxy-ca/spec.md` (créée), `openspec/specs/legacy-variable-cleanup/spec.md` (mise à jour).
- Archive : `openspec/changes/archive/2026-11-01-add-system-proxy-ca/.openspec.yaml`, `design.md`, `proposal.md`, `tasks.md`, `specs/system-proxy-ca/spec.md`, `specs/legacy-variable-cleanup/spec.md`, `STATISTICS.md`.
- `README.md`, `PROJECT.md`, `BUILD.md` et `DEVOPS.md` : inchangés, leur contenu n’est pas rendu inexact par cette migration ciblée.

## Commandes

| Contrôle ou opération | Résultat |
|---|---|
| Exécution initiale de `/root/diu/root-install-debian.sh` dans le LXC 100 | Échec attendu de diagnostic : code 1, `PROXY_CA` non définie à la ligne 1843. |
| `python3 -B -m unittest discover -s tests -p 'test_system_proxy_ca.py' -v` | 5 tests réussis. |
| `python3 -B -m unittest discover -s tests -p 'test_config_cleanup.py' -v` | 7 tests réussis. |
| `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p 'test_*.py'` | 672 tests réussis, 2 ignorés. |
| `bash -n root-install-debian.sh modules/diu/variables/system/system_proxy_ca.sh modules/system/variables-cleanup.sh` | Réussi. |
| `shellcheck root-install-debian.sh modules/diu/variables/system/system_proxy_ca.sh modules/system/variables-cleanup.sh` | Réussi, aucun diagnostic. |
| `python3 -B -m py_compile tests/test_system_proxy_ca.py tests/test_config_cleanup.py` | Réussi. |
| `openspec validate add-system-proxy-ca --type change --strict --no-interactive` | Réussi après correction du titre de delta. |
| `openspec archive add-system-proxy-ca --yes --json` | Réussi ; archive créée et spécifications canoniques mises à jour. |

La première suite globale avec `/usr/bin/python3` 3.13.5 a échoué sur 26 fixtures de venv ; le test témoin passe avec Python 3.14.10 documenté dans `DEVOPS.md`. Une première suite sous Python 3.14.10 a rencontré un échec de construction Debian isolé ; le fichier `test_diu_packaging.py` a ensuite réussi (11/11) et la dernière suite globale a réussi (672, 2 ignorés). La télémétrie totale de commandes et leurs durées : N/A.

## Accès web

- Aucun appel de recherche ou de consultation web pendant cette session SCM.
- Total d’appels web observé : 0.

## Synthèse globale

La déclaration statique `SYSTEM_PROXY_CA` initialise le défaut `0` dans le scope `system`. Le point d’entrée utilise le nouveau nom avec un repli sûr à `0`, et `config_cleanup` retire l’ancienne affectation avant le chargement historique sans transférer sa valeur. Les tests ciblés, ShellCheck, la syntaxe Bash, la compilation Python et la validation OpenSpec stricte ont réussi ; la suite finale a réussi avec 672 tests et 2 ignorés. L’archivage est effectué. Le commit et les publications Git sont les étapes SCM suivantes. L’installation de la nouvelle version dans le LXC et le cycle suivant restent en attente du changement de version sur l’hôte et de la disponibilité du paquet.


## Change `add-system-proxy-variable` — openspec/changes/archive/2026-11-01-add-system-proxy-variable/STATISTICS.md


# Statistiques — add-system-proxy-variable

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `add-system-proxy-variable`, code de lot non attribué.
- Décision validée : `SYSTEM_PROXY`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- La migration historique ne transfère que les affectations littérales
  `PROXY=0|1`, respecte une déclaration `SYSTEM_PROXY` déjà présente et
  bloque les formes ambiguës sans les afficher.
- Tests de la suite complète : 679 réussis, 2 ignorés, 0 échec.
- Archivage OpenSpec : réussi sous
  `2026-11-01-add-system-proxy-variable`.
- L’archivage a émis un avertissement non bloquant : `proposal.md` ne reprend
  pas les en-têtes `Why` et `What Changes` du modèle. Les deltas et
  spécifications canoniques sont valides ; les deux validations strictes
  canoniques réussissent.
- Le paquet Debian n’a pas été reconstruit dans cette session. L’exécution
  CISMP avec la version précédente a révélé `PROXY: unbound variable` à la
  ligne 1854 ; la recette avec la nouvelle version attend le changement de
  version sur l’hôte.

## Types de messages et d’outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour produire ces totaux sans estimation.

## Fichiers modifiés

18 fichiers liés au changement et à sa clôture documentaire :

- Implémentation : `root-install-debian.sh`,
  `modules/diu/variables/system/system_proxy.sh`,
  `modules/system/variables-cleanup.sh`.
- Tests : `tests/test_system_proxy.py`, `tests/test_config_cleanup.py`.
- Documentation : `CHANGELOG.md`, `TECHNICAL.md`, `DEVELOPMENT_MAP.md`,
  `openspec/BATCH_CODES.md`.
- Spécifications canoniques : `openspec/specs/system-proxy/spec.md`,
  `openspec/specs/legacy-variable-cleanup/spec.md`.
- Archive : `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`,
  `specs/system-proxy/spec.md`, `specs/legacy-variable-cleanup/spec.md` et
  `STATISTICS.md`.

## Commandes

- `bash -n root-install-debian.sh modules/diu/variables/system/system_proxy.sh modules/system/variables-cleanup.sh` : réussi.
- `shellcheck root-install-debian.sh modules/diu/variables/system/system_proxy.sh modules/system/variables-cleanup.sh` : réussi.
- `python3 -m py_compile tests/test_system_proxy.py tests/test_config_cleanup.py` : réussi.
- `python3 -B tests/test_system_proxy.py` : 5 tests réussis.
- `python3 -B tests/test_config_cleanup.py` : 9 tests réussis.
- `python3 -B -m unittest discover -s tests` : 679 tests réussis, 2 ignorés.
- `openspec validate add-system-proxy-variable --strict` : réussi avant
  archivage.
- `openspec validate system-proxy --strict` et
  `openspec validate legacy-variable-cleanup --strict` : réussis après
  synchronisation canonique.
- `openspec archive add-system-proxy-variable --yes` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Les tests ciblés, la suite complète, ShellCheck, Bash et OpenSpec valident le
changement source et documentaire. La déclaration statique, les deux
consommateurs et la migration de configuration sont archivés. Le changement
de version et la nouvelle exécution dans CISMP restent à effectuer après la
mise à jour du paquet sur l’hôte. Les résultats de commit et de publication
SCM sont fournis dans la synthèse de clôture, hors de ces statistiques de
réalisation. Le `STATISTICS.md` global de la racine est absent ; il n’a pas
été créé ici et le prompt SGS devra être mandaté pour le générer.


## Change `add-system-time-zone` — openspec/changes/archive/2026-09-28-add-system-time-zone/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-system-unofficial-apt` — openspec/changes/archive/2026-10-02-add-system-unofficial-apt/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `add-zsh-sshhvp1` — openspec/changes/archive/2026-11-12-add-zsh-sshhvp1/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| gpt-6.1-terra | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle gpt-6.1-terra, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Mandat | SCM direct ; alias sshhvp1 | Demande utilisateur ; RUN SCM-zsh-sshhvp1 enregistré après amorçage. |

## 2. Types de messages et d’outils

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Tests | 1353 tests dont deux ignorés ; 21 ciblés réussis | unittest discover et tests ciblés. |

## 3. Fichiers modifiés

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | Déclaration GLOBAL Zsh, tests, documentation et OpenSpec | Git diff et artefacts du change. |

## 4. Commandes

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1351 | Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides. |
| Tests finaux réussis | 1351 | Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides. |
| Tests finaux échoués | 0 | Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides. |
| Fichiers ayant passé un contrôle syntaxique | 2 | Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides. |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 1 | Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides. |
| Validations OpenSpec strictes échouées | 0 | Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides. |
| Tâches OpenSpec prouvées et terminées | 2 | Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides. |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Intégration | Zsh Debian avec SSH simulé | Syntaxe, paramètres, environnement X11 et priorité des alias personnels. |

## 5. Accès web

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Télémétrie native | N/A | Chemin natif exact non exposé ; aucun contenu de session recherché. |

## 6. Synthèse globale

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Livraison | CICD prévue après rapport | Mandat utilisateur et SCM. |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "gpt-6.1-terra",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1"
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [
              {
                "line": 1,
                "note": "Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "2"
          },
          "tasks": {
            "evidence": [
              {
                "line": 1,
                "note": "Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "2"
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1351"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Validation finale : 1353 tests dont deux ignorés, 21 ciblés, Bash et Python contrôlés, 122 spécifications valides."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1351"
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Mandat",
            "proof": "Demande utilisateur ; RUN SCM-zsh-sshhvp1 enregistré après amorçage.",
            "value": "SCM direct ; alias sshhvp1"
          }
        ],
        "2": [
          {
            "label": "Tests",
            "proof": "unittest discover et tests ciblés.",
            "value": "1353 tests dont deux ignorés ; 21 ciblés réussis"
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Git diff et artefacts du change.",
            "value": "Déclaration GLOBAL Zsh, tests, documentation et OpenSpec"
          }
        ],
        "4": [
          {
            "label": "Intégration",
            "proof": "Syntaxe, paramètres, environnement X11 et priorité des alias personnels.",
            "value": "Zsh Debian avec SSH simulé"
          }
        ],
        "5": [
          {
            "label": "Télémétrie native",
            "proof": "Chemin natif exact non exposé ; aucun contenu de session recherché.",
            "value": "N/A"
          }
        ],
        "6": [
          {
            "label": "Livraison",
            "proof": "Mandat utilisateur et SCM.",
            "value": "CICD prévue après rapport"
          }
        ]
      },
      "id": "01a1c6d4-6541-7fb1-82f3-997b307df2a2",
      "input_sha256": "5047e177eaa48742af2a66ae56852b4cf92283047637e1e5f6f9132994b53614",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->

<!-- CAB_STATISTICS_CURRENT_V1 -->

Change : `add-zsh-sshhvp1` · état local : `archived`. Les valeurs absentes restent N/A.

### 1. Statistiques générales et décisions

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |


| Rôle | Agent | Modèle | Raisonnement |
| --- | --- | --- | --- |


Provenance : change-periods:4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945

### 2. Messages et outils

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |


### 3. Fichiers et tâches

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |


### 4. Commandes et validations

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | 2 | Cases locales de tasks.md ; ne valent pas validation du RUN. |


### 5. Accès web

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |


### 6. Synthèse et couverture

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |


<!-- CAB_STATISTICS_CURRENT_END -->
<!-- CAB_STATISTICS_DOCUMENT_V1 {"content_sha256": "860b32756bafc5f31b573f1da9b472bf515d9a9244821c11c7dc6bd02ef3e168", "generated_at": "2026-11-13T13:43:41.735225+00:00", "revision": "860b32756bafc5f31b573f1da9b472bf515d9a9244821c11c7dc6bd02ef3e168", "scope": "change"} -->


## Change `adjust-project-sync-local-resources` — openspec/changes/archive/2026-11-06-adjust-project-sync-local-resources/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé sync-local-resources-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| GPT-6 | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé sync-local-resources-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé sync-local-resources-2026-11-06

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle GPT-6, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Périmètre | Synchronisation des ressources locales ; session directe sans orchestrateur. | Contrat projects-sync et tests. |

## 2. Types de messages et d’outils

### Relevé sync-local-resources-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé sync-local-resources-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 4. Commandes

### Relevé sync-local-resources-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Contrôles | 50 tests ciblés ; bash -n, ShellCheck, py_compile et OpenSpec strict réussis. | Sorties du 2026-11-06. |

## 5. Accès web

### Relevé sync-local-resources-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 6. Synthèse globale

### Relevé sync-local-resources-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Limites | Mesures natives indisponibles ; aucune synchronisation réelle ni CI/CD. | Collecte initiale non disponible. |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "GPT-6",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Périmètre",
            "proof": "Contrat projects-sync et tests.",
            "value": "Synchronisation des ressources locales ; session directe sans orchestrateur."
          }
        ],
        "4": [
          {
            "label": "Contrôles",
            "proof": "Sorties du 2026-11-06.",
            "value": "50 tests ciblés ; bash -n, ShellCheck, py_compile et OpenSpec strict réussis."
          }
        ],
        "6": [
          {
            "label": "Limites",
            "proof": "Collecte initiale non disponible.",
            "value": "Mesures natives indisponibles ; aucune synchronisation réelle ni CI/CD."
          }
        ]
      },
      "id": "sync-local-resources-2026-11-06",
      "input_sha256": "ebc08fb432a1f554a667f3ec3d2aa05c3a7fef705031866ce32300efc76862c6",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `align-devops-tests-environment-flags` — openspec/changes/archive/2026-10-24-align-devops-tests-environment-flags/STATISTICS.md


# STATISTIQUES — Alignement des indicateurs de tests DevOps

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`).
- Racine : `/home/devops/datas/diu`.
- Date : 24 octobre 2026, Europe/Paris.
- Session : correction SCM directe, dans la continuité du périmètre autonome
  approuvé avec cycle OpenSpec et rapport d'archive.
- Change : `align-devops-tests-environment-flags`.
- Archive : `2026-10-24-align-devops-tests-environment-flags`.
- Demande : aligner les deux nouvelles variables sur les lignes existantes,
  plutôt que reformater toutes les variables. L'exemple fourni précise un
  retrait de huit espaces avant `export`.
- Preuves : [proposition](proposal.md), [conception](design.md),
  [tâches](tasks.md), [delta](specs/devops-tests-environment-flags/spec.md),
  [canon](../../../specs/devops-tests-environment-flags/spec.md) et sorties
  des commandes de cette session.

Aucune configuration locale réelle n'est lue ou modifiée. Les exemples et
tests ne conservent que le format demandé et des données synthétiques.
L'archive initiale reste historique et n'est pas réécrite.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Suite ciblée unittest | 0,174 s selon unittest |
| Durée complète de la correction | N/A : absence de chronométrage global |
| Tokens, coût, CPU et mémoire | N/A : absence de collecte instrumentée |
| Messages et outils exhaustifs | N/A : absence d'export de télémétrie |
| Approbations CAB | N/A : session SCM directe sans pilotage |

La compétence de statistiques SCMP n'est pas invoquée. Les sous-tests ne
sont pas comptés comme méthodes unittest supplémentaires.

## 3. Fichiers et comportement livré

| Catégorie | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 2 | modules/diu/variables/environnements/env_devops_tests_docker.sh ; env_devops_tests_lxc.sh |
| Tests existants modifiés | 1 | tests/test_env_devops_tests.py |
| Documents existants modifiés | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/devops-tests-environment-flags/spec.md |
| Documents de la nouvelle archive | 5 | proposal.md ; design.md ; tasks.md ; specs/devops-tests-environment-flags/spec.md ; STATISTIQUES.md |
| **Total du périmètre de cette correction** | **12** | **2 + 1 + 3 + 1 + 5** |

Sept fichiers existants sont modifiés et cinq nouveaux documents composent
l'archive. Les quatre artefacts actifs sont déplacés par OpenSpec ; le rapport
est ajouté ensuite. Aucun autre fichier n'est supprimé ou renommé par l'agent.

Les nouvelles lignes de `ENV_DEVOPS_TESTS_DOCKER` et `ENV_DEVOPS_TESTS_LXC`
commencent par huit espaces ASCII avant `export`. La désactivation reconnaît
les lignes sans retrait, avec espaces ou avec tabulations, en conservant les
noms voisins et l'autre indicateur. Les défauts restent `0`, les valeurs
existantes sont préservées et les lignes déjà présentes ne sont pas migrées.

`DEVOPS.md` a changé en parallèle : son en-tête généré indique un nouveau
relevé UTC, `2026-10-24T14:03:49Z`. Ce fichier n'est pas modifié par l'agent et
reste hors du total de ses écritures. Sa version documentaire est `0.7` et
son chemin OpenSpec reste `/home/devops/.local/npm/bin/openspec`.

## 4. Tests et vérifications

| Suite | Méthodes | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| tests/test_env_devops_tests.py | 10 | 10 | 0 | 0 | 0 |

```bash
python3 -B -m unittest discover -s tests -p test_env_devops_tests.py -v
```

Les neuf méthodes préexistantes sont conservées et une méthode est ajoutée
pour la suppression des lignes indentées. Le test d'initialisation exige
exactement huit espaces. Les suppressions sont vérifiées avec retrait vide,+huit espaces et tabulation. Les tests existants continuent de vérifier les
valeurs configurées, l'export, l'idempotence, les erreurs et le chargeur.

| Vérification | État et résultat |
| --- | --- |
| bash -n de chaque déclaration | Exécutée et réussie, deux commandes distinctes |
| ShellCheck des deux déclarations | Exécutée et réussie, aucun diagnostic |
| python3 -m py_compile du test | Exécutée et réussie, cache isolé sous le dépôt puis nettoyé |
| Change OpenSpec strict | Exécutée et réussie avant code/tests, puis avant archivage |
| Canon OpenSpec strict | Exécutée et réussie après archivage |
| OpenSpec global strict initial et final | Exécutée et échouée : 68 éléments, 46 valides et 22 en échec ; mêmes éléments et mêmes diagnostics avant/après |
| OpenSpec global standard | Non exécutée pour cette correction ; aucun résultat historique présenté comme actuel |
| Concordance delta/canon | Exécutée et réussie : deux exigences modifiées identiques au delta, six exigences et neuf scénarios finaux |
| Intégrité des artefacts archivés | Exécutée et réussie : quatre empreintes conservées après déplacement |
| Intégrité code/tests/documents avant et après archivage | Exécutée et réussie : les six fichiers qualifiés sont inchangés par l'archivage |
| UTF-8/LF sans BOM | Exécutée et réussie sur les onze fichiers précédant le rapport ; contrôle final incluant le rapport |
| Temporaires | Aucun résidu des préfixes tests devops et compile align |
| Suite complète et tests Docker/LXC réels | Non exécutés : hors périmètre de cette correction de format |

Les commandes OpenSpec emploient `OPENSPEC_TELEMETRY=0` et le chemin explicite
`/home/devops/.local/npm/bin/openspec`. Le contrôle global utilise
`validate --all --strict --json --no-interactive` ; le canon ciblé utilise
`validate devops-tests-environment-flags --type spec --strict --no-interactive`.

Un premier contrôle des empreintes a signalé la modification concurrente de
DEVOPS.md. Son en-tête et son chemin OpenSpec ont été relus sans écrasement.
Un contrôle auxiliaire de concordance a également échoué à cause d'une
expression régulière trop large dans le vérificateur ; sa correction limitée
au vérificateur a permis de confirmer les deux blocs d'exigences. Aucun de
ces échecs de contrôle n'a modifié les sources ou les attentes des tests.

## 5. Cohérence documentaire et archivage

| Élément SCM | État et preuve |
| --- | --- |
| Projet réel | Deux générateurs alignés, suppression compatible avec les retraits ; dix méthodes réussies |
| AGENTS.md | Inchangé par l'agent ; règles de périmètre et rapport respectées |
| PROJECT.md | Inchangé ; responsabilités des modules et architecture préservées |
| TECHNICAL.md | Section Indicateurs de tests DevOps complétée avec le retrait, la suppression et l'absence de migration |
| BUILD.md | Inchangé ; aucune modification de construction, de dépendance ou de packaging |
| DEVOPS.md | Régénération concurrente constatée, conservée sans intervention de l'agent ; chemin OpenSpec inchangé |
| README.md | Présentation des deux indicateurs complétée avec les huit espaces et la conservation des lignes existantes |
| CHANGELOG.md | Entrée Unreleased ajoutée sans nouvelle version de publication |
| openspec/specs/ | Initialisation et Désactivation modifiées ; quatre autres exigences conservées |

Commande d'archivage exécutée avec succès :

```bash
OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive align-devops-tests-environment-flags --yes
```

La commande constate les tâches complètes, annonce deux exigences modifiées,
zéro ajout/suppression/renommage, synchronise le canon puis confirme l'archive
ciblée. Le change actif est absent après l'opération.

| Résultat | Nombre |
| --- | ---: |
| Tâches de réalisation et qualification terminées | 6 sur 6 |
| Exigences finales | 6 |
| Exigences modifiées | 2 |
| Exigences conservées | 4 |
| Scénarios finaux | 9 |
| Changes archivés | 1 |
| Documents finaux de l'archive | 5 |

Le contrôle final porte sur les six sections, les liens locaux, UTF-8/LF sans
BOM, l'intégrité des sources et artefacts, les tâches cochées et les totaux :
12 = 2 + 1 + 3 + 1 + 5 = 7 + 5 ; 10 = 9 + 1 ; 10 = 10 + 0 + 0 + 0 ;
6 = 2 + 4. Aucun archivage futur n'est coché par anticipation.

## 6. Limites et état terminal

Correction réalisée, testée, documentée, synchronisée et archivée. Le rapport
accompagne cette seule correction ; l'archive initiale reste historique.

Les 22 éléments en échec OpenSpec strict sont préexistants et leurs
diagnostics restent identiques. Ils concernent notamment les deux changes
Forgejo incomplets, le change d'architecture avec avertissement et 19
spécifications avec avertissements. Aucun n'est corrigé dans ce périmètre.
La spécification ciblée est valide en mode strict.

Seules les futures lignes générées adoptent les huit espaces. Les valeurs
et lignes déjà présentes dans la configuration réelle restent intactes.
Il n'y a pas de reformatage global, migration, déploiement, exécution de tests
Docker/LXC réels, inspection Git, commit, push, branche, tag ou release.
Aucun service partagé ou processus OpenCode n'est redémarré ou arrêté.


## Change `allow-gitlab-self-signed-tls` — openspec/changes/archive/2026-09-07-allow-gitlab-self-signed-tls/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `allow-git-provider-credentials-0660` — openspec/changes/archive/2026-10-26-allow-git-provider-credentials-0660/STATISTICS.md


# STATISTIQUES — Identifiants Git en 0600 ou 0660

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, `diu`, /home/devops/datas/diu.
- Session SCM directe ; date utilisateur : 26 octobre 2026, Europe/Paris.
- Change : `allow-git-provider-credentials-0660`.
- Archive : `2026-10-26-allow-git-provider-credentials-0660`.
- Périmètre proposé puis explicitement approuvé par « Je valide ».
- Preuves : commandes de cette session, [proposition](proposal.md),
  [conception](design.md), [tâches](tasks.md), [revue](review.md), cinq deltas
  sous specs/ et cinq spécifications canoniques synchronisées.

Acceptation exacte de 0600 et 0660 pour les six fichiers username/token des
providers Forgejo, GitHub et GitLab. Les fichiers existants gardent leur
contenu et leur mode ; les autres modes restent refusés avant lecture.
Nouveaux identifiants et secrets temporaires restent en 0600. Le groupe peut
lire et modifier un identifiant en 0660 ; aucune permission système ou ACL
n'est modifiée. Aucun push de tools-codex ni déploiement du DIU n'est exécuté.

## 2. Durées et mesures disponibles

| Mesure | Valeur et source |
| --- | --- |
| Première suite projets | 109,340 s, sortie unittest : 283 tests |
| Dernière suite dédiée | 2,709 s, sortie unittest : 14 tests |
| Campagne finale combinée | 111,256 s, sortie unittest : 297 tests |
| Durée totale de conversation ou session | N/A : pas de mesure continue depuis le début |
| Tokens, coût, CPU et mémoire | N/A : pas d'instrumentation dédiée |
| Messages et appels d'outils exhaustifs | N/A : pas d'export de télémétrie |
| Approbations CAB et télémétrie OpenCode | N/A : session SCM directe, sans CAB ni skill de statistiques SCMP |

Les durées sont celles des passages distincts, non une somme de temps total.
Les sous-tests ne sont pas comptés comme méthodes supplémentaires.

## 3. Fichiers et comportement livré

| Catégorie | Nombre | Chemins |
| --- | ---: | --- |
| Code existant modifié | 3 | lib/forgejo-auth.sh ; lib/github-auth.sh ; lib/gitlab-auth.sh |
| Test créé | 1 | tests/test_provider_credential_permissions.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Canon OpenSpec modifié | 5 | forgejo-auth ; forgejo-release ; implement-projects-forgejo-push ; implement-projects-github-push ; implement-projects-gitlab-push |
| Delta actif voisin aligné | 1 | modify-projects-forgejo-push-force-with-lease/specs/forgejo-auth/spec.md, une phrase de permission |
| Fichiers dans la nouvelle archive | 10 | proposal.md ; design.md ; tasks.md ; review.md ; cinq specs/*/spec.md ; STATISTIQUES.md |
| **Total du correctif** | **23** | **3 + 1 + 3 + 5 + 1 + 10** |

Douze fichiers préexistants modifiés et onze nouveaux fichiers à leur
emplacement final. Les neuf fichiers du change ont été déplacés par OpenSpec,
avec conservation de leurs SHA-256 avant/après. Le rapport est créé ensuite.
La modification préexistante de DEVOPS.md est conservée sans édition par la
session ; elle n'est pas comptée dans ces 23 fichiers. Son inclusion au commit
global conditionnel relève du prompt SCM, pas du correctif fonctionnel.

## 4. Tests et vérifications

| Passage | Exécutés | Réussis | Échoués | Ignorés |
| --- | ---: | ---: | ---: | ---: |
| Lecteurs seuls | 5 | 5 | 0 | 0 |
| Dédié final | 14 | 14 | 0 | 0 |
| Première suite projets sans isolation système Git | 283 | 280 | 1 | 2 |
| Test de configuration Git rejoué avec isolation | 1 | 1 | 0 | 0 |
| Campagne finale projets + suite dédiée | 297 | 295 | 0 | 2 |

Ces passages se recouvrent et leurs nombres ne doivent pas être additionnés.
Le passage de construction des fixtures d'intégration (13 méthodes) a échoué
avec 29 échecs de sous-tests et deux erreurs : les répertoires héritaient du
bit setgid du dépôt partagé. Le scratch propre aux tests est maintenant
explicitement isolé en 0700, puis les mêmes assertions exactes ont réussi.
Aucun comportement applicatif ni attente de sécurité n'a été affaibli.

La première suite projets a échoué sur
`test_git_local_update_preserves_mode_without_asking` : écriture refusée dans
/etc/gitconfig. Le test ne charge aucune bibliothèque modifiée. La campagne
finale redirige GIT_CONFIG_SYSTEM vers une fixture temporaire sous le projet,
sans changer les tests ni la configuration Git hôte. Les deux tests Go sont
ignorés faute de binaire dans le PATH de test ou DIU_TEST_GO ; ils sont hors
du comportement corrigé. Leurs identifiants sont :
`test_real_go_version_from_inaccessible_caller_directory` et
`test_runuser_execution_envelope_preserves_arguments_and_changes_child_directory`.

La campagne finale emploie /home/devops/python/current/bin/python3 -B,
unittest.TestLoader.discover sur test_projects*.py et
sur test_provider_credential_permissions.py, regroupés en une TestSuite.

La suite dédiée vérifie les six lecteurs et douze modes refusés, les fichiers
absents/vides et stat en échec, 24 parcours push/fetch avec modes privés,
partagés ou mixtes, les clones GitHub/GitLab existants, leur initialisation,
les API Forgejo/GitHub et le registre GitLab. Les lecteurs et le cœur Git sont
réels ; Git, curl et Docker sont des transports simulés sans réseau.
Les secrets fictifs sont vérifiés hors arguments et sorties ; fichiers privés
Git/curl et DOCKER_CONFIG sont nettoyés après succès et échec.

| Contrôle | Résultat observé |
| --- | --- |
| bash -n des trois bibliothèques et cinq scripts de fixtures | Exécuté et réussi |
| Compilation Python py_compile | Exécutée et réussie avec le Python DevOps |
| ShellCheck des trois bibliothèques | Exécuté, code 1 : Forgejo/GitHub sans diagnostic ; GitLab garde SC2295 ligne 30 et trois SC2034 lignes 44–46 |
| Comparaison ShellCheck avant/après | Réussie : diagnostics et positions intégralement identiques, aucun ajout ni exclusion |
| Change OpenSpec strict avant code et avant archive | Exécuté et réussi sans diagnostic |
| Global OpenSpec strict initial | Exécuté, code 1 : 68 éléments, 46 valides, 22 en échec |
| Global strict avec le change actif | Exécuté, code 1 : 69 éléments, 47 valides, mêmes diagnostics préexistants |
| Global strict après archive | Exécuté, code 1 : 68 éléments, 46 valides, 22 en échec ; aucun diagnostic ajouté, deux avertissements de longueur retirés dans les exigences Forgejo release modifiées |
| Global standard final | Exécuté, code 1 : 68 éléments, 66 valides ; deux changes Forgejo préexistants en échec, 60 canons valides |
| Concordance deltas/canons | Réussie : cinq capacités, sept exigences et 40 scénarios, hors lignes vides normalisées par OpenSpec |
| UTF-8/LF, sans BOM, blancs finaux et fin de fichier | Réussi sur les fichiers du périmètre avant archive ; contrôle étendu à l'archive et au présent rapport |
| Suite complète du dépôt | Non exécutée : suites projets et authentification retenues |
| Publications réelles, Docker/LXC réels, installation | Non exécutés : correctif des sources et fixtures isolées |

## 5. Cohérence documentaire et archivage

| Document | État et preuve |
| --- | --- |
| Projet réel | Six lecteurs corrigés, transports simulés et 295 tests finaux réussis ; pas de déploiement |
| AGENTS.md | Inchangé : règles OpenSpec, secrets et validation appliquées |
| PROJECT.md | Inchangé : architecture modulaire conservée, session directe autorisée par SCM |
| TECHNICAL.md | Fichiers d'identifiants décrit 600/660, partage de groupe et protection temporaire |
| BUILD.md | Inchangé : build et packaging non concernés |
| DEVOPS.md | Non édité, modification préexistante conservée ; chemins Python/OpenSpec utilisés |
| README.md | Ajout des règles publiques 0600/0660 |
| CHANGELOG.md | Entrée Unreleased, sans version ou publication inventée |
| openspec/specs/ | Cinq canons synchronisés, sept exigences et 40 scénarios conformes aux deltas |

Commande d'archivage exécutée et réussie sous devops :

```bash
/home/devops/.local/npm/bin/openspec archive allow-git-provider-credentials-0660 --json --yes
```

Un seul archivage réussi. Résultat OpenSpec : zéro ajout, sept modifications,
zéro suppression ou renommage d'exigence ; specsUpdated=true. Change actif
absent, archive présente, neuf empreintes conservées et cinq tâches cochées.
Aucun BLOCKER.md ou BLOCKERS.md ni lien correspondant : nettoyage non requis.

Totaux vérifiables : 23 = 3 + 1 + 3 + 5 + 1 + 10 ;
297 = 295 + 0 + 2 ; cinq tâches sur cinq ; sept exigences, 40 scénarios ;
un change archivé, dix fichiers dans son archive, six sections dans ce rapport.

## 6. Limites et clôture

Le correctif des sources, ses tests, les cinq spécifications et la
documentation sont cohérents dans le périmètre validé. Les quatre diagnostics
ShellCheck GitLab et les 22 éléments OpenSpec strict en échec sont préexistants.
En mode standard, les deltas des changes
modify-projects-forgejo-push-force-with-lease et restore-forgejo-push-to-create
omettent toujours deux scénarios du canon ; cette correction n'est pas autorisée.
Le premier reçoit uniquement l'alignement de sa phrase de permissions.
Aucune réussite globale du dépôt n'est affirmée.

Aucun fichier d'identifiant réel n'a été ouvert ou modifié ; le correctif n'est
pas installé dans /root/diu. Les commandes rid utilisant cette installation
nécessitent la livraison habituelle du DIU avant de profiter du correctif.
Le commit global et les publications conditionnelles SCM suivent la
vérification de ce rapport ; leurs résultats réels sont restitués dans le
bilan final, sans les présumer ici.


## Change `allow-human-sudo-devops` — openspec/changes/archive/2026-10-02-allow-human-sudo-devops/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `allow-human-sudo-docker` — openspec/changes/archive/2026-10-02-allow-human-sudo-docker/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `authenticate-diu-github-updates` — openspec/changes/archive/2026-11-03-authenticate-diu-github-updates/STATISTICS.md


# Statistiques — authenticate-diu-github-updates

## Statistiques générales et décisions

- Session directe du 2026-11-03, coordonnée avec l'autre chat DIU ; change archivé, code non attribué.
- Le lecteur de jeton GitHub existant permet la lecture des releases et le téléchargement des assets privés ; les accès publics sans jeton restent anonymes.
- Version locale : 1.0.6. La construction et les publications de paquets restent à la charge du développeur.
- Durée totale et tokens : N/A, mesures exhaustives indisponibles.

## Types de messages et d'outils

- Exécution directe par Codex ; messages de coordination entre chats à la demande du développeur. Aucun agent de codage délégué.
- Décompte exhaustif des messages et outils : N/A, journal agrégé indisponible.

## Fichiers modifiés

- Application : `modules/diu/update.sh` ; tests : `tests/test_diu_github_private_update.py`.
- Documents : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`.
- OpenSpec : ce change archivé et `openspec/specs/diu-package-update/spec.md`.
- `PROJECT_VERSION` dans `project.env` a été actualisée localement ; fichier hors Git. Volume de lignes et inventaire Git : N/A à la rédaction.

## Commandes

- Suite globale avec le Python DevOps : 1 088 tests exécutés, dont 2 ignorés, sans échec ; durée 261,577 secondes.
- 66 tests ciblés réussis, dont cinq tests GitHub privés avec jeton factice : accès, permissions, refus, absence de jeton et redirection sans transfert du jeton. Syntaxe Bash, ShellCheck, compilation Python et UTF-8/LF réussis.
- Validation stricte OpenSpec du change et de la spécification synchronisée réussie ; archivage effectué.
- Total exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

L'API GitHub a été consultée en lecture seule par le plugin connecté : les releases privées exposent les identifiants d'assets attendus. Les tests d'authentification utilisent des jetons factices et un serveur local ; ils ne valident pas les identifiants locaux de production.

## Synthèse globale

Correction, documentation et tests validés ; change archivé. Aucun test d'installation réelle ni lecture des secrets locaux de production n'a été effectué. Les opérations Git locales relèvent de la clôture de session ; aucune publication distante n'est engagée ici.


## Change `background-zsh-sshhvp1` — openspec/changes/archive/2026-11-12-background-zsh-sshhvp1/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| gpt-6.1-terra | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle gpt-6.1-terra, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Mandat | SCM direct, correction sshhvp1 | Demande utilisateur et change OpenSpec. |

## 2. Types de messages et d’outils

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Suite finale | 1354 tests dont deux ignorés ; aucun échec | unittest discover, 273,612 s. |

## 3. Fichiers modifiés

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | GLOBAL Zsh, test, documentation et spécification | Diff et archive du change. |

## 4. Commandes

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1352 | Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés. |
| Tests finaux réussis | 1352 | Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés. |
| Tests finaux échoués | 0 | Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés. |
| Fichiers ayant passé un contrôle syntaxique | 2 | Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés. |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 1 | Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés. |
| Validations OpenSpec strictes échouées | 0 | Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés. |
| Tâches OpenSpec prouvées et terminées | 2 | Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés. |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Test isolé | Options SSH, silence et conservation alias vérifiés | Conteneur Debian, SSH simulé ; aucune connexion à hvp1. |

## 5. Accès web

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Télémétrie | N/A | Source native exacte non exposée ; rattachement CAB et gel sans métriques. |

## 6. Synthèse globale

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| CAB | Échec de préparation atelier transmis à DCAB | FAILED_TO_START, dispatched=false ; request_id background-zsh-test-01. |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "gpt-6.1-terra",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1"
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "2"
          },
          "tasks": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "2"
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1352"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite 1354 tests, deux ignorés ; 21 ciblés, syntaxe Bash/Python et OpenSpec strict validés."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1352"
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Mandat",
            "proof": "Demande utilisateur et change OpenSpec.",
            "value": "SCM direct, correction sshhvp1"
          }
        ],
        "2": [
          {
            "label": "Suite finale",
            "proof": "unittest discover, 273,612 s.",
            "value": "1354 tests dont deux ignorés ; aucun échec"
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Diff et archive du change.",
            "value": "GLOBAL Zsh, test, documentation et spécification"
          }
        ],
        "4": [
          {
            "label": "Test isolé",
            "proof": "Conteneur Debian, SSH simulé ; aucune connexion à hvp1.",
            "value": "Options SSH, silence et conservation alias vérifiés"
          }
        ],
        "5": [
          {
            "label": "Télémétrie",
            "proof": "Source native exacte non exposée ; rattachement CAB et gel sans métriques.",
            "value": "N/A"
          }
        ],
        "6": [
          {
            "label": "CAB",
            "proof": "FAILED_TO_START, dispatched=false ; request_id background-zsh-test-01.",
            "value": "Échec de préparation atelier transmis à DCAB"
          }
        ]
      },
      "id": "01a1c6d4-6541-7fb1-82f3-997b307df2a2",
      "input_sha256": "4ee6822c4b8f797c25180785471f15e519b5ad6da89eb921cf064a9c429c5653",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->

<!-- CAB_STATISTICS_CURRENT_V1 -->

Change : `background-zsh-sshhvp1` · état local : `archived`. Les valeurs absentes restent N/A.

### 1. Statistiques générales et décisions

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |


| Rôle | Agent | Modèle | Raisonnement |
| --- | --- | --- | --- |


Provenance : change-periods:4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945

### 2. Messages et outils

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |


### 3. Fichiers et tâches

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |


### 4. Commandes et validations

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | 2 | Cases locales de tasks.md ; ne valent pas validation du RUN. |


### 5. Accès web

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |


### 6. Synthèse et couverture

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |


<!-- CAB_STATISTICS_CURRENT_END -->
<!-- CAB_STATISTICS_DOCUMENT_V1 {"content_sha256": "65d7f5b66cb7d7c016779b1ea0398deaaaa795424736fac25d34169230fec794", "generated_at": "2026-11-13T13:43:41.639123+00:00", "revision": "65d7f5b66cb7d7c016779b1ea0398deaaaa795424736fac25d34169230fec794", "scope": "change"} -->


## Change `cicd-version-idempotence-cleanup` — openspec/changes/archive/2026-11-03-cicd-version-idempotence-cleanup/STATISTICS.md


# Statistiques — cicd-version-idempotence-cleanup

## Statistiques générales et décisions

- Session SCM directe du 2026-11-03, version locale 1.0.7, code non attribué.
- Priorité aux versions stables dans DIU sans epoch Debian ; reprises de publication sans remplacement d'asset ou déplacement de tag.
- Durée totale et tokens : N/A, mesures exhaustives indisponibles.

## Types de messages et d'outils

- Exécution directe par Codex, avec coordination entre chats DIU autorisée ; aucun agent de codage délégué.
- Décompte exhaustif des messages et outils : N/A, journal agrégé indisponible.

## Fichiers modifiés

- Modules de version, CI/CD, publication Debian et mise à jour DIU ; aides, documentation et tests associés.
- Huit spécifications synchronisées et change archivé ; cartographie et registre actualisés sans attribution de code. Le bloc de version du change actif `reconcile-diu-deb-packaging-contract` est mis en cohérence pour conserver les règles et le scénario synchronisés.
- PROJECT_VERSION mis à jour localement dans project.env, fichier exclu de Git. Volume de lignes : N/A.

## Commandes

- Suite globale avec le Python DevOps : 1 103 tests exécutés, dont 2 ignorés, sans échec ; 257,782 secondes. Les modifications finales ciblées de GitLab ont également été vérifiées par 32 tests ciblés réussis.
- Syntaxe Bash, ShellCheck du périmètre, compilation Python, validation OpenSpec stricte du change et validation globale standard réussies ; après archivage et mise en cohérence, 119 éléments OpenSpec valides.
- Le contrôle OpenSpec strict sur tout le dépôt signale 47 spécifications historiques hors du change avec avertissements préexistants.
- Total exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

- Forgejo et GitHub : inventaire et nettoyage des versions 2026 autorisés, sans modification des branches ni des versions stables.
- Sauvegarde vérifiée : 216 tags locaux, métadonnées de 194 releases et 193 assets. Suppression vérifiée de 216 tags locaux, 208 tags et 194 releases Forgejo, 9 tags GitHub ; aucune release GitHub 2026.
- Sauvegarde privée hors Git : `output/version-cleanup-20261103-R1/`.

## Synthèse globale

Change validé et archivé. La construction et la publication des paquets de production restent à la charge du développeur. Les releases supprimées ne peuvent pas retrouver leurs identifiants ou compteurs initiaux lors d'une restauration.


## Change `clarify-devops-lxc-ssh-access` — openspec/changes/archive/2026-10-26-clarify-devops-lxc-ssh-access/STATISTICS.md


# STATISTIQUES — Accès SSH LXC et conservation des dépendances de test

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu` ; date utilisateur : 26 octobre 2026, Europe/Paris.
- Session SCM directe, sans pilotage OpenCode/CAB ni compétence de télémétrie SCMP.
- Change : `clarify-devops-lxc-ssh-access`.
- Archive : `2026-10-26-clarify-devops-lxc-ssh-access`.
- Autorisation : périmètre proposé puis explicitement validé par le développeur,
  avec ajout de la cinquième puce de conservation des binaires et bibliothèques.
- Sources de preuve : commandes de cette session, [proposition](proposal.md),
  [conception](design.md), [tâches](tasks.md), [delta](specs/projects-template-devops/spec.md)
  et [spécification synchronisée](../../../specs/projects-template-devops/spec.md).

Le titre devient « Conteneur LXC, pour tests nécessitant des droits root accessible en SSH ».
La première puce devient « Variables d'accès disponible dans project.env pour l'accès SSH ».
La cinquième et dernière puce est exactement :
« Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests. »
L’autorisation commune reste identique en quatrième position pour LXC.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Fenêtre mesurée de réalisation avant rapport | 397 s, de 15:47:21 à 15:53:58 UTC le 26 octobre 2026 ; hors exploration antérieure, attente de validation, rapport et commit |
| Premier passage ciblé | 6,876 s ; échec corrigé avant validation |
| Passage ciblé après correction | 8,729 s ; cinq méthodes réussies |
| Suite complète du générateur | 85,631 s selon unittest |
| Durée globale de la conversation | N/A : absence de mesure continue couvrant toute la conversation |
| Tokens, coût, CPU et mémoire | N/A : aucune instrumentation dédiée disponible |
| Messages et outils exhaustifs | N/A : absence d’export de télémétrie de cette session |
| Approbations CAB | N/A : session directe, sans protocole CAB |

Les sous-tests ne sont pas comptés comme méthodes supplémentaires.
Les résultats des archives précédentes ne sont pas utilisés comme preuves actuelles.

## 3. Fichiers et comportement livré

| Catégorie | Nombre | Chemins |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique modifiée | 1 | openspec/specs/projects-template-devops/spec.md |
| Fichiers de la nouvelle archive | 6 | .openspec.yaml ; proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final** | **12** | **1 + 1 + 3 + 1 + 6** |

Six fichiers préexistants modifiés et six nouveaux fichiers à leur emplacement final.
Les cinq artefacts du change sont déplacés par OpenSpec ; le rapport est créé ensuite.
Le générateur ajoute la dernière puce après l’autorisation commune et propage tout
échec d’écriture. Le helper commun accepte un séparateur final interne optionnel :
trois sauts de ligne par défaut pour Docker, un seul avant la cinquième puce LXC.
Le texte de l’autorisation commune n’est pas modifié.

Les deux conteneurs comportent cinq puces. LXC reste conditionné à la valeur
exacte `ENV_DEVOPS_TESTS_LXC=1`, indépendamment de Docker ; son ordre et le format
documentaire `0.7` sont conservés. Les trois parcours partagent le même rendu.
Aucune installation, désinstallation ni connexion SSH n’est déclenchée par ce rendu.
Les documents déjà générés adoptent ces textes à leur prochaine génération normale.

## 4. Tests et vérifications

| Passage | Méthodes exécutées | Réussies | Échouées | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Ciblé initial | 5 | 1 | 4 | 0 | 0 |
| Ciblé corrigé | 5 | 5 | 0 | 0 | 0 |
| Suite complète finale | 121 | 119 | 0 | 0 | 2 |

Le premier passage a produit treize échecs de sous-tests dans quatre méthodes :
le helper d’autorisation émettait la séparation entre rubriques avant la cinquième
puce. Le séparateur a été adapté ; les mêmes attentes exactes passent ensuite.
Aucun test n’a été affaibli pour accepter cette mise en page incorrecte.

Les cinq méthodes ciblées sont les tests des indicateurs indépendants, des valeurs
désactivantes, de la création, du traitement groupé et de la conservation du
document après échec de rendu/remplacement. L’assertion commune contrôle le titre,
la première puce, le texte intégral des cinq puces et leur ordre. Un stub SSH
interdit et un échec simulé d’écriture de la cinquième puce complètent les cas existants.

Commande de la suite finale réellement exécutée :

```bash
env PYTHONDONTWRITEBYTECODE=1 /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
```

Les deux tests Go sont ignorés : `go` est absent du PATH de test et `DIU_TEST_GO`
n’est pas défini. L’UID effectif observé est 1000 ; les tests de permissions
ordinaires ne sont pas ignorés pour une exécution root.

| Contrôle | Résultat réel |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi après correction finale |
| shellcheck modules/projects/template.sh | Exécuté et réussi, aucun diagnostic |
| Compilation Python | Exécutée et réussie avec le Python DevOps et py_compile.compile ; cfile temporaire sous le projet, nettoyé |
| Change OpenSpec strict avant code | Exécuté et réussi |
| Change OpenSpec strict avant archivage | Exécuté et réussi |
| Canon projects-template-devops standard après synchronisation | Exécuté et réussi, huit avertissements de longueur préexistants |
| Global OpenSpec strict initial | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec |
| Global OpenSpec strict avec le change actif | Exécuté et échoué : 69 éléments, 47 valides, 22 en échec ; change ciblé valide sans diagnostic |
| Global OpenSpec strict après archivage | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec ; éléments et diagnostics identiques à l’état initial |
| Global OpenSpec standard final | Exécuté et échoué : 68 éléments, 66 valides, deux changes Forgejo préexistants en échec |
| Concordance delta/canon | Exécutée et réussie : cinq exigences et onze scénarios, hors lignes vides normalisées par OpenSpec |
| Archivage | Exécuté et réussi : cinq exigences modifiées, zéro ajout, suppression ou renommage |
| Empreintes des artefacts déplacés | Exécutées et réussies : les cinq SHA-256 sont conservés |
| Références inchangées | AGENTS.md, PROJECT.md, BUILD.md et DEVOPS.md conservent leurs SHA-256 initiaux |
| UTF-8/LF sans BOM | Réussi sur les onze fichiers avant rapport ; vérification finale étendue au rapport |
| Temporaires | Aucun résidu après la suite sous .diu-test-devops-* ou .diu-scm-pycompile-* |
| Suite complète du dépôt | Non exécutée : suite du générateur directement concernée retenue |
| Tests réels Docker/LXC et accès SSH | Non exécutés : modification documentaire du générateur uniquement |

Les validations OpenSpec utilisent le binaire explicite
`/home/devops/.local/npm/bin/openspec`, avec `--no-interactive`, `--strict` pour
le change et les comparaisons globales, `--json` pour les relevés globaux.
La validation standard ciblée utilise `--type spec`.

## 5. Cohérence documentaire et archivage

| Élément SCM | État et preuve |
| --- | --- |
| Projet réel | Nouveau rendu vérifié dans les trois parcours, 119 méthodes finales réussies |
| AGENTS.md | Inchangé, empreinte conservée ; règles de périmètre et statistiques appliquées |
| PROJECT.md | Inchangé, empreinte conservée ; architecture du module projects préservée |
| TECHNICAL.md | Traçabilité du document DevOps mise à jour : SSH, cinq puces, ordre et échecs d’écriture |
| BUILD.md | Inchangé, empreinte conservée ; construction et packaging non concernés |
| DEVOPS.md | Inchangé, empreinte conservée ; relevé daté utilisé pour les chemins d’outils, nouvelle rédaction à la prochaine génération |
| README.md | Description des rubriques mise à jour : accès SSH et conservation finale des dépendances |
| CHANGELOG.md | Entrée Unreleased dédiée, sans version de publication inventée |
| openspec/specs/ | projects-template-devops synchronisé : cinq exigences modifiées, onze scénarios concernés |

Commande d’archivage réussie :

```bash
env OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive clarify-devops-lxc-ssh-access --json --yes
```

La première invocation JSON sans `--yes` a refusé l’archivage sans effet, avec
`archive_confirmation_required`. L’invocation complète exécute l’archivage
déjà autorisé par le développeur ; un seul archivage a réussi.
Le change actif est absent, l’archive est présente, les quatre tâches sont
cochées sur preuves et les cinq artefacts déplacés gardent leurs empreintes.
Le fichier BLOCKERS.md et ses liens sont absents : aucun nettoyage n’est nécessaire.

| Sources qualifiées | SHA-256 |
| --- | --- |
| modules/projects/template.sh | 3ce749956c57b0571b73f7470d3e07109f9856e25692cc13d37fa8f09e21ce36 |
| tests/test_projects_template_devops.py | 82f2752e29ee5ae37824fac82bbacbae6cfb5c424943187977b2a6425d7be63d |

Totaux : 12 = 1 + 1 + 3 + 1 + 6 ; 121 = 119 + 0 + 0 + 2 ; quatre tâches sur quatre ;
cinq exigences modifiées, onze scénarios, un change archivé et six fichiers dans l’archive.
Le contrôle du rapport vérifie six sections, UTF-8/LF, liens et totaux avant l’étape Git.

## 6. Limites et clôture

Le générateur, ses tests, la documentation et la spécification sont alignés sur
la demande validée. Le change est archivé et ce rapport est produit.
Le contrôle global strict reste en échec sur les mêmes 22 éléments préexistants.
En mode standard, seuls modify-projects-forgejo-push-force-with-lease et
restore-forgejo-push-to-create échouent : leurs deltas omettent deux scénarios
existants du canon Forgejo. Ces éléments hors périmètre restent inchangés.

Le relevé DEVOPS.md réel n’a pas été régénéré ; aucun conteneur ni paquet
installé n’a été modifié. Aucune information d’accès SSH réelle n’a été lue.
Le commit local conditionnel SCM est l’étape suivant la vérification de ce
rapport ; sa branche, son SHA et son résultat réel sont restitués dans le bilan
final. Aucun push, changement de branche, tag ou déploiement n’est autorisé ici.

Préparation Git observée : dépôt existant, branche `main` conforme à
LOCAL_DEFAULT_BRANCH, identité auteur/committer extraite localement et validée
sans lecture des autres variables. L’index initial est vide et les différences
des six fichiers existants du change correspondent au périmètre validé.
DEVOPS.md présente une modification antérieure au change : son empreinte
initiale est conservée et ce fichier est exclu du commit. Les douze chemins
du change sont indexés explicitement pour le seul commit local autorisé.


## Change `clarify-devops-nodejs-download-errors` — openspec/changes/archive/2026-10-02-clarify-devops-nodejs-download-errors/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `clean-legacy-debian-release` — openspec/changes/archive/2026-09-05-clean-legacy-debian-release/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `concise-diu-update-output` — openspec/changes/archive/2026-11-06-concise-diu-update-output/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé scm-diu-output-20261106

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| non communiqué | N/A | N/A | non communiqué | N/A | N/A | N/A |

### Agents orchestrateurs — relevé scm-diu-output-20261106

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé scm-diu-output-20261106

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle non communiqué, raisonnement non communiqué.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Session | SCM directe ; sans CICD ; aucun orchestrateur | validation du périmètre et restrictions du développeur |

## 2. Types de messages et d’outils

### Relevé scm-diu-output-20261106

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé scm-diu-output-20261106

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Périmètre | Code DIU, réseau, aides, tests et documentation ; spécifications synchronisées | change archivé et fichiers concernés |

## 4. Commandes

### Relevé scm-diu-output-20261106

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1216 | Bilan final : 1216 tests, dont 2 ignorés |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation finale | 1216 tests exécutés dont 2 ignorés ; bash -n, ShellCheck, py_compile et OpenSpec strict réussis | résultats des commandes en session |
| Essai antérieur | Python système : 26 erreurs de fixture site-packages ; Python DevOps : suite réussie | sortie unittest et vérification des chemins |

## 5. Accès web

### Relevé scm-diu-output-20261106

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 6. Synthèse globale

### Relevé scm-diu-output-20261106

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Télémétrie | N/A : compteurs natifs complets non disponibles ; initialisation statistique partielle | session directe sans collecte de pilotage |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "non communiqué",
            "reasoning": "non communiqué",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [
              {
                "line": 6,
                "note": "Bilan final : 1216 tests, dont 2 ignorés"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1216"
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [
          "scm-diu-output-20261106"
        ],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Session",
            "proof": "validation du périmètre et restrictions du développeur",
            "value": "SCM directe ; sans CICD ; aucun orchestrateur"
          }
        ],
        "3": [
          {
            "label": "Périmètre",
            "proof": "change archivé et fichiers concernés",
            "value": "Code DIU, réseau, aides, tests et documentation ; spécifications synchronisées"
          }
        ],
        "4": [
          {
            "label": "Validation finale",
            "proof": "résultats des commandes en session",
            "value": "1216 tests exécutés dont 2 ignorés ; bash -n, ShellCheck, py_compile et OpenSpec strict réussis"
          },
          {
            "label": "Essai antérieur",
            "proof": "sortie unittest et vérification des chemins",
            "value": "Python système : 26 erreurs de fixture site-packages ; Python DevOps : suite réussie"
          }
        ],
        "6": [
          {
            "label": "Télémétrie",
            "proof": "session directe sans collecte de pilotage",
            "value": "N/A : compteurs natifs complets non disponibles ; initialisation statistique partielle"
          }
        ]
      },
      "id": "scm-diu-output-20261106",
      "input_sha256": "e4101eeba894f20dabeb2f331fb4549d86d696bcb40bf006a77c991f951c61ca",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `condition-devops-test-container-sections` — openspec/changes/archive/2026-10-24-condition-devops-test-container-sections/STATISTICS.md


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



## Change `condition-project-opencode-on-directory` — openspec/changes/archive/2026-10-03-condition-project-opencode-on-directory/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `condition-project-orchestrated-coding-copy` — openspec/changes/archive/2026-10-10-condition-project-orchestrated-coding-copy/STATISTICS.md


# STATISTIQUES — condition-project-orchestrated-coding-copy

Session SCM directe sur DIU, périmètre proposé puis explicitement validé par
le développeur avec « Je valide » le 2026-10-10 : spécification, code, tests,
documentation, réconciliation des chevauchements, archivage du seul change
dédié et rapport. Aucune compétence ni télémétrie de session pilotée utilisée.

## 1. Statistiques générales et décisions

| Mesure | Valeur |
| --- | ---: |
| Méthodes distinctes dans les exécutions finales | 214 |
| Méthodes finales réussies / échouées / ignorées | 212 / 0 / 2 |
| Exécutions de méthodes, répétitions comprises | 312 |
| Exécutions réussies / échouées / ignorées | 307 / 1 / 4 |
| Tâches du change prouvées et cochées | 7 / 7 |
| Archives réalisées | 1 |
| Exigences ajoutées / modifiées / retirées / renommées | 4 / 1 / 0 / 0 |
| Fichiers préexistants modifiés | 9 |
| Fichiers nouveaux livrés, rapport compris | 8 |
| Total des fichiers livrés | 17 |

Agent unique : Codex. Sous-agents : aucun. Durée globale, temps actif, tokens,
coût, quotas et modèle exact : N/A, aucun chronométrage global ni télémétrie
exploitable. Les durées des suites sont celles des sorties unittest, sans
estimation du temps global. Le changement documentaire ne lance aucun service.

## 2. Messages et outils

Comptages exhaustifs des messages et appels d'outils : N/A, aucun journal
exhaustif exporté. Écritures avec apply_patch ; validations par commandes
natives. Les témoins SHA-256 et les contenus canoniques avant synchronisation
ont été conservés en mémoire pour contrôler le périmètre sans Git.

La suite de copie conditionnelle a été exécutée deux fois (10 méthodes
chacune), la seconde après ajout des scénarios de défaut interactif et de
source non régulière à la création. La suite DevOps a été exécutée deux fois
(88 méthodes chacune) : échec sandbox puis relance hors sandbox réussie.
Les quatre autres suites totalisent 116 méthodes, exécutées une fois.
Aucun test n'a été affaibli ni diagnostic supprimé pour obtenir un succès.

## 3. Fichiers modifiés

Neuf fichiers préexistants modifiés :

- `modules/projects/projects.sh` : uniquement sync_project et create_project,
  lecture du mode destination, contrôle de la source requise, sélection des
  copies et propriété du document conditionnel ; exclusions existantes conservées ;
- `TECHNICAL.md` : Métadonnées générales, copie, préservation et échecs ;
- `README.md` : condition de copie à la création et à la synchronisation ;
- `CHANGELOG.md` : entrée Unreleased ;
- `openspec/specs/projects-sync/spec.md` : une exigence modifiée ;
- `openspec/specs/implement-projects-update/spec.md` : quatre exigences ajoutées ;
- `openspec/changes/add-projects-sync-broker/specs/projects-sync/spec.md` :
  même exception conditionnelle dans la sélection réduite déjà implémentée ;
- `openspec/changes/refactor-projects-template-copy/specs/projects-template-creation/spec.md` :
  même réserve conditionnelle dans l'exigence et les scénarios de copie ;
- `openspec/changes/refactor-projects-template-copy/proposal.md` : réserve
  conditionnelle explicitée.

Huit fichiers nouveaux livrés : `tests/test_projects_orchestrated_copy.py`
et les sept fichiers de cette archive : `.openspec.yaml`, `proposal.md`,
`design.md`, `tasks.md`, les deux deltas `specs/*/spec.md` et ce rapport.
Les six artefacts du change ont été déplacés par OpenSpec à l'archivage.
Aucun fichier métier n'a été supprimé.

Neuf témoins restent identiques : AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md,
root-install-debian.sh, modules/projects/template.sh, modules/projects/git.sh,
tests/test_projects.py et tests/test_projects_orchestrated_coding.py.
Dans les deux canons, les dix exigences antérieures non ciblées sont intactes.
Le contrôle porte sur les témoins ciblés, sans inventaire exhaustif du dépôt.

## 4. Commandes et validations

Les commandes utilisent les chemins déclarés par DEVOPS.md. Les suites sont
exécutées depuis la racine avec le Python DevOps :

```text
/home/devops/python/current/bin/python3 -B tests/test_projects_orchestrated_copy.py
/home/devops/python/current/bin/python3 -B tests/test_projects.py
/home/devops/python/current/bin/python3 -B tests/test_projects_orchestrated_coding.py
/home/devops/python/current/bin/python3 -B tests/test_rid_help.py
/home/devops/python/current/bin/python3 -B tests/test_projects_template_openspec.py
/home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py
```

| Suite finale | Réussis | Échecs | Ignorés |
| --- | ---: | ---: | ---: |
| test_projects_orchestrated_copy.py | 10 | 0 | 0 |
| test_projects.py | 26 | 0 | 0 |
| test_projects_orchestrated_coding.py | 17 | 0 | 0 |
| test_rid_help.py | 56 | 0 | 0 |
| test_projects_template_openspec.py | 17 | 0 | 0 |
| test_projects_template_devops.py, hors sandbox | 86 | 0 | 2 |
| Total | 212 | 0 | 2 |

Les deux cas DevOps ignorés exigent un utilisateur non root ; ils ne sont pas
revendiqués comme réussis. La première exécution DevOps a compté 85 réussites,
un échec sur chown d'un document temporaire et deux cas ignorés. Sa relance
hors sandbox a réussi sans modification de module ni de test (65,143 s).
La première exécution a duré 63,973 s. Les autres durées rapportées sont
1,166 s puis 1,076 s pour la copie conditionnelle, 1,805 s pour les projets,
0,780 s pour le mode, 1,491 s pour l'aide et 1,204 s pour le modèle OpenSpec.

| Validation | État et preuve |
| --- | --- |
| `bash -n modules/projects/projects.sh` | Exécutée et réussie |
| `python3 -m py_compile tests/test_projects_orchestrated_copy.py` | Exécutée et réussie avec le Python DevOps ; cache temporaire sous la racine, supprimé automatiquement |
| ShellCheck des fonctions sync_project et create_project | Exécutée et réussie, sans exclusion de règle |
| ShellCheck du fichier complet | Exécutée et échouée avant/après sur le seul SC2004 préexistant de keys[${index}], hors périmètre |
| Change dédié strict avant code et avant archive | Exécutée et réussie après découpage de l'exigence initiale trop longue |
| Changes actifs réconciliés stricts | Exécutée et réussie pour add-projects-sync-broker et refactor-projects-template-copy |
| Archivage avec synchronisation | Exécutée et réussie, specsUpdated: true ; 4 ajouts et 1 modification |
| Canon implement-projects-update strict, avant/après | Exécutée et réussie |
| Canon projects-sync strict avant | Exécutée et échouée avec deux avertissements préexistants de longueur, requirements[1] et requirements[2] |
| Canon projects-sync strict après | Exécutée et échouée avec le seul avertissement préexistant requirements[1], inchangé |
| Canon projects-sync non strict après | Exécutée et réussie avec cet avertissement signalé |
| Deltas archivés et canons | Concordance exacte des cinq blocs ciblés ; dix anciens blocs non ciblés identiques |
| UTF-8/LF et périmètre | Contrôles ciblés réussis avant archive ; rapport et fichiers livrés contrôlés à la clôture |
| Construction Debian, navigateur, déploiement | Non exécutés, non pertinents pour cette sélection de fichiers Bash |

L'exigence modifiée de projects-sync a été raccourcie sous 500 caractères ;
l'avertissement requirements[2] est donc éliminé. requirements[1] concerne
Source de synchronisation contrôlée, inchangée. Aucune réussite stricte globale
du dépôt n'est revendiquée ; les blocs de ce change sont valides.

OpenSpec a utilisé `/home/devops/.local/npm/bin/openspec` :

```text
openspec validate condition-project-orchestrated-coding-copy --type change --strict
openspec validate add-projects-sync-broker --type change --strict
openspec validate refactor-projects-template-copy --type change --strict
openspec archive condition-project-orchestrated-coding-copy --yes --json
openspec validate implement-projects-update --type spec --strict
openspec validate projects-sync --type spec --strict
openspec validate projects-sync --type spec
```

L'archivage autorisé a utilisé OPENSPEC_TELEMETRY=0 et DO_NOT_TRACK=1,
sans --skip-specs ni --no-validate. Le rapport clôt la tâche d'archivage ;
les autres changes actifs restent hors archivage.

## 5. Accès web et effets externes

Aucun outil web, appel API métier, installation, publication, migration,
activation OpenCode/CAB ni synchronisation d'un projet réel n'a été exécuté.
Les nouvelles fixtures et le cache de compilation sont sous la racine et
nettoyés automatiquement. Les suites existantes emploient leurs temporaires
habituels. Les opérations externes des nouvelles fixtures sont simulées,
y compris chown, OpenSpec et génération DevOps ; les assertions de propriété
vérifient les arguments transmis, pas une qualification de propriétaire en
production. Les attributs préservés en mode No sont contrôlés sur disque.

Écart de protocole : une inspection initiale git status --short a précédé
la lecture de l'interdiction SCM. Elle a été signalée et n'a pas été répétée.
Aucune écriture Git, préparation de commit, branche, commit ou push réalisée.
La relance hors sandbox a été acceptée par le contrôle de la plateforme ;
aucun rejet automatique d'approbation ni contournement de demande interactive.

## 6. Synthèse globale et cohérence documentaire

Le protocole racine du modèle est copié et personnalisé uniquement pour Yes
lu dans la configuration destination. Pour No, absence ou vide : pas de copie
ni de suppression, préservation d'un document destination et de ses attributs.
Un mode invalide ou une source requise absente/non régulière échoue avant la
copie du modèle. À la création, la configuration préparée reste disponible
en cas d'échec. sync all décide par projet et poursuit après une erreur.

| Élément | État et preuve |
| --- | --- |
| Projet réel | Sources livrées, 212 réussites finales ; aucune synchronisation réelle ni installation |
| AGENTS.md | Inchangé, empreinte identique ; règles générales et distinction SCM/pilotage conservées |
| PROJECT.md | Inchangé, empreinte identique ; Architecture fonctionnelle / Module projects couvre le périmètre |
| TECHNICAL.md | Mis à jour dans Projets et configuration Git / Métadonnées générales |
| BUILD.md | Inchangé, empreinte identique ; Objet concerne la construction du paquet, aucun impact sur son contenu ou sa chaîne |
| DEVOPS.md | Inchangé, empreinte identique ; inventaire généré et chemins des runtimes réutilisés |
| README.md | Mis à jour : condition Yes, préservation en No et source requise |
| CHANGELOG.md | Entrée Unreleased ajoutée ; aucune version ou date de publication inventée |
| OpenSpec | 4 ajouts, 1 modification, 7 tâches closes, 1 archive ; deux changes actifs réconciliés et conservés |
| ancien protocole local racine | Absent, facultatif pour SCM ; non créé ni restauré |

Le canon projects-sync historique cite encore les ressources OpenCode alors
que leur retrait est déjà implémenté et couvert par le change actif
add-projects-sync-broker. Ce retrait n'est ni annulé ni archivé ici ; son delta
conserve maintenant la nouvelle condition pour un futur archivage. De même,
l'exclusion Git prévue dans refactor-projects-template-copy n'est pas
implémentée dans cette session. Ces écarts préexistants sont explicites et ne
remettent pas en cause la cohérence ciblée de la condition documentaire.

Totaux vérifiés : 10 + 26 + 17 + 56 + 17 + 88 = 214 méthodes finales ;
212 réussies + 2 ignorées = 214. Répétitions : 214 + 10 + 88 = 312 ;
307 réussies + 1 échec sandbox + 4 ignorées = 312. Fichiers : 9 préexistants
+ 8 nouveaux = 17, dont 7 dans cette archive. Exigences : 4 ajoutées
+ 1 modifiée = 5. Aucun retrait ni renommage d'exigence.

Limites conservées : SC2004 hors périmètre, avertissement canonique de longueur,
deux tests nécessitant non-root non exécutés, aucune qualification de production.
Les six sections, les totaux, UTF-8/LF, tâches et concordance des deltas font
l'objet du contrôle final du rapport et de l'archive.


## Change `configure-devops-home-openspec` — openspec/changes/archive/2026-10-02-configure-devops-home-openspec/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `configure-gitlab-container-registry` — openspec/changes/configure-gitlab-container-registry/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `configure-system-hosts-json` — openspec/changes/archive/2026-11-04-configure-system-hosts-json/STATISTICS.md


# Statistiques — configure-system-hosts-json

## Statistiques générales et décisions

Session SCM directe, Codex, 2026-11-04. Périmètre validé : fichier JSON d'hôtes, plusieurs couples, validation préalable et intégration aux deux constructeurs Debian. Le développeur a validé l'extension au constructeur générique. Code de lot non attribué, attribution et normalisation ultérieures par ACL. Durée, modèle précis, consommation et coût : N/A, mesures indisponibles.

## Types de messages et d'outils

Messages et appels par type : N/A, comptage exhaustif indisponible. Aucun pilotage OpenCode ni télémétrie CAB.

## Fichiers modifiés

Réseau système et validateur JSON, modèle vierge, liste Git, deux constructeurs et recette, aides, documentation, tests, spécifications, cartographie et registre. Nombre exhaustif de fichiers : N/A, comptage non collecté.

## Commandes

Validation finale : 177 tests ciblés réussis (5 réseau, 12 packaging DIU, 13 constructeur générique, 24 versions, 4 liens, 15 APT, 60 aides et 44 logiciels) ; syntaxe de quatre scripts Bash et six fichiers Python, ShellCheck et aide réelle réussis. Trois spécifications synchronisées et le change ont réussi la validation OpenSpec stricte. Une validation intermédiaire du change a échoué sur un scénario omis puis a été corrigée ; les tests de comparaison et de fixtures ont échoué avant adaptation puis ont réussi. Nombre total de commandes : N/A, comptage exhaustif indisponible.

## Accès web

Aucun accès web recensé pendant cette session.

## Synthèse globale

Quatre tâches validées, change archivé. Les tests ont inspecté des paquets de fixture et n'ont pas installé le paquet ni modifié `/etc/hosts` réel. L'effet d'une mise à jour Debian réelle sur une configuration déjà personnalisée n'a pas été testé ; la protection repose sur le mécanisme conffile de dpkg. Le rapport statistique global est absent et nécessite une demande SGS distincte.


## Change `converge-rid-to-diu` — openspec/changes/archive/2026-11-05-converge-rid-to-diu/STATISTICS.md


# Statistiques — convergence des commandes DIU

## 1. Statistiques générales et décisions

Date : 2026-11-05. Agent de codage : Codex, session directe SCM. Aucun pilotage OpenCode/CAB ni sous-agent. Version exacte du modèle, tokens, coûts et durée totale de session : N/A, compteurs non collectés. La durée de 262,911 s ci-dessous mesure seulement le dernier lancement des tests.

Le périmètre autonome a été explicitement validé avant les écritures : convergence des commandes, alias, fonctions et fichiers d’aide, tests, spécifications courantes et documentation. Archivage du seul change de convergence inclus. Aucun commit, tag, publication, installation ou CI/CD. Les anciennes archives et les contributions concurrentes sont préservées.

Code non attribué ; attribution et normalisation définitive à traiter ultérieurement par ACL. Archivage réussi le 2026-11-05 sous `2026-11-05-converge-rid-to-diu` ; spécifications synchronisées et rapport vérifié.

## 2. Types de messages et d’outils

Outils employés : `functions.exec`, commandes locales via `exec_command`, édition ciblée via `apply_patch`, consultation de résultats via `write_stdin`. Aucun appel de navigation web ni d’outil de délégation. Les messages reçus d’une session parallèle ne constituent pas des agents délégués à ce change.

Totaux exhaustifs des messages, appels d’outils et écritures : N/A, absence de collecte native exploitable pour cette session directe. La validation du périmètre est attestée ; aucun total de permissions natives n’est reconstruit.

## 3. Fichiers modifiés

96 fichiers existants concernés : 11 Bash, 10 Python, 75 fichiers de spécification ou documentation. Ce comptage inclut cinq fichiers logiques renommés, sans compter deux fois leurs anciens chemins. Liste exhaustive et matrice documentaire dans [review.md](review.md).

Renommages : `lib/diu-help.sh`, `tests/test_diu_help.py`, `openspec/specs/diu-help/spec.md`, et les deux deltas d’aide actifs de `add-projects-forgejo-clone` et `reconcile-diu-deb-packaging-contract`.

Neuf fichiers créés dans le périmètre de clôture : huit artefacts de ce change, dont ce rapport, et la nouvelle spécification canonique `diu-command-convergence/spec.md` issue de la synchronisation. Le total logique final vérifié est 105 fichiers distincts touchés ; le déplacement du dossier de change vers l’archive ne double pas ce comptage. La nouvelle spécification canonique et les huit fichiers archivés sont présents et vérifiés.

`DEVOPS.md` n’est pas modifié par cette session ; son état antérieur est préservé. Les 1 196 fichiers d’archives préexistants admissibles sont identiques par SHA-256. Le retrait concomitant du moteur logiciel `deb`, dont la suppression de son module et l’adaptation de `tests/test_software.py`, appartient à l’autre session et n’est pas attribué à cette convergence.

## 4. Commandes et validations

| Contrôle | Résultat observé |
|---|---|
| `bash -n` | Réussi, 11 fichiers distincts. |
| Compilation via `py_compile` | Réussie, 10 fichiers Python distincts, dont la reprise avec le Python DevOps déclaré. |
| `shellcheck` avec les dépendances explicites | Réussi, 13 fichiers ; premier appel incomplet en échec SC1091, corrigé en passant les fichiers sourcés, sans exclusion de diagnostic. |
| Tests ciblés initiaux | 311 cas : 283 réussis, 2 ignorés, 26 erreurs de fixtures venv sous Python système 3.13.5. |
| Reprise des 26 cas en erreur | 26 réussis sous `/home/devops/python/current/bin/python3` 3.14.10. |
| Tests isolés des liens et alias | 7 réussis, déjà inclus dans le périmètre ciblé ; ne pas les additionner au bilan final. |
| Tests des fichiers partagés après modification concurrente | 108 réussis. |
| Premier lancement global | 1 189 cas, 45 échecs et 2 ignorés ; 44 échecs liés aux anciens tests logiciels chargés avant le retrait concurrent de `deb`, 1 empreinte Zsh attendue actualisée après comparaison des sept lignes d’alias. Essai intermédiaire. |
| Lancement global final | 1 177 cas exécutés, 1 175 réussis, 2 ignorés, 0 échec, 0 erreur ; durée 262,911 s ; sources inchangées pendant le lancement. |
| OpenSpec ciblé strict | Change validé avant archivage ; canons convergence, aide et liens validés après archivage avec `--strict --no-interactive`. |
| OpenSpec global strict | Échec : 47 diagnostics préexistants, identiques à la copie isolée de l’état initial ; aucun nouvel échec introduit. |
| UTF-8/LF, chemins et absence des anciens identifiants exécutables | Réussis sur le périmètre concerné. |

Les suites utilisent `unittest.defaultTestLoader.loadTestsFromNames` pour les contrôles ciblés et `unittest.defaultTestLoader.discover('tests', pattern='test_*.py')` pour le global, puis `unittest.TextTestRunner`. Le dernier lancement global utilise le Python DevOps déclaré. Seul son résultat constitue le bilan final de tests, sans ajout des reprises déjà incluses.

Nombre exhaustif de commandes et répartition réussies/échouées : N/A, non collectés ; les contrôles listés sont des preuves bornées, pas un total d’activité. `openspec archive converge-rid-to-diu --yes --json` : réussi, spécifications synchronisées (2 exigences ajoutées, 1 modifiée). Références finales de cartographie et registre actualisées et vérifiées. Après archivage : les trois canons concernés passent le strict ; le global reste à 79 éléments réussis et 47 en échec, diagnostics préexistants inchangés.

## 5. Accès web

Aucun appel d’outil de recherche ou de consultation web pour ce change : 0. Les URL présentes dans le code et les documents ne constituent pas des consultations. Les commandes de test sont exécutées sur les fixtures prévues par le projet ; aucun déploiement réel n’a été lancé.

## 6. Synthèse globale

La convergence est réalisée et qualifiée sur l’état partagé courant. Les anciens noms DIU ne sont plus générés dans les alias ni employés dans les interfaces exécutables concernées. Les aides utilisent `diu` et les raccourcis de développement `diut` ; routage et arguments sont conservés par cette convergence. Les fichiers d’alias et shells installés ne sont pas migrés automatiquement.

Bilan final des tests : 1 177 exécutés = 1 175 réussis + 2 ignorés + 0 échec + 0 erreur. Les 47 diagnostics OpenSpec stricts préexistants restent hors périmètre. La revue documentaire et ses limites sont disponibles dans [review.md](review.md).

Archivage réussi et total logique de 105 fichiers vérifié (96 existants et 9 créés). `STATISTICS.md` global absent : aucun fichier global créé. Mandater le prompt SGS.md pour générer le fichier STATISTICS.md général à la racine du projet.


## Change `converge-software-desired-state` — openspec/changes/archive/2026-11-11-converge-software-desired-state/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| GPT-6 | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle GPT-6, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Session | Codage direct | Historique ; bornes complètes indisponibles. |

## 2. Types de messages et d’outils

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Suite générale | 1 326 cas, 2 ignorés, aucun échec | unittest discover -s tests, 232,788 s. |
| Tests ciblés | 75 réussis | Aide, migration et commandes retirées. |

## 3. Fichiers modifiés

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Debian | Installation, convergence et retrait jsvc réussis | Conteneur isolé ; migration et persistance vérifiées. |

## 4. Commandes

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1324 | Suite complète : 1 326 cas dont deux ignorés, 1 324 réussis et aucun échec. |
| Tests finaux réussis | 1324 | Suite complète : 1 326 cas dont deux ignorés, 1 324 réussis et aucun échec. |
| Tests finaux échoués | 0 | Suite complète : 1 326 cas dont deux ignorés, 1 324 réussis et aucun échec. |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | 9 | Neuf tâches cochées avant archivage. |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| OpenSpec | 30 spécifications synchronisées | Simulation : 119 spécifications valides ; archive créée. |

## 5. Accès web

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Rôles partagés | rsyslog et CrowdSec préservés | Décisions utilisateur et tests isolés. |

## 6. Synthèse globale

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Mesures natives | Non disponibles | Aucune télémétrie exhaustive rétroactive attestée. |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "GPT-6",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [
              {
                "line": 1,
                "note": "Neuf tâches cochées avant archivage."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "9"
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite complète : 1 326 cas dont deux ignorés, 1 324 réussis et aucun échec."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1324"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite complète : 1 326 cas dont deux ignorés, 1 324 réussis et aucun échec."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Suite complète : 1 326 cas dont deux ignorés, 1 324 réussis et aucun échec."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1324"
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Session",
            "proof": "Historique ; bornes complètes indisponibles.",
            "value": "Codage direct"
          }
        ],
        "2": [
          {
            "label": "Suite générale",
            "proof": "unittest discover -s tests, 232,788 s.",
            "value": "1 326 cas, 2 ignorés, aucun échec"
          },
          {
            "label": "Tests ciblés",
            "proof": "Aide, migration et commandes retirées.",
            "value": "75 réussis"
          }
        ],
        "3": [
          {
            "label": "Debian",
            "proof": "Conteneur isolé ; migration et persistance vérifiées.",
            "value": "Installation, convergence et retrait jsvc réussis"
          }
        ],
        "4": [
          {
            "label": "OpenSpec",
            "proof": "Simulation : 119 spécifications valides ; archive créée.",
            "value": "30 spécifications synchronisées"
          }
        ],
        "5": [
          {
            "label": "Rôles partagés",
            "proof": "Décisions utilisateur et tests isolés.",
            "value": "rsyslog et CrowdSec préservés"
          }
        ],
        "6": [
          {
            "label": "Mesures natives",
            "proof": "Aucune télémétrie exhaustive rétroactive attestée.",
            "value": "Non disponibles"
          }
        ]
      },
      "id": "01a1c6d4-6541-7fb1-82f3-997b307df2a2",
      "input_sha256": "584cc66574351b83d95cbcefdae4b0385879e3f10554b8204571d87ece62d735",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `converge-system-prerequisites` — openspec/changes/archive/2026-09-28-converge-system-prerequisites/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `correct-pytest-debian-package` — openspec/changes/archive/2026-09-05-correct-pytest-debian-package/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `create-projects-forgejo-repository` — openspec/changes/archive/2026-09-19-create-projects-forgejo-repository/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `debian-recipe-file-mode` — openspec/changes/archive/2026-11-10-debian-recipe-file-mode/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé scm-debian-recipe-file-mode-20261110

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé scm-debian-recipe-file-mode-20261110

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé scm-debian-recipe-file-mode-20261110

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Résultat | Change archivé ; mode de fichier déclaratif, code non attribué. | openspec/changes/archive/2026-11-10-debian-recipe-file-mode/tasks.md |

## 2. Types de messages et d’outils

### Relevé scm-debian-recipe-file-mode-20261110

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé scm-debian-recipe-file-mode-20261110

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 4. Commandes

### Relevé scm-debian-recipe-file-mode-20261110

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validations | 15 tests ciblés ; 1238 tests globaux dont 2 ignorés ; Bash, ShellCheck et OpenSpec strict réussis. | Résultats de session du 2026-11-10 |

## 5. Accès web

### Relevé scm-debian-recipe-file-mode-20261110

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 6. Synthèse globale

### Relevé scm-debian-recipe-file-mode-20261110

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Télémétrie | N/A : identité native et compteurs non disponibles ; collecte directe non initialisée. | Session directe Codex |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Résultat",
            "proof": "openspec/changes/archive/2026-11-10-debian-recipe-file-mode/tasks.md",
            "value": "Change archivé ; mode de fichier déclaratif, code non attribué."
          }
        ],
        "4": [
          {
            "label": "Validations",
            "proof": "Résultats de session du 2026-11-10",
            "value": "15 tests ciblés ; 1238 tests globaux dont 2 ignorés ; Bash, ShellCheck et OpenSpec strict réussis."
          }
        ],
        "6": [
          {
            "label": "Télémétrie",
            "proof": "Session directe Codex",
            "value": "N/A : identité native et compteurs non disponibles ; collecte directe non initialisée."
          }
        ]
      },
      "id": "scm-debian-recipe-file-mode-20261110",
      "input_sha256": "26aef31e59eded3f8af3627d6ecfadbeeae89e980aba8932705454a2d8db94ee",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `declare-apt-sources-and-software-recipes` — openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| gpt-6.1-sol | N/A | N/A | medium | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle gpt-6.1-sol, raisonnement medium.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Mandat | SCM et prérequis bureau explicitement validés | Conversation ; proposal.md et inventory.md. |

Codage direct sans orchestrateur. La fenêtre native débute après exploration ; les totaux du change non établis restent indisponibles.

## 2. Types de messages et d’outils

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Suite finale | 1 347 tests dont 2 ignorés, 0 échec ; 184,610 s | unittest discover -s tests sur le code final. |

## 3. Fichiers modifiés

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | 80 | Écart Git de production avant rapport ; DEVOPS.md préexistant exclu. |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Recettes et variables | 23 recettes GLOBAL, 18 variables de sources et 22 blocs retirés | Tests de chargement et empreinte des blocs protégés dans tasks.md. |

#### Fichiers de la livraison SCM

| Chemin relatif | Attribution |
| --- | --- |
| CHANGELOG.md | Production du change |
| DEVELOPMENT_MAP.md | Production du change |
| DEVOPS.md | Préexistant conservé |
| README.md | Production du change |
| TECHNICAL.md | Production du change |
| lib/diu-help.sh | Production du change |
| modules/diu/variables/diu/diu_apt_repository_fd.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_apache2.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_chatgpt.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_crowdsec_agent.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_crowdsec_bouncer.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_fastfetch.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_jsvc.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_lemonldap.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_mongodb.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_omada.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_openjdk.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_openvswitch.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_postfix.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_postgresql.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_qemu_guest_agent.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_ssh_server.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_syncthing.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_syslog_client.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_syslog_server.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_wazuh_agent.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_wazuh_server.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_webmin.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_zoom.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_zsh.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_backport.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_contrib.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_nonfrfee.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_nonfrfee_firmware.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_sources.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_updates.sh | Production du change |
| modules/diu/variables/system/system_apt_unofficial.sh | Production du change |
| modules/softwares/apt-configuration.sh | Production du change |
| modules/softwares/apt-convergence.sh | Production du change |
| modules/softwares/apt-management.sh | Production du change |
| modules/softwares/apt-recipes.sh | Production du change |
| modules/softwares/apt-state.sh | Production du change |
| modules/softwares/bootstrap.sh | Production du change |
| modules/softwares/crowdsec-hooks.sh | Production du change |
| modules/softwares/crowdsec-state.sh | Production du change |
| modules/softwares/global-declarations.sh | Production du change |
| modules/softwares/syslog-hooks.sh | Production du change |
| modules/softwares/syslog-state.sh | Production du change |
| modules/softwares/zsh_configuration.py | Production du change |
| modules/system/apt-source-state.sh | Production du change |
| modules/system/apt.sh | Production du change |
| modules/system/apt_sources.py | Production du change |
| modules/system/infos.sh | Production du change |
| modules/system/software-versions.sh | Production du change |
| openspec/BATCH_CODES.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/.openspec.yaml | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/design.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/inventory.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/proposal.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/review.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-software-declarations/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-source-initialization/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/software-management/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/system-debian-apt/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/tasks.md | Production du change |
| openspec/specs/apt-software-declarations/spec.md | Production du change |
| openspec/specs/apt-source-initialization/spec.md | Production du change |
| openspec/specs/software-management/spec.md | Production du change |
| openspec/specs/system-debian-apt/spec.md | Production du change |
| root-install-debian.sh | Production du change |
| tests/test_apt_recipe_sources.py | Production du change |
| tests/test_apt_source_initialization.py | Production du change |
| tests/test_crowdsec_api_key.py | Production du change |
| tests/test_diu_command_links.py | Production du change |
| tests/test_module_infos.py | Production du change |
| tests/test_root_shellcheck.py | Production du change |
| tests/test_software_apt_convergence.py | Production du change |
| tests/test_software_global_declarations.py | Production du change |
| tests/test_software_zsh_configuration.py | Production du change |
| tests/test_system_apt_unofficial.py | Production du change |
| tests/test_system_proxy.py | Production du change |

## 4. Commandes

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1345 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Tests finaux réussis | 1345 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Tests finaux échoués | 0 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Fichiers ayant passé un contrôle syntaxique | 61 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 1 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Validations OpenSpec strictes échouées | 0 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Tâches OpenSpec prouvées et terminées | 9 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation | 48 bash -n/ShellCheck, 13 py_compile ; 121 spécifications strictes | Commandes finales, simulation et validation après archive. |
| Debian | Cycle jsvc, indépendance firmware, prérequis bureau idempotent et Zsh préservé | Conteneurs dédiés supprimés ; preuves tasks.md. |

## 5. Accès web

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Sources | Code local, manuel APT, métadonnées APT et références Git | Aucune mesure web exhaustive ajoutée aux compteurs natifs. |

## 6. Synthèse globale

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Suivi | SGS 2.7.1 et snapshot natif gelé | Même binding/session que le RUN SCM-apt-sources-recipes. |

Archive et spécifications vérifiées ; CICD 1.3.8 prévue après rapport. Tous les logiciels externes ne sont pas qualifiés par installation réelle.


### Télémétrie native et chronologie des modèles

| Rôle | Agent | Session | Mode |
| --- | --- | --- | --- |
| coder | codex | 01a1c6d4-6541-7fb1-82f3-997b307df2a2 | direct |

| Mesure | Valeur | Couverture |
| --- | --- | --- |
| command_wall_seconds | 1121.778 | native |
| commands | 149 | native |
| commands_failure | 13 | native |
| commands_success | 136 | native |
| files_touched | 27 | partial |
| message_span_seconds | 27.548 | native |
| messages | 20 | native |
| messages_assistant | 18 | native |
| messages_llm | 25 | native |
| messages_user | 2 | native |
| reasoning_span_seconds | 2216.972 | native |
| tokens_cache_read | 84385792 | native |
| tokens_cache_write | 0 | native |
| tokens_input | 84504351 | native |
| tokens_output | 116818 | native |
| tokens_reasoning | 63337 | native |
| tokens_total | 84621169 | native |
| tool_wall_seconds | 30.056 | native |
| tools | 181 | native |
| tools_llm | 176 | native |
| writes | 42 | partial |

| Début | Fin | Modèle | Fournisseur | Raisonnement |
| --- | --- | --- | --- | --- |
| 2026-11-11T11:59:00.350000+00:00 | 2026-11-11T13:05:01.258000+00:00 | gpt-6.1-sol | openai | medium |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "gpt-6.1-sol",
            "reasoning": "medium",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [
              {
                "line": 1,
                "note": "Écart Git de production avant rapport ; DEVOPS.md préexistant exclu."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "80"
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1"
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "61"
          },
          "tasks": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "9"
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1345"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1345"
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Mandat",
            "proof": "Conversation ; proposal.md et inventory.md.",
            "value": "SCM et prérequis bureau explicitement validés"
          }
        ],
        "2": [
          {
            "label": "Suite finale",
            "proof": "unittest discover -s tests sur le code final.",
            "value": "1 347 tests dont 2 ignorés, 0 échec ; 184,610 s"
          }
        ],
        "3": [
          {
            "label": "Recettes et variables",
            "proof": "Tests de chargement et empreinte des blocs protégés dans tasks.md.",
            "value": "23 recettes GLOBAL, 18 variables de sources et 22 blocs retirés"
          }
        ],
        "4": [
          {
            "label": "Validation",
            "proof": "Commandes finales, simulation et validation après archive.",
            "value": "48 bash -n/ShellCheck, 13 py_compile ; 121 spécifications strictes"
          },
          {
            "label": "Debian",
            "proof": "Conteneurs dédiés supprimés ; preuves tasks.md.",
            "value": "Cycle jsvc, indépendance firmware, prérequis bureau idempotent et Zsh préservé"
          }
        ],
        "5": [
          {
            "label": "Sources",
            "proof": "Aucune mesure web exhaustive ajoutée aux compteurs natifs.",
            "value": "Code local, manuel APT, métadonnées APT et références Git"
          }
        ],
        "6": [
          {
            "label": "Suivi",
            "proof": "Même binding/session que le RUN SCM-apt-sources-recipes.",
            "value": "SGS 2.7.1 et snapshot natif gelé"
          }
        ]
      },
      "id": "01a1c6d4-6541-7fb1-82f3-997b307df2a2",
      "input_sha256": "2805313052f315649270db3c9b955de1a2828878aa5cacc58161e913c7b56dff",
      "native_telemetry": {
        "format": "cab-native-sgs-1",
        "sessions": [
          {
            "agent": "codex",
            "binding": "codex-19dc91ea4f25c04813c657a9ba4c754e83090294083bb9222f4a0e02ac150380",
            "cab_direct": true,
            "change": "declare-apt-sources-and-software-recipes",
            "collector": {
              "source": "codex-native",
              "status": "collecting"
            },
            "coverage": {
              "ccab_claimed": "unavailable",
              "ccab_open": "unavailable",
              "ccab_resolved_retained": "unavailable",
              "ccab_total_retained": "unavailable",
              "command_wall_seconds": "native",
              "commands": "native",
              "commands_api": "unavailable",
              "commands_failure": "native",
              "commands_success": "native",
              "compactions": "unavailable",
              "cost_usd": "unavailable",
              "duration_seconds": "unavailable",
              "files_touched": "partial",
              "generation_seconds": "unavailable",
              "message_span_seconds": "native",
              "messages": "native",
              "messages_assistant": "native",
              "messages_llm": "native",
              "messages_user": "native",
              "permissions": "unavailable",
              "preparation_seconds": "unavailable",
              "reasoning_span_seconds": "native",
              "tests": "unavailable",
              "tokens_cache_read": "native",
              "tokens_cache_write": "native",
              "tokens_input": "native",
              "tokens_output": "native",
              "tokens_reasoning": "native",
              "tokens_total": "native",
              "tool_wall_seconds": "native",
              "tools": "native",
              "tools_llm": "native",
              "ttft_seconds": "unavailable",
              "update_cutover_seconds": "unavailable",
              "update_preparation_seconds": "unavailable",
              "wait_seconds": "unavailable",
              "web": "unavailable",
              "web_open": "unavailable",
              "web_search": "unavailable",
              "writes": "partial"
            },
            "ended_at": "2026-11-11T13:05:01.258000+00:00",
            "events": 849,
            "host": "hvp1",
            "instance": "codex-01a1c6d4-6541-7fb1-82f3-997b307df2a2-uid1000",
            "metrics": {
              "command_wall_seconds": "1121.778",
              "commands": "149",
              "commands_failure": "13",
              "commands_success": "136",
              "files_touched": "27",
              "message_span_seconds": "27.548",
              "messages": "20",
              "messages_assistant": "18",
              "messages_llm": "25",
              "messages_user": "2",
              "reasoning_span_seconds": "2216.972",
              "tokens_cache_read": "84385792",
              "tokens_cache_write": "0",
              "tokens_input": "84504351",
              "tokens_output": "116818",
              "tokens_reasoning": "63337",
              "tokens_total": "84621169",
              "tool_wall_seconds": "30.056",
              "tools": "181",
              "tools_llm": "176",
              "writes": "42"
            },
            "mode": "direct",
            "models": [
              {
                "from": "2026-11-11T11:59:00.350000+00:00",
                "model": {
                  "name": "gpt-6.1-sol",
                  "provider": "openai",
                  "reasoning": "medium"
                },
                "source": "codex-native",
                "until": "2026-11-11T13:05:01.258000+00:00"
              }
            ],
            "project": "/home/devops/datas/diu",
            "role": "coder",
            "run": "SCM-apt-sources-recipes",
            "session": "01a1c6d4-6541-7fb1-82f3-997b307df2a2",
            "started_at": "2026-11-11T11:58:59.871Z"
          }
        ]
      },
      "notes": {
        "1": [
          "Codage direct sans orchestrateur. La fenêtre native débute après exploration ; les totaux du change non établis restent indisponibles."
        ],
        "6": [
          "Archive et spécifications vérifiées ; CICD 1.3.8 prévue après rapport. Tous les logiciels externes ne sont pas qualifiés par installation réelle."
        ]
      },
      "scope": "cumulative",
      "state": "archived",
      "tables": {
        "3": [
          {
            "columns": [
              "Chemin relatif",
              "Attribution"
            ],
            "rows": [
              [
                "CHANGELOG.md",
                "Production du change"
              ],
              [
                "DEVELOPMENT_MAP.md",
                "Production du change"
              ],
              [
                "DEVOPS.md",
                "Préexistant conservé"
              ],
              [
                "README.md",
                "Production du change"
              ],
              [
                "TECHNICAL.md",
                "Production du change"
              ],
              [
                "lib/diu-help.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/diu/diu_apt_repository_fd.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_apache2.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_chatgpt.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_crowdsec_agent.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_crowdsec_bouncer.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_fastfetch.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_jsvc.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_lemonldap.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_mongodb.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_omada.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_openjdk.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_openvswitch.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_postfix.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_postgresql.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_qemu_guest_agent.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_ssh_server.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_syncthing.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_syslog_client.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_syslog_server.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_wazuh_agent.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_wazuh_server.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_webmin.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_zoom.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_zsh.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_backport.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_contrib.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_nonfrfee.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_nonfrfee_firmware.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_sources.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_updates.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_unofficial.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-configuration.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-convergence.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-management.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-recipes.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-state.sh",
                "Production du change"
              ],
              [
                "modules/softwares/bootstrap.sh",
                "Production du change"
              ],
              [
                "modules/softwares/crowdsec-hooks.sh",
                "Production du change"
              ],
              [
                "modules/softwares/crowdsec-state.sh",
                "Production du change"
              ],
              [
                "modules/softwares/global-declarations.sh",
                "Production du change"
              ],
              [
                "modules/softwares/syslog-hooks.sh",
                "Production du change"
              ],
              [
                "modules/softwares/syslog-state.sh",
                "Production du change"
              ],
              [
                "modules/softwares/zsh_configuration.py",
                "Production du change"
              ],
              [
                "modules/system/apt-source-state.sh",
                "Production du change"
              ],
              [
                "modules/system/apt.sh",
                "Production du change"
              ],
              [
                "modules/system/apt_sources.py",
                "Production du change"
              ],
              [
                "modules/system/infos.sh",
                "Production du change"
              ],
              [
                "modules/system/software-versions.sh",
                "Production du change"
              ],
              [
                "openspec/BATCH_CODES.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/.openspec.yaml",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/design.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/inventory.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/proposal.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/review.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-software-declarations/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-source-initialization/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/software-management/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/system-debian-apt/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/tasks.md",
                "Production du change"
              ],
              [
                "openspec/specs/apt-software-declarations/spec.md",
                "Production du change"
              ],
              [
                "openspec/specs/apt-source-initialization/spec.md",
                "Production du change"
              ],
              [
                "openspec/specs/software-management/spec.md",
                "Production du change"
              ],
              [
                "openspec/specs/system-debian-apt/spec.md",
                "Production du change"
              ],
              [
                "root-install-debian.sh",
                "Production du change"
              ],
              [
                "tests/test_apt_recipe_sources.py",
                "Production du change"
              ],
              [
                "tests/test_apt_source_initialization.py",
                "Production du change"
              ],
              [
                "tests/test_crowdsec_api_key.py",
                "Production du change"
              ],
              [
                "tests/test_diu_command_links.py",
                "Production du change"
              ],
              [
                "tests/test_module_infos.py",
                "Production du change"
              ],
              [
                "tests/test_root_shellcheck.py",
                "Production du change"
              ],
              [
                "tests/test_software_apt_convergence.py",
                "Production du change"
              ],
              [
                "tests/test_software_global_declarations.py",
                "Production du change"
              ],
              [
                "tests/test_software_zsh_configuration.py",
                "Production du change"
              ],
              [
                "tests/test_system_apt_unofficial.py",
                "Production du change"
              ],
              [
                "tests/test_system_proxy.py",
                "Production du change"
              ]
            ],
            "title": "Fichiers de la livraison SCM"
          }
        ]
      }
    }
  ]
}
-->


## Change `declare-diu-variables-version-variable` — openspec/changes/archive/2026-11-02-declare-diu-variables-version-variable/STATISTICS.md


# Statistiques — declare-diu-variables-version-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `declare-diu-variables-version-variable`, code de lot non
  attribué.
- Contrat validé : `DIU_VARIABLES_VERSION`, `DYNAMIC`, `ENABLE`, scope `diu`;
  `variable_generator()` retourne la version du paquet Debian `diu` installé
  via `dpkg-query`, et échoue explicitement si elle est indisponible.
- L’ancienne valeur littérale `VERSION_VARIABLES` n’est pas transférée;
  `VERSION` demeure conservée.
- La suite complète de référence compte 1010 tests réussis, 2 ignorés et aucun
  échec avec `/home/devops/python/current/bin/python3`.
- Archivage réussi sous `2026-11-02-declare-diu-variables-version-variable`;
  trois exigences ajoutées et une modifiée dans deux spécifications.
- Publication réussie : paquet `2026.11.02.14.25`, commit `cb83983`, tag
  `v2026.11.02.14.25`, release Forgejo 401.
- Le paquet a été transféré dans CISMP (LXC 100), SHA-256 vérifié
  (`ee9ace47efe826927a119def4c44c2bce7bfc099fa3589846265dc7679c7e6dc`), puis
  la version installée a été vérifiée avec `dpkg-query`.
- Relance de `/root/diu/root-install-debian.sh` dans CISMP : code de sortie 0;
  les deux variables de version affichent `2026.11.02.14.25`, puis le script
  termine après la section réseau sans autre erreur de variable.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/diu/diu_variables_version.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_diu_variables_version.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`, `DEVOPS.md` régénéré par
  `ridu` après la publication précédente.
- Spécifications canoniques : ajout de `diu-variables-version`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  1010 tests réussis, 2 ignorés.
- Tests ciblés `tests.test_diu_variables_version` et
  `tests.test_config_cleanup` : 99 tests réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `/home/devops/.local/npm/bin/openspec validate declare-diu-variables-version-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive declare-diu-variables-version-variable --yes --json` :
  réussi; deux spécifications archivées.
- `git diff --check` : réussi.
- `sudo -n -i zsh -lic 'rcicddiu'` : publication réussie; release Forgejo 401.
- `sudo -n -i zsh -lic 'ridu'` : mise à jour de l’hôte réussie.
- Installation CISMP par `lxc-attach` après contrôle SHA-256 : réussie.
- Relance `/root/diu/root-install-debian.sh` dans LXC 100 : code 0.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le résumé DIU utilise désormais `DIU_VARIABLES_VERSION`, générée depuis la
version du paquet Debian installé. Le nettoyage retire sans évaluation
l’ancienne valeur littérale et bloque les expressions ambiguës. Les tests
ciblés, la suite complète de référence, ShellCheck, la syntaxe Bash et OpenSpec
stricte passent. Publication, installation LXC et nouveau cycle d’exécution
ont réussi. Le script d’installation a terminé sans autre erreur de variable.


## Change `declare-diu-version-variable` — openspec/changes/archive/2026-11-02-declare-diu-version-variable/STATISTICS.md


# Statistiques — declare-diu-version-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `declare-diu-version-variable`, code de lot non attribué.
- Contrat validé : `DIU_VERSION`, `DYNAMIC`, `ENABLE`, scope `diu`; sa
  fonction génératrice lit la version installée du paquet Debian `diu` avec
  `dpkg-query`.
- `VERSION_ALIAS` est retirée sans migration; `VERSION` et
  `VERSION_VARIABLES` sont conservées.
- La suite complète de référence compte 1005 tests réussis, 2 ignorés et aucun
  échec avec `/home/devops/python/current/bin/python3`.
- Archivage réussi sous `2026-11-02-declare-diu-version-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/diu/diu_version.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_diu_version.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `diu-version`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  1005 tests réussis, 2 ignorés.
- Tests ciblés `tests.test_diu_version` et `tests.test_config_cleanup` :
  97 tests réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `/home/devops/.local/npm/bin/openspec validate declare-diu-version-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive declare-diu-version-variable --yes --json` :
  réussi; deux spécifications archivées.
- `git diff --check` : réussi.
- `pytest -q` avec le Python système : 976 réussis, 2 ignorés, 26 échecs dans
  les tests de détection d’environnements virtuels de projet; l’interpréteur de
  référence `/home/devops/python/current/bin/python3` exécute toute la suite
  sans échec.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le résumé DIU utilise désormais `DIU_VERSION`, générée depuis la version du
paquet installé. L’ancienne affectation `VERSION_ALIAS` est supprimée sans
évaluation ni transfert, et les contrôles de syntaxe, ShellCheck, OpenSpec et
la suite complète de référence réussissent. La publication, l’installation
LXC et le nouveau cycle d’exécution restent à effectuer.


## Change `decouple-softwares-from-universal-update` — openspec/changes/archive/2026-11-05-decouple-softwares-from-universal-update/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé scm-decouple-softwares-20261105

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| non communiqué | N/A | N/A | non communiqué | N/A | N/A | N/A |

### Agents orchestrateurs — relevé scm-decouple-softwares-20261105

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé scm-decouple-softwares-20261105

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle non communiqué, raisonnement non communiqué.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Mandat | SCM direct ; périmètre et livraison validés, DEVOPS.md préexistant inclus. | Conversation développeur du 2026-11-05 |

## 2. Types de messages et d’outils

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Télémétrie | Comptes détaillés des messages et outils non disponibles ; aucune sonde de pilotage. | Session directe SCM |

## 3. Fichiers modifiés

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | Code, aides, cinq tests, spécifications, documentation, cartographie et registre du change. | Git diff et archive OpenSpec |

## 4. Commandes

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1211 | Sortie observée dans la session SCM du 2026-11-05 : tests |
| Tests finaux réussis | N/A | 1209 réussis et 2 ignorés : le moteur impose un total égal aux succès et échecs. |
| Tests finaux échoués | 0 | Sortie observée dans la session SCM du 2026-11-05 : tests_failure |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 5 | Sortie observée dans la session SCM du 2026-11-05 : openspec_strict_success |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | 4 | Sortie observée dans la session SCM du 2026-11-05 : tasks |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation finale | 1 211 tests exécutés, 2 ignorés ; 132 tests ciblés ; bash -n, ShellCheck et py_compile réussis. | unittest discover ; unittest ciblé ; contrôles de syntaxe |
| Incidents corrigés | Un test ciblé initialement échoué par régression de texte, corrigé ; appel validate multi-arguments refusé puis quatre validations unitaires réussies. | Sorties de commande |

## 5. Accès web

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | 0 | Sortie observée dans la session SCM du 2026-11-05 : web |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Web | Aucun accès web. | Journal de session |

## 6. Synthèse globale

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Archive | Change archivé et quatre spécifications synchronisées, chacune validée strictement ; livraison encore à vérifier. | openspec archive et validate --strict |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "non communiqué",
            "reasoning": "non communiqué",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : openspec_strict_success"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "5"
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : tasks"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "4"
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : tests"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1211"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : tests_failure"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [],
            "reason": "1209 réussis et 2 ignorés : le moteur impose un total égal aux succès et échecs.",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : web"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Mandat",
            "proof": "Conversation développeur du 2026-11-05",
            "value": "SCM direct ; périmètre et livraison validés, DEVOPS.md préexistant inclus."
          }
        ],
        "2": [
          {
            "label": "Télémétrie",
            "proof": "Session directe SCM",
            "value": "Comptes détaillés des messages et outils non disponibles ; aucune sonde de pilotage."
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Git diff et archive OpenSpec",
            "value": "Code, aides, cinq tests, spécifications, documentation, cartographie et registre du change."
          }
        ],
        "4": [
          {
            "label": "Validation finale",
            "proof": "unittest discover ; unittest ciblé ; contrôles de syntaxe",
            "value": "1 211 tests exécutés, 2 ignorés ; 132 tests ciblés ; bash -n, ShellCheck et py_compile réussis."
          },
          {
            "label": "Incidents corrigés",
            "proof": "Sorties de commande",
            "value": "Un test ciblé initialement échoué par régression de texte, corrigé ; appel validate multi-arguments refusé puis quatre validations unitaires réussies."
          }
        ],
        "5": [
          {
            "label": "Web",
            "proof": "Journal de session",
            "value": "Aucun accès web."
          }
        ],
        "6": [
          {
            "label": "Archive",
            "proof": "openspec archive et validate --strict",
            "value": "Change archivé et quatre spécifications synchronisées, chacune validée strictement ; livraison encore à vérifier."
          }
        ]
      },
      "id": "scm-decouple-softwares-20261105",
      "input_sha256": "8d30cac6db163a342477b27b0acd18c21b78496b8c64494e6e8e0296665b4192",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `define-modular-architecture` — openspec/changes/define-modular-architecture/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `disable-diu-psycopg-management` — openspec/changes/archive/2026-10-03-disable-diu-psycopg-management/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `disable-variable-globale-software-apt-codex-cli-home` — openspec/changes/archive/2026-09-06-disable-variable-globale-software-apt-codex-cli-home/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `display-software-inventory` — openspec/changes/archive/2026-11-05-display-software-inventory/STATISTICS.md


# Statistiques — inventaire des logiciels

## 1. Statistiques générales et décisions

Session SCM directe du 2026-11-05, réalisée par Codex après validation du périmètre. Aucun pilotage ni sous-agent. Modèle exact, durée globale, consommation de tokens et coût : N/A, mesures non collectées. Aucun commit, déploiement, publication ni CI/CD.

Code de lot non attribué : attribution et normalisation définitive des sous-lots à traiter ultérieurement par ACL.

## 2. Types de messages et d’outils

Lecture, modification et commandes locales via les outils de la session. Aucune navigation web. Nombre exhaustif de messages, appels d’outils, autorisations et écritures : N/A, absence de télémétrie exhaustive.

## 3. Fichiers modifiés

Code et tests : `root-install-debian.sh`, `lib/diu-help.sh`, `modules/softwares/infos.sh`, `tests/test_module_infos.py`. Documentation et cadrage : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`. Spécifications : `module-infos`, `diu-help` et `software-inventory`. Le change et ses rapports complètent ce périmètre. Voir [review.md](review.md) pour les détails et limites.

## 4. Commandes et validations

- Syntaxe Bash et ShellCheck réussis ; compilation Python réussie.
- Tests ciblés : 19 informations de modules et 61 aides réussis.
- Premier lancement global : 1 177 tests, 2 ignorés, 1 échec et 2 erreurs dans un même test de génération DevOps dont une fixture avait des permissions incompatibles ; reprise isolée réussie.
- Second lancement global : 1 179 tests, 1 177 réussis, 2 ignorés, aucun échec ni erreur, en 289,934 s. Seul ce lancement constitue le bilan final, sans additionner les tests ciblés déjà inclus.
- OpenSpec strict : change, `module-infos` et `diu-help` validés. Le contrôle global strict présente 47 échecs ; 47 échecs étaient également observés lors de la session précédente.
- Un répertoire temporaire `.diu-test-devops-w_p2t73i` reste présent avec des éléments appartenant à `devops` ; ses permissions n’ont pas été forcées.

Nombre exhaustif de commandes et leur ventilation : N/A, absence de collecte exhaustive. L’archivage `2026-11-05-display-software-inventory` a réussi et ses spécifications ont été synchronisées.

## 5. Accès web

Aucun appel d’outil de recherche ou de consultation web : 0. Les moteurs logiciels sont détectés localement, sans requête réseau.

## 6. Synthèse globale

La vue présente les moteurs en colonnes et les logiciels déclarés avec leurs états colorés. `diu infos`, `diu infos softwares` et `diu softwares infos` partagent l’affichage. La clé API et les noms de variables ne sont pas affichés. Bilan final : 1 179 tests = 1 177 réussis + 2 ignorés, aucun échec ni erreur. Voir [review.md](review.md).

Archivage et synchronisation réussis le 2026-11-05. Si `STATISTICS.md` global est absent, mandater SGS pour le générer ; ne pas le créer automatiquement.


## Change `diu-command-links` — openspec/changes/archive/2026-11-04-diu-command-links/STATISTICS.md


# Statistiques — diu-command-links

Change archivé le 2026-11-04 ; blocages antérieurs résolus. Session directe SCM du 2026-11-04.

## Statistiques générales et décisions

Un agent direct ; deux liens prévus. Durée et quotas : N/A, non mesurés.

## Types de messages et d’outils

N/A : aucune télémétrie exhaustive disponible.

## Fichiers modifiés

Code, tests, documentation, change OpenSpec, cartographie et registre ciblés ; total exact N/A en présence de modifications concurrentes préexistantes.

## Commandes

88 tests ciblés réussis ; contrôles Bash, compilation Python, ShellCheck -x et validation OpenSpec stricte réussis. ShellCheck brut a signalé SC1091 après une modification concurrente.

## Accès web

Aucun accès web effectué.

## Synthèse globale

Réalisation partielle testée localement ; dépendance et validation globale en attente. Aucun paquet installé, commit, push ou archivage.

Reprise du 2026-11-04 : suite complète réussie avec le Python DevOps, 1 160 tests dont 2 ignorés ; 194 tests ciblés réussis. Mesures d’autres sessions : N/A ; aucun total cumulé inventé. Change alors ouvert ; blocages historiques résolus.

Reprise du 2026-11-04 à 08:50 UTC : 127 tests ciblés réussis ; ShellCheck
réussi. Validation globale : 1 163 tests exécutés, dont 2 ignorés et un échec
dans un change concurrent de packaging. Vérification complémentaire : 17 tests
réussis. Les totaux de sessions distinctes ne sont pas additionnés. Change alors ouvert ; blocages historiques résolus.

Archivage du 2026-11-04 : les trois exigences sont synchronisées ; 1 164
tests exécutés dont 2 ignorés, ShellCheck réussi. Les blocages antérieurs sont
résolus. L’archivage ne prouve pas l’installation sur une machine cible.


## Change `diu-package-update` — openspec/changes/archive/2026-11-03-diu-package-update/STATISTICS.md


# Statistiques — diu-package-update

## Statistiques générales et décisions

- Session directe SCM du 2026-11-03 ; change `diu-package-update`, code non attribué, archivé le 2026-11-03.
- La mise à jour DIU précède les autres modules ; l'alias historique est conservé et les releases publiques configurées sont comparées selon les versions Debian.
- Version projet : 1.0.4. Aucune mise à jour réelle du paquet DIU n'a été exécutée.
- Durée, nombre de tours et consommation de tokens : N/A, mesures complètes non disponibles.

## Types de messages et d'outils

- Session exécutée directement par Codex, sans délégation ni télémétrie de pilotage.
- Décomptes exhaustifs des messages, appels et approbations : N/A, journal complet non disponible.

## Fichiers modifiés

- Implémentation et routage : `modules/diu/update.sh`, `modules/diu/update-all.sh`, `root-install-debian.sh`, `lib/rid-help.sh`.
- Tests : `tests/test_diu_package_update.py`, `tests/test_projects_general_update.py`, `tests/test_rid_help.py`, `tests/test_software.py`.
- Documentation : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`.
- OpenSpec : présent change archivé et spécifications `diu-package-update` et `universal-update`.
- Configuration locale : seule la valeur `PROJECT_VERSION` de `project.env` a été modifiée. Total exhaustif et volume de lignes : N/A, inventaire Git non consulté pendant la réalisation.

## Commandes

- Suite complète avec Python DevOps : 1 080 tests exécutés, dont 2 ignorés ; durée 253,417 s. Une première exécution avec Python 3.13 a été interrompue après erreurs de préparation de venv ; le cas isolé réussit avec Python DevOps 3.14.
- Vérifications ciblées : 117 tests réussis ; syntaxe Bash, ShellCheck et compilation Python réussis.
- Validation stricte OpenSpec du change et des deux spécifications réussie. Archivage effectué et spécifications synchronisées. Les contrôles utilisent des réponses et installations simulées.
- Total exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

Aucune recherche web effectuée par l’agent. Les requêtes de mise à jour du DIU dans les tests ciblés ont été simulées ; le décompte exhaustif des accès réseau de la suite globale est N/A.

## Synthèse globale

Implémentation, documentation et validation technique terminées ; change archivé. Aucun résultat d'installation ni de publication ne découle de ces tests. La publication Git éventuelle relève de la clôture SCM et n'est pas attestée par ce rapport.


## Change `document-devops-docker-test-reference` — openspec/changes/archive/2026-10-22-document-devops-docker-test-reference/STATISTICS.md


# STATISTIQUES — Références Docker dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date de session et d'archive : 22 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, périmètre explicitement validé par le développeur.
- Change : `document-devops-docker-test-reference`.
- Archive : `2026-10-22-document-devops-docker-test-reference`.
- Objet : compléter la rubrique Docker générée par son titre explicite,
  `/var/run/docker.sock` et `debian:stable-slim`.
- Preuves : sorties de commandes de la session, tâches cochées après
  validation, contrôles ciblés et [review.md](review.md).

Le rapport n'utilise aucune compétence de télémétrie SCMP, aucun service CAB
et aucune session OpenCode pilotée. Il décrit les observations disponibles.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Durée complète de session | N/A : aucun chronométrage global initialisé |
| Première suite, Python système 3.13.5 | 51,142 s, durée fournie par unittest |
| Suite finale, Python DevOps 3.14.9 | 61,508 s, durée fournie par unittest |
| Total des durées unittest observées | 112,650 s = 51,142 + 61,508 ; hors exploration, édition, lint et OpenSpec |
| Tokens, coût et ressources machine | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages ou appels d'outils | N/A : aucun export de télémétrie de session |
| Approbations CAB | N/A : protocole CAB non applicable à cette session SCM directe |

## 3. Fichiers et contrat livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 6 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; review.md ; STATISTIQUES.md |
| **Total final du périmètre** | **12** | **1 + 1 + 3 + 1 + 6** |

Six fichiers existants sont modifiés et six documents d'archive sont créés.
Les cinq artefacts actifs sont déplacés par OpenSpec, puis le présent rapport
est ajouté. Aucun fichier préexistant n'est supprimé ou renommé par la session.

Le rendu comporte quatre puces après le titre
`Docker, pour tests nécessitant des droits root` : version détectée ou
diagnostic, chemin du binaire ou diagnostic, `/var/run/docker.sock`,
`debian:stable-slim`. Les références restent présentes si Docker est absent
ou défaillant. Les autres rubriques, sondes et interfaces sont conservées ;
la version documentaire reste `0.6`.

Les cinq témoins inchangés sont AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et
openspec/config.yaml. Le générateur retrouve son empreinte initiale en
remplaçant en mémoire uniquement la fonction de rendu modifiée. Les dix
empreintes de fichiers existants figées avant archivage sont conservées
par celui-ci. Les 38 exigences canoniques hors modification sont identiques.

## 4. Tests et vérifications

| Exécution unittest | Méthodes | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Première suite, Python système | 89 | 80 | 0 | 9 | 0 |
| Suite finale, Python DevOps | 89 | 89 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **178** | **169** | **0** | **9** | **0** |

Ces 178 exécutions couvrent 89 méthodes distinctes ; les sous-tests ne sont
pas comptés comme des méthodes supplémentaires. Les neuf erreurs initiales
`StopIteration` proviennent des chemins de paquets des fixtures venv sous le
Python système. Une reproduction isolée confirme ce décalage ; la suite
finale réussit avec le Python DevOps déclaré dans DEVOPS.md, sans modification
des fixtures venv. Les commandes exactes figurent dans review.md.

| Autre contrôle | Résultat |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, zéro diagnostic |
| Compilation Python du test modifié | Exécutée et réussie sous les deux interpréteurs, caches temporaires supprimés |
| Change OpenSpec strict | Trois validations réussies ; une tentative initiale échouée pour longueur de rédaction, corrigée avant implémentation |
| Spécification canonique, validation ordinaire | Exécutée et réussie avant et après synchronisation, avec huit avertissements préexistants |
| Spécification canonique, validation stricte | Exécutée et échouée avant et après synchronisation pour les mêmes huit avertissements de longueur, indices 0, 2, 4, 6, 7, 8, 9 et 10 |
| Synchronisation ciblée | Exécutée et vérifiée : 39 exigences initiales, 40 finales, une ajoutée et une modifiée |
| Cohérence documentaire | Revue par fichier consignée dans review.md |
| UTF-8/LF, absence de BOM, six sections, tâches et totaux | Contrôle local final effectué après écriture du rapport, résultat consigné dans review.md |
| Docker réel, disponibilité du socket ou de l'image | Non exécutés : références documentaires ; seules les sondes simulées sont utilisées dans les tests |

Aucun test ni règle de validation n'a été désactivé ou affaibli. Le faux
binaire Docker accepte uniquement l'argument `--version`. Le code de rendu
ajoute des chaînes fixes et ne sonde pas le socket, ne télécharge ni ne
lance de conteneur, et ne modifie aucune permission.

## 5. Résultats et archivage

Commande exécutée avec le PATH Node DevOps explicite :

```bash
/home/devops/.local/npm/bin/openspec archive document-devops-docker-test-reference --yes
```

Elle retourne zéro, annonce les tâches complètes, synchronise la spécification
et crée l'archive ciblée. L'absence du change actif et la présence des cinq
artefacts archivés sont vérifiées avant création du rapport.

| Résultat OpenSpec | Nombre |
| --- | ---: |
| Tâches élémentaires validées séparément | 2 sur 2 |
| Exigences ajoutées | 1 |
| Exigences modifiées | 1 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Changes archivés dans cette session | 1 |

Le présent fichier constitue le sixième document de l'archive. Aucun autre
change n'est archivé. Les écritures restent dans le périmètre approuvé.
Aucun commit, push, branche, tag, release, installation ou action Docker
réelle n'est effectué. Aucun état Git n'est inspecté pendant la session SCM.

## 6. Limites et suites

L'évolution est implémentée, vérifiée et archivée. Les huit avertissements
canoniques de longueur préexistants demeurent hors périmètre et empêchent
toujours la validation stricte du document canonique complet ; le delta ciblé
est strictement valide et la validation canonique ordinaire réussit.

Le changement de titre peut affecter un consommateur recherchant exactement
`# Docker`. Le tag `debian:stable-slim` suit Debian stable sans figer de version
ou de digest. Ces références ne démontrent ni la présence ni le fonctionnement
du socket ou de l'image.

Le DEVOPS.md existant n'est pas régénéré et la production n'est pas mise à
jour. Les documents adopteront le nouveau rendu à leur prochaine génération
normale avec les sources modifiées. Aucun autre change ni correction des
écarts rédactionnels antérieurs n'est engagé.


## Change `document-devops-opencode-password-source` — openspec/changes/archive/2026-10-28-document-devops-opencode-password-source/STATISTICS.md


# STATISTIQUES — Source du mot de passe API OpenCode dans DEVOPS.md

## 1. Identification et périmètre

Projet : Debian Installeur Unifié (`diu`). Session SCM directe, le 28 octobre 2026.
Archive : `2026-10-28-document-devops-opencode-password-source`.
Ajout d'une puce statique après le chemin OpenCode ; spécification, test existant,
documentation et clôture associés. Extension : remise en forme de huit exigences
canoniques trop longues, sans changement de leur texte normatif ni suppression
de scénario existant. Aucun pilotage, CAB ou sous-agent.

## 2. Mesures disponibles

| Mesure | Résultat et preuve |
| --- | --- |
| Test ciblé de structure | 1 réussi en 0,408 s, sortie unittest |
| Suite de génération complète | 152 tests en 170,699 s : 150 réussis, 2 ignorés, 0 échec |
| Cas ignorés | Go réel absent ; tests Go et enveloppe runuser nécessitant ce binaire |
| Exigences longues remises en forme | 8 ; répartition avec 10 sous-exigences courtes |
| Delta synchronisé par archivage | 1 exigence ajoutée, 0 modifiée, 0 supprimée, 0 renommée |
| Durée totale, jetons et coût | N/A : pas de télémétrie qualifiée de la session complète |
| Approbations CAB et appels web | Non applicable : session directe, aucun appel web |

Le test ciblé appartient aux 152 tests ; les deux exécutions ne sont pas additionnées.

## 3. Fichiers et comportement livré

Après nettoyage du bilan résolu, dix fichiers constituent le livrable : cinq
sources/documents et cinq fichiers d'archive.

- `modules/projects/template.sh` : helper commun ajoutant exactement la puce demandée après le chemin OpenCode, avant les dépendances éventuelles.
- `tests/test_projects_template_devops.py` : test existant complété pour le bloc exact et l'unicité de la puce.
- `TECHNICAL.md` : rendu, position et limites documentés.
- `CHANGELOG.md` : entrée Unreleased.
- `openspec/specs/projects-template-devops/spec.md` : huit exigences remises en forme et delta OpenCode synchronisé.
- Archive : `proposal.md`, `design.md`, `tasks.md`, `specs/projects-template-devops/spec.md`, présent `STATISTIQUES.md`.

Le bilan historique `BLOCKERS.md`, créé pendant la suspension, est supprimé
après vérification de ce rapport selon SCM. Aucun autre fichier n'est supprimé.
Le DEVOPS.md préexistant est préservé, sans édition ou régénération par cette
session. Le commit complet du projet prévu par SCM peut inclure cet état préexistant.

## 4. Validations et preuves

| Commande ou contrôle | Résultat |
| --- | --- |
| `python3 -B tests/test_projects_template_devops.py ProjectsTemplateDevopsTests.test_generation_structure_versions_and_executable_paths -v` avec Python DevOps | Réussi, 1 test |
| `/home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py -v` | Réussi, 152 tests dont 2 ignorés |
| `bash -n modules/projects/template.sh` | Réussi |
| `shellcheck modules/projects/template.sh` | Réussi, aucun diagnostic |
| `/home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py` | Réussi |
| `openspec validate document-devops-opencode-password-source --strict --no-interactive` | Réussi avant code et avant archivage |
| `openspec validate projects-template-devops --type spec --strict --no-interactive` | Échec initial sur huit textes de plus de 500 caractères ; réussi après leur remise en forme et après archivage |
| `openspec archive document-devops-opencode-password-source --yes --json` | Réussi, `specsUpdated=true`, 1 exigence ajoutée |
| UTF-8/LF et intégrité documentaire | Vérifiés sur sources et artefacts ; rapport et nettoyage contrôlés avant commit |

OpenSpec est exécuté via `/home/devops/.local/npm/bin/openspec`.
La première transformation préparatoire a été arrêtée par une assertion avant
écriture (nombre de sous-exigences navigateurs) ; le découpage corrigé a ensuite
été appliqué et validé. Aucune validation n'a été contournée.

La remise en forme conserve les textes normatifs mot pour mot hors espaces,
vérifiés par assertions lors de la transformation. SHA-256 canonique avant :
`52feebb389024d5a9eb75dc7d33b7bb4eb7bb59f18670efd44a43f601c027a51` ;
après remise en forme avant ajout du delta :
`8e7b405226c4721126539fc5d5fd08491a4b8bf7fb3dd3cc46a4fb3039e132fc`.
Les preuves des tests sont conservées à la reprise : aucun code ni test n'a
changé depuis leur exécution réussie. La suite complète des autres fonctionnalités
du dépôt n'est pas exécutée, hors périmètre de cet ajout documentaire.

## 5. Cohérence documentaire

| Document | État et justification |
| --- | --- |
| Projet réel | Helper de rubrique OpenCode et test de structure cohérents ; texte statique sans consultation de configuration pour cet ajout |
| AGENTS.md | Inchangé, règles d'agents sans modification |
| PROJECT.md | Inchangé, architecture et rôles de développement préservés |
| TECHNICAL.md | Mis à jour dans « Traçabilité du document DevOps » |
| BUILD.md | Inchangé, construction et packaging Debian sans changement |
| DEVOPS.md | Inchangé par cette session, rubrique OpenCode déjà conforme à la demande |
| README.md | Inchangé, présentation de la génération au format 0.7 toujours exacte ; détail porté par TECHNICAL.md |
| CHANGELOG.md | Mis à jour dans Unreleased |
| openspec/config.yaml | Inchangé, schéma spec-driven conservé |
| openspec/specs/ | Spécification concernée validée strictement après synchronisation ; autres capacités inchangées |
| Change | Archivé avec toutes les tâches cochées, blocage documentaire résolu |

## 6. Limites et clôture

L'ajout ne lit pas OPENCODE_PASSWORD ou project.env ; il indique une source
conventionnelle sans prouver la présence d'un mot de passe ou le fonctionnement
de l'API. Versions sondées, chemins, format 0.7 et autres rubriques conservés.
Aucun secret réel reçu ou reproduit. Aucun déploiement ni test réel de l'API.
Les deux tests Go ignorés restent explicitement signalés.

L'archive et son rapport précèdent les étapes Git conditionnelles SCM.
Le résultat du commit, du tag et de chaque publication est vérifié puis restitué
dans le bilan de session ; leur réussite n'est pas anticipée par ce rapport.


## Change `enforce-provider-version-authority` — openspec/changes/archive/2026-11-10-enforce-provider-version-authority/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : increment.

Agent coder : codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Objectif | Autorité des tags et écrasement sous lease | Change OpenSpec archivé |
| Collecte | Suivi direct enregistré tardivement ; gel indisponible | Session directe |

## 2. Types de messages et d’outils

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Messages et outils | N/A : mesures exhaustives non disponibles | Session directe |

## 3. Fichiers modifiés

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | Code, tests, aides, documentation et spécifications | Diff du projet |

## 4. Commandes

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation globale | 1 236 tests exécutés, 2 ignorés, aucun échec | python3 -m unittest discover -s tests |
| Autres contrôles | Bash, ShellCheck et OpenSpec strict réussis | Sorties des commandes |

## 5. Accès web

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Web | N/A : mesure exhaustive indisponible | Session directe |

## 6. Synthèse globale

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Livraison | CI/CD prévue après archivage et contrôles finaux | État de session |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Objectif",
            "proof": "Change OpenSpec archivé",
            "value": "Autorité des tags et écrasement sous lease"
          },
          {
            "label": "Collecte",
            "proof": "Session directe",
            "value": "Suivi direct enregistré tardivement ; gel indisponible"
          }
        ],
        "2": [
          {
            "label": "Messages et outils",
            "proof": "Session directe",
            "value": "N/A : mesures exhaustives non disponibles"
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Diff du projet",
            "value": "Code, tests, aides, documentation et spécifications"
          }
        ],
        "4": [
          {
            "label": "Validation globale",
            "proof": "python3 -m unittest discover -s tests",
            "value": "1 236 tests exécutés, 2 ignorés, aucun échec"
          },
          {
            "label": "Autres contrôles",
            "proof": "Sorties des commandes",
            "value": "Bash, ShellCheck et OpenSpec strict réussis"
          }
        ],
        "5": [
          {
            "label": "Web",
            "proof": "Session directe",
            "value": "N/A : mesure exhaustive indisponible"
          }
        ],
        "6": [
          {
            "label": "Livraison",
            "proof": "État de session",
            "value": "CI/CD prévue après archivage et contrôles finaux"
          }
        ]
      },
      "id": "01a1c4e3-9664-7ab3-902a-0e0e1b04135c",
      "input_sha256": "2204ead80a1a6b8660022a5e555aae888e0e99c87ca7b8060fdbcd7be527b168",
      "scope": "increment",
      "state": "archived"
    }
  ]
}
-->


## Change `ensure-debian-components-on-global-update` — openspec/changes/archive/2026-09-05-ensure-debian-components-on-global-update/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `ensure-devops-tool-executable-permissions` — openspec/changes/archive/2026-10-23-ensure-devops-tool-executable-permissions/STATISTICS.md


# STATISTIQUES — Préparation des exécutables DevOps avant le relevé des versions

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 23 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, périmètre autonome explicitement validé après
  proposition, avec implémentation, tests, documentation, archivage et rapport.
- Change : `ensure-devops-tool-executable-permissions`.
- Archive : `2026-10-23-ensure-devops-tool-executable-permissions`.
- Objet : préparer les droits d'exécution des sept outils DevOps connus
  avant les inventaires et sondes, sans installation ni parcours récursif.
- Sources de preuve : commandes et sorties de cette session,
  [tasks.md](tasks.md), [design.md](design.md) et
  [delta OpenSpec](specs/projects-template-devops/spec.md).

La session est exécutée directement. La compétence de télémétrie réservée aux
sessions SCMP n'est pas invoquée ; aucun pilotage CAB/OpenCode n'est lancé.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Capture des empreintes initiales | 2026-10-23T13:07:29.104Z |
| Point de mesure avant le rapport | 2026-10-23T13:20:36.250Z |
| Intervalle partiel mesuré | 787,146 s entre ces deux points ; hors exploration antérieure et contrôles suivant ce point |
| Durée globale complète | N/A : les échanges précédant cette reprise ne sont pas chronométrés globalement |
| Première suite unittest | 77,476 s ; 113 méthodes, un échec |
| Suite unittest finale | 77,948 s ; 113 méthodes, toutes réussies |
| Total des durées unittest | 155,424 s = 77,476 + 77,948 ; hors édition, lint et OpenSpec |
| Tokens, coût, CPU et mémoire | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie |
| Approbations CAB | N/A : SCM directe, sans protocole CAB |

## 3. Fichiers et contrat livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 5 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **11** | **1 + 1 + 3 + 1 + 5** |

Six fichiers existants sont modifiés et cinq documents sont présents dans
l'archive finale. Les quatre artefacts du change actif ont été déplacés par
OpenSpec ; le rapport a été ajouté ensuite. Aucun fichier préexistant hors
de ce déplacement OpenSpec n'est supprimé ou renommé.

La préparation traite uniquement, sous `/home/${ENV_DEVOPS_USER}` :

- `go/current/bin/go` ;
- `node/current/bin/node` ;
- `node/current/bin/npm` ;
- `.opencode/bin/opencode` ;
- `.local/npm/bin/openspec` ;
- `python/current/bin/python3` ;
- `python/current/bin/pip3`.

Elle ajoute les bits `ugo+x` manquants, conserve propriétaire et droits de
lecture et d'écriture, et ne réapplique pas chmod si les trois bits sont
déjà présents. Les liens sont conservés et leur cible ordinaire est confinée
au domicile canonique. Les outils absents ne sont pas créés ; les cibles
externes ou non ordinaires et les erreurs de préparation bloquent le rendu.
Le document précédent reste conservé ; les droits déjà ajoutés persistent
si une étape suivante échoue. Les sondes directes distinguent binaire absent
et binaire présent non exécutable sans corriger ses droits elles-mêmes.

Les outils hôte, les autres fichiers, le format documentaire 0.6, les
commandes, les utilisateurs et interpréteurs de sonde ainsi que la borne de
15 secondes sont préservés. Les parcours individuel, groupé et de création
utilisent le même rendu. Le code ne déploie pas cette modification dans
l'installation de production.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Première suite | 113 | 112 | 1 | 0 | 0 |
| Suite finale après correction de l'isolation | 113 | 113 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **226** | **225** | **1** | **0** | **0** |

Les 113 méthodes distinctes ont toutes réussi lors de la dernière exécution :
103 préexistantes et 10 nouvelles. Les sous-tests ne sont pas comptés comme
méthodes supplémentaires.

La nouvelle couverture vérifie les sept outils sans droit d'exécution avant
l'inventaire JavaScript et les versions, les propriétaires et modes, les
fichiers hôte et non listés, l'idempotence sans modification de ctime, les
liens de fichiers et de dossiers `current` internes, les liens externes, les
objets non ordinaires, les absences et liens cassés internes, les refus de
chmod, les erreurs de résolution et de lecture de mode, et les diagnostics
des sondes directes.

Commande de suite exécutée deux fois :

```bash
env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py
```

| Contrôle | État et résultat réellement observé |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, aucun diagnostic |
| Compilation du test Python | Exécutée et réussie avant les tests et après la correction de l'isolation, via py_compile.compile avec doraise=True ; cfile temporaire sous la racine, automatiquement nettoyé |
| Change OpenSpec strict avant le code | Première tentative échouée pour longueur d'exigence ; texte réparti en quatre exigences puis validation réussie avant toute écriture de code et de test |
| Change OpenSpec strict avant archivage | Exécuté et réussi |
| Delta archivé final en mode strict | Exécuté et réussi dans une fixture temporaire isolée, avec le canon initial reconstruit et vérifié par les empreintes de ses 45 exigences ; fixture nettoyée |
| Validation directe par l'ancienne commande change validate sur un chemin d'archive | Exécutée et échouée : archive non reconnue comme change actif ; remplacée par la validation isolée ci-dessus, sans réarchivage |
| Canon OpenSpec ordinaire | Exécuté et réussi avant et après synchronisation ; huit avertissements de longueur identiques |
| Contrôle OpenSpec global strict avant archivage | Exécuté et échoué : 46 éléments valides, 22 en échec, total 68 incluant le change actif |
| Contrôle global strict immédiatement après archivage | Exécuté et échoué : 45 éléments valides, 22 en échec ; un avertissement de longueur supplémentaire dans l'exigence modifiée a été détecté puis corrigé |
| Contrôle global strict final | Exécuté et échoué : 45 éléments valides, 22 en échec, total 67 ; les huit avertissements du canon initial sont retrouvés sans nouvel avertissement |
| Synchronisation du canon | Contrôle réussi : 45 exigences initiales, 49 finales ; quatre ajoutées, une modifiée, 44 préservées ; les cinq blocs du delta correspondent au canon final |
| Empreintes et périmètre | Contrôle réussi sur 77 fichiers de référence : six modifications prévues, 71 fichiers inchangés ; huit empreintes figées avant archivage restent identiques, le delta ayant reçu la correction rédactionnelle décrite |
| UTF-8/LF, absence de BOM | Contrôle réussi sur les dix fichiers avant le rapport ; contrôle final incluant le onzième fichier |
| Temporaires de test et compilation | Aucun résidu des préfixes propres à cette session |
| Installation de production, autres modules, test de génération sur le domicile réel | Non exécutés : hors périmètre |

Tous les appels OpenSpec utilisent explicitement le Node DevOps
`/home/devops/node/current/bin/node` et le programme
`/home/devops/.local/npm/bin/openspec`, avec `OPENSPEC_TELEMETRY=0`.
Les validations emploient `validate`, `--type change`, `--type spec`,
`--strict`, `--all` et `--json` selon le contrôle.

Un premier contrôle auxiliaire d'extraction d'empreintes a échoué en raison
d'une expression régulière trop large et d'une sortie tronquée. Il a été
corrigé et repris en lecture seule ; les contrôles finaux ci-dessus sont
réussis.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Fonction prepare_executables appelée dans le rendu après la capture temporelle et avant inventaires et sondes ; 113 méthodes distinctes réussies |
| AGENTS.md | Inchangé, empreinte et mode conservés ; périmètre approuvé, rapport d'archive et encodage respectés ; incident de test extérieur explicité en section 6 |
| PROJECT.md | Inchangé, empreinte et mode conservés ; responsabilités du module projects et architecture préservées |
| TECHNICAL.md | Mis à jour dans Traçabilité du document DevOps : sept outils, confinement, droits, échecs et reprise |
| BUILD.md | Inchangé, empreinte et mode conservés ; aucun changement de construction, dépendance ou installation |
| DEVOPS.md | Inchangé, empreinte et mode conservés ; aucune régénération du document courant, conformément au périmètre validé |
| README.md | Mis à jour dans la présentation de la génération DevOps : préparation, limites et adoption à la prochaine génération |
| CHANGELOG.md | Entrée Unreleased ajoutée, sans version ou date de publication inventée |
| openspec/specs/ | projects-template-devops synchronisée ; quatre exigences ajoutées, Écriture limitée et robuste modifiée pour autoriser la préparation connue hors du projet ciblé ; 44 exigences préservées |

Commande d'archivage réellement exécutée :

```bash
env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive ensure-devops-tool-executable-permissions --yes
```

Elle retourne zéro, confirme les tâches complètes, synchronise quatre ajouts et
une modification, puis annonce l'archive ciblée. Le change actif est absent
et les quatre artefacts archivés sont présents avant création du rapport.
Aucun autre change n'est archivé et aucun réarchivage n'est effectué.

L'exigence modifiée de 661 caractères produisait après synchronisation un
avertissement de longueur supplémentaire. Sa formulation a été ramenée à
498 caractères dans le canon et le delta archivé, sans changer le contrat ni
les scénarios. Le delta final a ensuite été validé strictement dans la fixture
isolée et sa concordance avec le canon a été vérifiée.

| Résultat | Nombre |
| --- | ---: |
| Tâches préalables cochées | 6 sur 6 |
| Exigences ajoutées | 4 |
| Exigences modifiées | 1 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Changes archivés | 1 |
| Documents finaux dans l'archive | 5 |

Les opérations d'archivage et de rapport sont décrites séparément des tâches
préalables pour éviter de les cocher avant leur réalisation. Le contrôle
final du rapport vérifie six sections, 11 fichiers, les totaux
226 = 225 + 1 + 0 + 0, 113 = 103 + 10 et 49 = 45 + 4, les six tâches cochées,
les empreintes témoins, l'encodage et l'absence de temporaires.

## 6. Limites, incident et état terminal

Le périmètre demandé est implémenté, testé, documenté, synchronisé et archivé.
Le contrôle global strict du dépôt reste en échec sur 22 éléments préexistants :
19 spécifications avec avertissements, un ancien change d'architecture avec
avertissement et deux anciens changes Forgejo omettant des scénarios du canon
(`modify-projects-forgejo-push-force-with-lease` et
`restore-forgejo-push-to-create`). Ces éléments restent hors périmètre.
Le canon ciblé est valide en mode ordinaire, avec ses huit avertissements de
longueur préexistants ; le delta final est valide en mode strict.

Lors de la première suite, un test préexistant de chemins de prompts simulait
l'identité DevOps mais conservait le domicile réel. La nouvelle préparation
a donc transitoirement passé le mode de l'OpenCode installé de 664 à 775,
avant l'échec du sous-test utilisant le domicile inexistant ci-builder.
Le mode initial 664 a été immédiatement restauré. Les six autres outils
réels possédaient déjà leurs trois bits d'exécution et ont conservé des
métadonnées de changement antérieures à la session. Le ctime d'OpenCode a été
modifié par cet ajout puis sa restauration et ne peut pas être rétabli.

Le test de chemins isole désormais la préparation, comme il isolait déjà les
sondes et identités ; ses assertions de chemins sont conservées. Les dix
nouveaux tests exercent la préparation réelle sur leurs seules fixtures dans
le dépôt. La suite complète finale réussit et le mode réel OpenCode 664 a été
revérifié. Aucun processus OpenCode n'a été lancé, fermé ou redémarré.

DEVOPS.md courant n'est pas régénéré et l'installation de production n'est
pas mise à jour. Les prochaines générations utilisant ces sources prépareront
les droits comme décrit. Aucun état Git n'est inspecté et aucun commit, push,
branche, tag ou release n'est créé. Aucun service partagé n'est modifié.



## Change `ensure-diu-link-at-startup` — openspec/changes/archive/2026-11-04-ensure-diu-link-at-startup/STATISTICS.md


# Statistiques — ensure-diu-link-at-startup

Change archivé le 2026-11-04 après session SCM directe.

## Statistiques générales et décisions

Un agent direct ; vérification du lien de production au démarrage. Durée et quotas : N/A, non mesurés.

## Types de messages et d’outils

N/A : télémétrie exhaustive indisponible.

## Fichiers modifiés

Point d’entrée, tests ciblés, documentation, spécification, cartographie et registre. Comptage de lignes : N/A.

## Commandes

Suite complète : 1 165 tests exécutés, dont 2 ignorés, sans échec. Tests ciblés : 65 réussis. Syntaxe Bash, ShellCheck, compilation Python et OpenSpec strict réussis.

## Accès web

Aucun accès web pour l’implémentation et la validation.

## Synthèse globale

Contrôle au démarrage implémenté et archivé. Vérifications isolées ; aucune installation sur la machine réelle. Les privilèges root et chemins système sont simulés dans le test de démarrage.


## Change `ensure-projects-git-commit-init` — openspec/changes/ensure-projects-git-commit-init/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `error-softwares-apt-chatgpt-state` — openspec/changes/archive/2026-09-06-error-softwares-apt-chatgpt-state/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `error-softwares-remove-github-codex-cli` — openspec/changes/archive/2026-09-06-error-softwares-remove-github-codex-cli/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `fix-ci-prompts-index` — openspec/changes/archive/2026-10-19-fix-ci-prompts-index/STATISTICS.md


# STATISTIQUES — Correction de l'alias ci

## 1. Identification et périmètre

Projet : Debian Installeur Unifié (`diu`).
Date : 19 octobre 2026, Europe/Paris.
Session : SCM directe, correction de l'alias `ci`.
Change : `fix-ci-prompts-index`.
Archive : `2026-10-19-fix-ci-prompts-index`.

Le périmètre validé couvre le chemin de l'alias Zsh généré pour root,
l'empreinte du rendu attendu, le changelog et le cycle OpenSpec complet avec
ce rapport. Il ne comprend aucune modification d'une configuration installée,
des ressources de prompts ou des autres alias.

Les valeurs non secrètes PROJECT_NAME et PROJECT_ID sont vérifiées par
extraction locale filtrée. Aucune écriture de project.env n'est effectuée
dans cette session. Aucun état Git n'est inspecté ; aucun commit, push,
changement de branche, installation ou déploiement n'est exécuté.

## 2. Durées et mesures disponibles

| Mesure | Résultat |
| --- | ---: |
| Exécutions de la suite ciblée | 1 |
| Tests exécutés et réussis | 9 |
| Échecs, erreurs, tests ignorés | 0 |
| Durée de la suite, mesurée par unittest | 7.337 s |
| Agents délégués | 0 |
| Dépendances ajoutées | 0 |
| Archivages exécutés | 1 |

Durée globale de session : N/A, absence de chronométrage global continu.
Tokens, coût et comptes exhaustifs des messages et outils : N/A, absence de
télémétrie de pilotage en SCM. Statistiques Git et inventaire global des
modifications antérieures ou concurrentes : N/A, inspection Git non autorisée
et absence de relevé global initial.

## 3. Fichiers et contrat

Trois fichiers préexistants sont modifiés :

- `root-install-debian.sh`, ligne de génération de l'alias `ci` ;
- `tests/test_root_shellcheck.py`, seule empreinte attendue de `/root/.zshrc` ;
- `CHANGELOG.md`, entrée sous `Unreleased`.

Une spécification principale est créée :
`openspec/specs/system-shell-aliases/spec.md`.

Cinq artefacts sont créés dans le change puis déplacés par l'archivage :
`.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md` et
`specs/system-shell-aliases/spec.md`. Ce rapport complète l'archive : six
fichiers archivés, soit dix fichiers de livraison distincts au total.
La création et le déplacement d'un même artefact ne sont pas comptés deux fois.

Le contrat livré est exactement :

```sh
alias ci='cat /home/devops/datas/prompts/INDEX.md'
```

Le rendu isolé de la configuration Zsh est comparé avant et après correction.
Une seule ligne change : le chemin de `ci`. L'ancienne empreinte est
`ce4738f3e57fa8c21ee1ec4f58caaa9b5a254d832f883307f2ed7764005e8a88` ;
la nouvelle est
`d15e57e0a4e3245c93f03f583485a192492d60a43f4a0e532177187f2a1e3c98`.
Toutes les autres lignes du rendu et toutes les autres empreintes du test
restent identiques. Aucun test n'est supprimé, désactivé ou ajouté.

## 4. Tests et vérifications

| Contrôle | État et preuve |
| --- | --- |
| Syntaxe Bash | Exécutée et réussie : `bash -n root-install-debian.sh` |
| ShellCheck | Exécuté et réussi : `shellcheck root-install-debian.sh` |
| Compilation Python | Exécutée et réussie : `py_compile.compile` avec le Python DevOps, résultat dans un répertoire temporaire du projet ensuite nettoyé |
| Suite ciblée | Exécutée et réussie : neuf tests en 7.337 s, aucun échec, erreur ou ignoré |
| Comparaison du rendu | Exécutée et réussie : seule la ligne ci diffère ; ancienne empreinte cohérente et nouvelle calculée sur le rendu réel |
| Validation stricte du change | Exécutée et réussie avant le code et les tests, puis avant archivage |
| Validation stricte de la spécification synchronisée | Exécutée et réussie après archivage |
| Périmètre des trois fichiers préexistants modifiés | Contrôlé par comparaison SHA-256 avec les contenus attendus calculés avant correction |
| Encodage | UTF-8/LF, absence de NUL et LF final contrôlés sur les fichiers du périmètre |
| Installation réelle et suite entière du dépôt | Non exécutées, hors de la validation ciblée nécessaire |

Commande de la suite ciblée :

```sh
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_root_shellcheck.py
```

Les tests extraient et rendent les commandes du monolithe sans lancer
l'installation. La comparaison utilise `generated_commands` et
`render_commands` existantes, sans les redirections vers les fichiers système.
La compilation Python utilise `TemporaryDirectory` dans la racine du projet.

Le premier contrôle final du rapport échoue sur une comparaison littérale
d'une phrase répartie sur deux lignes. La comparaison est corrigée pour
normaliser les espaces avant vérification ; aucun contenu livré ni total
n'est modifié pour satisfaire ce contrôle.

Commandes OpenSpec exécutées avec le binaire indiqué dans DEVOPS.md :

```sh
/home/devops/.local/npm/bin/openspec validate fix-ci-prompts-index --type change --strict --no-interactive
/home/devops/.local/npm/bin/openspec validate system-shell-aliases --type spec --strict --no-interactive
```

## 5. Résultats, cohérence et archivage

Archivage officiel exécuté une seule fois :

```sh
/home/devops/.local/npm/bin/openspec archive fix-ci-prompts-index --json --yes
```

Résultat : `specsUpdated=true`, une exigence ajoutée, aucune modifiée,
supprimée ou renommée. Les six tâches du change sont cochées. La section
Purpose générée automatiquement est renseignée après archivage, puis la
spécification principale passe la validation stricte. Les exigences de cette
spécification correspondent au delta archivé.

| Élément de la matrice SCM | État et justification |
| --- | --- |
| Projet réel | Alias corrigé dans le générateur et neuf tests ciblés réussis ; configuration installée non modifiée |
| AGENTS.md | Inchangé : sections 5, 6, 7 et 21 appliquées pour la validation, OpenSpec et le rapport d'archive |
| PROJECT.md | Inchangé : Présentation et Technologies restent exactes ; aucun changement d'architecture |
| TECHNICAL.md | Inchangé : Traçabilité du document DevOps indique déjà le dossier datas/prompts et son INDEX.md |
| BUILD.md | Inchangé : Contenu du paquet et chaîne de construction non affectés |
| DEVOPS.md | Inchangé : rubrique Prompts avec /home/devops/datas/prompts et son INDEX.md ; outils DevOps réutilisés |
| README.md | Inchangé : présentation de l'inventaire DevOps avec les chemins datas/prompts déjà exacts |
| CHANGELOG.md | Mis à jour : Unreleased décrit le chemin ci et la portée sur les configurations générées |
| openspec/specs/ | Nouvelle spécification system-shell-aliases, une exigence et deux scénarios ; validation stricte réussie |
| openspec/config.yaml | Inchangé : schéma spec-driven conservé |

Les empreintes des sept fichiers de cadrage et de configuration laissés
inchangés sont comparées au relevé précédant la correction. Le contrôle final
vérifie aussi l'absence du change actif, la présence des cinq artefacts
archivés avec leurs empreintes initiales, les six tâches cochées et ce rapport
à six sections. Aucun document nécessaire du périmètre n'est absent.

## 6. Limites et suites

La correction des sources prend effet lors d'une génération ultérieure de la
configuration Zsh par le DIU. Elle ne modifie pas le shell courant, le DIU
installé ou une configuration root déjà présente. Aucune installation réelle
n'est exécutée pour ce contrôle.

Les autres alias, les variables, les permissions et la construction du paquet
restent inchangés. Aucun nouveau paramètre ni mécanisme de migration n'est
introduit. Le repli est le rétablissement de la ligne précédente et de son
empreinte attendue.

Le contrôle de périmètre est limité aux écritures effectuées et aux fichiers
explicitement examinés ; il ne prétend pas établir l'état global du dépôt.
Les autres changes actifs ne sont ni modifiés ni archivés. Aucun échec de
validation ou écart documentaire connu ne reste dans le périmètre traité.


## Change `fix-direct-provider-push` — openspec/changes/archive/2026-11-10-fix-direct-provider-push/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : increment.

Agent coder : codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Objectif | Push direct et réconciliation CI/CD | Change OpenSpec archivé |
| Collecte native | Non initialisée en début de session ; mesures quantitatives non collectées | Session directe |

## 2. Types de messages et d’outils

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Messages et outils | N/A : mesures exhaustives non disponibles | Session directe |

## 3. Fichiers modifiés

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Périmètre | Code Git et version, routage, aides, tests, documentation et OpenSpec | Diff local |

## 4. Commandes

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation globale | 1 226 tests exécutés, 2 ignorés, aucun échec | python3 -m unittest discover -s tests |
| Contrôles ciblés | Bash, ShellCheck et OpenSpec strict réussis | Sorties des commandes |

## 5. Accès web

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Web | N/A : aucune mesure exhaustive collectée | Session directe |

## 6. Synthèse globale

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Livraison | CI/CD à effectuer après archivage et contrôles finaux | État de session |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Objectif",
            "proof": "Change OpenSpec archivé",
            "value": "Push direct et réconciliation CI/CD"
          },
          {
            "label": "Collecte native",
            "proof": "Session directe",
            "value": "Non initialisée en début de session ; mesures quantitatives non collectées"
          }
        ],
        "2": [
          {
            "label": "Messages et outils",
            "proof": "Session directe",
            "value": "N/A : mesures exhaustives non disponibles"
          }
        ],
        "3": [
          {
            "label": "Périmètre",
            "proof": "Diff local",
            "value": "Code Git et version, routage, aides, tests, documentation et OpenSpec"
          }
        ],
        "4": [
          {
            "label": "Validation globale",
            "proof": "python3 -m unittest discover -s tests",
            "value": "1 226 tests exécutés, 2 ignorés, aucun échec"
          },
          {
            "label": "Contrôles ciblés",
            "proof": "Sorties des commandes",
            "value": "Bash, ShellCheck et OpenSpec strict réussis"
          }
        ],
        "5": [
          {
            "label": "Web",
            "proof": "Session directe",
            "value": "N/A : aucune mesure exhaustive collectée"
          }
        ],
        "6": [
          {
            "label": "Livraison",
            "proof": "État de session",
            "value": "CI/CD à effectuer après archivage et contrôles finaux"
          }
        ]
      },
      "id": "01a1c4e3-9664-7ab3-902a-0e0e1b04135c",
      "input_sha256": "1fc40986f208391b94673e5caceb95d3bca587747ac9fee02a4abe750105e94e",
      "scope": "increment",
      "state": "archived"
    }
  ]
}
-->


## Change `fix-diu-http-compression` — openspec/changes/archive/2026-11-03-fix-diu-http-compression/STATISTICS.md


# Statistiques — fix-diu-http-compression

## Statistiques générales et décisions

- Session SCM directe du 2026-11-03 ; change archivé, code non attribué.
- `curl --compressed` décode les réponses de l'API et les paquets avant traitement ; les autres règles de mise à jour sont conservées.
- Version de projet locale : 1.0.5. Le développeur se charge des constructions et publications de paquets.
- Durée totale et consommation de tokens : N/A, mesures exhaustives indisponibles.

## Types de messages et d'outils

- Exécution directe par Codex ; coordination avec l'autre chat DIU pour les fichiers et la version. Aucun pilotage ni agent délégué.
- Décompte complet des messages et outils : N/A, journal agrégé indisponible.

## Fichiers modifiés

- Application : `modules/diu/update.sh` ; tests : `tests/test_diu_http_compression.py`.
- Documentation et suivi : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`.
- OpenSpec : ce change archivé et `openspec/specs/diu-package-update/spec.md`.
- `PROJECT_VERSION` dans `project.env` a été actualisée localement ; fichier exclu de Git. Nombre global de lignes et inventaire Git : N/A à la rédaction de ce rapport.

## Commandes

- Suite globale avec le Python DevOps : 1 083 tests exécutés, dont 2 ignorés, sans échec ; durée 259,732 secondes.
- Trois tests HTTP locaux vérifient le décodage Zstandard de l'API et du paquet, et l'arrêt en cas de données corrompues ; installation simulée. Trois tests du module, onze d'orchestration et 44 tests logiciels ont également réussi.
- Syntaxe Bash, ShellCheck, compilation Python, UTF-8/LF, validation stricte OpenSpec et archivage réussis. Une première exécution ciblée a échoué sur les permissions setgid de la fixture Debian ; correction de la fixture et réexécution réussie.
- Total exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

Aucune recherche web ; les tests du correctif utilisent un serveur local et des fixtures. L'inventaire exhaustif des accès réseau de la suite globale est N/A.

## Synthèse globale

Correction et validations réalisées ; change archivé. Aucune installation réelle, construction de paquet de production ou publication de release n'est déduite de ces preuves. Les opérations Git et leur résultat relèvent de la clôture de session.


## Change `fix-forgejo-push-inherited-remote` — openspec/changes/archive/2026-10-19-fix-forgejo-push-inherited-remote/STATISTICS.md


# STATISTIQUES — Push Forgejo après changement de dépôt

## 1. Identification et périmètre

Projet : Debian Installeur Unifié (`diu`).
Date : 19 octobre 2026, Europe/Paris.
Session : SCM directe, correction du push après copie ou changement de dépôt.
Change : `fix-forgejo-push-inherited-remote`.
Archive : `2026-10-19-fix-forgejo-push-inherited-remote`.

Le périmètre couvre le réalignement des URL du remote Forgejo configuré, le
premier push malgré une référence de suivi héritée, les tests locaux, les
documents concernés et le cycle OpenSpec complet avec ce rapport. Les seules
valeurs non secrètes PROJECT_NAME et PROJECT_ID sont extraites localement de
project.env ; le fichier réel n'est ni affiché ni modifié.

Pendant SCM, aucun état Git du dépôt réel n'est inspecté. Les commits, tags,
références et pushes nécessaires aux tests concernent exclusivement des
dépôts temporaires locaux. Aucun projet réel, dont `prompts`, ni installation
DIU n'est modifié ou publié.

## 2. Mesures disponibles

| Mesure | Résultat |
| --- | ---: |
| Exécutions des suites de tests | 2 |
| Nouveaux tests exécutés et réussis | 14 |
| Tests existants exécutés et réussis | 100 |
| Total de tests exécutés et réussis | 114 |
| Échecs, erreurs et tests ignorés | 0 |
| Durée de la nouvelle suite | 2.491 s |
| Durée des suites existantes regroupées | 15.053 s |
| Durée cumulée des tests | 17.544 s |
| Diagnostics ShellCheck complets préexistants | 3 |
| Nouveaux diagnostics ShellCheck | 0 |
| Agents délégués | 0 |
| Dépendances ajoutées | 0 |
| Archivages exécutés | 1 |

Durée globale : N/A, absence de chronométrage continu de la session.
Tokens, coût et comptes exhaustifs des messages, outils et lectures : N/A,
absence de télémétrie de pilotage en SCM ; la compétence de statistiques de
pilotage n'est pas invoquée. Statistiques Git du dépôt réel : N/A,
inspection Git exclue pendant SCM. Inventaire global des changements
antérieurs ou concurrents : N/A, absence de relevé global autorisé.

## 3. Fichiers et contrat livré

Six fichiers préexistants sont modifiés :

- `modules/projects/git.sh` : helper de réalignement et lease du premier push ;
- `tests/test_rid_help.py` : assertion supplémentaire sur le lease explicite ;
- `TECHNICAL.md`, `README.md`, `CHANGELOG.md` : comportement et compatibilité ;
- `openspec/specs/implement-projects-forgejo-push/spec.md` : deux exigences.

Un fichier de tests est créé : `tests/test_projects_forgejo_push.py`.
Six artefacts sont créés puis archivés : `.openspec.yaml`, `proposal.md`,
`design.md`, `tasks.md`, `review.md` et le delta
`specs/implement-projects-forgejo-push/spec.md`. Ce rapport complète l'archive,
soit sept fichiers archivés et quatorze fichiers de livraison distincts au
total. Les déplacements d'archivage ne sont pas comptés comme de nouvelles
créations.

Le remote Forgejo configuré utilise la destination déclarée dans project.env
pour toutes ses URL de récupération et de publication. Les anciennes URL ne
sont pas affichées ; les autres remotes sont préservés. Une réexécution
conforme n'écrit pas la configuration. Une erreur bloque le push sans faux
succès et une correction partielle peut être reprise.

Pour un dépôt annoncé absent, le premier push explicite utilise
`--force-with-lease=refs/heads/<branche>:`. Il ne dépend plus de l'ancienne
référence de suivi et refuse d'écraser une branche créée entre-temps. Aucune
référence locale n'est supprimée. Le fetch des dépôts existants, les tags
sans forçage, les variables et les parcours GitLab/GitHub sont conservés.

## 4. Tests et vérifications

| Contrôle | État et preuve |
| --- | --- |
| Syntaxe Bash | Exécutée et réussie : `bash -n modules/projects/git.sh` |
| Nouvelle suite locale | Exécutée et réussie : 14 tests, 2.491 s |
| Suites existantes ciblées | Exécutées et réussies : 100 tests, 15.053 s |
| Compilation Python | Exécutée et réussie : py_compile des deux fichiers modifiés ou créés, sorties temporaires confinées au projet |
| ShellCheck complet | Exécuté et échoué : SC2034, SC2269, SC2086, tous préexistants et hors des fonctions modifiées |
| Comparaison ShellCheck avant/après | Exécutée et réussie : mêmes trois codes, niveaux et messages, aucun nouveau diagnostic |
| ShellCheck des fonctions modifiées | Exécuté et réussi : aucun diagnostic sur `_git_push_provider` et `forgejo_remote_ensure` extraites |
| Validation stricte du change | Exécutée et réussie avant le code puis avant archivage |
| Validation stricte de la spécification synchronisée | Exécutée et réussie après condensation des deux descriptions modifiées |
| Périmètre du code et du test existant | Reconstruction du SHA-256 initial du Bash et retrait du seul ajout d'assertion pour retrouver l'empreinte initiale du test |
| UTF-8/LF, absence de NUL et LF final | Contrôlés sur les fichiers livrés, y compris l'archive et ce rapport |
| Serveur Forgejo réel et installation | Non exécutés : hors périmètre, aucune publication ni installation |

La nouvelle suite est lancée par :

```sh
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_forgejo_push.py -v
```

Les suites `test_rid_help.py`, `test_projects_provider_unavailable.py` et
`test_projects.py` sont regroupées avec `unittest.defaultTestLoader.discover`
dans une seule exécution du même Python DevOps. Leur TMPDIR est un répertoire
temporaire sous la racine du projet, ensuite nettoyé ; l'écriture des caches
Python est désactivée. Les nouveaux tests imposent `GIT_ALLOW_PROTOCOL=file`
et isolent les configurations Git globales et système. Les appels API et
credentials sont simulés ; les opérations Git testées utilisent Git réel.

Le scénario complet reproduit le remote hérité, son réalignement, la
référence de suivi périmée, puis la publication de la branche et du tag.
Un autre scénario crée la branche distante entre vérification et push : le
lease refuse la publication, conserve cette branche et ne publie aucun tag.
Les URL multiples, pushurl distinctes, erreurs, reprise, idempotence et
destination nommée avec branche différente sont également vérifiées.

Le Bash initial est reconstruit dans une copie temporaire avec l'empreinte
`ea62e5b1c7d5d6a1adad40a85582e034fa29e397cbb0d71847d68d38cac891aa`.
Les trois diagnostics identiques sont comparés avant et après. La suite
entière du dépôt n'est pas exécutée : les quatre modules de tests ciblés
couvrent les fonctions et fournisseurs concernés.

## 5. Cohérence et archivage

L'archivage officiel est exécuté une seule fois :

```sh
/home/devops/.local/npm/bin/openspec archive fix-forgejo-push-inherited-remote --json --yes
```

Résultat : `specsUpdated=true`, deux exigences modifiées, aucune ajoutée,
supprimée ou renommée. Les neuf tâches préalables sont cochées. Aucun autre
change actif n'est repris ni archivé.

La première validation du delta échoue sur deux noms de scénarios omis.
Les noms existants sont conservés et la validation stricte réussit avant le
code. Après archivage, la validation stricte de la spécification principale
signale deux descriptions trop longues, toutes deux dans les exigences
modifiées. Les descriptions sont condensées avec les détails conservés dans
les scénarios, à l'identique dans le delta archivé et la spécification
principale ; la validation stricte réussit ensuite. Aucun réarchivage ni
changement de code après ses tests n'est effectué.

| Élément SCM | État et justification |
| --- | --- |
| Projet réel | Sources corrigées, 114 tests ciblés réussis ; DIU installé et dépôt prompts réel inchangés |
| AGENTS.md | Inchangé : sections 5, 6, 7, 13 et 21 appliquées pour périmètre, validation, OpenSpec et rapport |
| PROJECT.md | Inchangé : module projects, architecture et technologies conservés |
| TECHNICAL.md | Mis à jour : configuration des fournisseurs, publication Git et compatibilité |
| BUILD.md | Inchangé : construction Debian et chaîne de packaging non concernées |
| DEVOPS.md | Inchangé : outils existants utilisés, aucune dépendance ni génération d'inventaire |
| README.md | Mis à jour : publication Forgejo, réalignement, premier push et limites serveur |
| CHANGELOG.md | Mis à jour : entrée Unreleased sans version ni publication inventée |
| openspec/specs/ | Deux exigences synchronisées, validation stricte réussie et égalité avec les blocs du delta archivé |
| openspec/config.yaml | Inchangé : schéma spec-driven conservé |

Les empreintes initiales d'AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et
openspec/config.yaml sont conservées. Le contrôle final vérifie les fichiers
livrés, l'absence du change actif, la présence de l'archive, les neuf tâches
cochées, les six sections de ce rapport et les totaux. Le fichier `review.md`
fournit les preuves détaillées et la correspondance entre critères et tests.

## 6. Limites et suites

La correction est livrée dans les sources de développement. Le DIU installé
n'est pas remplacé ; le comportement de `rid` ne changera qu'après sa mise à
jour par le processus habituel. Aucun push réel n'est exécuté pour confirmer
la publication du projet prompts.

La création effective d'un dépôt absent dépend toujours de l'activation
push-to-create sur Forgejo. Les réécritures Git d'URL qui empêchent d'obtenir
la destination déclarée provoquent un échec explicite ; elles ne sont pas
modifiées. Une erreur intermédiaire de configuration peut laisser un
réalignement partiel, repris à la réexécution. Le repli consiste à rétablir
le code précédent ; les URL déjà réalignées ne sont pas restaurées
automatiquement.

Les trois diagnostics ShellCheck préexistants restent signalés et hors du
périmètre. Aucun nouveau diagnostic ni échec de test ne subsiste. Le contrôle
de périmètre est limité aux fichiers examinés et aux écritures effectuées ;
il ne prétend pas établir l'état global du dépôt sans inspection Git.


## Change `fix-forgejo-repository-identity` — openspec/changes/fix-forgejo-repository-identity/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `fix-github-release-image-case` — openspec/changes/archive/2026-10-15-fix-github-release-image-case/STATISTICS.md


# STATISTIQUES — Correction de la casse GHCR

## 1. Identification et périmètre

Date : 15 octobre 2026, Europe/Paris. Change :
`fix-github-release-image-case`. Archive :
`2026-10-15-fix-github-release-image-case`.

Périmètre SCM validé : normalisation locale des chemins GHCR versionné et
`latest`, résumé CI/CD, tests, documentation, spécification et archivage.
Les valeurs de `project.env`, les identifiants, les remotes Git et la casse
du tag de version sont préservés. Aucune publication réelle, installation,
création de commit ou branche n'est réalisée. Aucun état Git ni fichier
sensible réel n'est inspecté pendant cette session SCM. Les fichiers
`project.env` utilisés par les tests sont exclusivement des fixtures.

## 2. Durées et mesures disponibles

Début du relevé SHA-256 (UTC) : 2026-10-15T15:34:25.647002+00:00.
Rapport préparé le 2026-10-15T17:48:26.696385+02:00, Europe/Paris.
Intervalle observé : 841.048 s ; il ne mesure pas la conversation entière.
Somme des durées unittest : 2,787 s.

Agents délégués : 0. OpenCode/CAB et sondes de pilotage : non utilisés.
Tokens, coût, compte exhaustif des messages/outils : N/A, aucune télémétrie
de pilotage n'est activée pour SCM. Statistiques Git de lignes : N/A, aucune
inspection Git n'est effectuée. La comparaison du module à son empreinte
initiale confirme exactement trois substitutions de références GHCR.

## 3. Fichiers et cohérence documentaire

Quinze fichiers préexistants sont suivis par SHA-256 : six modifiés attendus,
neuf inchangés. Cinq fichiers nouveaux sont conservés dans l'archive :
`proposal.md`, `design.md`, `tasks.md`,
`specs/implement-projects-github-release/spec.md` et ce rapport.
Les quatre premiers ont été créés dans le change puis déplacés par archivage.
Les catégories création et déplacement ne s'additionnent pas.

Fichiers préexistants modifiés :

- `modules/projects/git.sh` : trois expansions Bash en minuscules, dans la
  release GHCR et le résumé CI/CD.
- `tests/test_projects.py` : quatre configurations de casse, conservation
  du fichier et des variables, identité de connexion, version RC1 et résumé.
- `TECHNICAL.md` : section « Variables des fournisseurs distants », règle
  de construction GHCR et invariants de configuration.
- `README.md` : commande de release GHCR et exemple de conversion.
- `CHANGELOG.md` : entrée dans Unreleased.
- `openspec/specs/implement-projects-github-release/spec.md` : exigence
  de publication enrichie et trois scénarios supplémentaires.

| Document de la matrice SCM | État et justification |
|---|---|
| Projet réel | Trois constructions GHCR corrigées ; publication simulée et résumé vérifiés. |
| AGENTS.md | Inchangé, SHA-256 identique ; règles de sécurité et périmètre respectés. |
| PROJECT.md | Inchangé, SHA-256 identique ; architecture et objectifs non modifiés. |
| TECHNICAL.md | Mis à jour dans les variables des fournisseurs distants. |
| BUILD.md | Inchangé, SHA-256 identique ; construction du paquet Debian non concernée. |
| DEVOPS.md | Inchangé par la session, SHA-256 identique ; aucun outil ou environnement ajouté. |
| README.md | Mis à jour avec la commande GHCR, sa conversion et son prérequis d'image construite. |
| CHANGELOG.md | Mis à jour dans Unreleased, sans version ni date de publication inventée. |
| openspec/specs/ | Une exigence modifiée ; deux autres exigences préservées ; validation stricte finale réussie. |

Les neuf références inchangées sont `AGENTS.md`, `PROJECT.md`, `BUILD.md`,
`DEVOPS.md`, `PROMPTS/SCM.md`, `openspec/config.yaml`,
`openspec/specs/projects-cicd/spec.md`, `root-install-debian.sh` et
`lib/github-auth.sh`. Les autres changes actifs restent hors périmètre.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Méthodes sans échec | Méthodes en échec | Constats d'échec, sous-tests inclus | Erreurs | Durée s |
|---|---:|---:|---:|---:|---:|---:|
| Release GHCR ciblée | 1 | 1 | 0 | 0 | 0 | 0,443 |
| Suite projets élargie avec TMPDIR dans le dépôt | 26 | 19 | 7 | 22 | 0 | 1,662 |
| CI/CD et releases applicables | 8 | 8 | 0 | 0 | 0 | 0,682 |
| Total, répétitions incluses | 35 | 28 | 7 | 22 | 0 | 2,787 |

Résultat applicable final : huit méthodes distinctes réussies ; la méthode
GHCR comprend quatre sous-tests de casse. Les tests concernés couvrent
l'ordre du pipeline, les opérations ignorées, les résumés, les releases
GitHub et les reprises de push Docker GitLab.

Commandes unittest exécutées avec
`TMPDIR=/home/devops/datas/diu/openspec/changes/fix-github-release-image-case`
et `PYTHONDONTWRITEBYTECODE=1` :

- `python3 -m unittest discover -s tests -p test_projects.py -k github_release -v` :
  exécutée et réussie.
- `python3 -m unittest discover -s tests -p test_projects.py` :
  exécutée et échouée. Sept méthodes de création/synchronisation fabriquent
  explicitement un faux utilisateur `../tmp/<nom-fixture>` et supposent
  leurs fixtures sous `/tmp`, malgré TMPDIR. Elles ne peuvent pas retrouver
  les modèles placés dans le dépôt. Vingt-deux constats incluent les
  sous-tests de deux méthodes paramétrées. Ces fonctions et cette hypothèse
  de harnais ne sont pas corrigées dans le périmètre GHCR.
- `python3 -m unittest discover -s tests -p test_projects.py -k cicd -k github_release -k gitlab_docker -v` :
  exécutée et réussie.

Autres contrôles :

- `bash -n modules/projects/git.sh` : exécutée et réussie.
- Compilation de `tests/test_projects.py` par `py_compile.compile(...,
  doraise=True)`, dans un répertoire temporaire du change nettoyé :
  exécutée et réussie.
- `shellcheck modules/projects/git.sh` : exécutée et échouée avec SC2034,
  SC2269 et SC2086 dans des fonctions hors correction. Reconstruction en
  mémoire du module initial, vérifiée contre son SHA-256 de départ :
  diagnostics ShellCheck strictement identiques avant/après.
- ShellCheck des deux fonctions extraites sans contexte : exécutée et échouée,
  avec SC2153 dû aux déclarations GitLab absentes de l'extrait.
- ShellCheck des mêmes fonctions, en fournissant seulement les cinq
  déclarations GitLab externes nécessaires : exécutée et réussie, sans
  suppression de diagnostic ni modification du code.
- Contrôles UTF-8/LF et empreintes ciblées : exécutés et réussis.
- Validation stricte du change avant code puis avant archivage :
  exécutée et réussie.
- Validation stricte de la spécification après synchronisation : premier
  contrôle échoué sur la longueur du texte normatif, puis réussi après
  condensation de l'exigence dans le delta archivé et la spécification
  principale, sans perte des scénarios.
- Publication réelle GHCR, build Docker et mise à jour du DIU installé :
  non exécutés, hors périmètre.

Les contrôles des invariants OpenSpec, des six sections de ce rapport, de
l'encodage et des totaux sont vérifiés à la clôture. Aucune assertion de test
n'a été affaiblie pour masquer un échec.

## 5. Résultats et archivage

`AzenorPixs/PKeycloak` produit `ghcr.io/azenorpixs/pkeycloak` pour les
deux tags Docker et le résumé. La version `1.2.3-RC1` conserve ses
majuscules. Le fichier fixture est identique octet pour octet après release ;
les variables GitHub chargées conservent leur casse et Docker reçoit
l'identité de connexion originale.

Archivage officiel exécuté une seule fois sous le compte devops :

`/home/devops/.local/npm/bin/openspec archive fix-github-release-image-case --json --yes`

Code de sortie : 0. Réponse : `specsUpdated=true`, zéro exigence ajoutée,
une modifiée, zéro supprimée, zéro renommée. L'archive contient les sept
tâches d'implémentation/qualification cochées et ce rapport de clôture.

La spécification finale conserve trois exigences, dont deux exigences
antérieures inchangées, et six scénarios. Le corps normatif de l'exigence
modifiée est identique entre le delta archivé et la spécification principale.
La correction rédactionnelle après archivage répond à la limite de longueur
du validateur et ne change ni les scénarios ni l'implémentation.
Aucun second archivage n'est exécuté.

## 6. Limites et suites

La qualification établit les références transmises à Docker sur fixtures ;
elle ne prouve ni les droits GHCR du compte réel ni une publication effective.
Le DIU installé n'est pas mis à jour par cette session.

Les trois diagnostics ShellCheck historiques du module complet et la
dépendance de sept tests de création/synchronisation à `/tmp` restent
signalés hors périmètre. Le résultat de la suite élargie n'est pas présenté
comme une réussite. Les validations applicables à la correction réussissent.

La normalisation ne remplace pas les autres validations de syntaxe de
référence assurées par Docker. Aucun fournisseur autre que GHCR, aucune
configuration de projet réelle et aucun correctif du libellé Docker
d'interruption du résumé CI/CD ne sont inclus dans cette correction.


## Change `fix-gitlab-release-asset-link-validation` — openspec/changes/fix-gitlab-release-asset-link-validation/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `fix-replay-provider-credentials` — openspec/changes/archive/2026-11-10-fix-replay-provider-credentials/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : increment.

Agent coder : codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Objectif | Identifiants conservés dans le projet source | Change OpenSpec archivé |
| Collecte | Collecte native non disponible pour ce change | Session directe |

## 2. Types de messages et d’outils

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Messages et outils | N/A : mesures exhaustives non disponibles | Session directe |

## 3. Fichiers modifiés

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | Code, tests, aides, documentation et spécifications | Diff du projet |

## 4. Commandes

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation globale | 1 236 tests exécutés, 2 ignorés, aucun échec | python3 -m unittest discover -s tests |
| Autres contrôles | Bash, ShellCheck et OpenSpec strict réussis | Sorties des commandes |

## 5. Accès web

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Web | N/A : mesure exhaustive indisponible | Session directe |

## 6. Synthèse globale

### Relevé 01a1c4e3-9664-7ab3-902a-0e0e1b04135c

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Livraison | CI/CD prévue après archivage et contrôles finaux | État de session |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Objectif",
            "proof": "Change OpenSpec archivé",
            "value": "Identifiants conservés dans le projet source"
          },
          {
            "label": "Collecte",
            "proof": "Session directe",
            "value": "Collecte native non disponible pour ce change"
          }
        ],
        "2": [
          {
            "label": "Messages et outils",
            "proof": "Session directe",
            "value": "N/A : mesures exhaustives non disponibles"
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Diff du projet",
            "value": "Code, tests, aides, documentation et spécifications"
          }
        ],
        "4": [
          {
            "label": "Validation globale",
            "proof": "python3 -m unittest discover -s tests",
            "value": "1 236 tests exécutés, 2 ignorés, aucun échec"
          },
          {
            "label": "Autres contrôles",
            "proof": "Sorties des commandes",
            "value": "Bash, ShellCheck et OpenSpec strict réussis"
          }
        ],
        "5": [
          {
            "label": "Web",
            "proof": "Session directe",
            "value": "N/A : mesure exhaustive indisponible"
          }
        ],
        "6": [
          {
            "label": "Livraison",
            "proof": "État de session",
            "value": "CI/CD prévue après archivage et contrôles finaux"
          }
        ]
      },
      "id": "01a1c4e3-9664-7ab3-902a-0e0e1b04135c",
      "input_sha256": "ca9e231f32232d62d6248d7e0dd2bcdbca74e591c1a52bba19dc8a47e3b951f8",
      "scope": "increment",
      "state": "archived"
    }
  ]
}
-->


## Change `fix-root-shellcheck` — openspec/changes/archive/2026-09-28-fix-root-shellcheck/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `fix-system-update-apt-cli-warning` — openspec/changes/archive/2026-11-05-fix-system-update-apt-cli-warning/STATISTICS.md


# Statistiques — correction de l’avertissement APT

## 1. Statistiques générales et décisions

Session SCM directe du 2026-11-05, réalisée par Codex, sans sous-agent ni pilotage. Le change est archivé, son code de lot reste non attribué. Aucune CI/CD ni mise à jour réelle de la machine. Modèle exact, durée, tokens et coût : N/A, non mesurés.

## 2. Types de messages et d’outils

Lectures, modifications, commandes et tests locaux. Totaux exhaustifs des messages, outils et autorisations : N/A, non collectés.

## 3. Fichiers modifiés

Code : `modules/system/apt.sh`. Test : `tests/test_system_update_report.py`. Documentation : `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`. OpenSpec : proposition, conception, tâches et delta archivés, spécification canonique `openspec/specs/system-update-report/spec.md`, et ce rapport. Total de fichiers distincts touchés : 12 ; nombre exhaustif d’opérations de fichier : N/A.

## 4. Commandes et validations

Bilan final : 1 205 tests exécutés, dont 1 203 réussis, 2 ignorés et 0 échoué. Tests ciblés : 39 réussis, inclus dans la suite globale. Deux fichiers distincts ont passé un contrôle syntaxique : `modules/system/apt.sh` et `tests/test_system_update_report.py` ; ShellCheck réussi. Trois validations OpenSpec strictes réussies et une échouée avant correction du texte canonique ; trois tâches OpenSpec prouvées et terminées. Animation et véritable exécution APT non rejouées. Totaux des commandes : N/A, non collectés.

## 5. Accès web

Aucun appel à un outil web : 0. Aucun déploiement ou installation réelle.

## 6. Synthèse globale

Le message exact de compatibilité de l’interface APT ne produit plus de faux avertissement. Les autres avertissements et échecs restent détectés. La validation est isolée et ne démontre pas une nouvelle mise à jour réelle sur l’hôte.


## Change `fix-system-update-codex-duplicate` — openspec/changes/archive/2026-11-05-fix-system-update-codex-duplicate/STATISTICS.md


# Statistiques — bilan Codex CLI sans doublon

## 1. Statistiques générales et décisions

Session SCM directe le 2026-11-05 par Codex, sans sous-agent ni pilotage. Change archivé, code de lot non attribué. Aucune CI/CD ni mise à jour réelle. Modèle exact, durée, tokens et coût : N/A, non mesurés.

## 2. Types de messages et d’outils

Lectures, modifications, commandes et tests locaux. Totaux exhaustifs des messages, appels et autorisations : N/A, non collectés.

## 3. Fichiers modifiés

Code : `modules/system/apt.sh`. Test : `tests/test_system_update_report.py`. Documentation : `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`. OpenSpec : proposition, conception, tâches et delta archivés, spécification canonique `openspec/specs/system-update-report/spec.md`, et ce rapport. Total de fichiers distincts touchés : 12. Nombre total d’opérations de fichier : N/A.

## 4. Commandes et validations

Bilan final : 1 207 tests exécutés, dont 1 205 réussis, 2 ignorés et 0 échoué. Tests ciblés : 73 réussis, inclus dans la suite globale. Deux fichiers distincts ont passé un contrôle syntaxique : `modules/system/apt.sh`, `tests/test_system_update_report.py` ; ShellCheck réussi. Deux validations OpenSpec strictes réussies ; trois tâches OpenSpec prouvées et terminées. Total exhaustif des commandes : N/A.

## 5. Accès web

Aucun appel à un outil web : 0. Aucun déploiement, installation ou mise à jour réelle.

## 6. Synthèse globale

Le bilan affiche une seule ligne Codex CLI à succès, avec version actuelle ou versions avant et après. En cas d’échec, les diagnostics de la recette restent visibles ; les commandes directes sont préservées. La validation sur fixtures ne prouve pas une mise à jour réelle de l’hôte.


## Change `force-diu-update-version` — openspec/changes/archive/2026-11-04-force-diu-update-version/STATISTICS.md


# Statistiques — version DIU explicite

## Statistiques générales et décisions

Session SCM directe du 2026-11-04 : change archivé après validation. L’installation explicite sélectionne GitHub et peut réinstaller ou rétrograder ; le mode sans argument est conservé. Durée, tokens et coût : N/A, non mesurés.

## Types de messages et d’outils

Un agent Codex a réalisé la session. Nombre de messages et d’appels d’outils : N/A, télémétrie non collectée.

## Fichiers modifiés

Moteur et routage DIU, aide, tests de mise à jour et de routage, README, TECHNICAL, CHANGELOG, cartographie, registre et spécification OpenSpec ; artefacts du présent change. Totaux de fichiers et de lignes : N/A, mesure exhaustive non disponible.

## Commandes

OpenSpec strict, syntaxe Bash, ShellCheck et compilation Python réussis. Contrôles ciblés : 14 tests de mise à jour, 60 tests d’aide et 11 tests de routage réussis. Première suite globale : 1 151 tests, un échec d’attente de routage corrigé, deux ignorés. Deuxième suite globale : 1 152 tests réussis, dont deux ignorés, avec le Python DevOps déclaré.

## Accès web

Aucun accès web de production ; réponses et installations simulées dans les tests.

## Synthèse globale

Change validé et archivé le 2026-11-04. Les quatre tâches sont cochées ; l’ancien libellé « RÉALISÉ À VALIDER » du sous-lot dans l’archive précède la validation globale et reste conservé comme état historique. Aucune installation réelle, aucun commit ni aucune publication. Code de lot non attribué ; ACL reste à exécuter pour son attribution.


## Change `generalize-projects-template-devops` — openspec/changes/archive/2026-10-02-generalize-projects-template-devops/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `git-https-token-auth` — openspec/changes/archive/2026-08-12-git-https-token-auth/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `github-only-diu-update` — openspec/changes/archive/2026-11-03-github-only-diu-update/STATISTICS.md


# Statistiques — github-only-diu-update

## Statistiques générales et décisions

Session SCM directe du 2026-11-03, agent Codex. Change archivé après validation ; GitHub est la source unique de mise à jour du paquet DIU. Version inchangée et aucun commit, sur décision du développeur. Durée, tokens et coût : N/A, mesures non collectées.

## Types de messages et d’outils

Échanges de cadrage, validation explicite du périmètre, lectures, commandes, modifications et contrôles. Nombre exhaustif de messages et d’appels par outil : N/A, télémétrie non collectée. Aucun agent délégué.

## Fichiers modifiés

Moteur `modules/diu/update.sh`, aide `lib/rid-help.sh`, tests `test_diu_package_update.py` et `test_diu_http_compression.py`, `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`, canon `openspec/specs/diu-package-update/spec.md` et artefacts du présent change, y compris ce rapport. Nombre total des fichiers et lignes modifiées : N/A, inventaire Git non effectué.

## Commandes

Contrôles réussis : `bash -n` et ShellCheck pour les deux scripts ; compilation syntaxique des deux fichiers Python ; 9 tests ciblés de mise à jour, 3 tests de compression et 59 tests d’aide. Validation finale : 1 121 tests exécutés, dont 2 ignorés, sans échec ; les tests ciblés sont inclus dans la suite globale et ne sont pas additionnés. OpenSpec strict a réussi après correction d’une première validation stricte échouée (scénarios omis dans le delta) ; archivage réussi et canon synchronisé ; après deux validations strictes du canon en échec sur une longueur excessive, reformulation équivalente et validation stricte réussie. Première suite globale interrompue pour relancer avec un répertoire temporaire dans le projet ; elle ne constitue pas une validation finale. Comptage exhaustif des commandes : N/A.

## Accès web

Aucun appel à un outil web par l’agent. Les API et installations de mise à jour sont simulées dans les tests ; aucune vérification réelle du dépôt GitHub ou installation réelle n’est revendiquée.

## Synthèse globale

Les trois tâches du change sont validées selon `tasks.md`. Les comportements hors mise à jour DIU et la version du projet restent hors modification ; l’indisponibilité de GitHub bloque la mise à jour sans repli. Publication et déploiement : non effectués. Rapport global racine absent : maintenance non applicable ; mandater SGS pour sa création.


## Change `handle-cicd-release-unavailability` — openspec/changes/archive/2026-11-04-handle-cicd-release-unavailability/STATISTICS.md


# Statistiques — handle-cicd-release-unavailability

## Statistiques générales et décisions

Change exécuté en session SCM directe, archivé le 2026-11-04. Les indisponibilités reconnues en release CI/CD sont non bloquantes, avec publication potentiellement partielle signalée. Les autres erreurs et les releases directes conservent leur contrat. Code de lot non attribué ; attribution ultérieure par ACL.

## Types de messages et d'outils

Agent de codage : Codex. Nombre de messages et appels d'outils : N/A, comptage exhaustif indisponible. Aucune télémétrie de pilotage requise ou déclenchée.

## Fichiers modifiés

Code : `modules/projects/git.sh`, `modules/projects/diu-release.sh`, `lib/github-auth.sh`. Tests : `tests/test_projects.py`, `tests/test_projects_cicd_debian.py`, `tests/test_projects_cicd_replay.py`, `tests/test_projects_forgejo_debian_idempotence.py`, `tests/test_projects_github_debian_release.py`. Documentation : `README.md`, `BUILD.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`. Synchronisation de `openspec/specs/projects-cicd/spec.md` et archivage du change. Des fichiers partagés contenaient également des modifications d'autres sessions, préservées.

## Commandes

Validation globale Python DevOps : 1 171 tests exécutés, dont 2 ignorés, résultat OK. Tests ciblés CI/CD, rejeu, GitHub, Forgejo et GitLab réussis. Syntaxe Bash, ShellCheck avec exclusion SC1091 pour imports dynamiques existants, OpenSpec strict et validation de la spécification synchronisée réussis. La première suite globale, avec `/usr/bin/python3`, a échoué avec 26 erreurs de fixtures venv ; la suite globale avec le Python DevOps documenté a réussi.

## Accès web

Aucun accès web utilisé pour cette correction. Les tests de publication utilisent des transports simulés ; aucune release réelle n'a été déclenchée.

## Synthèse globale

Implémentation et change archivés ; validation locale réussie dans les limites des transports simulés. Durée, nombre total de commandes et volumes de télémétrie : N/A, données exhaustives indisponibles. Aucun numéro de version ou code de lot n'a été créé par cette session.


## Change `harmonize-cicd-publication-messages` — openspec/changes/archive/2026-11-03-harmonize-cicd-publication-messages/STATISTICS.md


# Statistiques — harmonize-cicd-publication-messages

## Statistiques générales et décisions

- Session SCM directe du 2026-11-03 ; code non attribué.
- Harmonisation des messages des publications Debian et de l'affichage Git local, sans annoncer de vérification non réalisée.
- Aucun commit, push ni incrément de version ; le correctif préexistant de nettoyage est conservé.
- Durée totale et tokens : N/A, mesures exhaustives indisponibles.

## Types de messages et d'outils

- Exécution directe par Codex ; aucun agent de codage délégué.
- Décompte exhaustif des messages et appels d'outils : N/A, journal agrégé indisponible.

## Fichiers modifiés

- Modules de publication Forgejo, GitHub et GitLab, affichage Git local, aide, tests et documentation associée.
- Spécification projects-cicd synchronisée ; change archivé ; cartographie et registre mis à jour sans attribution de code.
- Le fichier project.env n'a pas été modifié. Volume de lignes : N/A.

## Commandes

- Suite globale Python DevOps : 1 119 tests exécutés, dont 2 ignorés, sans échec ; 261,321 secondes. Les dernières modifications ont été vérifiées par les tests ciblés.
- Tests ciblés : 14 Forgejo push, 4 Forgejo Debian, 28 GitHub Debian, 32 projet/GitLab, 10 rejeu et 59 aides ; tous réussis.
- Syntaxe Bash, ShellCheck, compilation Python et validation OpenSpec stricte du change réussies.
- Total exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

Aucun accès web ni publication distante ; transports et identifiants de test fictifs.

## Synthèse globale

Messages et alignement harmonisés ; contrôles et archivage réalisés. Les modifications restent locales et non commitées ; la version reste inchangée.


## Change `harmonize-project-configuration` — openspec/changes/archive/2026-11-03-harmonize-project-configuration/STATISTICS.md


# Statistiques — harmonize-project-configuration

## Statistiques générales et décisions

Session directe SCM du 2026-11-03 ; un agent Codex. Périmètre validé : questionnaire de création et mise à jour, retrait de la copie du protocole, tests, documentation et cycle OpenSpec. Aucun commit ni incrément de version.

## Types de messages et d'outils

Nombre total de messages et d'appels d'outils : N/A, télémétrie exhaustive non disponible. Aucun pilotage ni sonde CAB.

## Fichiers modifiés

Code : `modules/projects/projects.sh`. Tests : `tests/test_projects_orchestrated_coding.py`, `tests/test_projects_orchestrated_copy.py`. Documentation : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, cartographie et registre. Change et deux spécifications OpenSpec synchronisées. Certains fichiers comportaient des modifications d'autres travaux, conservées.

## Commandes

62 tests ciblés réussis ; `bash -n`, ShellCheck, `py_compile` et validation stricte du change réussis. Une première exécution des tests a échoué avant adaptation ; une exécution plus large a été interrompue et ne constitue pas une validation.

## Accès web

Aucun accès web pour cette session.

## Synthèse globale

Parcours harmonisé et change archivé. Mesures de durée, jetons, quotas et coût : N/A, données non disponibles. Code de lot non attribué ; attribution ultérieure par ACL. Tests limités aux périmètres concernés, sans exécution de création réelle sur l'environnement utilisateur.


## Change `idelete-projects-gitp` — openspec/changes/archive/2026-09-07-idelete-projects-gitp/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-flatpak-engine` — openspec/changes/archive/2026-09-12-implement-flatpak-engine/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-module-softwares-apt` — openspec/changes/archive/2026-09-05-implement-module-softwares-apt/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-module-softwares-install-apt-cgpt` — openspec/changes/archive/2026-09-06-implement-module-softwares-install-apt-cgpt/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-module-softwares-install-github` — openspec/changes/archive/2026-09-06-implement-module-softwares-install-github/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-projects-forgejo-push` — openspec/changes/archive/2026-09-07-implement-projects-forgejo-push/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-projects-forgejo-update` — openspec/changes/archive/2026-09-07-implement-projects-forgejo-update/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-projects-github-push` — openspec/changes/archive/2026-09-07-implement-projects-github-push/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-projects-github-update` — openspec/changes/archive/2026-09-07-implement-projects-github-update/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-projects-gitlab-push` — openspec/changes/archive/2026-09-07-implement-projects-gitlab-push/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-projects-gitlab-release` — openspec/changes/archive/2026-09-07-implement-projects-gitlab-release/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-projects-update` — openspec/changes/archive/2026-09-07-implement-projects-update/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-softwares-apt-update` — openspec/changes/archive/2026-09-06-implement-softwares-apt-update/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-softwares-install-github-codex-cli` — openspec/changes/archive/2026-09-06-implement-softwares-install-github-codex-cli/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `implement-softwarres-flatpak` — openspec/changes/archive/2026-09-12-implement-softwarres-flatpak/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `improve-system-update-report` — openspec/changes/archive/2026-11-05-improve-system-update-report/STATISTICS.md


# Statistiques — improve-system-update-report

## 1. Statistiques générales et décisions

- Change archivé le 2026-11-05 ; code non attribué, attribution ultérieure par ACL.
- Session SCM directe, un agent Codex ; aucun agent de pilotage ni sous-agent.
- Périmètre : bilan Debian, moteurs logiciels et logiciels DIU activés ; aucune livraison CI/CD ni mise à jour réelle du système.
- Durée, tokens, coûts et nombre de décisions : N/A, télémétrie non disponible.

## 2. Types de messages et d'outils

N/A : comptages exhaustifs et télémétrie de session non disponibles.

## 3. Fichiers modifiés

- Code : `modules/system/apt.sh`, `modules/diu/update-all.sh`.
- Tests : `tests/test_system_update_report.py`, `tests/test_software_engines.py`, `tests/test_system_network_hosts.py`.
- Documentation : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`.
- OpenSpec : proposition, conception, tâches et spécification du change ; spécification canonique `openspec/specs/system-update-report/spec.md`.
- Fichiers distincts touchés : 16, en comptant les artefacts OpenSpec archivés une seule fois. Total des opérations de fichier : N/A, inventaire événementiel non disponible.

## 4. Commandes

- Bilan final : 1 200 tests exécutés, dont 1 198 réussis, 2 ignorés et 0 échoué ; Python du projet, le 2026-11-05.
- Contrôles ciblés : 55 tests réussis. Cinq fichiers distincts ont passé un contrôle syntaxique : `modules/system/apt.sh`, `modules/diu/update-all.sh`, `tests/test_system_update_report.py`, `tests/test_software_engines.py`, `tests/test_system_network_hosts.py`.
- Validations OpenSpec strictes : 3 réussies et 2 échouées avant correction. Tâches OpenSpec prouvées et terminées : 5.
- Animation vérifiée dans un pseudo-terminal.
- Une première suite globale a été interrompue ; une autre s'est arrêtée sur une attente de test réseau corrigée avant la suite réussie.
- Total exhaustif des commandes et durées : N/A, télémétrie exhaustive indisponible.

## 5. Accès web

Aucun accès web effectué pour ce change. Aucune publication ou modification système réelle.

## 6. Synthèse globale

La validation automatique est réussie dans le périmètre isolé. Le fonctionnement sur une mise à jour APT réelle et les versions effectivement disponibles sur chaque hôte restent non vérifiés. Maintenance des statistiques globales soumise au contrôle de cohérence du registre.


## Change `install-devops-psycopg` — openspec/changes/archive/2026-10-02-install-devops-psycopg/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `install-system-prerequisites` — openspec/changes/archive/2026-09-05-install-system-prerequisites/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `inventory-project-javascript-dependencies-in-devops` — openspec/changes/archive/2026-10-09-inventory-project-javascript-dependencies-in-devops/STATISTICS.md


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


## Change `isolate-created-project-directories` — openspec/changes/archive/2026-11-06-isolate-created-project-directories/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé create-project-directories-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| GPT-6 | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé create-project-directories-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé create-project-directories-2026-11-06

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle GPT-6, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Périmètre | Création des dossiers locaux et initialisation OpenSpec ; session directe. | Change et décision validée. |

## 2. Types de messages et d’outils

### Relevé create-project-directories-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé create-project-directories-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | modules/projects/projects.sh, tests de projets, README.md, TECHNICAL.md, CHANGELOG.md et spécifications associées. | Diff local. |

## 4. Commandes

### Relevé create-project-directories-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Contrôles | 61 tests ciblés, bash -n, ShellCheck, compilation Python et validation OpenSpec stricte réussis. | Résultats du 2026-11-06. |

## 5. Accès web

### Relevé create-project-directories-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 6. Synthèse globale

### Relevé create-project-directories-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Limites | Aucune création réelle ni CI/CD ; télémétrie et borne initiale indisponibles. | Tests sur fixtures. |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "GPT-6",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Périmètre",
            "proof": "Change et décision validée.",
            "value": "Création des dossiers locaux et initialisation OpenSpec ; session directe."
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Diff local.",
            "value": "modules/projects/projects.sh, tests de projets, README.md, TECHNICAL.md, CHANGELOG.md et spécifications associées."
          }
        ],
        "4": [
          {
            "label": "Contrôles",
            "proof": "Résultats du 2026-11-06.",
            "value": "61 tests ciblés, bash -n, ShellCheck, compilation Python et validation OpenSpec stricte réussis."
          }
        ],
        "6": [
          {
            "label": "Limites",
            "proof": "Tests sur fixtures.",
            "value": "Aucune création réelle ni CI/CD ; télémétrie et borne initiale indisponibles."
          }
        ]
      },
      "id": "create-project-directories-2026-11-06",
      "input_sha256": "e0fac12866dcf4dd7a6e189e5373eae4dd9c20b6e48f8b8bc598700fc3b2efc1",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `manage-opencode-v2-github-engine` — openspec/changes/archive/2026-11-14-manage-opencode-v2-github-engine/STATISTICS.md


# Statistiques du change — manage-opencode-v2-github-engine

<!-- CAB_STATISTICS_CURRENT_V1 -->

Change : `manage-opencode-v2-github-engine` · état local : `archived`. Les valeurs absentes restent N/A.

## 1. Statistiques générales et décisions

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | 41169.121073 | Bornes serveur et union des périodes fermées. |
| Durée hors pauses et attentes | 41169.121073 | Bornes serveur et union des périodes fermées. |
| Tokens d’entrée | 209159392 | Périodes CAB : bornes et empreintes de l’export. |
| Tokens de sortie | 647139 | Périodes CAB : bornes et empreintes de l’export. |
| Tokens de raisonnement | 523279 | Périodes CAB : bornes et empreintes de l’export. |
| Tokens de cache lus | 207633792 | Périodes CAB : bornes et empreintes de l’export. |
| Tokens de cache écrits | 0 | Périodes CAB : bornes et empreintes de l’export. |
| Total natif des tokens | 209806531 | Périodes CAB : bornes et empreintes de l’export. |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |


| Rôle | Agent | Modèle | Raisonnement |
| --- | --- | --- | --- |
| coder | codex | N/A | N/A |


Provenance : change-periods:92bfda897f33496e18067b8fbbfb1bb1fafc1321e111e37909023b1d10c566e4

## 2. Messages et outils

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |


## 3. Fichiers et tâches

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |


## 4. Commandes et validations

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 285 | Reçus de runners unittest terminés, référencés par la revue ; aucune déclaration LLM. |
| Tests finaux réussis | 285 | Reçus de runners unittest terminés, référencés par la revue ; aucune déclaration LLM. |
| Tests finaux échoués | 0 | Reçus de runners unittest terminés, référencés par la revue ; aucune déclaration LLM. |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | 13 | Cases locales de tasks.md ; ne valent pas validation du RUN. |


## 5. Accès web

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |


## 6. Synthèse et couverture

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |


<!-- CAB_STATISTICS_CURRENT_END -->
<!-- CAB_STATISTICS_DOCUMENT_V1 {"content_sha256": "61d8049a061dc820c8996042784c09f4aa820ec4274ac9534fbc61f05d54dd1f", "generated_at": "2026-11-14T22:56:10.954099+00:00", "revision": "61d8049a061dc820c8996042784c09f4aa820ec4274ac9534fbc61f05d54dd1f", "scope": "change"} -->


## Change `manage-production-hosts-entries` — openspec/changes/archive/2026-11-04-manage-production-hosts-entries/STATISTICS.md


# Statistiques — manage-production-hosts-entries

## Statistiques générales et décisions

Session SCM directe, Codex, 2026-11-04. Commandes add, del, del all et list sur le seul JSON de production ; génération de hosts depuis ce fichier pour tous les points d'entrée ; tri numérique des IP puis alphabétique des FQDN. Code de lot non attribué ; attribution ultérieure par ACL. Durée, modèle précis, tokens et coût : N/A, mesures indisponibles.

## Types de messages et d'outils

Nombre de messages et appels par type : N/A, comptage exhaustif indisponible. Aucun pilotage OpenCode ni télémétrie CAB.

## Fichiers modifiés

Routage, module réseau, validateur JSON, aides, tests, README, TECHNICAL, CHANGELOG, spécifications, cartographie et registre. Nombre exhaustif de fichiers : N/A, mesure non collectée.

## Commandes

Validation finale : 84 tests ciblés réussis (9 réseau, 60 aides et 15 APT) ; syntaxe Bash et Python, ShellCheck, aide réelle et validation OpenSpec stricte réussies. Une erreur de syntaxe intermédiaire dans les tests a été corrigée avant validation finale. Nombre total de commandes : N/A, comptage exhaustif indisponible.

## Accès web

Aucun accès web recensé pendant cette session.

## Synthèse globale

Quatre tâches validées et change archivé. Tests réalisés sur fixtures isolées ; aucun fichier hosts ou JSON de production n'a été modifié. Attribution du code et statistiques globales à traiter séparément.


## Change `manage-projects-git-safe-directory` — openspec/changes/archive/2026-10-22-manage-projects-git-safe-directory/STATISTICS.md


# STATISTIQUES — safe.directory système des projets

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date de session et d'archive : 22 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, `projects-git-safe-directory`.
- Change : `manage-projects-git-safe-directory`.
- Archive : `2026-10-22-manage-projects-git-safe-directory`.
- Objet : exception safe.directory système exacte pour init/update,
  diagnostic sans écriture pour status, aide et documentation associées.
- Sources de preuve : sorties de commandes de cette session, empreintes
  ciblées, tâches, deltas et [review.md](review.md).

Ce rapport consigne les mesures observées. Il ne lance ni télémétrie de
pilotage, ni service CAB, ni session OpenCode, ni agent délégué.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Durée complète de la session | N/A : aucun chronométrage global initialisé |
| Première série dédiée, 22 tests | 1,420 s, durée fournie par unittest |
| Deuxième série dédiée, 24 tests | 1,798 s, durée fournie par unittest |
| Suite finale groupée, 118 tests | 6,757 s, durée fournie par unittest |
| Total des durées unittest observées | 9,975 s = 1,420 + 1,798 + 6,757 ; hors exploration, édition, lint et OpenSpec |
| Tokens, coût et ressources machine | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie de session |
| Statistiques d'approbations CAB | N/A : protocole CAB non utilisé dans cette session SCM |

## 3. Fichiers et contrat

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 2 | modules/projects/git.sh ; lib/rid-help.sh |
| Tests | 2 | test_rid_help.py modifié ; test_projects_git_safe_directory.py créé |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécifications principales synchronisées | 4 | projects-git-init ; implement-projects-git-update ; projects-git-status ; rid-help |
| Documents de l'archive créée | 9 | proposal.md ; design.md ; tasks.md ; quatre deltas spec.md ; review.md ; STATISTIQUES.md |
| **Total final du périmètre** | **20** | **2 + 2 + 3 + 4 + 9** |

Dix fichiers existants sont modifiés : deux scripts, un test, trois documents
et quatre spécifications. Dix fichiers sont créés : un test et neuf
documents d'archive. Les nouveaux artefacts actifs sont déplacés dans
l'archive par OpenSpec ; aucun fichier préexistant n'est supprimé ou renommé.

Les empreintes des quatre cadrages inchangés (AGENTS.md, PROJECT.md, BUILD.md,
DEVOPS.md), d'openspec/config.yaml et des deux fichiers contrôlés du change
voisin ensure-projects-git-commit-init sont conservées : sept fichiers témoins.
Les exigences antérieures des quatre spécifications synchronisées sont aussi
préservées, par comparaison de leurs empreintes initiales avant les ajouts.

Le contrat livré utilise un chemin absolu canonique, aucun joker ajouté et
un ajout système idempotent. Les erreurs sont explicites, les autres règles
et propriétaires sont préservés. status n'écrit pas safe.directory, même via
ses replis. Les signatures publiques, le questionnaire des variables et
l'initialisation silencieuse sont conservés.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Première série dédiée | 22 | 19 | 3 | 0 | 0 |
| Série dédiée après corrections | 24 | 24 | 0 | 0 | 0 |
| Suite finale groupée | 118 | 118 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **164** | **161** | **3** | **0** | **0** |

Les 118 méthodes de la suite finale se répartissent en 26 tests dédiés,
56 tests d'aide/routage/Git, 9 tests de mise à jour générale et 27 tests de
projets. Ce total est distinct des 164 exécutions cumulées ; les sous-tests
unittest ne sont pas comptés comme des méthodes supplémentaires.
Les trois échecs initiaux sont expliqués et corrigés dans review.md.

| Autre contrôle | État final |
| --- | --- |
| bash -n, chacun des deux scripts | Exécuté et réussi |
| ShellCheck des sept fonctions concernées | Exécuté et réussi, zéro diagnostic |
| ShellCheck du fichier d'aide complet | Exécuté et réussi |
| ShellCheck du fichier Git complet | Exécuté et échoué : SC2034, SC2269 et SC2086 antérieurs et hors périmètre, reproduits sur le contenu initial à SHA-256 identique |
| python3 -m py_compile, deux tests | Exécuté et réussi, caches temporaires isolés puis supprimés |
| Validation stricte du change | Exécutée et réussie avant implémentation et avant archivage |
| Validation stricte des spécifications Git init/update/status synchronisées | Trois exécutées et réussies |
| Validation stricte de rid-help complet | Exécutée et échouée : cinq exigences anciennes trop longues, indices 3, 8, 9, 10, 11 ; mêmes avertissements sur le document initial reconstruit et validé en isolation |
| Delta rid-help ajouté | Inclus dans le change validé strictement, aucun avertissement propre |
| UTF-8/LF, six sections, totaux et tâches | Vérifiés sur le périmètre final par contrôle local après écriture de ce rapport |
| Configuration système réelle et publication | Non exécutées : tous les tests Git utilisent des fichiers temporaires isolés |

## 5. Résultats et archivage

La commande exécutée est :

```bash
/home/devops/.local/npm/bin/openspec archive manage-projects-git-safe-directory --yes
```

Elle retourne zéro et annonce les tâches complètes, la synchronisation
réussie de quatre spécifications et l'archive
`2026-10-22-manage-projects-git-safe-directory`.

| Résultat OpenSpec | Nombre |
| --- | ---: |
| Exigences ajoutées | 6 |
| Exigences modifiées | 0 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Tâches d'implémentation et de validation terminées | 8 sur 8 |
| Changes archivés pendant cette session | 1 |

Les six exigences se répartissent en deux pour init, une pour update, deux
pour status et une pour l'aide. Le change actif ciblé n'existe plus ; son
archive contient le présent rapport et review.md. Aucun autre change n'a
été archivé. Le bilan documentaire par fichier, avec les motifs des cadrages
inchangés et les preuves de cohérence, figure dans review.md.

Commits et pushes du dépôt de travail : zéro. Aucune branche, aucun tag,
aucune release et aucune installation système créés par cette session.
Les fixtures Git temporaires des tests ne représentent pas une publication
ou un commit du dépôt de travail. Aucun réarchivage n'est nécessaire pour
produire ou corriger ce rapport.

## 6. Limites et suites

L'évolution est implémentée, testée et archivée. Le dépôt n'est pas déclaré
exempt de tous diagnostics : trois diagnostics ShellCheck et cinq
avertissements stricts du document rid-help préexistaient à cette évolution
et restent hors périmètre. Aucune règle de validation n'a été désactivée.

Une règle globale prioritaire peut neutraliser la confiance système.
Un include système qui neutralise l'entrée exacte bloque la commande,
sans réordonner les règles administrateur. Une première tentative peut
laisser une entrée inactive, sans doublon supplémentaire aux relances.
Les écritures précédentes restent en place en cas d'échec.

L'installation de production du DIU n'a pas été mise à jour et aucune
exception n'a été ajoutée à la configuration réelle de cette machine.
Les dépôts existants adopteront le comportement lors d'un prochain init ou
update avec les sources livrées et les droits système nécessaires.


## Change `manage-software-engines` — openspec/changes/archive/2026-11-05-manage-software-engines/STATISTICS.md


# Statistiques — gestion des moteurs logiciels

## 1. Statistiques générales et décisions

Session SCM directe du 2026-11-05 réalisée par Codex. Périmètre validé : trois moteurs, migration de la variable Flatpak, conservation des dépendances lors de la désactivation, mise à jour des aides et aucune CI/CD. Aucun sous-agent ni pilotage OpenCode. Modèle exact, durée totale, tokens et coût : N/A, mesures non collectées. Code de lot non attribué, à traiter ultérieurement par ACL.

## 2. Types de messages et d’outils

Lectures, commandes locales, tests isolés et modifications de fichiers. Aucun appel d’outil web ; aucun déploiement ou publication. Les totaux exhaustifs des messages, appels, permissions et écritures sont N/A : aucune télémétrie exhaustive n’a été collectée pour cette session directe.

## 3. Fichiers modifiés

Code : `modules/system/apt.sh`, `modules/system/infos.sh`, `modules/softwares/apt.sh`, `modules/softwares/software.sh`, `modules/softwares/infos.sh`, `modules/softwares/flatpak.sh`, `lib/diu-help.sh` et les déclarations `system_flatpak.sh`, `system_apt_engine.sh`, `system_github_engine.sh`. Tests : `test_software_engines.py`, `test_system_flatpak.py`, `test_software_flatpak.py`, `test_module_infos.py`, `test_system_network_hosts.py`.

Documentation : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`, spécifications des moteurs, de Flatpak, des informations et de l’inventaire, ainsi que les artefacts et rapports du change. `AGENTS.md`, `PROJECT.md`, `BUILD.md` et `DEVOPS.md` sont restés inchangés par cette session. Le nombre exhaustif de fichiers distincts touchés est N/A : les modifications concurrentes n’ont pas été attribuées à ce change.

## 4. Commandes et validations

- Dix scripts Bash contrôlés par `bash -n` et ShellCheck ; compilation Python des cinq fichiers de test concernés.
- Tests ciblés : 10 moteurs, 7 Flatpak système, 9 Flatpak logiciel, 19 informations, 31 logiciels au premier contrôle, 61 aides, 15 APT système et 14 réseau ; reprise des logiciels après modification concurrente : 32 réussis. Les scénarios de couleurs rouge et verte ont aussi été vérifiés isolément.
- Premier lancement global : 1 189 tests, 2 ignorés, aucun échec ; une fixture réseau a été isolée pendant l’exécution.
- Second lancement : 1 189 tests, 2 ignorés, un échec intermittent d’un test de construction Debian ; ce test a réussi isolément. Une modification concurrente de la déclaration Codex CLI a été détectée ; elle a été conservée.
- Troisième lancement final : 1 190 tests exécutés, 1 188 réussis, 2 ignorés, aucun échec ni erreur, 233,065 s. Aucune source ajoutée, modifiée ou supprimée durant ce passage. Les résultats ciblés inclus ne sont pas additionnés au bilan final.
- OpenSpec strict : le change et les six spécifications existantes concernées sont valides. Le contrôle strict global retourne 47 échecs ; un contrôle précédent présentait également 47 échecs. Le nombre exhaustif de commandes et leur ventilation sont N/A, non collectés.

Aucune installation, suppression de paquets ou commande CI/CD réelle n’a été exécutée. Archivage `2026-11-05-manage-software-engines` et synchronisation OpenSpec réussis.

## 5. Accès web

Aucun appel à un outil de recherche ou de consultation web : 0. Les tests utilisent des dépendances simulées et n’exécutent aucune installation ni requête réseau réelle.

## 6. Synthèse globale

Les trois moteurs sont configurables par les commandes `system engine install|remove`. L’activation vérifie les dépendances, la désactivation conserve les paquets et les états désactivés sont reflétés dans l’inventaire. L’ancienne variable Flatpak est reprise si nécessaire ; `UNSET` reste indéterminé. Bilan final : 1 190 = 1 188 réussis + 2 ignorés, sans échec ni erreur. Voir [review.md](review.md).

Archivage et synchronisation réussis le 2026-11-05. Si le rapport global `STATISTICS.md` est absent, mandater SGS pour le générer ; ne pas le créer automatiquement.


## Change `manage-system-drivers-displaylink` — openspec/changes/archive/2026-09-28-manage-system-drivers-displaylink/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `manage-system-network-hosts` — openspec/changes/archive/2026-11-04-manage-system-network-hosts/STATISTICS.md


# Statistiques — manage-system-network-hosts

## Statistiques générales et décisions

Session SCM directe, Codex, 2026-11-04. Périmètre validé : génération système de hosts, commandes et aides, retrait des entrées Docker, synchronisation OpenSpec. Durée, modèle précis, consommation et coût : N/A, mesures indisponibles. Aucun code de lot attribué ; normalisation définitive à traiter par ACL.

## Types de messages et d'outils

Messages et appels par type : N/A, comptage exhaustif indisponible. Aucun pilotage OpenCode ni télémétrie CAB.

## Fichiers modifiés

Module réseau créé ; routeur système, script principal, aides, tests, README, TECHNICAL, CHANGELOG, cartographie et registre adaptés. Spécifications synchronisées et change archivé. Nombre exhaustif de fichiers modifiés : N/A, inventaire Git non utilisé pour ce comptage.

## Commandes

Contrôles finaux : 4 tests réseau, 6 Docker DevOps, 15 APT, 17 informations et 11 mise à jour générale : 53 tests réussis, aucun échec dans ces suites. Bash syntaxe et ShellCheck réussis ; compilation syntaxique de deux tests Python réussie ; aide réelle consultée. Validations OpenSpec strictes finales réussies pour le change puis les deux spécifications ; deux validations intermédiaires du change ont échoué sur la longueur et deux validations des spécifications sur leurs introductions, corrigées ensuite. Total des commandes : N/A, comptage exhaustif non collecté.

## Accès web

Aucun accès web recensé pendant cette session de codage.

## Synthèse globale

Quatre tâches OpenSpec validées et change archivé. Le fichier `/etc/hosts` réel n'a pas été modifié par les tests ; activation en environnement réel non exécutée. Les statistiques globales du projet sont absentes et restent à générer séparément.


## Change `migrate-env-devops-projects-root` — openspec/changes/archive/2026-11-04-migrate-env-devops-projects-root/STATISTICS.md


# Statistiques — migrate-env-devops-projects-root

Change archivé le 2026-11-04 ; les blocages antérieurs sont résolus. Reprise SCM directe du 2026-11-04.

## Statistiques générales et décisions

Un agent direct pour cette reprise. Durée et quotas : N/A, non mesurés. La livraison et le parcours piloté ne sont pas prouvés.

## Types de messages et d’outils

N/A : aucune télémétrie exhaustive disponible.

## Fichiers modifiés

Pour cette reprise : `tasks.md`, `BLOCKERS.md`, `STATISTICS.md`, cartographie, registre et rapports de blocage du change dépendant. Travaux préexistants et concurrents non comptabilisés.

## Commandes

Suite DevOps : 1 160 tests, dont 2 ignorés, sans échec. Tests ciblés : 194 réussis. Bash et OpenSpec strict réussis. ShellCheck -x échoué ; diagnostics détaillés dans le bilan.

## Accès web

Aucun accès web dans cette reprise.

## Synthèse globale

Validation partielle ; livraison, pilotage, synchronisation et archivage en attente. Aucun commit ni publication réalisés dans cette reprise.

Reprise du 2026-11-04 à 08:50 UTC : 127 tests ciblés réussis ; ShellCheck
réussi. Validation globale : 1 163 tests exécutés, dont 2 ignorés et un échec
dans un change concurrent de packaging. Vérification complémentaire : 17 tests
réussis. Les totaux de sessions distinctes ne sont pas additionnés. Change alors ouvert ; blocages historiques résolus.

Validation finale du 2026-11-04 : 1 164 tests exécutés, dont 2 ignorés, sans
échec ; ShellCheck et syntaxe Bash réussis. Les anciens échecs sont conservés
comme historique. Archivage encore à effectuer à cette étape.

Archivage du 2026-11-04 : synchronisation OpenSpec réussie, migration et
correction ShellCheck validées ; 1 164 tests exécutés, dont 2 ignorés. Les
blocages historiques sont résolus. La livraison reste distincte de l’archivage.


## Change `modification-softwares-install-apt-chatgpt` — openspec/changes/archive/2026-09-06-modification-softwares-install-apt-chatgpt/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `modify-projects-clone-pg-database` — openspec/changes/modify-projects-clone-pg-database/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `modify-projects-docker-build` — openspec/changes/archive/2026-09-07-modify-projects-docker-build/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `modify-projects-forgejo-push-force-with-lease` — openspec/changes/modify-projects-forgejo-push-force-with-lease/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `modify-projects-gitpdi` — openspec/changes/archive/2026-09-07-modify-projects-gitpdi/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `move-crowdsec-configuration-to-software-scope` — openspec/changes/archive/2026-11-01-move-crowdsec-configuration-to-software-scope/STATISTICS.md


# Statistiques — move-crowdsec-configuration-to-software-scope

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `move-crowdsec-configuration-to-software-scope`, code de lot non attribué.
- Les contrôles du dépôt APT, de l'agent, du bouncer et la clé API CrowdSec
  relèvent désormais du scope `softwares`.
- `SOFTWARES_APT_CROWDSEC_AGENT` et
  `SOFTWARES_APT_CROWDSEC_BOUNCER` sont `STATIC`, `ENABLE`, défaut `0`.
- Le dépôt CrowdSec conserve la détection des sources existantes et se déduit
  des contrôles agent/bouncer lorsque sa valeur n'est pas déjà configurée.
- Les paquets `crowdsec` et `crowdsec-firewall-bouncer-iptables` sont installés
  par APT.
- La clé API historique est migrée sans affichage ni exécution. Le fichier
  `softwares.env` passe en mode `0600`; le YAML du bouncer est remplacé via un
  fichier temporaire privé, sans passer la clé dans les arguments d'un
  processus enfant.
- Archivage réussi sous
  `2026-11-01-move-crowdsec-configuration-to-software-scope` avec deux
  spécifications ajoutées et quatre modifiées.
- Suite complète DIU avec l'interpréteur `/home/devops/python/current/bin/python3` :
  790 tests réussis, 2 ignorés, aucun échec.
- Publication du paquet DIU et cycle d'exécution dans CISMP non inclus dans ce
  relevé d'archive; ces étapes restent à réaliser.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`, `modules/system/apt.sh`,
  `modules/system/infos.sh`, `modules/softwares/infos.sh`, et quatre modules
  de déclaration CrowdSec sous `modules/diu/variables/softwares/`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_module_infos.py`,
  `tests/test_system_apt_unofficial.py`, `tests/test_system_crowdsec_agent.py`,
  `tests/test_crowdsec_api_key.py`, `tests/test_crowdsec_bouncer.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `legacy-variable-cleanup`, `module-infos`,
  `system-crowdsec-agent`, `system-debian-apt` et `software-apt-crowdsec`.
- Archive : proposition, design, tâches, quatre deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  790 tests réussis, 2 ignorés.
- Tests ciblés de migration, APT, agent, bouncer, clé API et informations des
  modules : réussis.
- `bash -n` sur le point d'entrée, le nettoyage, APT et les modules de
  déclaration CrowdSec : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les six fichiers Python de test modifiés : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  move-crowdsec-configuration-to-software-scope --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  move-crowdsec-configuration-to-software-scope --yes --json` : réussi;
  deux specs ajoutées, quatre modifiées.
- `/home/devops/.local/npm/bin/openspec validate --archived --json
  --no-interactive` : 123/135 changes valides; les 12 échecs concernent des
  tâches incomplètes dans d'autres archives.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le dépôt APT CrowdSec, l'agent, le bouncer et leur clé API sont regroupés sous
le scope logiciels. Les valeurs historiques sont migrées sans modification;
la clé est traitée sans exposition et les fichiers qui la contiennent sont
privés. Les tests, contrôles shell, validation stricte du change et archivage
réussissent. La publication et l'exécution CISMP sont distinctes et restent à
effectuer après ce relevé. Le rapport général `STATISTICS.md` à la racine est
absent; sa production relève du prompt SGS.


## Change `move-hosts-commands-to-system` — openspec/changes/archive/2026-11-04-move-hosts-commands-to-system/STATISTICS.md


# Statistiques — move-hosts-commands-to-system

## Statistiques générales et décisions

Session SCM directe, Codex, 2026-11-04. Commandes hosts déplacées sous system, anciennes syntaxes projects supprimées. Code de lot non attribué ; attribution ultérieure par ACL. Durée, modèle précis, consommation et coût : N/A, données non collectées.

## Types de messages et d'outils

Comptage exhaustif des messages et outils : N/A. Aucun pilotage OpenCode ni télémétrie CAB.

## Fichiers modifiés

Routeurs, aides, tests, documentation, spécification, cartographie et registre. Nombre exhaustif de fichiers : N/A.

## Commandes

Validation finale : 104 tests ciblés réussis (11 réseau, 61 aides, 15 APT, 17 informations). Syntaxe Bash et Python, ShellCheck et validation OpenSpec stricte réussis. Un test d'aide a échoué pendant l'adaptation puis a réussi après correction du texte. Archivage annoncé réussi et présence de l'archive vérifiée ; code de sortie final de la commande d'archivage non observé.

## Accès web

Aucun accès web recensé pendant l'implémentation.

## Synthèse globale

Quatre tâches validées et change archivé. JSON et hosts de production non modifiés par les tests. Code de lot et rapport statistique global à traiter séparément.


## Change `nest-system-engine-update` — openspec/changes/archive/2026-11-06-nest-system-engine-update/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé scm-nest-system-engine-update-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé scm-nest-system-engine-update-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé scm-nest-system-engine-update-2026-11-06

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Périmètre | Migration des mises à jour système sous engine ; sans CI/CD | Validation du périmètre dans la conversation |

## 2. Types de messages et d’outils

### Relevé scm-nest-system-engine-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Collecte | Télémétrie native indisponible ; session directe sans orchestrateur | Historique de session |

## 3. Fichiers modifiés

### Relevé scm-nest-system-engine-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | Routage et aide Bash, tests, documentation et spécifications OpenSpec | Change nest-system-engine-update |

## 4. Commandes

### Relevé scm-nest-system-engine-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation globale | 1212 tests exécutés, 2 ignorés ; Python DevOps 3.14.10 | unittest discover du 2026-11-06 |
| Premier essai | Python système 3.13 : 26 erreurs de préparation venv ; reprise réussie avec Python DevOps | unittest discover du 2026-11-06 |
| Contrôles | Bash -n, ShellCheck, tests ciblés, OpenSpec strict : réussis | Sorties de validation du 2026-11-06 |

## 5. Accès web

### Relevé scm-nest-system-engine-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Accès web | Aucun accès web utilisé | Historique de session |

## 6. Synthèse globale

### Relevé scm-nest-system-engine-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Livraison | Change archivé ; CI/CD non exécutée à la demande | Archivage OpenSpec du 2026-11-06 |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [
          "scm-nest-system-engine-update-2026-11-06"
        ],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Périmètre",
            "proof": "Validation du périmètre dans la conversation",
            "value": "Migration des mises à jour système sous engine ; sans CI/CD"
          }
        ],
        "2": [
          {
            "label": "Collecte",
            "proof": "Historique de session",
            "value": "Télémétrie native indisponible ; session directe sans orchestrateur"
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Change nest-system-engine-update",
            "value": "Routage et aide Bash, tests, documentation et spécifications OpenSpec"
          }
        ],
        "4": [
          {
            "label": "Validation globale",
            "proof": "unittest discover du 2026-11-06",
            "value": "1212 tests exécutés, 2 ignorés ; Python DevOps 3.14.10"
          },
          {
            "label": "Premier essai",
            "proof": "unittest discover du 2026-11-06",
            "value": "Python système 3.13 : 26 erreurs de préparation venv ; reprise réussie avec Python DevOps"
          },
          {
            "label": "Contrôles",
            "proof": "Sorties de validation du 2026-11-06",
            "value": "Bash -n, ShellCheck, tests ciblés, OpenSpec strict : réussis"
          }
        ],
        "5": [
          {
            "label": "Accès web",
            "proof": "Historique de session",
            "value": "Aucun accès web utilisé"
          }
        ],
        "6": [
          {
            "label": "Livraison",
            "proof": "Archivage OpenSpec du 2026-11-06",
            "value": "Change archivé ; CI/CD non exécutée à la demande"
          }
        ]
      },
      "id": "scm-nest-system-engine-update-2026-11-06",
      "input_sha256": "9b1fe10e1e537b111b2b2fb01bdd73e8139008a6f73fba9f33f265cc6e926089",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `prefer-project-venvs-for-devops-dependencies` — openspec/changes/archive/2026-10-09-prefer-project-venvs-for-devops-dependencies/STATISTICS.md


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


## Change `preserve-cab-hmac-key-permissions` — openspec/changes/preserve-cab-hmac-key-permissions/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `prioritize-project-version` — openspec/changes/archive/2026-11-02-prioritize-project-version/STATISTICS.md


# Statistiques — priorité de PROJECT_VERSION

## 1. Statistiques générales et décisions

Session directe SCM du 2026-11-02, plan SCM-PROJECT-VERSION-20261102-R1.
Version de livraison 1.0.0, déjà déclarée dans project.env ; ce fichier reste
inchangé. Un agent Codex, sans délégation, OpenCode, CAB ni sonde de pilotage.
Le change prioritize-project-version est archivé sous
2026-11-02-prioritize-project-version. Quatre tâches validées ; six exigences
ajoutées et trois modifiées dans six capacités synchronisées. Code non attribué,
sans allocation de code ni de sous-lot définitif hors ACL.
Durée totale de session, tokens, coûts, quotas : N/A, pas de mesure exhaustive.

## 2. Types de messages et d'outils

Exploration, proposition du périmètre, validation explicite, suivi et restitution.
Outils : résolution SCM, recherches/lectures ciblées, patches, exécution locale
et validations. Totaux exhaustifs des appels et messages : N/A, sans journal
instrumenté. Aucune télémétrie réservée aux sessions pilotées n'est invoquée.
Les vérifications et publications Git interviennent après ce rapport ; leurs
résultats sont restitués dans le bilan final de la session.

## 3. Fichiers modifiés

Trente-deux livrables dans le périmètre, rapport inclus. L'archivage ne compte
pas comme une seconde création des mêmes fichiers. Les éventuelles modifications
préexistantes du projet ne sont pas attribuées à cette session.

- `lib/project-version.sh`
- `lib/rid-help.sh`
- `modules/projects/git.sh`
- `modules/projects/docker.sh`
- `modules/projects/diu-packaging.sh`
- `modules/projects/debian-build.sh`
- `modules/projects/diu-release.sh`
- `tests/test_project_version.py`
- `tests/test_projects_docker_build_args.py`
- `PROJECT.md`
- `TECHNICAL.md`
- `BUILD.md`
- `README.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `openspec/BATCH_CODES.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/design.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/proposal.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/specs/deb-package/spec.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/specs/forgejo-release/spec.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/specs/modify-projects-docker-build/spec.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/specs/project-version/spec.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/specs/projects-debian-build/spec.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/tasks.md`
- `openspec/specs/project-version/spec.md`
- `openspec/specs/deb-package/spec.md`
- `openspec/specs/projects-debian-build/spec.md`
- `openspec/specs/forgejo-release/spec.md`
- `openspec/specs/modify-projects-docker-build/spec.md`
- `openspec/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-prioritize-project-version/STATISTICS.md`

AGENTS.md, DEVOPS.md, root-install-debian.sh, la recette DIU et project.env ne sont
pas édités par cette session. Le routage existant appelle les fonctions adaptées,
sans nécessiter de modification du point d'entrée.

## 4. Commandes et validations

| Contrôle réellement exécuté | Résultat |
|---|---|
| Lecteur et deux constructeurs Debian | 28 tests réussis ; paquets réels de fixture |
| Sept suites ciblées version, Git, Docker, aide et packaging | 158 tests réussis en 21,959 s |
| Suite complète avec DIU_TEST_GO déclaré | 1 034 tests réussis en 308,793 s ; aucun échec, erreur ou saut |
| Complément final version et aides, dont cicddiu/cicddr | 74 tests réussis en 5,292 s |
| bash -n sur sept fichiers Bash | Réussi |
| ShellCheck sur les sept fichiers, puis aide finale | Réussi sans diagnostic |
| Compilation Python des deux fichiers de tests | Réussie |
| OpenSpec du change strict | Réussi avant archivage |
| openspec archive prioritize-project-version --yes | Réussi ; quatre tâches complètes, six ajouts et trois modifications |
| OpenSpec global standard, avant/après archivage | 117/117 valides |
| OpenSpec global strict, avant/après archivage | 70 valides et 47 refus, même ensemble de sources en échec |
| Canons project-version, deb-package, projects-debian-build, forgejo-release, rid-help | Cinq validations strictes réussies après synchronisation |
| Canon modify-projects-docker-build | Neuf diagnostics stricts historiques identiques avant/après ; standard valide |
| Contrôles documentaires avant archivage | 25 fichiers UTF-8/LF et nouvelles cibles de liens présents |

Les 28, 158 et 74 tests ciblés sont des sous-ensembles ou répétitions ; ils ne
s'ajoutent pas aux 1 034 tests uniques de la suite complète. Le nouveau fichier
contient 16 méthodes de test, dont des scénarios pour les trois fournisseurs.
La fixture Docker déplacée est adaptée uniquement pour retrouver la même
librairie de version ; ses assertions historiques restent conservées.
Les deux échecs de fixtures initiaux (groupe absent et contrôle GitHub non simulé)
sont corrigés puis les suites sont rejouées avec succès, sans affaiblir d'attente.

Les contrôles vérifient l'absence de repli silencieux, la priorité sur recette et
tags, les collisions avant nouveau commit, l'absence de fuite entre projets,
les pushes Git locaux réels sans forçage de tag, l'image locale versionnée,
les refus de paquet/image incohérents et la conservation des mécanismes sans clé.
Aucune installation, migration système ou publication réelle d'artefact n'est
exécutée pendant les tests. Les paquets réels et dépôts Git sont des fixtures
locales nettoyées ; Docker et les API utilisent des transports simulés.

## 5. Accès web

Aucune recherche web ni consultation de documentation distante pour la réalisation.
Les publications Git conditionnelles SCM et la vérification du plugin GitHub
suivent ce rapport ; elles sont distinguées dans le bilan final, sans anticipation
de réussite ni de comptage réseau exhaustif. Aucun secret n'est exposé.

## 6. Synthèse globale

La version optionnelle PROJECT_VERSION est prioritaire pour commits, tags,
pushes, builds et publications Debian/Docker. Une clé absente conserve les
mécanismes précédents. Une clé présente invalide est bloquante. Les collisions
de tags et les artefacts incohérents ne sont pas contournés.
PROJECT, TECHNICAL, BUILD, README et CHANGELOG sont actualisés ; aides, carte,
registre et six capacités sont réconciliés. AGENTS et DEVOPS restent applicables
sans édition ; les mêmes outils et runtimes sont utilisés. La matrice détaillée
et les preuves figurent dans tasks.md. L'installation du DIU n'est pas mise à jour.

La conformité stricte globale n'est pas revendiquée : 47 sources demeurent en
échec, sans nouveau diagnostic imputable au change ; les neuf diagnostics du
canon Docker sont conservés à l'identique. Le lien historique README vers
openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTIQUES.md
reste absent et hors périmètre. Les nouvelles références sont présentes.
Aucun BLOCKER.md/BLOCKERS.md dans cette archive ; aucun nettoyage nécessaire.
STATISTICS.md global absent : mandater SGS.md pour sa génération initiale.
L'attribution définitive du code et des sous-lots reste à traiter via ACL.


## Change `protect-github-push-with-lease` — openspec/changes/archive/2026-09-26-protect-github-push-with-lease/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `public-github-diu-update` — openspec/changes/archive/2026-11-04-public-github-diu-update/STATISTICS.md


# Statistiques de session

## Statistiques générales et décisions

Session SCM directe du 2026-11-04 : change archivé après validation. Le blocage initial lié au Python système a été levé avec le Python DevOps ; suite globale réussie. Durée et consommation : N/A, non mesurées.

## Types de messages et d’outils

Mesures détaillées : N/A, aucune télémétrie collectée. Un agent Codex a réalisé le travail.

## Fichiers modifiés

Moteur, trois fichiers de tests, README, TECHNICAL, CHANGELOG, cartographie, registre et change OpenSpec ; contrat et proposition du change de migration ajustés. Nombre total et lignes : N/A, mesure exhaustive non disponible.

## Commandes

Contrôles ciblés réussis : 10 tests de mise à jour, 3 tests HTTP, 59 tests d’aide, Bash, ShellCheck et deux validations OpenSpec strictes. Suite globale initiale interrompue après erreurs avec Python système ; fixture DEVOPS reproduite puis réussie avec Python DevOps. Suite globale Python DevOps : 1 147 tests, dont 2 ignorés, réussis. Les tests de mise à jour et HTTP ont été relancés après le dernier ajustement.

## Accès web

Aucun accès web de production ; tests HTTP sur serveur local.

## Synthèse globale

Mise à jour anonyme implémentée, validée et archivée. Aucune installation réelle ; commit et publications non effectués à cette étape.


## Change `publish-forgejo-release` — openspec/changes/archive/2026-08-12-publish-forgejo-release/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `publish-native-debian-architecture` — openspec/changes/archive/2026-11-11-publish-native-debian-architecture/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé SCM-CAB-300-DIU-ARCH

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé SCM-CAB-300-DIU-ARCH

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé SCM-CAB-300-DIU-ARCH

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

Correctif DIU nécessaire au paquet natif CAB3.0.0, expressément autorisé. Le change CODING_RULES de la session parallèle a son mandat et ses preuves distincts.

## 2. Types de messages et d’outils

### Relevé SCM-CAB-300-DIU-ARCH

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé SCM-CAB-300-DIU-ARCH

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 4. Commandes

### Relevé SCM-CAB-300-DIU-ARCH

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 58 | QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt |
| Tests finaux réussis | 58 | QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt |
| Tests finaux échoués | 0 | QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt |
| Fichiers ayant passé un contrôle syntaxique | 2 | QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 1 | QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 5. Accès web

### Relevé SCM-CAB-300-DIU-ARCH

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

58 tests ciblés réussis ; syntaxe, ShellCheck et OpenSpec strict réussis.

## 6. Synthèse globale

### Relevé SCM-CAB-300-DIU-ARCH

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

Publication CAB à reprendre sur ses sous-étapes DIU de release, même commit/tag et même paquet ; aucun renommage all ni nouvelle version CAB.


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1"
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "2"
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "58"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md et sortie de la campagne native-architecture-tests.txt"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "58"
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [
          "QUALIFICATION.md"
        ],
        "sessions": [
          "SCM-CAB-300-DIU-ARCH"
        ],
        "web_calls": []
      },
      "id": "SCM-CAB-300-DIU-ARCH",
      "input_sha256": "42e28b3750b47f8f821bde8fbe36980e78a7679e4b47171a8a3f7d29c41c4523",
      "notes": {
        "1": [
          "Correctif DIU nécessaire au paquet natif CAB3.0.0, expressément autorisé. Le change CODING_RULES de la session parallèle a son mandat et ses preuves distincts."
        ],
        "5": [
          "58 tests ciblés réussis ; syntaxe, ShellCheck et OpenSpec strict réussis."
        ],
        "6": [
          "Publication CAB à reprendre sur ses sous-étapes DIU de release, même commit/tag et même paquet ; aucun renommage all ni nouvelle version CAB."
        ]
      },
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `reconcile-cicd-git-publication` — openspec/changes/reconcile-cicd-git-publication/STATISTICS.md


# Statistiques — reconcile-cicd-git-publication

## Statistiques générales et décisions

Session SCM directe du 2026-11-04 ; change ouvert, publication et archivage en attente. Priorité aux fichiers versionnés locaux lors des conflits ; remplacement du tag distant sous lease sans sauvegarde. Les commits sont réservés au développeur. Durée, tokens et coût : N/A, mesures non disponibles.

## Types de messages et d'outils

Comptages exhaustifs par type : N/A, mesures non disponibles. Aucun pilotage OpenCode ni CAB.

## Fichiers modifiés

Code Git et releases, tests, documentation, change OpenSpec, cartographie et registre de codes. Le nombre final de fichiers est à établir à la clôture du change.

## Commandes

Suite globale : 1 182 tests exécutés dont 2 ignorés avec Python 3.14.10. Quatre tests ciblés de fusion et de lease réussis après le complément de test, syntaxe Bash et ShellCheck avec exclusion SC1091 réussis, validation stricte OpenSpec réussie. Une première suite avec Python 3.13 a échoué sur les fixtures venv et deux attentes de messages corrigées.

## Accès web

Lecture par le connecteur GitHub des commits et branches ; aucune écriture distante. Nombre exhaustif d'appels : N/A, mesure non collectée.

## Synthèse globale

Implémentation et contrôles sur fixtures réalisés ; synchronisation des spécifications, publication de `1.2.2` et archivage restent en attente selon [BLOCKERS.md](BLOCKERS.md). Aucun commit créé.


## Change `reconcile-diu-deb-packaging-contract` — openspec/changes/reconcile-diu-deb-packaging-contract/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `reconcile-forgejo-credential-bootstrap` — openspec/changes/reconcile-forgejo-credential-bootstrap/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `refactor-extract-logging` — openspec/changes/archive/2026-08-11-refactor-extract-logging/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refactor-help-command` — openspec/changes/archive/2026-09-12-refactor-help-command/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refactor-projects-git-analyse` — openspec/changes/archive/2026-09-15-refactor-projects-git-analyse/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refactor-projects-git-commit` — openspec/changes/archive/2026-09-15-refactor-projects-git-commit/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refactor-projects-git-init` — openspec/changes/archive/2026-09-13-refactor-projects-git-init/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refactor-projects-git-status` — openspec/changes/archive/2026-09-15-refactor-projects-git-status/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refactor-projects-template-copy` — openspec/changes/archive/2026-10-15-refactor-projects-template-copy/STATISTICS.md


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
existantes de ancien protocole local et pyproject.toml, ainsi que des créations
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


## Change `refine-projects-gitlab-push-config` — openspec/changes/archive/2026-09-07-refine-projects-gitlab-push-config/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refine-system-update-contexts` — openspec/changes/archive/2026-09-05-refine-system-update-contexts/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `refresh-codex-cli-state` — openspec/changes/archive/2026-11-05-refresh-codex-cli-state/STATISTICS.md


# Statistiques — état Codex CLI

## Statistiques générales et décisions

Session directe SCM du 5 novembre 2026, sans CI/CD. `SOFTWARES_APT_CODEX_CLI` est recalculée à chaque chargement selon l'exécutable accessible dans le PATH du DIU. Code de lot non attribué. Durée, tokens et quotas : N/A, mesures non disponibles.

## Types de messages et d'outils

Agent : Codex. Nombre exhaustif de messages et appels d'outils : N/A, télémétrie non collectée.

## Fichiers modifiés

Déclaration `modules/diu/variables/softwares/software_apt_codex_cli.sh`, tests `tests/test_software.py`, cadrage `TECHNICAL.md`, `CHANGELOG.md`, cartographie et registre, spécification `software-management` et artefacts de ce change.

## Commandes

Validation OpenSpec stricte, syntaxe Bash et ShellCheck réussis. Tests ciblés : 32 réussis. Suite globale : 1 190 tests exécutés, dont 2 ignorés, aucun échec. Le premier test ciblé a révélé une attente dépendant du PATH de l'hôte ; il a été isolé puis réexécuté avec succès.

## Accès web

Aucun accès web pendant cette session.

## Synthèse globale

Les transitions de présence et d'absence sont détectées à chaque chargement et persistées lorsque la configuration est accessible. L'archivage OpenSpec a réussi ; aucune installation, CI/CD ou publication n'a été exécutée.


## Change `remove-diu-variables-version` — openspec/changes/archive/2026-11-02-remove-diu-variables-version/STATISTICS.md


# Statistiques — remove-diu-variables-version

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `remove-diu-variables-version`, code de lot non attribué.
- Décision : retirer la déclaration dynamique `DIU_VARIABLES_VERSION`, sa
  ligne de résumé, ses tests et sa spécification canonique. `DIU_VERSION`
  reste la variable affichée pour la version du paquet.
- L’affectation historique `VERSION_VARIABLES` reste supprimée sans transfert;
  les expressions shell ambiguës bloquent le nettoyage.
- La suite complète de référence compte 1006 tests réussis, 2 ignorés et aucun
  échec avec `/home/devops/python/current/bin/python3`.
- Archivage réussi sous `2026-11-02-remove-diu-variables-version`;
  une exigence modifiée et deux retirées dans les spécifications canoniques.
- Publication réussie : paquet `2026.11.02.14.42`, commit `c93fac7`, tag
  `v2026.11.02.14.42`, release Forgejo 403.
- Le paquet a été transféré dans CISMP (LXC 100), SHA-256 vérifié
  (`17b500d967f5cd6f759e7be112490f273c70beb4a56f903e69a5f688d5f0c3d8`), puis
  sa version installée a été vérifiée avec `dpkg-query`.
- Relance de `/root/diu/root-install-debian.sh` dans CISMP : code de sortie 0;
  le résumé affiche `DIU_VERSION` uniquement et aucune erreur de variable ne
  survient.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : retrait de `modules/diu/variables/diu/diu_variables_version.sh`,
  mise à jour de `root-install-debian.sh` et
  `modules/system/variables-cleanup.sh`.
- Tests : retrait de `tests/test_diu_variables_version.py`, mise à jour de
  `tests/test_config_cleanup.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : retrait de `diu-variables-version`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  1006 tests réussis, 2 ignorés.
- Tests ciblés `tests.test_config_cleanup` : 95 tests réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `/home/devops/.local/npm/bin/openspec validate remove-diu-variables-version --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive remove-diu-variables-version --yes --json` :
  réussi; deux exigences retirées et une modifiée.
- `git diff --check` : réussi.
- `sudo -n -i zsh -lic 'rcicddiu'` : publication réussie; release Forgejo 403.
- `sudo -n -i zsh -lic 'ridu'` : mise à jour de l’hôte réussie.
- Installation CISMP par `lxc-attach` après contrôle SHA-256 : réussie.
- Relance `/root/diu/root-install-debian.sh` dans LXC 100 : code 0.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

La déclaration et l’affichage de `DIU_VARIABLES_VERSION` ont été retirés du
code actif, des tests et de la spécification canonique. `DIU_VERSION` reste
pour afficher la version du paquet DIU installé. Les tests, ShellCheck,
syntaxe Bash et validation OpenSpec stricte passent. Publication et
installation CISMP ont réussi. Le script s’est achevé sans erreur de variable;
le résumé conserve `DIU_VERSION`.


## Change `remove-orchestrated-coding-from-sync` — openspec/changes/archive/2026-11-03-remove-orchestrated-coding-from-sync/STATISTICS.md


# Statistiques — remove-orchestrated-coding-from-sync

## 1. Périmètre

Correction de la synchronisation unitaire et groupée ; code de lot non attribué.

## 2. Résultat

Le document ancien protocole local est exclu de la synchronisation ; la création de projet reste inchangée.

## 3. Fichiers

Code : modules/projects/projects.sh ; tests : tests/test_projects_orchestrated_copy.py ; documentation : README.md, CHANGELOG.md, DEVELOPMENT_MAP.md ; spécification : openspec/specs/projects-sync/spec.md et archive du change.

## 4. Validations

Le 2026-11-03 : 10 tests orchestrated copy, 8 tests development map et 32 tests projects réussis ; bash -n et ShellCheck réussis ; validation stricte du change réussie. Total : 50 tests.

## 5. Mesures de session

Durée, jetons, appels et télémétrie : N/A, mesures non disponibles.

## 6. Limites

La commande réelle sync all n'a pas été lancée sur les projets utilisateur. Aucun commit, push ou incrément de version.


## Change `remove-projects-sync-devops` — openspec/changes/archive/2026-10-02-remove-projects-sync-devops/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `remove-software-deb-engine` — openspec/changes/archive/2026-11-05-remove-software-deb-engine/STATISTICS.md


# Statistiques — suppression du moteur logiciel deb

## Statistiques générales et décisions

Session directe SCM du 5 novembre 2026. Retrait du moteur logiciel `deb`, sans modification du moteur APT et sans CI/CD. Code de lot non attribué. Durée, consommation et quotas : N/A, mesures non disponibles.

## Types de messages et d'outils

Codex a réalisé la session et coordonné les fichiers partagés avec la session de convergence des commandes. Décompte exhaustif des messages et appels : N/A, télémétrie non collectée.

## Fichiers modifiés

Code : `modules/softwares/software.sh`, `root-install-debian.sh`, `lib/diu-help.sh` ; suppression de `modules/softwares/deb.sh`. Tests : `tests/test_software.py` et `tests/test_remove_software_deb_engine.py`. Documentation : `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`. Spécification : `openspec/specs/software-management/spec.md` et artefacts de ce change.

## Commandes

Validation OpenSpec stricte réussie ; syntaxe Bash et Python, ShellCheck, 31 tests logiciels, un test de refus, 61 tests d'aide et 9 tests ShellCheck ciblés réussis. La suite globale partagée a exécuté 1 177 tests, dont 2 ignorés, sans échec ; résultat communiqué par la session de convergence sur l'état partagé. Un premier passage de 1 177 tests avait échoué sur l'ancienne empreinte Zsh, corrigée par cette session et revérifiée.

## Accès web

Aucun accès web pour ce change ; coordination via l'outil de conversations Codex.

## Synthèse globale

Le moteur logiciel `deb` et ses commandes sont retirés. Les commandes de construction de paquets Debian et le moteur APT sont conservés. L'archivage OpenSpec a réussi le 5 novembre 2026. Aucun commit, déploiement ou CI/CD n'a été exécuté.


## Change `remove-softwares-apt-update` — openspec/changes/archive/2026-11-06-remove-softwares-apt-update/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé scm-remove-softwares-apt-update-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| GPT-6 | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé scm-remove-softwares-apt-update-2026-11-06

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé scm-remove-softwares-apt-update-2026-11-06

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle GPT-6, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Session | SCM directe, sans orchestration ni CI/CD | Validation du périmètre par le développeur |

## 2. Types de messages et d’outils

### Relevé scm-remove-softwares-apt-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé scm-remove-softwares-apt-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | modules/softwares/apt.sh ; lib/diu-help.sh ; tests/test_software.py ; tests/test_diu_help.py ; CHANGELOG.md ; OpenSpec ; DEVELOPMENT_MAP.md ; openspec/BATCH_CODES.md | Fichiers modifiés |

## 4. Commandes

### Relevé scm-remove-softwares-apt-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Tests | 34 tests logiciels et 63 tests aide réussis ; suite globale 1 220 tests dont 2 ignorés | unittest discover ; Python DevOps pour la suite globale |
| Contrôles | bash -n, ShellCheck, py_compile et OpenSpec strict réussis | Commandes exécutées en session |

## 5. Accès web

### Relevé scm-remove-softwares-apt-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Web | Aucun accès web effectué | Historique de session |

## 6. Synthèse globale

### Relevé scm-remove-softwares-apt-update-2026-11-06

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Limites | Télémétrie native et borne de début non collectées ; pas de CI/CD ni pilotage CAB | Session directe |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "GPT-6",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [
          "scm-remove-softwares-apt-update-2026-11-06"
        ],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Session",
            "proof": "Validation du périmètre par le développeur",
            "value": "SCM directe, sans orchestration ni CI/CD"
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Fichiers modifiés",
            "value": "modules/softwares/apt.sh ; lib/diu-help.sh ; tests/test_software.py ; tests/test_diu_help.py ; CHANGELOG.md ; OpenSpec ; DEVELOPMENT_MAP.md ; openspec/BATCH_CODES.md"
          }
        ],
        "4": [
          {
            "label": "Tests",
            "proof": "unittest discover ; Python DevOps pour la suite globale",
            "value": "34 tests logiciels et 63 tests aide réussis ; suite globale 1 220 tests dont 2 ignorés"
          },
          {
            "label": "Contrôles",
            "proof": "Commandes exécutées en session",
            "value": "bash -n, ShellCheck, py_compile et OpenSpec strict réussis"
          }
        ],
        "5": [
          {
            "label": "Web",
            "proof": "Historique de session",
            "value": "Aucun accès web effectué"
          }
        ],
        "6": [
          {
            "label": "Limites",
            "proof": "Session directe",
            "value": "Télémétrie native et borne de début non collectées ; pas de CI/CD ni pilotage CAB"
          }
        ]
      },
      "id": "scm-remove-softwares-apt-update-2026-11-06",
      "input_sha256": "25fb8512523a48ea5df6dc377050f58283b3d08abb4b4490f7285e2f73e1e52b",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `rename-bunkerweb-upgrade-variable` — openspec/changes/archive/2026-11-02-rename-bunkerweb-upgrade-variable/STATISTICS.md


# Statistiques — rename-bunkerweb-upgrade-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-bunkerweb-upgrade-variable`, code de lot non attribué.
- Contrat validé : `DOCKER_STACK_BUNKERWEB_UPDATE`, `STATIC`, `ENABLE`, scope
  `docker`, défaut `0`.
- La dernière valeur historique littérale
  `DOCKER_STACK_BUNKERWEB_UPGRADE=0|1` est transférée exactement vers
  `docker.env`, sauf si le nouveau nom y est déjà configuré.
- Les réglages `DOCKER_STACK_BUNKERWEB_AUTO_UPDATE` et
  `DOCKER_STACK_BUNKERWEB_VERSION` restent distincts.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  991 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-bunkerweb-upgrade-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/docker/docker_stack_bunkerweb_update.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_docker_stack_bunkerweb_update.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `docker-stack-bunkerweb-update`, mise
  à jour de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  991 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration BunkerWeb : 96 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-bunkerweb-upgrade-variable --strict` : valide.
- `openspec archive rename-bunkerweb-upgrade-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le réglage de mise à jour BunkerWeb utilise désormais
`DOCKER_STACK_BUNKERWEB_UPDATE`, déclaré `STATIC/ENABLE` dans le scope `docker`,
avec un défaut `0`. La valeur historique littérale est migrée; le nouveau
réglage déjà configuré reste prioritaire. Les sélecteurs d’auto-update et de
version restent indépendants. La suite complète compte 991 tests réussis et 2
ignorés; ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec
stricte passent. Publication et relance dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.


## Change `rename-desktop-toggle-to-desktop-scope` — openspec/changes/archive/2026-11-02-rename-desktop-toggle-to-desktop-scope/STATISTICS.md


# Statistiques — rename-desktop-toggle-to-desktop-scope

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-desktop-toggle-to-desktop-scope`, code de lot non attribué.
- Contrat : variable `DESKTOP`, `STATIC`, `ENABLE`, scope `desktop`, défaut `0`.
- La valeur existante `SOFTWARES_APT_DESKTOP=0|1` dans `softwares.env` est
  transférée exactement vers `DESKTOP` dans `desktop.env`, sauf si un `DESKTOP`
  est déjà déclaré dans `desktop.env`.
- Une ancienne affectation `DESKTOP=0|1` de `variables.sh` est aussi migrée.
  La valeur persistée sous `SOFTWARES_APT_DESKTOP` prévaut sur cette valeur
  historique lorsqu'aucun `DESKTOP` nouveau n'existe.
- Archivage réussi sous `2026-11-02-rename-desktop-toggle-to-desktop-scope`,
  avec une spécification ajoutée et trois modifiées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 798 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet et nouvel essai dans CISMP restent à effectuer après
  ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`, `modules/desktop/infos.sh`,
  `modules/softwares/infos.sh`, ajout de
  `modules/diu/variables/desktop/desktop.sh` et retrait de l'ancienne
  déclaration logicielle.
- Tests : `tests/test_config_cleanup.py`, `tests/test_module_infos.py` et
  `tests/test_software_apt_desktop.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `legacy-variable-cleanup`, `module-infos` et
  `software-apt-desktop`.
- Archive : proposition, design, tâches, trois deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  798 tests réussis, 2 ignorés.
- Tests ciblés de déclaration `DESKTOP`, migration et informations des modules
  : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/desktop/desktop.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_software_apt_desktop.py
  tests/test_config_cleanup.py tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  rename-desktop-toggle-to-desktop-scope --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  rename-desktop-toggle-to-desktop-scope --yes --json` : réussi; une spec
  ajoutée, trois modifiées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

`DESKTOP` réside désormais dans le scope `desktop`. `config_cleanup` préserve
les valeurs déjà persistées sous `SOFTWARES_APT_DESKTOP` et respecte la priorité
de `desktop.env`. Les tests, contrôles Bash, validation stricte et archivage
réussissent. Publication et relance DIU dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève du
prompt SGS.


## Change `rename-env-devops-activation-variable` — openspec/changes/archive/2026-11-02-rename-env-devops-activation-variable/STATISTICS.md


# Statistiques — rename-env-devops-activation-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-env-devops-activation-variable`, code de lot non attribué.
- Contrat : `ENVIRONMENTS_DEVOPS`, `STATIC`, `ENABLE`, scope
  `environnements`, défaut `0`.
- L'ancienne valeur littérale `ENV_DEVOPS=0|1` est transférée exactement vers
  `environnements.env`; les valeurs `ENVIRONMENTS_DEVOPS` déjà configurées
  restent prioritaires.
- Les affectations historiques `ENV_DEVOPS` sont supprimées après migration,
  sans toucher aux noms voisins comme `ENV_DEVOPS_USER`.
- Archivage réussi sous `2026-11-02-rename-env-devops-activation-variable`,
  avec trois spécifications ajoutées et deux modifiées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 805 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet et nouvel essai dans CISMP restent à effectuer après
  ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`, `modules/environments/infos.sh` et
  `modules/diu/variables/environnements/env_devops.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_python.py`,
  `tests/test_devops_sudoers.py`, `tests/test_environment_devops.py` et
  `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `devops-environment`, `legacy-variable-cleanup`,
  `module-infos`, `devops-python` et `devops-sudoers`.
- Archive : proposition, design, tâches, cinq deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  805 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, Python, Sudoers et informations des
  modules : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/environnements/env_devops.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_environment_devops.py
  tests/test_config_cleanup.py tests/test_devops_sudoers.py
  tests/test_devops_python.py tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  rename-env-devops-activation-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  rename-env-devops-activation-variable --yes --json` : réussi; trois specs
  ajoutées, deux modifiées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle d'activation du profil DevOps est déclaré comme
`ENVIRONMENTS_DEVOPS` dans le scope `environnements`. Les valeurs historiques
`ENV_DEVOPS=0|1` sont migrées sans modification et les valeurs déjà configurées
gardent la priorité. Tests, contrôles Bash, validation stricte et archivage
réussissent. Publication et relance DIU dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève du
prompt SGS.


## Change `rename-env-docker-activation-variable` — openspec/changes/archive/2026-11-02-rename-env-docker-activation-variable/STATISTICS.md


# Statistiques — rename-env-docker-activation-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-env-docker-activation-variable`, code de lot non attribué.
- Contrat validé : `ENVIRONMENT_DOCKER`, `STATIC`, `ENABLE`, scope
  `environnements`, défaut `0`.
- La dernière valeur littérale `ENV_DOCKER=0|1` est transférée exactement vers
  `environnements.env`; les valeurs `ENVIRONMENT_DOCKER` déjà configurées
  gardent la priorité.
- Les anciens exports `ENV_DOCKER` sont supprimés après migration, sans
  toucher aux noms voisins comme `ENV_DOCKER_USER` et `ENV_DOCKER_GROUP`.
- Archivage réussi sous `2026-11-02-rename-env-docker-activation-variable`,
  avec trois spécifications ajoutées et une modifiée.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 811 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet et prochain essai CISMP restent à effectuer après ce
  relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/environnements/environment_docker.sh`,
  `modules/environments/infos.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_sudoers.py`,
  `tests/test_environment_docker.py`, `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `docker-environment`, `legacy-variable-cleanup`,
  `module-infos`, `docker-sudoers`.
- Archive : proposition, design, tâches, trois deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  811 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, Sudoers Docker et informations des
  modules : réussis.
- `bash -n root-install-debian.sh modules/system/variables-cleanup.sh
  modules/diu/variables/environnements/environment_docker.sh` : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile tests/test_environment_docker.py
  tests/test_config_cleanup.py tests/test_devops_sudoers.py
  tests/test_module_infos.py` : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  rename-env-docker-activation-variable --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  rename-env-docker-activation-variable --yes --json` : réussi; trois specs
  ajoutées, une modifiée.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle de provisionnement Docker est déclaré comme `ENVIRONMENT_DOCKER`
dans le scope `environnements`. La valeur historique `ENV_DOCKER=0|1` est
migrée exactement, la priorité de la nouvelle variable est respectée et les
variables suffixées restent intactes. Tests, ShellCheck, syntaxe et validation
OpenSpec stricte réussissent. Publication et relance DIU dans CISMP restent à
effectuer. Le rapport général `STATISTICS.md` à la racine est absent; sa
production relève du prompt SGS.


## Change `rename-env-ia-activation-variable` — openspec/changes/archive/2026-11-02-rename-env-ia-activation-variable/STATISTICS.md


# Statistiques — rename-env-ia-activation-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-env-ia-activation-variable`, code de lot non attribué.
- Contrat validé : `ENVIRONMENT_IA`, `STATIC`, `ENABLE`, scope
  `environnements`, défaut `0`.
- La dernière valeur historique littérale `ENV_IA=0|1` est transférée
  exactement vers `environnements.env`, sauf si `ENVIRONMENT_IA` y est déjà
  configurée; les variables suffixées `ENV_IA_USER`, `ENV_IA_GROUP` et
  `ENV_IA_PASSWORD` restent distinctes.
- Archivage réussi sous `2026-11-02-rename-env-ia-activation-variable`;
  trois spécifications ajoutées.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 823 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/environnements/environment_ia.sh`,
  `modules/environments/infos.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_devops_sudoers.py`,
  `tests/test_environment_ia.py`, `tests/test_module_infos.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `environment-ia`, `legacy-variable-cleanup`,
  `module-infos`.
- Archive : proposition, design, tâches, trois deltas de spécification et ce
  rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  823 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration, génération sudoers et informations
  des modules : réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-env-ia-activation-variable --strict` : valide.
- `openspec archive rename-env-ia-activation-variable --yes --json` : réussi;
  trois spécifications ajoutées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le provisionnement IA utilise désormais `ENVIRONMENT_IA`, déclaré en
`STATIC/ENABLE` dans le scope `environnements`, avec un défaut `0`. La valeur
historique exacte `ENV_IA=0|1` est migrée, la nouvelle valeur configurée reste
prioritaire et les variables suffixées ne sont pas renommées. Les contrôles
OpenSpec, Bash, ShellCheck, compilation Python et 823 tests passent. La
publication et la relance dans CISMP restent à effectuer. Le rapport général
`STATISTICS.md` à la racine est absent; sa production relève du prompt SGS.


## Change `rename-fastfetch-variable` — openspec/changes/archive/2026-11-02-rename-fastfetch-variable/STATISTICS.md


# Statistiques — rename-fastfetch-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-fastfetch-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_FASTFETCH`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `FASTFETCH=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà
  configuré.
- Le comportement APT existant est conservé : neofetch sur Debian
  bullseye/bookworm et fastfetch sur trixie.
- Archivage réussi sous `2026-11-02-rename-fastfetch-variable`; trois
  exigences ajoutées dans deux spécifications.
- Suite complète DIU avec `/home/devops/python/current/bin/python3` : 831 tests
  réussis, 2 ignorés, aucun échec.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_fastfetch.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_fastfetch.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-fastfetch`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  831 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Fastfetch : 56 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-fastfetch-variable --strict` : valide.
- `openspec archive rename-fastfetch-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle d’installation est désormais `SOFTWARES_APT_FASTFETCH`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `FASTFETCH=0|1` est migrée, le nouveau réglage déjà configuré
reste prioritaire, et les paquets APT existants par version Debian sont
conservés. La suite complète compte 831 tests réussis et 2 ignorés; ShellCheck,
syntaxe Bash, compilation Python et validation OpenSpec stricte passent. La
publication et la relance dans CISMP restent à effectuer. Le rapport général
`STATISTICS.md` à la racine est absent; sa production relève du prompt SGS.


## Change `rename-jsvc-variable` — openspec/changes/archive/2026-11-02-rename-jsvc-variable/STATISTICS.md


# Statistiques — rename-jsvc-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-jsvc-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_JSVC`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `JSVC=0|1` est transférée exactement
  vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  839 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-jsvc-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_jsvc.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_software_apt_jsvc.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-jsvc`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  839 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration jsvc : 58 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-jsvc-variable --strict` : valide.
- `openspec archive rename-jsvc-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle jsvc utilise désormais `SOFTWARES_APT_JSVC`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `JSVC=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. La suite complète compte 839 tests réussis et 2 ignorés;
ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec stricte
passent. La publication et la relance dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.


## Change `rename-lemonldap-variable` — openspec/changes/archive/2026-11-02-rename-lemonldap-variable/STATISTICS.md


# Statistiques — rename-lemonldap-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-lemonldap-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_LEMONLDAP`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `LEMONLDAP=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- `SYSTEM_APT_LEMONLDAP` demeure le réglage distinct du dépôt APT et utilise
  `SOFTWARES_APT_LEMONLDAP` comme repli initial uniquement quand aucune source
  LemonLDAP n’est détectée et qu’aucune valeur système n’est déjà définie.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  847 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-lemonldap-variable`; quatre exigences
  ajoutées dans trois spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_lemonldap.sh`,
  `modules/diu/variables/system/system_apt_unofficial.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_lemonldap.py`,
  `tests/test_system_apt_unofficial.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-lemonldap`, mise à jour
  de `legacy-variable-cleanup` et `system-debian-apt`.
- Archive : proposition, conception, tâches, trois deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  847 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration et dépôt APT : 76 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-lemonldap-variable --strict` : valide.
- `openspec archive rename-lemonldap-variable --yes --json` : réussi;
  trois spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle d’installation LemonLDAP-NG utilise désormais
`SOFTWARES_APT_LEMONLDAP`, déclaré `STATIC/ENABLE` dans le scope `softwares`,
avec un défaut `0`. La valeur historique exacte `LEMONLDAP=0|1` est migrée et
le nouveau réglage déjà configuré reste prioritaire. `SYSTEM_APT_LEMONLDAP`
reste le réglage système du dépôt et utilise la nouvelle variable seulement
comme repli initial. La suite complète compte 847 tests réussis et 2 ignorés;
ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec stricte
passent. Publication et relance dans CISMP restent à effectuer. Le rapport
général `STATISTICS.md` à la racine est absent; sa production relève du prompt
SGS.


## Change `rename-mongodb-variable` — openspec/changes/archive/2026-11-02-rename-mongodb-variable/STATISTICS.md


# Statistiques — rename-mongodb-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-mongodb-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_MONGODB`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `MONGODB=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- `MONGODB_VERSION` reste inchangée et distincte. `SYSTEM_APT_MONGODB` demeure
  le réglage système explicite du dépôt et utilise le nouveau contrôle logiciel
  comme repli initial, avec la version historique pour choisir la branche.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  855 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-mongodb-variable`; quatre exigences
  ajoutées dans trois spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_mongodb.sh`,
  `modules/diu/variables/system/system_apt_unofficial.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_mongodb.py`,
  `tests/test_system_apt_unofficial.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-mongodb`, mise à jour
  de `legacy-variable-cleanup` et `system-debian-apt`.
- Archive : proposition, conception, tâches, trois deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  855 tests réussis, 2 ignorés.
- Tests ciblés de déclaration, migration et dépôt APT : 78 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-mongodb-variable --strict` : valide.
- `openspec archive rename-mongodb-variable --yes --json` : réussi;
  trois spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle d’installation MongoDB utilise désormais
`SOFTWARES_APT_MONGODB`, déclaré `STATIC/ENABLE` dans le scope `softwares`,
avec un défaut `0`. La valeur historique exacte `MONGODB=0|1` est migrée;
`MONGODB_VERSION` reste inchangée, et la valeur système du dépôt `SYSTEM_APT_MONGODB`
reste prioritaire lorsqu’elle est déjà configurée. La suite complète compte
855 tests réussis et 2 ignorés; ShellCheck, syntaxe Bash, compilation Python et
validation OpenSpec stricte passent. Publication et relance dans CISMP restent
à effectuer. Le rapport général `STATISTICS.md` à la racine est absent; sa
production relève du prompt SGS.


## Change `rename-omada-variable` — openspec/changes/archive/2026-11-02-rename-omada-variable/STATISTICS.md


# Statistiques — rename-omada-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-omada-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_OMADA`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `OMADA=0|1` est transférée exactement
  vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- `OMADA_VERSION` et `SYSLOG_SERVER_SKIL_OMADA` restent inchangées; le nouveau
  réglage pilote le téléchargement et l’installation Omada ainsi que les règles
  firewall concernées.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  871 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-omada-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_omada.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_software_apt_omada.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-omada`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  871 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Omada : 66 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-omada-variable --strict` : valide.
- `openspec archive rename-omada-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Omada utilise désormais `SOFTWARES_APT_OMADA`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `OMADA=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. `OMADA_VERSION` et `SYSLOG_SERVER_SKIL_OMADA` sont
préservées. La suite complète compte 871 tests réussis et 2 ignorés; ShellCheck,
syntaxe Bash, compilation Python et validation OpenSpec stricte passent.
Publication et relance dans CISMP restent à effectuer. Le rapport général
`STATISTICS.md` à la racine est absent; sa production relève du prompt SGS.


## Change `rename-openjdk-variable` — openspec/changes/archive/2026-11-02-rename-openjdk-variable/STATISTICS.md


# Statistiques — rename-openjdk-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-openjdk-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_OPENJDK`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `OPENJDK=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Le comportement par Debian est conservé : OpenJDK 17 sur Bullseye/Bookworm,
  OpenJDK 21 sur Trixie.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  863 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-openjdk-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_openjdk.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_software_apt_openjdk.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-openjdk`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  863 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration OpenJDK : 64 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-openjdk-variable --strict` : valide.
- `openspec archive rename-openjdk-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle OpenJDK utilise désormais `SOFTWARES_APT_OPENJDK`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `OPENJDK=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. Les branches APT Java 17/21 selon Debian sont conservées. La
suite complète compte 863 tests réussis et 2 ignorés; ShellCheck, syntaxe Bash,
compilation Python et validation OpenSpec stricte passent. Publication et
relance dans CISMP restent à effectuer. Le rapport général `STATISTICS.md` à
la racine est absent; sa production relève du prompt SGS.


## Change `rename-openvswitch-variable` — openspec/changes/archive/2026-11-02-rename-openvswitch-variable/STATISTICS.md


# Statistiques — rename-openvswitch-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-openvswitch-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_OPENVSWITCH`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `OPENVSWITCH=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  879 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-openvswitch-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_openvswitch.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_openvswitch.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-openvswitch`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  879 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Open vSwitch : 68 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-openvswitch-variable --strict` : valide.
- `openspec archive rename-openvswitch-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Open vSwitch utilise désormais `SOFTWARES_APT_OPENVSWITCH`,
déclaré `STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La
valeur historique exacte `OPENVSWITCH=0|1` est migrée et le nouveau réglage
déjà configuré reste prioritaire. L’installation APT d’`openvswitch-switch`
reste conditionnelle. La suite complète compte 879 tests réussis et 2 ignorés;
ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec stricte
passent. Publication et relance dans CISMP restent à effectuer. Le rapport
général `STATISTICS.md` à la racine est absent; sa production relève du prompt
SGS.


## Change `rename-postfix-variable` — openspec/changes/archive/2026-11-02-rename-postfix-variable/STATISTICS.md


# Statistiques — rename-postfix-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-postfix-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_POSTFIX`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `POSTFIX=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- `POSTFIX_RELAY_HOST` reste distinct et conserve la configuration `relayhost`.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  895 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-postfix-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_postfix.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_software_apt_postfix.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-postfix`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  895 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Postfix : 72 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-postfix-variable --strict` : valide.
- `openspec archive rename-postfix-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Postfix utilise désormais `SOFTWARES_APT_POSTFIX`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `POSTFIX=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. `POSTFIX_RELAY_HOST` continue à configurer le relais. La suite
complète compte 895 tests réussis et 2 ignorés; ShellCheck, syntaxe Bash,
compilation Python et validation OpenSpec stricte passent. Publication et
relance dans CISMP restent à effectuer. Le rapport général `STATISTICS.md` à
la racine est absent; sa production relève du prompt SGS.


## Change `rename-postgresql-variable` — openspec/changes/archive/2026-11-02-rename-postgresql-variable/STATISTICS.md


# Statistiques — rename-postgresql-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-postgresql-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_POSTGRESQL`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `POSTGRESQL=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  887 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-postgresql-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_postgresql.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_postgresql.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-postgresql`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  887 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration PostgreSQL : 70 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-postgresql-variable --strict` : valide.
- `openspec archive rename-postgresql-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle du serveur PostgreSQL utilise désormais
`SOFTWARES_APT_POSTGRESQL`, déclaré `STATIC/ENABLE` dans le scope `softwares`,
avec un défaut `0`. La valeur historique exacte `POSTGRESQL=0|1` est migrée et
le nouveau réglage déjà configuré reste prioritaire. La suite complète compte
887 tests réussis et 2 ignorés; ShellCheck, syntaxe Bash, compilation Python et
validation OpenSpec stricte passent. Publication et relance dans CISMP restent
à effectuer. Le rapport général `STATISTICS.md` à la racine est absent; sa
production relève du prompt SGS.


## Change `rename-projects-network-hosts-commands` — openspec/changes/archive/2026-11-04-rename-projects-network-hosts-commands/STATISTICS.md


# Statistiques — rename-projects-network-hosts-commands

## Statistiques générales et décisions

Session SCM directe, Codex, 2026-11-04. Nouvelles commandes `projects system network hosts` ; anciennes commandes sans `hosts` supprimées ; aides adaptées. Code de lot non attribué, attribution ultérieure par ACL. Durée, modèle précis, consommation et coût : N/A, mesures indisponibles.

## Types de messages et d'outils

Comptage exhaustif des messages et outils : N/A, non collecté. Aucun pilotage OpenCode ni télémétrie CAB.

## Fichiers modifiés

Routage, aides, tests, README, TECHNICAL, CHANGELOG, cartographie, registre et spécification OpenSpec. Nombre exhaustif de fichiers : N/A, mesure non collectée.

## Commandes

Validation finale : 72 tests ciblés réussis (11 réseau et 61 aides), syntaxe Bash et Python et ShellCheck réussis. Validation OpenSpec stricte du change réussie ; validation de la spécification échouée sur longueur après archivage, corrigée et réussie ensuite. Nombre total de commandes : N/A, comptage exhaustif indisponible.

## Accès web

Aucun accès web recensé pendant cette session.

## Synthèse globale

Quatre tâches validées et change archivé. Routage et aides vérifiés sur fixtures isolées ; aucun JSON ou hosts de production modifié. Attribution du code et rapport statistique global à traiter séparément.


## Change `rename-qemu-guest-agent-variable` — openspec/changes/archive/2026-11-02-rename-qemu-guest-agent-variable/STATISTICS.md


# Statistiques — rename-qemu-guest-agent-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-qemu-guest-agent-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_QEMU_GUEST_AGENT`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `QEMU_GUEST_AGENT=0|1` est
  transférée exactement vers `softwares.env`, sauf si le nouveau nom y est déjà
  configuré.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  903 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-qemu-guest-agent-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_qemu_guest_agent.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_qemu_guest_agent.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-qemu-guest-agent`, mise
  à jour de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  903 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration : 74 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-qemu-guest-agent-variable --strict` : valide.
- `openspec archive rename-qemu-guest-agent-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle d’installation `qemu-guest-agent` utilise désormais
`SOFTWARES_APT_QEMU_GUEST_AGENT`, déclaré `STATIC/ENABLE` dans le scope
`softwares`, avec un défaut `0`. La valeur historique exacte
`QEMU_GUEST_AGENT=0|1` est migrée et le nouveau réglage déjà configuré reste
prioritaire. La suite complète compte 903 tests réussis et 2 ignorés; ShellCheck,
syntaxe Bash, compilation Python et validation OpenSpec stricte passent.
Publication et relance dans CISMP restent à effectuer. Le rapport général
`STATISTICS.md` à la racine est absent; sa production relève du prompt SGS.


## Change `rename-ssh-server-variable` — openspec/changes/archive/2026-11-02-rename-ssh-server-variable/STATISTICS.md


# Statistiques — rename-ssh-server-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-ssh-server-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_SSH_SERVER`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `SSH=0|1` est transférée exactement
  vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Les deux consommateurs utilisent la nouvelle variable; les valeurs
  `KEY_SSH_ADMIN` et `KEY_SSH_ACME` restent distinctes.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  927 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-ssh-server-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_ssh_server.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_ssh_server.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-ssh-server`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  927 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration OpenSSH : 80 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-ssh-server-variable --strict` : valide.
- `openspec archive rename-ssh-server-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle OpenSSH utilise désormais `SOFTWARES_APT_SSH_SERVER`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `SSH=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. Les clés `KEY_SSH_ADMIN` et `KEY_SSH_ACME` restent séparées.
La suite complète compte 927 tests réussis et 2 ignorés; ShellCheck, syntaxe
Bash, compilation Python et validation OpenSpec stricte passent. Publication et
relance dans CISMP restent à effectuer. Le rapport général `STATISTICS.md` à
la racine est absent; sa production relève du prompt SGS.


## Change `rename-syncthing-variable` — openspec/changes/archive/2026-11-02-rename-syncthing-variable/STATISTICS.md


# Statistiques — rename-syncthing-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-syncthing-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_SYNCTHING`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `SYNCTHING=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Les deux consommateurs utilisent la nouvelle variable : installation APT et
  préparation conditionnelle du fichier `.stignore`.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  935 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-syncthing-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_syncthing.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_syncthing.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-syncthing`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  935 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Syncthing : 82 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-syncthing-variable --strict` : valide.
- `openspec archive rename-syncthing-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Syncthing utilise désormais `SOFTWARES_APT_SYNCTHING`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `SYNCTHING=0|1` est migrée et le nouveau réglage déjà
configuré reste prioritaire. Les blocs d’installation APT et de préparation de
`.stignore` restent conditionnels. La suite complète compte 935 tests réussis
et 2 ignorés; ShellCheck, syntaxe Bash, compilation Python et validation
OpenSpec stricte passent. Publication et relance dans CISMP restent à effectuer.
Le rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.


## Change `rename-syslog-client-variable` — openspec/changes/archive/2026-11-02-rename-syslog-client-variable/STATISTICS.md


# Statistiques — rename-syslog-client-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-syslog-client-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_SYSLOG_CLIENT`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `SYSLOG_CLIENT=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- `SYSLOG_CLIENT_SERVER` reste distinct et configure la destination distante.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  911 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-syslog-client-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_syslog_client.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_syslog_client.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-syslog-client`, mise à
  jour de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  911 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration syslog : 76 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-syslog-client-variable --strict` : valide.
- `openspec archive rename-syslog-client-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le client rsyslog utilise désormais `SOFTWARES_APT_SYSLOG_CLIENT`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `SYSLOG_CLIENT=0|1` est migrée et le nouveau réglage déjà
configuré reste prioritaire. `SYSLOG_CLIENT_SERVER` conserve l’adresse distante.
La suite complète compte 911 tests réussis et 2 ignorés; ShellCheck, syntaxe
Bash, compilation Python et validation OpenSpec stricte passent. Publication et
relance dans CISMP restent à effectuer. Le rapport général `STATISTICS.md` à
la racine est absent; sa production relève du prompt SGS.


## Change `rename-syslog-server-variable` — openspec/changes/archive/2026-11-02-rename-syslog-server-variable/STATISTICS.md


# Statistiques — rename-syslog-server-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-syslog-server-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_SYSLOG_SERVER`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `SYSLOG_SERVER=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Les options `SYSLOG_SERVER_SKIL_*` restent distinctes pour sélectionner les
  catégories de journaux.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  919 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-syslog-server-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_syslog_server.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_syslog_server.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-syslog-server`, mise à
  jour de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  919 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration syslog : 78 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-syslog-server-variable --strict` : valide.
- `openspec archive rename-syslog-server-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le serveur rsyslog utilise désormais `SOFTWARES_APT_SYSLOG_SERVER`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `SYSLOG_SERVER=0|1` est migrée et le nouveau réglage déjà
configuré reste prioritaire. Les options `SYSLOG_SERVER_SKIL_*` conservent la
sélection des catégories de journaux. La suite complète compte 919 tests
réussis et 2 ignorés; ShellCheck, syntaxe Bash, compilation Python et validation
OpenSpec stricte passent. Publication et relance dans CISMP restent à effectuer.
Le rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.


## Change `rename-system-rc-local-variable` — openspec/changes/archive/2026-11-02-rename-system-rc-local-variable/STATISTICS.md


# Statistiques — rename-system-rc-local-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-system-rc-local-variable`, code de lot non attribué.
- Contrat validé : `SYSTEM_RC_LOCAL`, `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- La dernière valeur historique littérale `RCLOCAL=0|1` est transférée
  exactement vers `system.env`, sauf si le nouveau nom y est déjà configuré.
- Le consommateur conserve le comportement conditionnel de génération et de
  permissions de `/etc/rc.local`.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  983 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-system-rc-local-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/system/system_rc_local.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_system_rc_local.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `system-rc-local`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  983 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration RC.local : 94 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-system-rc-local-variable --strict` : valide.
- `openspec archive rename-system-rc-local-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle de `/etc/rc.local` utilise désormais `SYSTEM_RC_LOCAL`, déclaré
`STATIC/ENABLE` dans le scope `system`, avec un défaut `0`. La valeur
historique exacte `RCLOCAL=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. La suite complète compte 983 tests réussis et 2 ignorés;
ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec stricte
passent. Publication et relance dans CISMP restent à effectuer. Le rapport
général `STATISTICS.md` à la racine est absent; sa production relève du prompt
SGS.


## Change `rename-traefik-dockhand-upgrade-variable` — openspec/changes/archive/2026-11-02-rename-traefik-dockhand-upgrade-variable/STATISTICS.md


# Statistiques — rename-traefik-dockhand-upgrade-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-traefik-dockhand-upgrade-variable`, code de lot non
  attribué.
- Contrat validé : `DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE`, `STATIC`, `ENABLE`,
  scope `docker`, défaut `0`.
- La dernière valeur historique littérale
  `DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE=0|1` est transférée exactement vers
  `docker.env`, sauf si le nouveau nom y est déjà configuré.
- `DOCKER_STACK_TRAEFIK_DOCKHAND_AUTO_UPDATE` et
  `DOCKER_STACK_TRAEFIK_DOCKHAND_VERSION` restent distincts.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  999 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-traefik-dockhand-upgrade-variable`;
  trois exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/docker/docker_stack_traefik_dockhand_update.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_docker_stack_traefik_dockhand_update.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `docker-stack-traefik-dockhand-update`,
  mise à jour de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  999 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Traefik/Dockhand : 98 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-traefik-dockhand-upgrade-variable --strict` : valide.
- `openspec archive rename-traefik-dockhand-upgrade-variable --yes --json` :
  réussi; deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le réglage de mise à jour de la stack Traefik/Dockhand utilise désormais
`DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE`, déclaré `STATIC/ENABLE` dans le scope
`docker`, avec un défaut `0`. La valeur historique exacte est migrée et le
nouveau réglage déjà configuré reste prioritaire. Les sélecteurs d’auto-update
et de version ne changent pas. La suite complète compte 999 tests réussis et 2
ignorés; ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec
stricte passent. Publication et relance dans CISMP restent à effectuer. Le
rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.


## Change `rename-wazuh-client-variable` — openspec/changes/archive/2026-11-02-rename-wazuh-client-variable/STATISTICS.md


# Statistiques — rename-wazuh-client-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-wazuh-client-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_WAZUH_AGENT`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `WAZUH_CLIENT=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- `WAZUH_CLIENT_VERSION` reste le sélecteur distinct de version du paquet.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  951 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-wazuh-client-variable`; trois
  exigences ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_wazuh_agent.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_wazuh_agent.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-wazuh-agent`, mise à jour
  de `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  951 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Wazuh client : 86 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-wazuh-client-variable --strict` : valide.
- `openspec archive rename-wazuh-client-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle de l’agent Wazuh utilise désormais `SOFTWARES_APT_WAZUH_AGENT`,
déclaré `STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La
valeur historique exacte `WAZUH_CLIENT=0|1` est migrée et le nouveau réglage
déjà configuré reste prioritaire. `WAZUH_CLIENT_VERSION` reste distincte. La
suite complète compte 951 tests réussis et 2 ignorés; ShellCheck, syntaxe Bash,
compilation Python et validation OpenSpec stricte passent. Publication et
relance dans CISMP restent à effectuer. Le rapport général `STATISTICS.md` à
la racine est absent; sa production relève du prompt SGS.


## Change `rename-wazuh-server-variable` — openspec/changes/archive/2026-11-02-rename-wazuh-server-variable/STATISTICS.md


# Statistiques — rename-wazuh-server-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-wazuh-server-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_WAZUH_SERVER`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `WAZUH_SERVER=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Le repli d’initialisation de `SYSTEM_APT_WAZUH` utilise le nouveau contrôle
  logiciel avec `WAZUH_SERVER_UPGRADE`; cette variable de mise à niveau reste
  distincte.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  959 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-wazuh-server-variable`; quatre
  exigences ajoutées dans trois spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_wazuh_server.sh`,
  `modules/diu/variables/system/system_apt_unofficial.sh`.
- Tests : `tests/test_config_cleanup.py`,
  `tests/test_software_apt_wazuh_server.py`,
  `tests/test_system_apt_unofficial.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-wazuh-server`, mise à
  jour de `legacy-variable-cleanup` et `system-debian-apt`.
- Archive : proposition, conception, tâches, trois deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  959 tests réussis, 2 ignorés.
- Tests ciblés du contrôle Wazuh Server, de sa migration et du dépôt APT :
  104 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-wazuh-server-variable --strict` : valide.
- `openspec archive rename-wazuh-server-variable --yes --json` : réussi;
  trois spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Wazuh Server utilise désormais `SOFTWARES_APT_WAZUH_SERVER`,
déclaré `STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La
valeur historique exacte `WAZUH_SERVER=0|1` est migrée et le nouveau réglage
déjà configuré reste prioritaire. Le repli du dépôt `SYSTEM_APT_WAZUH` conserve
le rôle de `WAZUH_SERVER_UPGRADE`. La suite complète compte 959 tests réussis
et 2 ignorés; ShellCheck, syntaxe Bash, compilation Python et validation
OpenSpec stricte passent. Publication et relance dans CISMP restent à effectuer.
Le rapport général `STATISTICS.md` à la racine est absent; sa production relève
du prompt SGS.


## Change `rename-webmin-variable` — openspec/changes/archive/2026-11-02-rename-webmin-variable/STATISTICS.md


# Statistiques — rename-webmin-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-webmin-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_WEBMIN`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `WEBMIN=0|1` est transférée
  exactement vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- `SYSTEM_APT_WEBMIN` reste le réglage système distinct du dépôt APT.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  943 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-webmin-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_webmin.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_software_apt_webmin.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-webmin`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  943 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Webmin : 84 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-webmin-variable --strict` : valide.
- `openspec archive rename-webmin-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle d’installation Webmin utilise désormais `SOFTWARES_APT_WEBMIN`,
déclaré `STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La
valeur historique exacte `WEBMIN=0|1` est migrée et le nouveau réglage déjà
configuré reste prioritaire. `SYSTEM_APT_WEBMIN` demeure distinct pour le dépôt
APT. La suite complète compte 943 tests réussis et 2 ignorés; ShellCheck,
syntaxe Bash, compilation Python et validation OpenSpec stricte passent.
Publication et relance dans CISMP restent à effectuer. Le rapport général
`STATISTICS.md` à la racine est absent; sa production relève du prompt SGS.


## Change `rename-zoom-variable` — openspec/changes/archive/2026-11-02-rename-zoom-variable/STATISTICS.md


# Statistiques — rename-zoom-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-zoom-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_ZOOM`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `ZOOM=0|1` est transférée exactement
  vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  967 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-zoom-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_zoom.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_software_apt_zoom.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-zoom`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  967 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Zoom : 90 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-zoom-variable --strict` : valide.
- `openspec archive rename-zoom-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Zoom utilise désormais `SOFTWARES_APT_ZOOM`, déclaré
`STATIC/ENABLE` dans le scope `softwares`, avec un défaut `0`. La valeur
historique exacte `ZOOM=0|1` est migrée et le nouveau réglage déjà configuré
reste prioritaire. Le parcours existant du paquet Debian Zoom est conservé. La
suite complète compte 967 tests réussis et 2 ignorés; ShellCheck, syntaxe Bash,
compilation Python et validation OpenSpec stricte passent. Publication et
relance dans CISMP restent à effectuer. Le rapport général `STATISTICS.md` à
la racine est absent; sa production relève du prompt SGS.


## Change `rename-zsh-variable` — openspec/changes/archive/2026-11-02-rename-zsh-variable/STATISTICS.md


# Statistiques — rename-zsh-variable

Date de clôture documentaire : 2026-11-02. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `rename-zsh-variable`, code de lot non attribué.
- Contrat validé : `SOFTWARES_APT_ZSH`, `STATIC`, `ENABLE`, scope
  `softwares`, défaut `0`.
- La dernière valeur historique littérale `ZSH=0|1` est transférée exactement
  vers `softwares.env`, sauf si le nouveau nom y est déjà configuré.
- Le comportement APT et de configuration Zsh/Fish est conservé.
- La suite complète DIU avec `/home/devops/python/current/bin/python3` compte
  975 tests réussis, 2 ignorés, aucun échec.
- Archivage réussi sous `2026-11-02-rename-zsh-variable`; trois exigences
  ajoutées dans deux spécifications.
- Publication du paquet, installation LXC et relance de l’installateur restent
  à effectuer après ce relevé.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d’outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`,
  `modules/diu/variables/softwares/software_apt_zsh.sh`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_software_apt_zsh.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : ajout de `software-apt-zsh`, mise à jour de
  `legacy-variable-cleanup`.
- Archive : proposition, conception, tâches, deux deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  975 tests réussis, 2 ignorés.
- Tests ciblés de déclaration et migration Zsh : 92 réussis.
- `bash -n` sur les scripts Bash modifiés : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les fichiers Python modifiés : réussi.
- `openspec validate rename-zsh-variable --strict` : valide.
- `openspec archive rename-zsh-variable --yes --json` : réussi;
  deux spécifications archivées.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le contrôle Zsh utilise désormais `SOFTWARES_APT_ZSH`, déclaré `STATIC/ENABLE`
dans le scope `softwares`, avec un défaut `0`. La valeur historique exacte
`ZSH=0|1` est migrée et le nouveau réglage déjà configuré reste prioritaire.
Les installations et configurations Zsh/Fish conditionnelles sont
préservées. La suite complète compte 975 tests réussis et 2 ignorés;
ShellCheck, syntaxe Bash, compilation Python et validation OpenSpec stricte
passent. Publication et relance dans CISMP restent à effectuer. Le rapport
général `STATISTICS.md` à la racine est absent; sa production relève du prompt
SGS.


## Change `reorder-projects-template-devops` — openspec/changes/archive/2026-10-02-reorder-projects-template-devops/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `reorder-projects-template-openspec` — openspec/changes/archive/2026-10-02-reorder-projects-template-openspec/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `replay-cicd-existing-version` — openspec/changes/archive/2026-11-03-replay-cicd-existing-version/STATISTICS.md


# Statistiques — replay-cicd-existing-version

## Statistiques générales et décisions

- Session SCM directe du 2026-11-03, livraison locale 1.0.9, code non attribué.
- Un tag existant est rejoué depuis son commit isolé, sans intégrer les modifications locales ni ramener une branche distante en arrière.
- Sur décision de fonctionnement, la publication Docker est ignorée en rejeu tant que l'immutabilité du tag distant n'est pas vérifiée ; Debian reste indépendant.
- Durée totale et tokens : N/A, mesures exhaustives indisponibles.

## Types de messages et d'outils

- Exécution directe par Codex, sans délégation à un agent de codage.
- Décompte exhaustif des messages et outils : N/A, journal agrégé indisponible.

## Fichiers modifiés

- Orchestration Git, constructeur Docker, publications Debian Forgejo et GitHub, aides et tests associés.
- README, BUILD, TECHNICAL, CHANGELOG, Development Map et registre des codes ; quatre spécifications synchronisées et change archivé. Le delta actif Forgejo lié a été maintenu cohérent.
- PROJECT_VERSION mis à jour localement dans project.env, hors Git. Modifications préexistantes du projet comprises dans le commit demandé. Nombre de lignes : N/A.

## Commandes

- Suite globale avec le Python DevOps : 1 119 tests exécutés, dont 2 ignorés, sans échec, en 251,513 secondes. Les dernières modifications ont également été vérifiées par les tests ciblés.
- Dix tests ciblés de rejeu réussis, dont paquet Debian réel de fixture, contexte Docker sans identifiants, préservation de l'index, répétition et nettoyage sur interruption.
- Syntaxe Bash, ShellCheck du périmètre, compilation Python et validation OpenSpec : change et quatre spécifications stricts, 119 éléments valides en contrôle global standard.
- Décompte exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

- Consultation des spécifications OCI Distribution et de la documentation GitLab sur l'immutabilité des tags. Aucune publication d'artefact de production effectuée par cette session.

## Synthèse globale

Rejeu isolé, contrôles et documentation validés ; change archivé. Les registres Docker non vérifiés ne sont pas publiés pendant le rejeu. La construction et la publication des paquets de production restent à la charge du développeur.


## Change `report-and-display-system-hosts` — openspec/changes/archive/2026-11-04-report-and-display-system-hosts/STATISTICS.md


# Statistiques — report-and-display-system-hosts

## Statistiques générales et décisions

Session SCM directe, Codex, 2026-11-04. Consultation de hosts et résultat concis pour la mise à jour ciblée ; CI/CD explicitement exclue. Code de lot non attribué, attribution ultérieure par ACL. Durée, modèle, tokens et coût : N/A, mesures indisponibles.

## Types de messages et d'outils

Comptage exhaustif des messages et outils : N/A, non collecté. Aucun pilotage OpenCode ni télémétrie CAB.

## Fichiers modifiés

Modules système, routeur principal, aides, tests, documentation, spécification OpenSpec, cartographie et registre. Nombre exhaustif de fichiers : N/A.

## Commandes

Validation finale : 107 tests ciblés réussis (14 réseau, 61 aides, 15 APT et 17 informations), syntaxe Bash et Python, ShellCheck et OpenSpec strict réussis. Nombre total de commandes : N/A.

## Accès web

Aucun accès web recensé pendant cette session.

## Synthèse globale

Quatre tâches validées et change archivé. Tests sur fixtures ; aucun hosts ni JSON de production modifié. CI/CD non exécutée, conformément au périmètre. Attribution du code et rapport global à traiter séparément.


## Change `report-sudoers-human-accounts` — openspec/changes/archive/2026-10-02-report-sudoers-human-accounts/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `restore-diu-forgejo-fallback` — openspec/changes/archive/2026-11-03-restore-diu-forgejo-fallback/STATISTICS.md


# Statistiques — restore-diu-forgejo-fallback

## Statistiques générales et décisions

Session SCM directe du 2026-11-03, agent Codex. GitHub demeure prioritaire et Forgejo sert uniquement de secours lors de la recherche. La version locale est passée de 1.1.1 à 1.1.2. Durée, tokens et coût : N/A, mesures non collectées.

## Types de messages et d’outils

Échanges de cadrage et validation du développeur, lectures, commandes, modifications et vérifications. Totaux exhaustifs des messages et appels : N/A, télémétrie non collectée. Aucun agent délégué.

## Fichiers modifiés

Moteur `modules/diu/update.sh`, aide `lib/rid-help.sh`, test `tests/test_diu_package_update.py`, `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`, canon `openspec/specs/diu-package-update/spec.md`, configuration locale `project.env` et artefacts de cette archive. Nombre total de fichiers et de lignes : N/A, absence de mesure exhaustive.

## Commandes

Validation finale : 1 124 tests exécutés, dont 2 ignorés, sans échec ; 7 tests ciblés de priorité et secours inclus dans cette suite, non additionnés. Contrôles réussis : syntaxe Bash et ShellCheck pour deux scripts ; compilation syntaxique Python pour un fichier ; validation OpenSpec stricte du change et du canon ; archivage et synchronisation. Les tests utilisent des réponses simulées. Comptage exhaustif des commandes : N/A.

## Accès web

Aucun appel à un outil web pour cette implémentation. Tests sans consultation réelle des fournisseurs et sans installation réelle de DIU. Les éventuelles publications Git de fin de session sont distinctes et leur résultat figure dans le bilan de session.

## Synthèse globale

Trois tâches validées ; sauvegarde des priorités, contrôles et alias. Un échec de téléchargement ou d'installation ne déclenche aucun nouveau fournisseur. L'archive ne prouve pas une livraison ni une activation. Le rapport global racine étant absent, sa maintenance est non applicable ; mandater SGS pour sa création. Le code de lot et les sous-lots définitifs attendent ACL.


## Change `restore-forgejo-push-to-create` — openspec/changes/restore-forgejo-push-to-create/STATISTICS.md


Change ouvert sans session de codage enregistrée ; STATISTICS.md non attendu.


## Change `safe-package-rotation` — openspec/changes/archive/2026-08-12-safe-package-rotation/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `skip-unavailable-git-providers` — openspec/changes/archive/2026-10-16-skip-unavailable-git-providers/STATISTICS.md


# STATISTIQUES — Fournisseurs Git indisponibles

## 1. Identification et périmètre

Date : 16 octobre 2026, Europe/Paris. Change :
`skip-unavailable-git-providers`. Archive :
`2026-10-16-skip-unavailable-git-providers`.

Session SCM directe. Périmètre : pushes Git Forgejo/GitLab/GitHub, opérations
API/fetch nécessaires, poursuite CI/CD, parcours Forgejo groupé, tests,
documentation, spécifications et archivage ciblé. Les releases lancées
directement et les clonages conservent leur gestion d'erreur.

Aucun commit, push, appel API réel, build Docker, déploiement ou installation
système n'est exécuté. Aucun état Git ni fichier sensible réel n'est consulté.
Les tokens, mots de passe, configurations et outils des tests sont factices.
Aucune compétence statistique de pilotage, aucun agent délégué, OpenCode/CAB
ou sonde de pilotage ne sont utilisés.

## 2. Durées et mesures disponibles

Référence SHA-256 (UTC) : 2026-10-16T06:03:44.118346+00:00.
Contrôle final : 2026-10-16T08:23:28.379354+02:00, Europe/Paris.
Intervalle observé : 1184.261 s, distinct de la durée de la conversation.
Somme des durées unittest : 33,712 s.

Tokens, coût, compte exhaustif des messages/outils et durées des agents : N/A,
aucune télémétrie de pilotage n'est activée pour SCM. Statistiques Git de
lignes : N/A, aucune inspection Git. Agents délégués : 0.
Paquets système installés par la session : 0.

## 3. Fichiers et cohérence documentaire

Vingt-deux références préexistantes sont suivies par SHA-256 :
douze modifiées dans le périmètre, une modifiée en parallèle et préservée,
neuf identiques. Treize fichiers nouveaux sont livrés : un module de tests,
une spécification principale et onze fichiers dans l'archive. Dix fichiers
du change sont créés puis déplacés ; ces catégories ne s'additionnent pas.

Fichiers préexistants modifiés dans le périmètre :

- `modules/projects/git.sh` : contexte privé de push, classification Git/curl,
  résultat public non bloquant, statut CI/CD et parcours Forgejo groupé.
- `lib/forgejo-auth.sh` : transport contextualisé, statuts HTTP de vérification,
  authentification initiale et création de token.
- `lib/github-auth.sh` : transport et qualification des réponses API.
- `TECHNICAL.md`, `README.md`, `CHANGELOG.md` : contrat et limites.
- `openspec/specs/git-auth/spec.md`.
- `openspec/specs/projects-cicd/spec.md`.
- `openspec/specs/implement-projects-forgejo-push/spec.md`.
- `openspec/specs/implement-projects-gitlab-push/spec.md`.
- `openspec/specs/implement-projects-github-push/spec.md`.
- `openspec/specs/projects-forgejo-push-all/spec.md`.

Nouveaux fichiers hors archive :
`tests/test_projects_provider_unavailable.py` et
`openspec/specs/git-provider-availability/spec.md`.

L'archive conserve `proposal.md`, `design.md`, `tasks.md`, sept deltas
`specs/*/spec.md` et ce rapport. Les copies et artefacts temporaires
régénérables de qualification ont été nettoyés avant archivage.

| Élément de la matrice SCM | État et preuve |
|---|---|
| Projet réel | Pannes reconnues non bloquantes ; erreurs réelles conservées ; tests de branche/tag/API/fetch, poursuite et nettoyage réussis. |
| AGENTS.md | Inchangé, empreinte identique ; règles et autorisations conservées. |
| PROJECT.md | Inchangé, empreinte identique ; architecture, fournisseurs et objectifs préservés. |
| TECHNICAL.md | Mis à jour, section « Indisponibilité pendant une publication Git ». |
| BUILD.md | Inchangé, empreinte identique ; packaging Debian hors correction. |
| DEVOPS.md | Modification parallèle conservée sans écriture par la session : relevé passé de 05:51:15Z à 06:11:02Z et OpenCode détecté en 1.19.2 au lieu d'absent. Aucun lancement ni installation OpenCode par la session. |
| README.md | Mis à jour : résultat zéro, publication non confirmée, poursuite, releases ignorées et erreurs bloquantes. |
| CHANGELOG.md | Entrée Unreleased ajoutée, sans version ni publication inventée. |
| openspec/specs/ | Sept capacités synchronisées ; 43 exigences et 81 scénarios au total ; corps normatifs identiques aux versions prospectives qualifiées. |

Les neuf références identiques sont `AGENTS.md`, `PROJECT.md`, `BUILD.md`,
`PROMPTS/SCM.md`, `openspec/config.yaml`, `lib/gitlab-auth.sh`,
`tests/test_projects.py`, `tests/test_rid_help.py` et
`root-install-debian.sh`. La bibliothèque GitLab n'a pas besoin d'une
modification propre : elle utilise déjà le cœur Git commun.
Les autres changes actifs ne sont pas traités.

## 4. Tests et vérifications

| Exécution unittest | Méthodes | Réussites | Échecs | Erreurs | Durée s |
|---|---:|---:|---:|---:|---:|
| Indisponibilités initiales | 13 | 13 | 0 | 0 | 5,748 |
| Aide et publications existantes | 56 | 56 | 0 | 0 | 1,457 |
| Indisponibilités enrichies | 16 | 16 | 0 | 0 | 8,539 |
| CI/CD et releases existantes | 8 | 8 | 0 | 0 | 0,584 |
| Indisponibilités après qualification des délais | 16 | 16 | 0 | 0 | 7,143 |
| Indisponibilités finales, bootstrap compris | 17 | 17 | 0 | 0 | 8,578 |
| Aide et publications finales | 56 | 56 | 0 | 0 | 1,663 |
| Total, répétitions incluses | 182 | 182 | 0 | 0 | 33,712 |

Résultat final : **81 méthodes distinctes réussies**, dont 17 nouvelles
méthodes paramétrées, 56 existantes d'aide/publication et huit existantes de
CI/CD/releases. Les sous-tests ne sont pas additionnés aux méthodes.

Commandes exécutées avec un TMPDIR de validation sous le dépôt et
`PYTHONDONTWRITEBYTECODE=1` :

- `python3 -m unittest discover -s tests -p test_projects_provider_unavailable.py -v` :
  exécutée et réussie.
- `python3 -m unittest discover -s tests -p test_rid_help.py` :
  exécutée et réussie.
- `python3 -m unittest discover -s tests -p test_projects.py -k cicd -k github_release -k gitlab_docker -v` :
  exécutée et réussie.

Couverture : DNS, proxy DNS, connexion impossible, timeout, résolution trop
lente, transfert trop lent, HTTP 502/503/504 ; API, vérification des credentials
Forgejo, initialisation Forgejo, fetch, branche et tag ; poursuite des autres
fournisseurs, build local, releases ignorées, échec réel ultérieur, parcours
groupé, nettoyage et statut remis à zéro. Authentification, TLS, rejet,
message distant ambigu et 128 générique restent bloquants.
Les fichiers de configuration fixtures et les identifiants factices ne sont
ni modifiés par la qualification des pushes ordinaires ni divulgués.
Un Git hors contexte conserve son code 128 et ses diagnostics précédents.

Autres validations :

- `bash -n` sur les trois fichiers Bash modifiés : exécutée et réussie.
- Compilation Python du nouveau test par `py_compile.compile(...,
  doraise=True)`, dans un temporaire nettoyé : exécutée et réussie.
- ShellCheck complet : exécuté et échoué uniquement sur SC2034, SC2269,
  SC2086 historiques du module Git. Comparaison structurée des codes,
  niveaux et messages avec les copies initiales : identique. Les deux
  bibliothèques modifiées n'ont aucun diagnostic. Aucun nouveau diagnostic.
- UTF-8/LF, empreintes et périmètre : exécutés et réussis après qualification
  de la modification parallèle de DEVOPS.md ; le premier contrôle strict
  du périmètre s'était arrêté sur cette modification non produite par la session.
- Validation stricte du change : exécutée et réussie avant code et avant archive.
- Validation prospective des sept capacités, comparée aux six versions
  initiales : cinq réussites et deux avertissements de longueur hérités,
  dans l'exigence « identifiants Forgejo » et la sélection des projets de
  `forgejo push all`. Leurs corps sont inchangés ; aucun nouvel avertissement.
  Les exigences GitHub et CI/CD modifiées sont désormais sous la limite.
- Validation stricte après synchronisation : cinq capacités réussies et les
  deux mêmes avertissements hérités. Le premier contrôle de la nouvelle
  capacité avait détecté le Purpose provisoire généré par l'outil ; son objet
  a été rédigé dans la spécification principale puis validé strictement.
- Publication réelle, clonage réel, build Docker et mise à jour du DIU installé :
  non exécutés, hors périmètre.

Un premier patch documentaire s'est arrêté sur un contexte différent dans
TECHNICAL.md ; aucun fichier n'avait été modifié par ce patch. Il a été repris
sur le contexte effectivement observé. Aucun test n'a été affaibli ni ignoré
pour obtenir une réussite.

## 5. Résultats et archivage

Une indisponibilité reconnue donne « serveur indisponible — publication non
confirmée, reprise nécessaire », sans erreur DIU et avec code public zéro.
`git_with_token` conserve le code Git original. Le résumé CI/CD indique
« terminé avec indisponibilités », poursuit les fournisseurs disponibles et
le build activé, puis ignore les releases concernées.

Un contexte privé transmet le signal au travers des sous-shells API.
Les diagnostics natifs sont classés de façon restrictive ; un code 128 seul
ou un texte préfixé `remote:` ne suffit pas. Les invites interactives ne sont
pas redirigées. Le contexte et les temporaires sont nettoyés après les appels ;
les signaux HUP/INT/TERM disposent également d'un nettoyage du contexte.
Les appels curl contextualisés sont bornés à 10 s de connexion et 30 s au
total, sans sonde préalable ni retry automatique.

Archivage officiel exécuté une seule fois sous le compte devops :

`/home/devops/.local/npm/bin/openspec archive skip-unavailable-git-providers --json --yes`

Code de sortie : 0. Réponse : `specsUpdated=true`, sept exigences ajoutées,
cinq modifiées, zéro supprimée et zéro renommée. Sept tâches cochées.
Les sept ensembles de corps normatifs synchronisés correspondent aux versions
prospectives qualifiées. Le Purpose finalisé est une métadonnée documentaire ;
aucun second archivage n'est exécuté.

Le présent rapport comporte six sections. Les totaux, UTF-8/LF, les tâches,
la cohérence des deltas et les fichiers finaux sont contrôlés à la clôture.

## 6. Limites et suites

Une connexion perdue pendant un tag peut laisser la branche déjà publiée.
Le résultat reste non confirmé ; aucune annulation automatique n'est tentée.
Une reprise est nécessaire pour achever la publication.

Une panne non reconnue reste une erreur explicite. En particulier, le code
128 n'est jamais ignoré globalement. Les droits des comptes et la disponibilité
des services réels ne sont pas qualifiés par les fixtures.
Clonages et releases directes gardent leur contrat antérieur.

Les trois diagnostics ShellCheck et les deux avertissements OpenSpec hérités
restent hors correction et sont explicitement signalés. Les suites générales
sans rapport avec le flux de publication ne sont pas relancées. Le libellé
Docker initial d'un résumé interrompu n'est pas corrigé ici.
Le DIU installé n'est pas mis à jour et aucune publication réelle n'est faite.


## Change `software-configuration-lifecycle` — openspec/changes/archive/2026-11-13-software-configuration-lifecycle/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

Agrégat de périodes CAB bornées, plusieurs RUN et SID possibles ; aucun total historique de session repris.

Couverture du change incomplète : périodes ouvertes ou RUN sans attestation de début de codage ; totaux SGS indisponibles, mesures des seules périodes conservées séparément.

## 2. Types de messages et d’outils

### Relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

Les mesures natives portent les incréments observés entre instantanés ; pas de ventilation à l’intérieur d’un événement natif ou des événements tardifs.

## 4. Commandes

### Relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 5. Accès web

### Relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 6. Synthèse globale

### Relevé cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [
          "change-periods:d51adf8ac5a7f789cb299da132c25f87c7c710bcc67269fc4106c685b5b9ada4"
        ],
        "sessions": [
          "01a1c6d4-6541-7fb1-82f3-997b307df2a2"
        ],
        "web_calls": []
      },
      "id": "cab-change-a17aeefd375c5fc9445c4bc4a1f093793e73bf91cdc628942c8bc9722bfb90e7",
      "input_sha256": "49aa46ce6ae9e0599f7c32ecda8a56281b01c5e70c4942399d1f07804c902125",
      "notes": {
        "1": [
          "Agrégat de périodes CAB bornées, plusieurs RUN et SID possibles ; aucun total historique de session repris.",
          "Couverture du change incomplète : périodes ouvertes ou RUN sans attestation de début de codage ; totaux SGS indisponibles, mesures des seules périodes conservées séparément."
        ],
        "3": [
          "Les mesures natives portent les incréments observés entre instantanés ; pas de ventilation à l’intérieur d’un événement natif ou des événements tardifs."
        ]
      },
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `split-system-update-engines` — openspec/changes/archive/2026-11-05-split-system-update-engines/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé scm-split-system-update-engines-20261105

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé scm-split-system-update-engines-20261105

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé scm-split-system-update-engines-20261105

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Périmètre | Trois parcours système, retrait des syntaxes antérieures, documentation et OpenSpec | Demande développeur et change archivé |

## 2. Types de messages et d’outils

### Relevé scm-split-system-update-engines-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé scm-split-system-update-engines-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | modules/system/apt.sh ; lib/diu-help.sh ; tests/test_software_engines.py ; tests/test_system_flatpak.py ; documentation et OpenSpec | Fichiers du change |

## 4. Commandes

### Relevé scm-split-system-update-engines-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests finaux échoués | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation | 1209 tests exécutés, 2 ignorés ; 36 tests ciblés ; Bash et ShellCheck réussis | unittest discover et contrôles locaux |

## 5. Accès web

### Relevé scm-split-system-update-engines-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Web | Aucun appel web | Session locale |

## 6. Synthèse globale

### Relevé scm-split-system-update-engines-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Limite | Télémétrie détaillée indisponible ; CI/CD non exécutée à ce stade | Exécution directe SCM |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Périmètre",
            "proof": "Demande développeur et change archivé",
            "value": "Trois parcours système, retrait des syntaxes antérieures, documentation et OpenSpec"
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Fichiers du change",
            "value": "modules/system/apt.sh ; lib/diu-help.sh ; tests/test_software_engines.py ; tests/test_system_flatpak.py ; documentation et OpenSpec"
          }
        ],
        "4": [
          {
            "label": "Validation",
            "proof": "unittest discover et contrôles locaux",
            "value": "1209 tests exécutés, 2 ignorés ; 36 tests ciblés ; Bash et ShellCheck réussis"
          }
        ],
        "5": [
          {
            "label": "Web",
            "proof": "Session locale",
            "value": "Aucun appel web"
          }
        ],
        "6": [
          {
            "label": "Limite",
            "proof": "Exécution directe SCM",
            "value": "Télémétrie détaillée indisponible ; CI/CD non exécutée à ce stade"
          }
        ]
      },
      "id": "scm-split-system-update-engines-20261105",
      "input_sha256": "1116868b1faa81f36a8d8ee266c1b62ae6680b26a2eb9fbc8668308b35d52636",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `stop-setting-technical-account-passwords` — openspec/changes/archive/2026-11-04-stop-setting-technical-account-passwords/STATISTICS.md


# Statistiques du change

## Statistiques générales et décisions

- Session directe SCM du 2026-11-04 ; codeur : Codex ; modèle : N/A.
- Trois comptes techniques ; mots de passe existants préservés, rootless inchangé.
- Durées, jetons et coûts : N/A, mesures exhaustives indisponibles.
- Archivage OpenSpec réussi ; commit, publication et activation non réalisés.

## Types de messages et d'outils

- Totaux et répartition : N/A, télémétrie exhaustive indisponible.

## Fichiers modifiés

- Script principal, test isolé, cadrage technique, changelog, change et
  spécification OpenSpec, cartographie et registre ; totaux exhaustifs : N/A.

## Commandes

- Validation finale : 1 149 tests exécutés, dont 2 ignorés ; aucun échec.
- `bash -n`, ShellCheck sur le script principal, compilation Python et
  validation OpenSpec stricte : réussis. Trois tâches prouvées et terminées.
- Un premier essai ciblé a échoué à cause du test, corrigé puis réussi.
- Comptages exhaustifs de commandes : N/A.

## Accès web

- N/A : aucun relevé exhaustif des appels web n'a été produit.

## Synthèse globale

- Code et tests validés localement ; aucun déploiement ni essai réel de `ridt`.
- Rapport global absent : sa création relève d'un mandat SGS distinct.


## Change `support-debian-maintainer-scripts` — openspec/changes/archive/2026-11-11-support-debian-maintainer-scripts/STATISTICS.md


# Statistiques du change

### Agents de codage — relevé SCM-CAB-300-DIU-20261111

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs — relevé SCM-CAB-300-DIU-20261111

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé SCM-CAB-300-DIU-20261111

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle N/A, raisonnement N/A.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

Sous-chantier DIU du mandat CAB 3.0.0.

## 2. Types de messages et d’outils

### Relevé SCM-CAB-300-DIU-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 3. Fichiers modifiés

### Relevé SCM-CAB-300-DIU-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 4. Commandes

### Relevé SCM-CAB-300-DIU-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 37 | QUALIFICATION.md : 17 tests build et 20 tests CI/CD |
| Tests finaux réussis | 37 | QUALIFICATION.md : 17 tests build et 20 tests CI/CD |
| Tests finaux échoués | 0 | QUALIFICATION.md : 17 tests build et 20 tests CI/CD |
| Fichiers ayant passé un contrôle syntaxique | 1 | QUALIFICATION.md : 17 tests build et 20 tests CI/CD |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 1 | QUALIFICATION.md : 17 tests build et 20 tests CI/CD |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

## 5. Accès web

### Relevé SCM-CAB-300-DIU-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

37 tests réussis ; voir QUALIFICATION.md.

## 6. Synthèse globale

### Relevé SCM-CAB-300-DIU-20261111

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

Les mesures natives ne sont pas réparties artificiellement entre CAB et DIU. Le premier cycle 1.3.9 a été déclenché avant correction du format du rapport SGS ; le complément documentaire est livré par le cycle suivant.


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "N/A",
            "reasoning": "N/A",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md : 17 tests build et 20 tests CI/CD"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1"
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md : 17 tests build et 20 tests CI/CD"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1"
          },
          "tasks": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md : 17 tests build et 20 tests CI/CD"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "37"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md : 17 tests build et 20 tests CI/CD"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [
              {
                "line": 1,
                "note": "QUALIFICATION.md : 17 tests build et 20 tests CI/CD"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "37"
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [
          "QUALIFICATION.md"
        ],
        "sessions": [
          "SCM-CAB-300-DIU-20261111"
        ],
        "web_calls": []
      },
      "id": "SCM-CAB-300-DIU-20261111",
      "input_sha256": "695fab7fb07062d3132f1741097bf9ad079164f258840191a171874ba1130687",
      "notes": {
        "1": [
          "Sous-chantier DIU du mandat CAB 3.0.0."
        ],
        "5": [
          "37 tests réussis ; voir QUALIFICATION.md."
        ],
        "6": [
          "Les mesures natives ne sont pas réparties artificiellement entre CAB et DIU. Le premier cycle 1.3.9 a été déclenché avant correction du format du rapport SGS ; le complément documentaire est livré par le cycle suivant."
        ]
      },
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->


## Change `support-project-docker-build-args` — openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTICS.md


# STATISTIQUES — Arguments Docker publics

## 1. Identification et périmètre

Date : 15 octobre 2026, Europe/Paris. Change :
`support-project-docker-build-args`. Archive :
`2026-10-15-support-project-docker-build-args`.

Session SCM directe, sans délégation, OpenCode/CAB ou compétence de
statistiques de pilotage. Périmètre : lecteur générique de
build/docker-build.args, tests, adaptation d'un consommateur dans son dépôt,
revue documentaire et archivage ciblé. Aucune dépendance applicative n'est
ajoutée au DIU ; aucun commit, push, déploiement, publication ou installation
système n'est exécuté. Aucun état Git ni fichier sensible réel n'est consulté.

## 2. Durées et mesures disponibles

Référence SHA-256 prise le 2026-10-15T15:44:54+02:00.
Rapport produit le 2026-10-15T16:11:25+02:00.
Intervalle observé : 1590.931 s, sans prétendre mesurer
la conversation entière. Somme des durées unittest : 3,515 s.

Tokens, coût, compte exhaustif des messages/outils et télémétrie d'agents :
N/A, aucune sonde de pilotage n'est activée pour SCM. Lignes modifiées : N/A,
le relevé capture seulement les empreintes et aucune inspection Git n'est
réalisée. Agents délégués : 0. Paquets hôte installés : 0.

## 3. Fichiers et contrat

34 références préexistantes suivies par SHA-256 : 13 modifiées attendues,
21 inchangées. Les entrées consommateur ci-dessous sont des chemins relatifs
à son dépôt, distinct du moteur générique :

- `PROJECT.md`
- `TECHNICAL.md`
- `README.md`
- `CHANGELOG.md`
- `modules/projects/docker.sh`
- `openspec/specs/modify-projects-docker-build/spec.md`
- `consommateur/PROJECT.md`
- `consommateur/TECHNICAL.md`
- `consommateur/BUILD.md`
- `consommateur/README.md`
- `consommateur/CHANGELOG.md`
- `consommateur/tests/test_packaging.py`
- `consommateur/docs/exploitation.md`

Nouveaux fichiers hors change : tests/test_projects_docker_build_args.py et
consommateur/build/docker-build.args. Six fichiers du change sont créés puis
déplacés dans l'archive ; ce rapport y ajoute un septième fichier. Le fichier
de spécification principale existant est enrichi, aucune nouvelle capacité
principale n'est créée. Les catégories création, déplacement et modification
se recouvrent et ne sont pas additionnées comme des fichiers distincts.

La comparaison des corps normatifs confirme cinq exigences antérieures
inchangées et huit nouvelles exigences identiques au delta archivé : treize
exigences et vingt-et-un scénarios au total. Les autres changes actifs ne
sont pas traités. Règles, prompts, inventaires, configuration OpenSpec,
licences, .gitignore, BUILD du paquet Debian et runtime du consommateur restent
inchangés.

## 4. Tests et vérifications

| Suite | Cas exécutés | Réussis | Échecs | Erreurs | Durée s |
|---|---:|---:|---:|---:|---:|
| DIU initial | 16 | 16 | 0 | 0 | 0.727 |
| DIU, ajout flux simulé | 17 | 16 | 1 | 0 | 0.828 |
| DIU, correction fixture | 17 | 16 | 0 | 1 | 0.769 |
| DIU final | 17 | 17 | 0 | 0 | 0.807 |
| Consommateur packaging | 4 | 4 | 0 | 0 | 0.384 |
| Total, répétitions incluses | 71 | 69 | 1 | 1 | 3.515 |

Résultat final : **21 tests ciblés distincts réussis**, sans test ignoré,
soit 17 DIU et 4 packaging consommateur. L'échec puis l'erreur intermédiaires
concernent uniquement le harnais du flux CI/CD : print_title simulé absent,
puis fixture Dockerisation 1 alors que ce flux historique attend Yes.
Les assertions sont conservées, la fixture corrigée. Aucun comportement
hors périmètre du pipeline n'est modifié.

Bash -n et ShellCheck réussissent sur le module Docker. La suppression
SC2034 est limitée à une affectation par nameref réellement consommée et
couverte par les tests. Les deux modules Python concernés compilent.
Validation stricte du change avant archivage puis de la spécification
principale après archivage : exécutées et réussies, aucune issue.

Le BUILD local avec les six arguments du lecteur générique réussit et sa
version native correspond à la référence publique du consommateur. Aucun
project.env réel n'est chargé pour ce contrôle, capture Git automatique
Buildx désactivée, aucune CI/CD réelle n'est exécutée. Les tests du flux
simulent entièrement Git, runuser, Docker et publications.

## 5. Résultats et archivage

Le lecteur conserve octets et frontières de valeurs, y compris espaces,
quotes, dollars, antislashs, Unicode, #, = et valeur vide. Il ne les exécute
pas et ne les affiche pas. Doublons, clés invalides, CR/NUL, FIFO/liens et
fichiers hors limite sont refusés avant Docker. La lecture est bornée à
65 537 octets pour détecter également une croissance après stat ; maximum
accepté 65 536 octets. Cent appels vérifient la fermeture des descripteurs.
Sans fichier, la commande et l'utilisateur historiques restent identiques.

Archivage officiel exécuté une seule fois :
`openspec archive support-project-docker-build-args --json --yes`.
Résultat : specsUpdated=true, 8 exigences ajoutées, 0 modifiée, 0 supprimée,
0 renommée. Les huit tâches sont réalisées. Le rapport compte six sections.
La recherche ciblée des fichiers DIU concernés confirme l'agnosticisme ;
les paramètres applicatifs restent exclusivement dans le consommateur.

## 6. Limites et suites

Le fichier est public et non sensible. Sa syntaxe ne peut pas classifier une
valeur arbitraire ni garantir le masquage des sorties natives Docker.
Les quotes sont littérales et aucune interpolation d'environnement n'est
ajoutée. La cohérence applicative appartient au consommateur et à ses tests.

Les tests runtime/protocoles du consommateur ne sont pas relancés : ils ne
sont pas concernés par cette transmission de BUILD et leurs sources restent
inchangées. La validation locale n'est pas une publication ou installation.
Le DIU installé n'est pas mis à jour par cette session ; cette action reste
séparée. Images locales et cache de construction sont conservés, seules les
fixtures sous les deux dépôts sont nettoyées.


## Change `update-debian-packages-once` — openspec/changes/archive/2026-09-05-update-debian-packages-once/STATISTICS.md


STATISTICS.md missing ; aucune donnée inventée.


## Change `upgrade-devops-opencode-v2` — openspec/changes/archive/2026-10-28-upgrade-devops-opencode-v2/STATISTICS.md


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
<!-- CAB_STATISTICS_DOCUMENT_V1 {"content_sha256": "fa6d227fd8376760fca19f0b23010062fa6251152031c0d2173e8a189f267854", "generated_at": "2026-11-14T22:56:12.559326+00:00", "revision": "fa6d227fd8376760fca19f0b23010062fa6251152031c0d2173e8a189f267854", "scope": "project"} -->
