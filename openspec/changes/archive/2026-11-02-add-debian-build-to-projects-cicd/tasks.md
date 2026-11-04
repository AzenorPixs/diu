# Tâches — construction Debian dans la CI/CD

- [x] 1. Spécifier et valider les six étapes, les activations et la compatibilité CLI.
- [x] 2. Ajouter build debian, son aide et l'alias deb ; valider routage et packaging.
- [x] 3. Intégrer le build Debian, les publications indépendantes et le bilan ; valider les scénarios ciblés.
- [x] 4. Finaliser documentation et version 1.0.2, valider globalement et vérifier l'éligibilité à l'archivage.

## Sous-lots normalisés

Repères provisoires de add-debian-build-to-projects-cicd, code non attribué ;
aucun identifiant de lot ou de SL définitif n'est inventé. Attribution via ACL.

| Repère | Tâches | Dépendances | Validation prévue | État |
|---|---|---|---|---|
| Contrat | 1 | Périmètre validé | 2026-11-02 : contrat OpenSpec strict valide, scénarios historiques conservés | VALIDÉ |
| Commande et aides | 2 | Contrat | 2026-11-02 : 81 tests réussis ; trois syntaxes Bash et ShellCheck avec dépendance explicite réussis | VALIDÉ |
| Orchestration | 3 | Commande | 2026-11-02 : 165 tests ciblés réussis ; quatre syntaxes Bash, ShellCheck et trois compilations Python réussis | VALIDÉ |
| Qualification | 4 | Orchestration | 2026-11-02 : 1 049 tests globaux réussis ; version 1.0.2 et revue ci-dessous | VALIDÉ |

## Preuves finales — 2026-11-02

- Commandes/aides et packaging : 81 tests réussis en 8,474 s, avec les deux syntaxes et leurs aides avant bootstrap.
- Sept suites ciblées : 165 tests réussis en 30,974 s. Les 15 nouveaux tests couvrent l'ordre, les activations, les projets Debian seuls, Docker seuls et mixtes, les échecs, les indisponibilités et l'absence de fuite vers le projet suivant.
- Suite complète : `env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -m unittest discover -s tests` : 1 049 tests réussis en 319,997 s, aucun échec ni saut.
- Quatre fichiers Bash vérifiés par bash -n et ShellCheck : réussite ; lib/project-version.sh fourni comme dépendance explicite à ShellCheck, sans édition. Trois fichiers Python compilés : réussite.
- Paquet réel de fixture construit et inspecté avant les publications simulées ; recette absente et ancien artefact préservé en échec.
- OpenSpec du change strict : valide après conservation des scénarios historiques. Global avant archivage : 118/118 en standard, 71 valides et 47 refus historiques en strict.
- Vingt fichiers publics contrôlés UTF-8/LF et nouveaux liens présents. Ancien lien README vers STATISTIQUES.md absent, hors périmètre.
- PROJECT_VERSION passée de 1.0.1 à 1.0.2 par modification d'un seul octet ; autres octets, inode, permissions et propriétaire préservés. Aucun contenu privé n'est exposé.
- Au contrôle initial, empreintes inchangées pour AGENTS.md, lib/project-version.sh, les modules Docker/packaging historique/release et la recette DIU. Au contrôle final après archivage, AGENTS.md a changé sans édition de ce plan : règles applicables relues et contenu conservé ; les cinq sources produit protégées restent identiques. DEVOPS.md a été régénéré pendant les validations (relevé UTC 2026-11-02T19:57:20Z, PROXMOX) : pas d'écriture de ce plan dans ce fichier, chemins Python/OpenSpec/prompts relus et conservés.
- L'archivage est la transition suivante après cette qualification ; son résultat est consigné dans STATISTICS.md après succès.

## Matrice documentaire

| Document | État et preuve |
|---|---|
| Projet réel | Six étapes, alias, activations indépendantes et erreurs validés ; aucune CI/CD réelle ni installation |
| AGENTS.md | Non édité par ce plan ; changement concurrent constaté au contrôle final, règles relues et contenu conservé |
| PROJECT.md | Mis à jour : syntaxe canonique et six étapes |
| TECHNICAL.md | Mis à jour : orchestration, activations, publications et douzième paramètre de bilan |
| BUILD.md | Mis à jour : alias, étape 4 et conditions de publication |
| DEVOPS.md | Régénération constatée, fichier conservé sans édition de ce plan ; chemins nécessaires relus |
| DEVELOPMENT_MAP.md | Delta ciblé du change et progression ; aucun code attribué |
| README.md | Six étapes, alias et erreurs documentés ; ancien lien absent signalé hors périmètre |
| CHANGELOG.md | Entrée Unreleased dédiée à la livraison 1.0.2, sans date de release inventée |
| openspec/specs/ | Trois capacités prévues pour synchronisation, delta strict valide ; défauts globaux historiques signalés |

La conformité du périmètre est acquise ; la conformité stricte de tout le dépôt
n'est pas revendiquée. Aucun tag existant ni parcours historique n'est remplacé.
