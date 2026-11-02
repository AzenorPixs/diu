# Tâches — construction Debian générique

- [x] 1. Spécifier et valider le contrat, la compatibilité et le format de recette.
- [x] 2. Implémenter moteur, routage, aide et recette DIU ; valider les tests ciblés.
- [x] 3. Mettre à jour la documentation et valider les régressions et l'équivalence DIU.
- [x] 4. Effectuer la validation globale finale et vérifier l’éligibilité à la synchronisation et à l’archivage de ce seul change.

## Sous-lots normalisés

Code non attribué : repères provisoires fondés sur add-projects-debian-build,
sans allocation de code ou de SL définitif ; attribution ultérieure par ACL.

| Repère provisoire | Tâches | Dépendances | Critères et preuves | État |
|---|---|---|---|---|
| Contrat | 1 | Périmètre SCM validé | OpenSpec strict réussi le 2026-11-02 ; design.md | VALIDÉ |
| Moteur et interfaces | 2 | Contrat | 2026-11-02 : 12 tests réussis, trois syntaxes Bash et ShellCheck réussis ; compilation Python réussie | VALIDÉ |
| Documentation et qualification | 3, 4 | Moteur | 2026-11-02 : équivalence prouvée, 120 tests ciblés et 1 018 tests globaux réussis ; revue ci-dessous ; archivage après ces preuves | VALIDÉ |

## Preuves finales — 2026-11-02

- `env PYTHONPATH=tests /home/devops/python/current/bin/python3 -m unittest test_projects_build_deb test_diu_packaging test_rid_help test_projects test_root_shellcheck` : 120 tests réussis.
- `env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -m unittest discover -s tests` : 1 018 tests réussis en 214,688 s, aucun échec ni saut.
- Après les derniers motifs de refus : 12 tests du nouveau moteur rejoués avec succès, incluant l'aide générale, six aides contextuelles et le repli de version sans tag.
- `bash -n` sur chaque fichier Bash modifié : réussi. ShellCheck des trois fichiers : réussi. Compilation Python du nouveau test : réussie.
- OpenSpec du change en strict : réussi. OpenSpec global standard : 116/116 valides. Global strict : 69 valides, 47 refus pour diagnostics sur sources non modifiées (Purpose provisoires, scénarios anciens ou exigences longues). Aucun de ces diagnostics ne vise ce change ou rid-help.
- 17 fichiers du périmètre vérifiés UTF-8/LF ; recette et nouvelles cibles de liens présentes. Ancien lien README vers STATISTIQUES.md absent, hors du texte ajouté ; correction distincte non réalisée.
- Équivalence du paquet DIU : champs control, chemins, contenu, modes et propriétaires comparés sur paquets réels de fixture, avec fichiers exécutables et répertoires setgid.
- L'archivage et la synchronisation sont la transition suivante, après cette qualification ; leur résultat est consigné dans STATISTICS.md après succès.

## Matrice documentaire

| Document | État et preuve |
|---|---|
| Projet réel | Commande, aides, recette et comportement vérifiés par les tests ci-dessus ; aucun déploiement système |
| AGENTS.md | Inchangé : règles de sécurité, Bash et validations appliquées ; aucun nouveau protocole |
| PROJECT.md | Mis à jour : module projects et construction générique |
| TECHNICAL.md | Mis à jour : construction déclarative, données isolées, renvoi BUILD |
| BUILD.md | Mis à jour : format complet, activation, erreurs, limites, rotation et compatibilité historique |
| DEVOPS.md | Inchangé : outils existants jq/dpkg et runtimes conservés, aucune régénération |
| DEVELOPMENT_MAP.md | Delta ciblé : source du change, progression et statut, sans attribution de code |
| README.md | Nouvelle commande et aide documentées ; ancien lien STATISTIQUES.md absent signalé hors périmètre |
| CHANGELOG.md | Entrée Unreleased ajoutée, sans version de publication inventée |
| openspec/specs/ | Nouvelle capacité et ajout rid-help prévus par la synchronisation autorisée ; strict ciblé réussi |

Le périmètre fonctionnel est validé ; la conformité stricte globale du dépôt
n'est pas revendiquée. Les défauts hors périmètre ci-dessus ne sont pas corrigés.
