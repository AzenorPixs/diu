## Tâches
- [x] 1. Spécifier et valider le change.
- [x] 2. Ajouter affichage, agrégation, routage et aide.
- [x] 3. Adapter documentation et tests ciblés.
- [x] 4. Vérifier syntaxe, ShellCheck, tests et cohérence avant archivage.

## Validation observée
- `openspec validate add-system-drivers-infos --strict` : réussie avant implémentation ; revalidation avant archivage.
- `python3 -B -m unittest discover -s tests -p test_module_infos.py -v` : 14 tests réussis.
- Suite unittest isolée test_module_infos, test_system_drivers, test_system_apt et uniquement les méthodes d’aide de test_rid_help : 66 tests réussis. TMPDIR situé dans le dépôt et nettoyé.
- `bash -n` pour modules/system/infos.sh, modules/system/apt.sh, lib/rid-help.sh : réussi.
- `shellcheck modules/system/infos.sh modules/system/apt.sh lib/rid-help.sh` : réussi.
- UTF-8/LF vérifiés ; corps de system_update identique à celui observé avant intervention.
- Ordre Debian → drivers → réseau, aide help/?, routage, valeur absente/vide/0/UNSET, version installée, paquet incomplet, outil en erreur, conservation de la configuration et poursuite du réseau après erreur couverts.
- TECHNICAL adapté ; aucune modification requise de PROJECT, BUILD, DEVOPS ou README pour cet ajout d’information.
- Aucun effet système réel, aucune opération Git, aucune nouvelle dépendance. La version affichée est celle du paquet installé et ne prouve pas le fonctionnement des écrans.

## Fichiers applicatifs concernés
- modules/system/infos.sh : nouveau bloc et agrégation.
- modules/system/apt.sh : feuille infos drivers uniquement.
- lib/rid-help.sh : aide racine, parente et terminale.
- tests/test_module_infos.py : scénarios et ordre.
- TECHNICAL.md : comportement documenté.
