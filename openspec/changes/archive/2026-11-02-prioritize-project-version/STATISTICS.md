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
