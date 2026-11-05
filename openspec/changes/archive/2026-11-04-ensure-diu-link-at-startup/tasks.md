# Tâches

- [x] Spécifier la vérification au démarrage et les comportements préservés.
  Preuve : OpenSpec strict, 2026-11-04.
- [x] Implémenter le contrôle et vérifier ses scénarios en environnement isolé.
  Preuve : 65 tests ciblés réussis, 2026-11-04 ; privilèges et chemins simulés.
- [x] Vérifier syntaxe, ShellCheck, tests, OpenSpec et cohérence documentaire.
  Preuves du 2026-11-04 : 1 165 tests dont 2 ignorés, sans échec ; syntaxe Bash, ShellCheck, compilation Python et OpenSpec strict réussis.

## Sous-lots normalisés

### ensure-diu-link-at-startup — démarrage installé — code non attribué

- Tâches : spécification, contrôle de démarrage et validations.
- Objectif : rendre la commande de production disponible après exécution du script installé.
- Dépendances : helper et contrat du change archivé `diu-command-links`.
- Contrôles : scénarios isolés, syntaxe, ShellCheck, tests et validation OpenSpec.
- État au 2026-11-04 : VALIDÉ ; attribution du code à traiter par ACL.
