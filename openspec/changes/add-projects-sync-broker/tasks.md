## 1. Spécification et implémentation

- [x] 1.1 Réorienter et valider le change pour la synchronisation limitée.
- [x] 1.2 Limiter les contrôles, copies et droits à AGENTS.md, .gitignore
      et PROMPTS, sans copie OpenCode ou CAB locale ou globale.
- [x] 1.3 Couvrir les variantes unitaire et groupée, l'absence des sources
      exclues et la préservation des destinations existantes ou absentes.

## 2. Validation

- [ ] 2.1 Exécuter bash -n, ShellCheck et la compilation Python.
- [x] 2.2 Exécuter les tests projets et d'aide CLI.
- [x] 2.3 Vérifier le périmètre, UTF-8/LF, les sources et cadrages applicables
      et la conformité des exigences à la RFC 2119.
- [ ] 2.4 Valider le change et la capacité projects-sync en mode strict
      et vérifier l'éligibilité à l'archivage du seul change ciblé.

## Preuves observées

- Périmètre autonome validé le 2026-10-03 : retrait des copies OpenCode et
  CAB des projets et du broker global, avec spécification et archivage ciblé.
- `openspec validate add-projects-sync-broker --strict` : exécutée et réussie
  avant l'implémentation, via `/home/devops/.local/npm/bin/openspec`.
- `bash -n modules/projects/projects.sh` : exécutée et réussie.
- `python3 -m py_compile tests/test_projects.py` : exécutée et réussie,
  également avec `/home/devops/python/current/bin/python3`.
- Tests projets : 26 tests exécutés et réussis, y compris les variantes
  unitaire et groupée et les ressources exclues existantes ou absentes.
- Tests d'aide CLI : 56 tests exécutés et réussis.
- Revue sans Git : fonctions et tests hors synchronisation inchangés ;
  empreintes du routage, de l'aide et des cadrages inchangées. Les huit fichiers
  prévus sont UTF-8/LF ; les exigences du delta respectent la RFC 2119.
- Matrice de cohérence : AGENTS.md gouverne les accès ; PROJECT.md conserve
  son architecture ; TECHNICAL.md distingue sync des commandes de templates ;
  DEVOPS.md fournit les chemins des outils ; README.md décrit les publications.
  Aucun de ces cadrages ne devient inexact du fait du retrait. BUILD.md conserve
  des exemples historiques avec `proj`, contrairement à la CLI actuelle :
  écart préexistant hors périmètre, non corrigé.
- Validation finale du change en mode strict : exécutée et réussie.
- Validation de la capacité principale projects-sync en mode strict : exécutée
  et réussie avant synchronisation ; deux conseils informatifs de longueur
  sont signalés sur des exigences préexistantes, sans erreur.
- `shellcheck modules/projects/projects.sh` : exécutée et échouée sur
  SC2004 dans `project_env_set_variables`, hors synchronisation. Le même
  diagnostic est observé sur la version initiale conservée en mémoire.
  La correction d'une ligne attend une extension explicite du périmètre.
- Aucune synchronisation réelle, opération Git ou mise à jour de production
  n'a été exécutée. L'archivage reste non exécuté tant que la validation
  applicable n'est pas réussie.
