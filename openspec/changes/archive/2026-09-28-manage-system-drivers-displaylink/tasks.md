## Réalisation
- [x] 1. Spécifier et valider le change.
- [x] 2. Implémenter module, routage, aide et retrait du bloc.
- [x] 3. Tester succès, idempotence, erreurs et persistance sans effets système.
- [x] 4. Vérifier syntaxe, ShellCheck, régressions et documentation.
- [x] 5. Vérifier la cohérence finale et préparer la synchronisation/archivage.

## Preuves de validation

- `openspec validate manage-system-drivers-displaylink --strict` : exécutée et réussie avant implémentation ; contrôle final exécuté avant archivage.
- `bash -n` sur root-install-debian.sh, modules/system/drivers.sh, modules/system/apt.sh et lib/rid-help.sh : exécutée et réussie.
- `shellcheck modules/system/drivers.sh modules/system/apt.sh lib/rid-help.sh` : exécutée et réussie.
- `shellcheck -f json root-install-debian.sh` : exécutée, 632 diagnostics préexistants contre 635 avant modification ; aucun code de diagnostic en augmentation. Le monolithe complet n'est pas propre au lint.
- `python3 -B -m unittest discover -s tests -p test_system_drivers.py -v` : 20 tests réussis, outils système remplacés.
- Suite unittest ciblée : test_system_drivers, test_system_apt, test_system_drivers_display_link, test_module_infos, test_config_cleanup et uniquement méthodes contenant help de test_rid_help : 76 tests exécutés et réussis. TMPDIR placé dans un répertoire temporaire du dépôt.
- Vérification réelle du hash et des métadonnées du paquet local préexistant, sans téléchargement ni installation : réussie. Paquet corrompu refusé.
- UTF-8 et LF : vérifiés sur les fichiers concernés.
- Régression corrigée : test_config_cleanup recherchait l'ancien consommateur monolithique ; il vérifie désormais l'import et le consommateur du module.
- Cohérence : TECHNICAL mis à jour ; PROJECT, BUILD et README ne contiennent pas d'exigence DisplayLink contradictoire. Déclaration statique et chargeur préservés. Alignement minimal du scénario legacy-variable-cleanup.
- Installation/désinstallation réelle et affichage physique : non exécutés, hors périmètre de cette session. Aucun dépôt APT, service ou configuration root réel modifié ; aucune opération Git.
