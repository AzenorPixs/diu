## 1. Corrections
- [x] 1.1 Corriger expansions, substitutions et redirections avec préservation des sorties.
- [x] 1.2 Corriger les arguments ocsh et docker rootless inspect et documenter les faux positifs locaux.
- [x] 1.3 Ajouter les tests isolés.

## 2. Validation et préparation de clôture
- [x] 2.1 Exécuter bash -n, ShellCheck et les tests applicables.
- [x] 2.2 Vérifier la cohérence et l'éligibilité à la synchronisation et à l'archivage.

## Preuves
- bash -n sur root-install-debian.sh et les trois fichiers modulaires de SYSTEM_TIME_ZONE : succès.
- shellcheck root-install-debian.sh modules/diu/variables/system/system_time_zone.sh modules/system/variables-cleanup.sh modules/system/infos.sh : succès, zéro diagnostic.
- 76 tests unittest réussis : test_root_shellcheck.py, test_rid_help.py, test_module_infos.py, test_config_cleanup.py et test_system_time_zone.py. Exécution Python avec -B et répertoires temporaires confinés au projet.
- Comparaison des sorties de 13 cibles générées avec valeurs contrôlées : identiques avant/après. Les empreintes de référence sont conservées dans les tests. Les 14 corps heredoc Zsh sont également identiques.
- UTF-8, LF et syntaxe Python des fichiers concernés : succès.
- La copie temporaire de comparaison a été supprimée après les vérifications.

## Cohérence et limites
Les annotations sont locales et justifiées : imports externes, appels depuis les modules ou le trap, dollars volontairement littéraux et entrées historiques externes. Aucun diagnostic n'est désactivé globalement. Les listes ACME et Docker utilisent des tableaux ; les consommateurs scalaires conservent un argument unique. Les routes documentées dans lib/rid-help.sh transmettent désormais leurs arguments. Les cadrages existants restent applicables sans nouvelle dépendance, changement d'architecture ou de packaging. Aucune configuration locale réelle, opération Docker, installation système ou état Git n'a été utilisé pour la validation. L'installation complète reste non exécutée : les validations sont statiques et isolées.
