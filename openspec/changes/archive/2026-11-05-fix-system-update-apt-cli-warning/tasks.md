# Tâches

- [x] 1. Spécifier la classification du message APT. Preuve : validation OpenSpec stricte réussie le 2026-11-05.
- [x] 2. Corriger le filtre et vérifier les cas de non-régression. Preuve : 39 tests ciblés, `bash -n` et ShellCheck réussis le 2026-11-05.
- [x] 3. Mettre à jour les documents et valider le périmètre. Preuve : README revu, TECHNICAL et CHANGELOG mis à jour ; 1 205 tests exécutés dont 2 ignorés, aucun échec, le 2026-11-05.

## Sous-lots normalisés

### fix-system-update-apt-cli-warning — code non attribué
Tâches 1 à 3 ; objectif : supprimer le faux avertissement tout en conservant les diagnostics réels ; dépendances : spécification avant implémentation, tests avant validation finale ; critères : tests isolés, contrôles Bash et OpenSpec ; état : VALIDÉ avant archivage le 2026-11-05. Attribution et identifiants définitifs en attente d'ACL.
