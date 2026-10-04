## 1. Spécification

- [x] 1.1 Obtenir la validation explicite du périmètre autonome et de l'archivage ciblé (3 octobre 2026).
- [x] 1.2 Créer les artefacts du seul change ciblé et ses exigences RFC 2119.
- [x] 1.3 Valider strictement le change avant toute écriture de code ou de test.

## 2. Désactivation

- [x] 2.1 Commenter tout le bloc Psycopg DevOps et conserver la préparation Python.
- [x] 2.2 Conserver la commande Psycopg OpenCode en commentaire hors de la chaîne exécutée.
- [x] 2.3 Adapter les tests isolés à l'absence de gestion et aux comportements préservés.
- [x] 2.4 Actualiser la section concernée de TECHNICAL.md.

## 3. Validation et clôture

- [x] 3.1 Vérifier syntaxe Bash et Python, ShellCheck et tests ciblés sans effet externe.
- [x] 3.2 Examiner les modifications et la cohérence des cadrages, du code et des spécifications.
- [x] 3.3 Valider strictement le change final et établir son éligibilité à l'archivage.

L'archivage de ce seul change et la synchronisation de `devops-python` sont
inclus dans le périmètre validé.

## Preuves de validation — 3 octobre 2026

- Exécutée et réussie avant archivage : `/home/devops/.local/npm/bin/openspec validate disable-diu-psycopg-management --strict`.
  Tous les critères sont couverts par les validations ciblées ; toutes les
  tâches sont achevées et aucun blocage connu ne subsiste dans ce périmètre.
- Exécutée et réussie avant code/tests : `/home/devops/.local/npm/bin/openspec validate disable-diu-psycopg-management --strict`.
  La première tentative a refusé le remplacement d'un scénario d'installation ;
  le delta a été corrigé pour retirer explicitement les anciennes exigences
  et ajouter celles du périmètre validé. Aucun code/test n'avait été écrit.
- Exécutée et réussie : `bash -n root-install-debian.sh`.
- Exécutée et réussie : `shellcheck root-install-debian.sh` (script complet).
- Exécutée et réussie : ShellCheck sur stdin pour `launch_ocrw` et le bloc Python,
  avec `set -Eeuo pipefail` conservé comme dans le script réel. La première
  extraction sans ce contexte avait signalé SC2164 sur les deux `cd` existants ;
  aucune suppression de diagnostic ni modification de code n'a été nécessaire.
- Exécutée et réussie : `/home/devops/python/current/bin/python3 -m py_compile tests/test_devops_python.py`.
- Exécutée et réussie : `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p 'test_devops_python.py' -v` : 8 tests.
- Exécutée et réussie : `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p 'test_root_shellcheck.py' -v` : 9 tests.
- Exécutée et réussie hors bac à sable : `DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p 'test_projects_template_devops.py' -v` : 43 tests.
  Première exécution échouée dans le bac à sable : refus `chown: Invalid argument`
  sur une fixture temporaire, 42 tests réussis et un échec. La première revue
  automatique de la relance a expiré ; la seconde tentative autorisée a exécuté
  les 43 tests avec succès, sans changement du module ou des tests de régression.
- Exécutée et réussie : revue des modifications ciblées, UTF-8/LF et contrôle
  que toutes les références Psycopg du monolithe sont désormais commentées.
- Non exécutées : installation système, accès PostgreSQL, lancement Docker réel,
  réseau externe, suite exhaustive. Les validations utilisent des fixtures
  temporaires dans la racine du DIU, nettoyées par les tests. Le contrôle Python
  régénère son bytecode de test ; aucun état Git n'est inspecté ou modifié.

## Matrice de cohérence du périmètre

| Élément | Résultat |
| --- | --- |
| Projet réel | Les deux chemins spécifiques à Psycopg sont inactifs ; les liens/profil Python et la chaîne OpenCode sont testés. |
| AGENTS.md | Règles de périmètre et validation respectées ; aucun effet externe, secret ou changement Git. |
| PROJECT.md | Responsabilités modulaires et préparation d'environnement conservées. |
| TECHNICAL.md | Section Psycopg actualisée ; aucune autre section modifiée. |
| BUILD.md | Packaging inchangé ; les écarts de packaging déjà documentés restent hors périmètre. |
| DEVOPS.md | Environnement inchangé, interpréteurs et outil OpenSpec explicites utilisés. |
| README.md | Présentation et commandes de publication inchangées et compatibles avec ce changement. |
| OpenSpec | Delta validé avant code/tests ; archivage et synchronisation ciblés réussis, Purpose actualisé et spécification canonique validée strictement. |

Fichiers de code/documentation modifiés : `root-install-debian.sh`,
`tests/test_devops_python.py`, `TECHNICAL.md`. Seuls les quatre artefacts de ce
change sont créés ; seule `devops-python` est destinée à la synchronisation.
Les paquets existants ne sont pas désinstallés. La responsabilité des projets
pour Psycopg et le remplacement historique du préfixe Python sont les impacts
explicitement documentés. Aucun élargissement du périmètre n'est nécessaire.

## Archivage et état terminal

- Exécuté et réussi : `/home/devops/.local/npm/bin/openspec archive disable-diu-psycopg-management --json --yes`.
  Archive : `2026-10-03-disable-diu-psycopg-management` ; synchronisation de
  `devops-python` confirmée par l'outil, trois exigences ajoutées et trois retirées.
- L'outil conserve l'ancien Purpose lors de la synchronisation ; il a été
  actualisé dans `openspec/specs/devops-python/spec.md`, conformément à
  l'autorisation de cohérence et de synchronisation validée.
- Exécutée et réussie après synchronisation : `/home/devops/.local/npm/bin/openspec validate devops-python --type spec --strict`.
- État terminal : objectif livré dans les sources, toutes les tâches achevées,
  change archivé, 60 tests ciblés réussis, aucun blocage restant dans le périmètre.
  Les opérations système et Docker réelles restent non exécutées.
