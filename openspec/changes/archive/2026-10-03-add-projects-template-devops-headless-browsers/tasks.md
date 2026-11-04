## 1. Spécification

- [x] 1.1 Présenter le périmètre autonome et obtenir sa validation explicite.
- [x] 1.2 Créer la proposition, la conception et le delta projects-template-devops.
- [x] 1.3 Valider le change OpenSpec en mode strict.

## 2. Implémentation

- [x] 2.1 Ajouter la section finale et les sondes hôte Chromium et Firefox.
- [x] 2.2 Ajouter les tests déterministes de versions, chemins, variantes, priorités et indisponibilités.
- [x] 2.3 Vérifier l'actualisation, l'idempotence et les comportements existants d'écriture.
- [x] 2.4 Documenter la détection et sa limite dans TECHNICAL.md.

## 3. Validation

- [x] 3.1 Vérifier la syntaxe Bash et Python, ShellCheck, UTF-8 et les fins de ligne LF.
- [x] 3.2 Exécuter test_projects_template_devops.py.
- [x] 3.3 Exécuter test_projects_template_all.py et test_projects_general_update.py.
- [x] 3.4 Exécuter test_rid_help.py pour préserver help et ?.
- [x] 3.5 Contrôler la conformité au change et la cohérence des cadrages et des fichiers concernés.

## 4. Archivage

Les tâches de spécification, d'implémentation et de validation sont terminées.
La synchronisation et l'archivage du seul change ciblé ont réussi le 2026-10-03,
puis la validation stricte de la capacité synchronisée a réussi.
L'état terminal de cette session est : objectif réalisé, validations réussies,
change archivé ; aucun blocage restant dans le périmètre validé.

## État de session

Le développeur a validé le périmètre autonome proposé le 2026-10-03.
Le 2026-10-03, le contrôle OpenSpec sous le compte devops a échoué avant
exécution du CLI : su a demandé un mot de passe puis rendu Authentication failure.
Le développeur a demandé de vérifier l'accès sans mot de passe du compte ade
au compte devops. sudo -n -l a confirmé la règle (devops) NOPASSWD: ALL ;
sudo -n -iu devops id et OpenSpec --version ont réussi (version 1.14.0).
La reprise utilise sudo -n -u devops depuis la racine DIU pour conserver le cwd.
La validation stricte du change avant implémentation a réussi.

## Validations observées le 2026-10-03

- `bash -n modules/projects/template.sh` : exécutée et réussie.
- `shellcheck modules/projects/template.sh` : exécutée et réussie.
- `/usr/bin/python3 -m py_compile tests/test_projects_template_devops.py` : exécutée et réussie, avec PYTHONPYCACHEPREFIX temporaire dans la racine DIU, nettoyé ensuite.
- Sous devops, `/usr/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -v` : 43 tests, tous réussis, aucun ignoré ; DIU_TEST_GO, DIU_TEST_NODE et DIU_TEST_PYTHON désignent les runtimes de /home/devops.
- Sous devops, `/usr/bin/python3 -B -m unittest discover -s tests -p test_projects_template_all.py -v` : 8 tests réussis.
- Sous devops, `/usr/bin/python3 -B -m unittest discover -s tests -p test_projects_general_update.py -v` : 9 tests réussis.
- Sous devops, `/usr/bin/python3 -B -m unittest discover -s tests -p test_rid_help.py -v` : 56 tests réussis, dont help et ? pour la génération DevOps.
- `sudo -n -u devops env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec validate add-projects-template-devops-headless-browsers --type change --strict` : exécutée et réussie avant implémentation.
- Contrôle des fichiers concernés : UTF-8/LF vérifiés ; comparaison SHA-256 avant archivage : seuls template.sh, test_projects_template_devops.py et TECHNICAL.md ont changé parmi les 15 fichiers de référence contrôlés, hors nouveaux artefacts du change. Aucune inspection Git.
- Sondes réelles bornées sous devops : /usr/bin/chromium --version a relevé 154.0.8037.92 ; /usr/bin/firefox --version a relevé 153.4.0esr. Aucun test de navigation headless n'a été exécuté et aucun projet utilisateur n'a été régénéré.

Le diagnostic `which chromium chromium-browser firefox firefox-esr` a trouvé
/usr/bin/chromium, /usr/bin/firefox et /usr/bin/firefox-esr ; son code 1 indique
que chromium-browser n'a pas été trouvé dans le PATH système interrogé.
La première tentative de validation avec un chemin de change a été rejetée par
le CLI (le nom ne doit pas contenir de séparateur), puis le nom seul, depuis
la racine DIU sous devops, a été validé avec succès.

## Matrice de cohérence avant archivage

| Élément | Constat dans le périmètre |
| --- | --- |
| Projet réel | Section finale produite et actualisée, variantes et erreurs documentées, appels individuels, groupés et de création couverts par les tests. |
| AGENTS.md | Spécification validée avant code/tests, validations ciblées, aucune opération Git ni installation. |
| PROJECT.md | Architecture Bash et responsabilité du module projects préservées ; aucun ajustement nécessaire. |
| TECHNICAL.md | Détection hôte, priorité des noms, délai et limite headless documentés dans la rubrique dédiée. |
| BUILD.md | Aucun changement de construction ou packaging. |
| DEVOPS.md | Snapshot d'environnement conservé ; les versions hôte ont été sondées séparément sans régénérer le document racine. |
| README.md | Présentation générale et commande de publication inchangées ; aucun ajustement nécessaire. |
| openspec/specs/ | Capacité existante conservée jusqu'à synchronisation ; delta validé couvrant les deux exigences concernées. |

Aucun écart bloquant n'a été constaté dans ce périmètre. Le fonctionnement
effectif des navigateurs en headless reste explicitement non vérifié et hors
périmètre ; seules les versions, les chemins et l'option d'utilisation sont documentés.

## Preuves de clôture

- `sudo -n -u devops env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec validate add-projects-template-devops-headless-browsers --type change --strict` : exécutée et réussie à nouveau avant archivage.
- `sudo -n -u devops env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive add-projects-template-devops-headless-browsers --json --yes` : exécutée et réussie ; archive `2026-10-03-add-projects-template-devops-headless-browsers`, specsUpdated=true, une exigence ajoutée et une modifiée, aucune supprimée ou renommée.
- `sudo -n -u devops env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec validate projects-template-devops --type spec --strict` : exécutée et réussie après archivage. Le CLI émet des conseils informatifs sur la longueur des exigences, sans erreur ni échec de validation.
- Comparaison des empreintes des exigences avant/après synchronisation : seule « Structure et version documentaire » a changé ; seule « Navigateurs externes hôte pour le mode headless » a été ajoutée ; les autres exigences sont conservées.

La matrice de cohérence finale reprend les constats précédents, avec la capacité
projects-template-devops désormais synchronisée et validée. Le générateur,
les tests et TECHNICAL.md correspondent à cette capacité. La version documentaire
0.2, la syntaxe CLI, les rubriques existantes et les protections d'écriture sont
préservées. Aucun commit, push ou modification d'infrastructure n'a été effectué.
