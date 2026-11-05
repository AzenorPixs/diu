# Conception

## Décision
La convergence porte sur les identifiants DIU explicites, sans remplacement de sous-chaînes dans les autres mots : les termes réseau `bridge`, les variables `BRIDGE_*` et l’alias Docker `drid` restent identiques.

La bibliothèque devient `lib/diu-help.sh`. Les fonctions `rid_*` deviennent `diu_*`, les tests d’aide deviennent `tests/test_diu_help.py` et les capacités actives d’aide deviennent `diu-help`. Les identifiants historiques des changes et les chemins d’archives restent stables.

Le générateur conserve les cibles des alias de production et développement. Les raccourcis d’ouverture et de mise à jour deviennent `diuo` et `diuu` ; le raccourci d’édition devient `ndiu`. Les raccourcis CI/CD existants appellent `diut`, sans être exécutés pendant cette session.

## Compatibilité et retour
Le routage et les arguments demeurent identiques. Les anciens noms ne sont plus produits par le générateur ; les configurations et shells déjà en service ne sont pas modifiés. Le retour consiste à restaurer les fichiers de source concernés avant toute installation. Les alias et liens occupés ne sont ni supprimés ni remplacés sur la machine.

## Validation
Contrôler les aides et erreurs via le point d’entrée isolé, extraire le bloc d’alias pour vérifier ses noms et ses cibles sans exécuter le programme d’installation, rechercher les anciens identifiants dans les sources exécutables et vérifier l’absence de modification des archives. Exécuter syntaxe, ShellCheck, tests ciblés, suite de régression et validation OpenSpec stricte.
