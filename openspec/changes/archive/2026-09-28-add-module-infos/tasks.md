## 1. Spécification
- [x] 1.1 Valider le change ciblé.

## 2. Implémentation
- [x] 2.1 Extraire le réseau et ajouter les informations des modules.
- [x] 2.2 Ajouter le routage, l'aide et la documentation.

## 3. Validation
- [x] 3.1 Tester affichages, agrégation, routage et aide.
- [x] 3.2 Vérifier syntaxe, ShellCheck et cohérence avant archivage.

## Validation observée

- `python3 -B -m unittest discover -s tests -p test_module_infos.py -v` : 10 tests réussis.
- `python3 -B -m unittest discover -s tests -p test_rid_help.py -k '*test_*help*' -v` : 40 tests réussis. Le filtre a sélectionné tout le fichier (son nom contient help), y compris ses tests de projets sur données temporaires ; aucun dépôt réel du projet n'a été manipulé.
- `bash -n` : les 10 scripts concernés sont valides.
- ShellCheck : les sept nouveaux modules, modules/system/apt.sh et lib/rid-help.sh sont valides.
- ShellCheck monolithe : code 1 préexistant, mêmes nombres de diagnostics par règle. Les sept imports dynamiques sont annotés SC1091 et leurs fichiers contrôlés séparément.
- UTF-8 et LF vérifiés sur les scripts ; aucune configuration de production utilisée par les nouveaux tests.
- `openspec validate add-module-infos --strict --no-interactive` : réussi avant implémentation.

## Cohérence finale

Le correctif utilisateur Debian puis réseau est appliqué au code, au test d'ordre,
à la spécification et à TECHNICAL.md. Les sept modules restent dans l'ordre validé.
Le chargeur de variables, les paramètres système et les fonctions métier sans
rapport sont préservés. PROJECT.md conserve ses responsabilités de modules ;
BUILD.md couvre déjà modules/ et lib/ ; DEVOPS.md n'exige aucune nouvelle dépendance.
Les aides s'exécutent avant la configuration, conformément à rid-help.
Le bootstrap historique peut toujours initialiser la configuration ; seules
les fonctions infos sont sans mutation. La version affichée est celle du paquet
installé, et non une version inventée pour un checkout de développement.
Les tests ne constituent pas une exécution de l'installation de production.
