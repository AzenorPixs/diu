# Tâches — publication Debian GitHub

- [x] 1. Spécifier et valider les conditions Forgejo, les sélections et le transport.
- [x] 2. Réaliser le transport et le publisher Debian ; valider contrôles et erreurs sur fixtures.
- [x] 3. Intégrer commande directe, CI/CD et aides ; valider Docker seul, Debian seul et mixte.
- [x] 4. Finaliser documentation et version 1.0.3, valider globalement et vérifier l'éligibilité à l'archivage.

## Sous-lots normalisés

Repères provisoires de add-github-debian-release, code non attribué ; aucune
allocation de code ou de SL définitif. Attribution ultérieure par ACL.

| Repère | Tâches | Dépendances | Validation prévue | État |
|---|---|---|---|---|
| Contrat | 1 | Périmètre validé | 2026-11-02 : change strict valide, conditions Forgejo documentées | VALIDÉ |
| Publication Debian | 2 | Contrat | 2026-11-02 : 30 tests réussis ; syntaxe et ShellCheck des deux fichiers avec dépendances réussis | VALIDÉ |
| Sélection et CI/CD | 3 | Publisher | 2026-11-02 : 175 tests ciblés réussis ; cinq syntaxes Bash et ShellCheck réussis, trois tests Python compilés | VALIDÉ |
| Qualification | 4 | Intégration | 2026-11-02 : 1 074 tests globaux réussis, version 1.0.3 et revue ci-dessous | VALIDÉ |

## Preuves finales — 2026-11-02

- Publisher et authentification : 30 tests réussis en 18,787 s, incluant l'upload interrompu, Enterprise et les collisions de références.
- Sept suites ciblées : 175 tests réussis en 46,446 s. Le nouveau fichier contient 24 méthodes ; commande directe Docker seul, Debian seul, mixte, absence d'artefact, API et CI/CD sont couvertes.
- Suite complète : `env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -m unittest discover -s tests` : 1 074 tests réussis en 338,324 s, aucun échec ni saut.
- Syntaxe Bash et ShellCheck sur les cinq fichiers modifiés avec dépendances explicites : réussite. Trois fichiers Python compilés : réussite.
- OpenSpec du change strict : valide, y compris le contrat du helper GHCR et ses scénarios historiques conservés. Avant archivage, global standard 118/118 ; strict 71 valides et 47 refus historiques.
- Vingt-deux fichiers publics UTF-8/LF et nouvelles cibles de liens présents. Ancien lien README vers STATISTIQUES.md absent, hors périmètre.
- Huit sources surveillées inchangées : AGENTS, DEVOPS, lib/project-version.sh, lib/forgejo-auth.sh, modules/projects/diu-release.sh, diu-packaging.sh, docker.sh et recette DIU.
- PROJECT_VERSION passée de 1.0.2 à 1.0.3 par modification d'un seul octet, autres octets, inode, permissions et propriétaire préservés ; aucune autre valeur privée exposée.
- Les premiers essais de fixture héritaient du setgid sur DEBIAN ; mode exact 0755 ajouté à la fixture avant les tests réels. Les diagnostics ShellCheck de quotes et de portée dynamique sont corrigés sans affaiblissement des contrôles.
- L'archivage est la transition suivante, après qualification ; son résultat est consigné dans STATISTICS.md.

## Matrice documentaire

| Document | État et preuve |
|---|---|
| Projet réel | Commande publique, publisher, transport, sélection et CI/CD vérifiés sur fixtures ; aucune publication réelle d'artefact |
| AGENTS.md | Non édité, empreinte préservée ; règles de sécurité et de session directe appliquées |
| PROJECT.md | Mis à jour : destinations des images et paquets |
| TECHNICAL.md | Mis à jour : sélecteur, helper GHCR, API binaire et CI/CD |
| BUILD.md | Mis à jour : conditions Forgejo, sélection, métadonnées, Git et échecs partiels |
| DEVOPS.md | Non édité, empreinte préservée ; outils existants et chemins conservés |
| DEVELOPMENT_MAP.md | Delta ciblé du change, progression puis archivage ; aucun code attribué |
| README.md | Commande, activations et publications documentées ; ancien lien cassé signalé hors périmètre |
| CHANGELOG.md | Entrée Unreleased pour 1.0.3, sans date de publication inventée |
| openspec/specs/ | Quatre capacités synchronisées à l'archivage ; Purpose du canon GitHub élargi dans ce périmètre |

La conformité du périmètre est acquise ; la conformité stricte globale reste
limitée par les défauts historiques. Forgejo et GitLab ne sont pas modifiés.
