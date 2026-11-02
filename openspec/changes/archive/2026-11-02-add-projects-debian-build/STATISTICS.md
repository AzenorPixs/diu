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
