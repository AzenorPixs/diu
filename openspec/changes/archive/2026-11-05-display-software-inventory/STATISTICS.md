# Statistiques — inventaire des logiciels

## 1. Statistiques générales et décisions

Session SCM directe du 2026-11-05, réalisée par Codex après validation du périmètre. Aucun pilotage ni sous-agent. Modèle exact, durée globale, consommation de tokens et coût : N/A, mesures non collectées. Aucun commit, déploiement, publication ni CI/CD.

Code de lot non attribué : attribution et normalisation définitive des sous-lots à traiter ultérieurement par ACL.

## 2. Types de messages et d’outils

Lecture, modification et commandes locales via les outils de la session. Aucune navigation web. Nombre exhaustif de messages, appels d’outils, autorisations et écritures : N/A, absence de télémétrie exhaustive.

## 3. Fichiers modifiés

Code et tests : `root-install-debian.sh`, `lib/diu-help.sh`, `modules/softwares/infos.sh`, `tests/test_module_infos.py`. Documentation et cadrage : `README.md`, `TECHNICAL.md`, `CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`. Spécifications : `module-infos`, `diu-help` et `software-inventory`. Le change et ses rapports complètent ce périmètre. Voir [review.md](review.md) pour les détails et limites.

## 4. Commandes et validations

- Syntaxe Bash et ShellCheck réussis ; compilation Python réussie.
- Tests ciblés : 19 informations de modules et 61 aides réussis.
- Premier lancement global : 1 177 tests, 2 ignorés, 1 échec et 2 erreurs dans un même test de génération DevOps dont une fixture avait des permissions incompatibles ; reprise isolée réussie.
- Second lancement global : 1 179 tests, 1 177 réussis, 2 ignorés, aucun échec ni erreur, en 289,934 s. Seul ce lancement constitue le bilan final, sans additionner les tests ciblés déjà inclus.
- OpenSpec strict : change, `module-infos` et `diu-help` validés. Le contrôle global strict présente 47 échecs ; 47 échecs étaient également observés lors de la session précédente.
- Un répertoire temporaire `.diu-test-devops-w_p2t73i` reste présent avec des éléments appartenant à `devops` ; ses permissions n’ont pas été forcées.

Nombre exhaustif de commandes et leur ventilation : N/A, absence de collecte exhaustive. L’archivage `2026-11-05-display-software-inventory` a réussi et ses spécifications ont été synchronisées.

## 5. Accès web

Aucun appel d’outil de recherche ou de consultation web : 0. Les moteurs logiciels sont détectés localement, sans requête réseau.

## 6. Synthèse globale

La vue présente les moteurs en colonnes et les logiciels déclarés avec leurs états colorés. `diu infos`, `diu infos softwares` et `diu softwares infos` partagent l’affichage. La clé API et les noms de variables ne sont pas affichés. Bilan final : 1 179 tests = 1 177 réussis + 2 ignorés, aucun échec ni erreur. Voir [review.md](review.md).

Archivage et synchronisation réussis le 2026-11-05. Si `STATISTICS.md` global est absent, mandater SGS pour le générer ; ne pas le créer automatiquement.
