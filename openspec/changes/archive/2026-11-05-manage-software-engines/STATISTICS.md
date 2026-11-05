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
