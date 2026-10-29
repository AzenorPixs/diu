# Tâches

- [x] 1. Réconcilier les contrats B1 et préserver les scénarios.
- [x] 2. Séparer provider strict et setup confirmé avant les transports.
- [x] 3. Préserver les paires existantes et nettoyer les publications partielles.
- [x] 4. Tester refus, paire partielle, erreurs, permissions et indisponibilité sur fixtures.
- [x] 5. Vérifier syntaxe, ShellCheck, régressions et OpenSpec standard/strict.

## Historique B1/C1/V2 — vérifications du 28 octobre 2026

- Syntaxe Bash : six fichiers réussis.
- Compilation Python : trois fichiers de tests réussis avec le Python DevOps.
- Tests ciblés finaux : 153 réussis, aucun échec ni saut (14 bootstrap, 11 packaging,
  17 indisponibilité, 14 permissions, 14 publication Forgejo, 56 aide et 27 projets).
- Packaging : construction et inspection réelles d’un paquet de fixture,
  contrôle sans bit setgid, rotation et préservation après échec ; sélection
  de version vérifiée aussi avec un dépôt Git local isolé.
- ShellCheck : lib/forgejo-auth.sh, packaging, aide et point d’entrée réussis.
  git.sh conserve SC2034, SC2269 et SC2086 hors des blocs modifiés ;
  diu-release.sh conserve SC2034 et deux SC2016 hors des blocs modifiés.
- Suite complète exécutée pendant le travail : 659 tests, 10 échecs et 2 sauts.
  Les contrôles concernés sont hors du périmètre de correction : accès safe.directory
  système dans test_projects_orchestrated_coding ; empreinte Zsh et nombre de blocs
  dans test_root_shellcheck ; cinq cas de test_software et un de test_software_flatpak
  sur system_update absent des fixtures ; un ordre de journalisation de pipeline
  dans test_system_apt. Ces échecs ne sont ni masqués ni corrigés dans ce mandat.

Lors du relevé B1/C1/V2 précédent, la validation globale était en réserve ; la dernière tâche restait ouverte.
Les validations ciblées ne constituent ni publication distante, ni installation,
ni activation. Le change reste actif et non archivé.

OpenSpec final : 71/71 en standard et strict ; 16 validations individuelles réussies.
Le contrôle des archives conserve 105/117 avec les 12 diagnostics historiques, sans réouverture.

## Validation finale — ACSM-DIU-REGRESSIONS-SHELLCHECK-20261028-R1

Plan validé U1/Z1 appliqué sans archivage. Les dix échecs précédemment relevés
sont résolus et les six diagnostics ShellCheck ne sont plus présents.

| Contrôle exécuté | Résultat |
|---|---|
| Compilation des sept fichiers Python modifiés | Réussie, Python DevOps |
| Syntaxe Bash et ShellCheck des six fichiers de publication/routage | Six réussites, aucun diagnostic |
| Tests ciblés, neuf suites | 217 tests, aucun échec ni saut |
| Répétitions APT/Zsh | 20 itérations, 60 exécutions, aucun échec |
| Suite complète | 666 tests, aucun échec ni erreur, deux sauts Go |
| Complément avec DIU_TEST_GO déclaré dans DEVOPS.md | Les deux cas Go rejoués : deux réussites, aucun saut |
| OpenSpec global standard et strict | 72/72 valides dans les deux modes |
| Archives OpenSpec | 105/117, douze diagnostics historiques conservés |

Le générateur Zsh et update_all sont inchangés. Les configurations Git de test
sont isolées ; les appels API sont simulés. Aucun corps HTTP ni identifiant
sensible n’est ajouté aux sorties. Aucun saut n’est ajouté aux tests corrigés.

La validation globale en réserve est désormais acquise sur ces preuves.
Le change reste actif, sans archivage, publication distante ni activation.
