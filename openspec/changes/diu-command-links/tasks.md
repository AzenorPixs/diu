# Tâches

- [x] Spécifier les liens et la résolution du point d’entrée.
  Preuve : `openspec validate diu-command-links --strict`, 2026-11-04.
- [x] Implémenter les liens conditionnels et préserver les alias.
  Preuve : bootstrap, bibliothèque et constructeur du paquet ; tests ciblés, 2026-11-04.
- [x] Vérifier les cas nominaux, les collisions, les erreurs et l’idempotence.
  Preuve : 88 tests ciblés réussis, ShellCheck -x et syntaxe Bash réussis le 2026-11-04 ; pas d’installation réelle.
- [ ] Mettre à jour la documentation et valider la cohérence globale.
- [ ] Synchroniser et archiver après validation de tous les critères et dépendances.

## Sous-lots normalisés

### diu-command-links — commandes et liens — code non attribué

- Tâches : toutes les tâches ci-dessus ; objectif : commandes de production et de développement.
- Dépendance : `ENV_DEVOPS_PROJECTS_ROOT` dans `migrate-env-devops-projects-root`, validé et archivé le 2026-11-04.
- Contrôles : tests isolés, syntaxe, ShellCheck, OpenSpec strict et cohérence documentaire.
- État au 2026-11-04 : BLOQUÉ pour validation globale et archivage ; preuves ciblées ci-dessus. Voir [BLOCKERS.md](BLOCKERS.md).

Bilan durable : [BLOCKERS.md](BLOCKERS.md). Statistiques : [STATISTICS.md](STATISTICS.md).
