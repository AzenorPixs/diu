# Statistiques — convergence des commandes DIU

## 1. Statistiques générales et décisions

Date : 2026-11-05. Agent de codage : Codex, session directe SCM. Aucun pilotage OpenCode/CAB ni sous-agent. Version exacte du modèle, tokens, coûts et durée totale de session : N/A, compteurs non collectés. La durée de 262,911 s ci-dessous mesure seulement le dernier lancement des tests.

Le périmètre autonome a été explicitement validé avant les écritures : convergence des commandes, alias, fonctions et fichiers d’aide, tests, spécifications courantes et documentation. Archivage du seul change de convergence inclus. Aucun commit, tag, publication, installation ou CI/CD. Les anciennes archives et les contributions concurrentes sont préservées.

Code non attribué ; attribution et normalisation définitive à traiter ultérieurement par ACL. Archivage réussi le 2026-11-05 sous `2026-11-05-converge-rid-to-diu` ; spécifications synchronisées et rapport vérifié.

## 2. Types de messages et d’outils

Outils employés : `functions.exec`, commandes locales via `exec_command`, édition ciblée via `apply_patch`, consultation de résultats via `write_stdin`. Aucun appel de navigation web ni d’outil de délégation. Les messages reçus d’une session parallèle ne constituent pas des agents délégués à ce change.

Totaux exhaustifs des messages, appels d’outils et écritures : N/A, absence de collecte native exploitable pour cette session directe. La validation du périmètre est attestée ; aucun total de permissions natives n’est reconstruit.

## 3. Fichiers modifiés

96 fichiers existants concernés : 11 Bash, 10 Python, 75 fichiers de spécification ou documentation. Ce comptage inclut cinq fichiers logiques renommés, sans compter deux fois leurs anciens chemins. Liste exhaustive et matrice documentaire dans [review.md](review.md).

Renommages : `lib/diu-help.sh`, `tests/test_diu_help.py`, `openspec/specs/diu-help/spec.md`, et les deux deltas d’aide actifs de `add-projects-forgejo-clone` et `reconcile-diu-deb-packaging-contract`.

Neuf fichiers créés dans le périmètre de clôture : huit artefacts de ce change, dont ce rapport, et la nouvelle spécification canonique `diu-command-convergence/spec.md` issue de la synchronisation. Le total logique final vérifié est 105 fichiers distincts touchés ; le déplacement du dossier de change vers l’archive ne double pas ce comptage. La nouvelle spécification canonique et les huit fichiers archivés sont présents et vérifiés.

`DEVOPS.md` n’est pas modifié par cette session ; son état antérieur est préservé. Les 1 196 fichiers d’archives préexistants admissibles sont identiques par SHA-256. Le retrait concomitant du moteur logiciel `deb`, dont la suppression de son module et l’adaptation de `tests/test_software.py`, appartient à l’autre session et n’est pas attribué à cette convergence.

## 4. Commandes et validations

| Contrôle | Résultat observé |
|---|---|
| `bash -n` | Réussi, 11 fichiers distincts. |
| Compilation via `py_compile` | Réussie, 10 fichiers Python distincts, dont la reprise avec le Python DevOps déclaré. |
| `shellcheck` avec les dépendances explicites | Réussi, 13 fichiers ; premier appel incomplet en échec SC1091, corrigé en passant les fichiers sourcés, sans exclusion de diagnostic. |
| Tests ciblés initiaux | 311 cas : 283 réussis, 2 ignorés, 26 erreurs de fixtures venv sous Python système 3.13.5. |
| Reprise des 26 cas en erreur | 26 réussis sous `/home/devops/python/current/bin/python3` 3.14.10. |
| Tests isolés des liens et alias | 7 réussis, déjà inclus dans le périmètre ciblé ; ne pas les additionner au bilan final. |
| Tests des fichiers partagés après modification concurrente | 108 réussis. |
| Premier lancement global | 1 189 cas, 45 échecs et 2 ignorés ; 44 échecs liés aux anciens tests logiciels chargés avant le retrait concurrent de `deb`, 1 empreinte Zsh attendue actualisée après comparaison des sept lignes d’alias. Essai intermédiaire. |
| Lancement global final | 1 177 cas exécutés, 1 175 réussis, 2 ignorés, 0 échec, 0 erreur ; durée 262,911 s ; sources inchangées pendant le lancement. |
| OpenSpec ciblé strict | Change validé avant archivage ; canons convergence, aide et liens validés après archivage avec `--strict --no-interactive`. |
| OpenSpec global strict | Échec : 47 diagnostics préexistants, identiques à la copie isolée de l’état initial ; aucun nouvel échec introduit. |
| UTF-8/LF, chemins et absence des anciens identifiants exécutables | Réussis sur le périmètre concerné. |

Les suites utilisent `unittest.defaultTestLoader.loadTestsFromNames` pour les contrôles ciblés et `unittest.defaultTestLoader.discover('tests', pattern='test_*.py')` pour le global, puis `unittest.TextTestRunner`. Le dernier lancement global utilise le Python DevOps déclaré. Seul son résultat constitue le bilan final de tests, sans ajout des reprises déjà incluses.

Nombre exhaustif de commandes et répartition réussies/échouées : N/A, non collectés ; les contrôles listés sont des preuves bornées, pas un total d’activité. `openspec archive converge-rid-to-diu --yes --json` : réussi, spécifications synchronisées (2 exigences ajoutées, 1 modifiée). Références finales de cartographie et registre actualisées et vérifiées. Après archivage : les trois canons concernés passent le strict ; le global reste à 79 éléments réussis et 47 en échec, diagnostics préexistants inchangés.

## 5. Accès web

Aucun appel d’outil de recherche ou de consultation web pour ce change : 0. Les URL présentes dans le code et les documents ne constituent pas des consultations. Les commandes de test sont exécutées sur les fixtures prévues par le projet ; aucun déploiement réel n’a été lancé.

## 6. Synthèse globale

La convergence est réalisée et qualifiée sur l’état partagé courant. Les anciens noms DIU ne sont plus générés dans les alias ni employés dans les interfaces exécutables concernées. Les aides utilisent `diu` et les raccourcis de développement `diut` ; routage et arguments sont conservés par cette convergence. Les fichiers d’alias et shells installés ne sont pas migrés automatiquement.

Bilan final des tests : 1 177 exécutés = 1 175 réussis + 2 ignorés + 0 échec + 0 erreur. Les 47 diagnostics OpenSpec stricts préexistants restent hors périmètre. La revue documentaire et ses limites sont disponibles dans [review.md](review.md).

Archivage réussi et total logique de 105 fichiers vérifié (96 existants et 9 créés). `STATISTICS.md` global absent : aucun fichier global créé. Mandater le prompt SGS.md pour générer le fichier STATISTICS.md général à la racine du projet.
