## 1. Spécification
- [x] 1.1 Valider le change et les adaptations des exigences existantes.

## 2. Implémentation
- [x] 2.1 Ajouter la déclaration et migrer les consommateurs.
- [x] 2.2 Étendre le nettoyage historique et documenter les impacts.

## 3. Validation
- [x] 3.1 Exécuter les tests de détection, persistance, nettoyage et prérequis.
- [x] 3.2 Vérifier syntaxe, lint, portée et cohérence avant archivage.

## Validations observées

- `python3 -B -m unittest discover -s tests -p test_system_drivers_display_link.py -v` : 8 tests réussis, avec plusieurs cas par paquet et statut.
- `python3 -B -m unittest discover -s tests -p test_config_cleanup.py -v` : 6 tests réussis.
- `python3 -B -m unittest discover -s tests -p test_system_apt.py -v` : 10 tests réussis ; TMPDIR isolé sous la racine du projet.
- `bash -n` : point d'entrée, déclaration et nettoyage valides.
- `shellcheck modules/diu/variables/system/system_drivers_display_link.sh modules/system/variables-cleanup.sh` : réussi.
- ShellCheck du monolithe : diagnostics préexistants, mêmes nombres par règle avant/après ; non corrigés hors périmètre.
- UTF-8/LF vérifiés, chemin compatible avec le chargeur existant.
- Recherche DISPLAY_LINK : consommateurs migrés ; ancien nom conservé seulement dans migration, tests et documentation, hors archives historiques.

## Cohérence du périmètre

- AGENTS.md : exclusions respectées, aucune configuration locale consultée, aucune opération Git.
- PROJECT.md : responsabilités system et diu conservées.
- TECHNICAL.md : sémantique statique, migration, trois valeurs et limites documentées.
- BUILD.md : nouvelle déclaration déjà couverte par modules/, aucune modification nécessaire.
- DEVOPS.md : aucun ajout de dépendance ; outils existants utilisés.
- README.md : aucune présentation de DISPLAY_LINK à modifier dans le périmètre recherché.
- OpenSpec : nouvelle capacité et adaptations de legacy-variable-cleanup et system-prerequisites incluses.
- Le nettoyage de variables.sh est livré pour la prochaine exécution, non exécuté sur la production.
- Aucun changement APT, DisplayLink, DKMS ni test réel d'installation effectué.
