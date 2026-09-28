## 1. Implémentation
- [x] 1.1 Ajouter la déclaration statique et migrer les consommateurs.
- [x] 1.2 Étendre le nettoyage et les informations Debian.
- [x] 1.3 Adapter les tests et le cadrage technique.

## 2. Validation
- [x] 2.1 Vérifier la syntaxe Bash et les 27 tests isolés.
- [x] 2.2 Vérifier ShellCheck sur les trois fichiers modulaires et l'absence de nouveau diagnostic dans le monolithe.
- [x] 2.3 Contrôler les références autorisées et la cohérence du change OpenSpec.
- [x] 2.4 Résoudre la barrière de validation ShellCheck globale avant synchronisation et archivage.

## Preuves de validation
- `bash -n` exécuté sur les quatre fichiers Bash concernés : succès.
- `python3 -B -m unittest discover -s tests -p 'test_system_time_zone.py' -v` : 7 tests réussis.
- `python3 -B -m unittest discover -s tests -p 'test_config_cleanup.py' -v` : 6 tests réussis.
- `python3 -B -m unittest discover -s tests -p 'test_module_infos.py' -v` : 14 tests réussis.
- ShellCheck des trois fichiers modulaires : succès.
- ShellCheck global incluant root-install-debian.sh : échec. Comparaison en mémoire avec la version reconstruite avant les deux remplacements : 632 diagnostics avant, 631 après, zéro nouveau et zéro sur les lignes modifiées. Aucun diagnostic masqué ou désactivé dans le monolithe.
- `openspec validate add-system-time-zone --type change --strict` : succès avant implémentation.
- Recherche dans root-install-debian.sh, modules, lib, tests, deb et les cadrages concernés : TIME_ZONE reste uniquement dans le nettoyage et ses tests/documentation.
- UTF-8/LF et syntaxe Python des fichiers concernés : succès.

## Cohérence et limites
Le chargeur et le packaging restent inchangés. PROJECT.md et README.md ne nécessitent pas de modification. TECHNICAL.md documente l'initialisation et la suppression sans transfert ni sauvegarde. Les spécifications principales seront synchronisées lors de l'archivage ; les deltas validés décrivent le comportement implémenté. Aucun accès Git, aucune lecture ou modification de configuration locale réelle, aucune installation système. Le périmètre complémentaire fix-root-shellcheck a été explicitement validé puis réalisé. La barrière ShellCheck globale est levée : les quatre fichiers passent ensemble sans diagnostic. Les 76 tests ciblés, dont les 27 de cette évolution, passent. Le change est éligible à la synchronisation et à l'archivage autonomes.

## Validation finale complémentaire
- shellcheck root-install-debian.sh modules/diu/variables/system/system_time_zone.sh modules/system/variables-cleanup.sh modules/system/infos.sh : succès, zéro diagnostic après fix-root-shellcheck.
- Les échecs ShellCheck mentionnés plus haut décrivent uniquement le constat initial, désormais résolu.
