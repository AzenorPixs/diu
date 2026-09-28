## 1. Spécification
- [x] 1.1 Valider le change et sa cohérence avec le périmètre approuvé.

## 2. Implémentation
- [x] 2.1 Ajouter la déclaration dynamique et migrer les consommateurs.
- [x] 2.2 Étendre le nettoyage historique et documenter la migration.

## 3. Validation
- [x] 3.1 Exécuter les tests isolés de détection et nettoyage.
- [x] 3.2 Vérifier syntaxe, ShellCheck, portée et cohérence documentaire.
- [x] 3.3 Vérifier la cohérence finale avant synchronisation et archivage.

## Résultats observés

- `python3 -B -m unittest discover -s tests -p 'test_system_debian*.py' -v` : 11 tests réussis.
- `python3 -B -m unittest discover -s tests -p 'test_config_cleanup.py' -v` : 5 tests réussis.
- `bash -n` sur les trois scripts concernés : réussi.
- `shellcheck modules/diu/variables/system/system_debian_environnement.sh modules/system/variables-cleanup.sh` : réussi.
- ShellCheck sur root-install-debian.sh : code 1 préexistant ; mêmes nombres
  de diagnostics par règle avant/après. Aucune correction hors périmètre.
- Sourcing isolé de la déclaration sur cette machine : PHYSICAL.
- Vérification UTF-8/LF et absence des anciens consommateurs : réussie.
- Validation OpenSpec stricte du change : réussie.

## Cohérence et portée

- AGENTS.md : exclusions respectées ; aucune inspection Git dans ce job SCM.
- PROJECT.md : évolution locale explicitement autorisée par le développeur.
- TECHNICAL.md : déclaration, priorité et migration documentées.
- BUILD.md : nouveau fichier déjà couvert par le packaging modules/ ; inchangé.
- DEVOPS.md : outils existants réutilisés ; inchangé.
- README.md : aucun détail contradictoire sur cette variable ; inchangé.
- Chargeur inchangé ; configurations locales non consultées et non modifiées.
- Les tests couvrent des environnements simulés ; aucun essai matériel LXC,
  Docker, Proxmox ou Hyper-V supplémentaire n'a été exécuté.
- Les artefacts DisplayLink antérieurs restent hors périmètre et intacts.
- L'archivage et la synchronisation sont effectués après ce contrôle via OpenSpec.
