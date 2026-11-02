# Tâches — priorité de version

- [x] 1. Spécifier et valider la priorité et les invariants de compatibilité.
- [x] 2. Réaliser le lecteur partagé et les sélections Debian ; valider les fixtures.
- [x] 3. Intégrer Git, CICD, Docker et les publications ; valider les transports simulés.
- [x] 4. Mettre à jour aides et documentation puis valider globalement et vérifier l'éligibilité à l'archivage.

## Sous-lots normalisés

Code non attribué : repères provisoires de prioritize-project-version, sans
allocation de code ni de SL définitif. Attribution ultérieure par ACL.

| Repère | Tâches | Dépendances | Validation prévue | État |
|---|---|---|---|---|
| Contrat | 1 | Périmètre validé | OpenSpec strict réussi le 2026-11-02 | VALIDÉ |
| Lecture et Debian | 2 | Contrat | 2026-11-02 : 28 tests réussis, syntaxe Bash et ShellCheck sur trois fichiers réussis | VALIDÉ |
| Git et Docker | 3 | Lecture | 2026-11-02 : 158 tests réussis ; Git local réel, trois fournisseurs simulés ; sept syntaxes et ShellCheck réussis | VALIDÉ |
| Qualification | 4 | Intégrations | 2026-11-02 : 1 034 tests globaux réussis, 74 tests finaux version/aide, revue ci-dessous | VALIDÉ |

## Preuves finales — 2026-11-02

- Lecteur et Debian : 28 tests réussis, dont construction réelle de paquets de fixture en 1.0.0 malgré recette et tags concurrents.
- Sept suites ciblées : 158 tests réussis en 21,959 s ; commits individuels et groupés sur Git local réel, pushes des trois fournisseurs sur dépôts locaux, transports Docker/API simulés.
- Suite complète : `env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -m unittest discover -s tests` : 1 034 tests réussis en 308,793 s, aucun échec ni saut.
- Après les compléments d'aide cicddiu/cicddr : `env PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_project_version test_rid_help` : 74 tests réussis en 5,292 s.
- Sept fichiers Bash vérifiés par bash -n et ShellCheck : réussite. Deux tests Python compilés : réussite.
- OpenSpec du change strict : valide. Global standard avant archivage : 117/117 valides. Global strict : 70 valides, 47 refus préexistants. Le canon Docker conserve notamment neuf diagnostics de scénarios anciens ; les deltas créés sont valides en strict.
- Vingt-cinq fichiers vérifiés UTF-8/LF et nouveaux liens présents. Ancien lien README vers STATISTIQUES.md toujours absent, hors du texte ajouté.
- PROJECT_VERSION déjà égale à 1.0.0 : fichier privé inchangé ; recette DIU inchangée. L'archivage suit cette qualification et son résultat est consigné dans STATISTICS.md.

## Matrice documentaire

| Document | État et preuve |
|---|---|
| Projet réel | Priorité testée pour Git, Debian et Docker ; aucune installation système ni release réelle d'artefact |
| AGENTS.md | Inchangé : règles de sécurité et vérifications appliquées, aucun nouveau protocole |
| PROJECT.md | Mis à jour : version optionnelle transverse du module projects |
| TECHNICAL.md | Mis à jour : lecteur partagé, formats, Git, images, cohérence et repli |
| BUILD.md | Mis à jour : ordre de priorité des deux constructeurs et publications |
| DEVOPS.md | Inchangé dans cette session : mêmes outils et runtimes, aucune régénération |
| DEVELOPMENT_MAP.md | Delta ciblé du change, progression puis archivage ; aucun code attribué |
| README.md | Version optionnelle et comportements documentés ; ancien lien cassé signalé hors périmètre |
| CHANGELOG.md | Entrée Unreleased dédiée, version de livraison 1.0.0 demandée, aucune date de release inventée |
| openspec/specs/ | Six capacités synchronisées à l'archivage ; maintien explicite des diagnostics historiques |

La qualification du périmètre est acquise ; une conformité stricte globale du
dépôt n'est pas revendiquée. Les défauts hors périmètre restent signalés.
