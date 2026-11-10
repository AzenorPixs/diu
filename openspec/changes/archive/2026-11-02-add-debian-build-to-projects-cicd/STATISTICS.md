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
