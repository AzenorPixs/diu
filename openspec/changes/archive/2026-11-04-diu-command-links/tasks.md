# Tâches

- [x] Spécifier les liens et la résolution du point d’entrée.
  Preuve : `openspec validate diu-command-links --strict`, 2026-11-04.
- [x] Implémenter les liens conditionnels et préserver les alias.
  Preuve : bootstrap, bibliothèque et constructeur du paquet ; tests ciblés, 2026-11-04.
- [x] Vérifier les cas nominaux, les collisions, les erreurs et l’idempotence.
  Preuve : 88 tests ciblés réussis, ShellCheck -x et syntaxe Bash réussis le 2026-11-04 ; pas d’installation réelle.
- [x] Mettre à jour la documentation et valider la cohérence globale.
  Preuves : cadrage technique, build, README et changelog relus ; 1 164 tests globaux dont 2 ignorés et ShellCheck réussis le 2026-11-04.
- [x] Vérifier les conditions de synchronisation et d’archivage : dépendance
  archivée, tests et contrôles réussis, spécification prête à synchroniser.

Jalon maintenu : « Synchroniser et archiver après validation de tous les critères
et dépendances ». Il intervient après la validation des tâches, conformément au
processus SCM, et ne peut être attesté avant son exécution.

## Sous-lots normalisés

### diu-command-links — commandes et liens — code non attribué

- Tâches : toutes les tâches ci-dessus ; objectif : commandes de production et de développement.
- Dépendance : `ENV_DEVOPS_PROJECTS_ROOT` dans `migrate-env-devops-projects-root`, validé et archivé le 2026-11-04.
- Contrôles : tests isolés, syntaxe, ShellCheck, OpenSpec strict et cohérence documentaire.
- État au 2026-11-04 : VALIDÉ ; archivage à effectuer ; preuves ci-dessus. Voir [STATISTICS.md](STATISTICS.md).

Blocages historiques résolus ; voir [STATISTICS.md](STATISTICS.md).

