# Tâches

- [x] Spécifier la priorité des valeurs et le traitement sûr des anciennes affectations.
- [x] Déclarer les variables et migrer les consommateurs concernés, y compris
  les usages de `DEVOPS_USER` vers `ENV_DEVOPS_USER`.
- [ ] Vérifier la syntaxe, les migrations et les contrats OpenSpec.
  La suite globale a exécuté 1148 tests, dont 2 ignorés, sans échec. Les 219
  tests ciblés et OpenSpec strict réussissent; une synchronisation OpenSpec
  simulée réussit dans une copie temporaire. La forme historique présente sur
  l'hôte est acceptée par l'analyseur, sans exécution ni affichage de valeur.
  ShellCheck brut des 21 scripts concernés retourne 10 diagnostics sur
  `lib/docker.sh` et `lib/gitlab-auth.sh` (SC2009, SC2016, SC2034, SC2155,
  SC2295); ce contrôle reste à qualifier, sans correction hors périmètre.
- [ ] Publier le paquet et relancer le parcours dans CISMP — différé, hors du
  mandat courant sans commit ni incrément de version.

## Sous-lots normalisés

### migrate-env-devops-projects-root — ordre et migration — code non attribué

- Tâches : déclaration, migration des consommateurs et validation ciblée.
- Dépendance : `ENV_DEVOPS_USER` pour le défaut lorsque les deux valeurs de
  racine sont absentes; sa déclaration unitaire existe désormais et son défaut
  validé est `root`.
- Contrôles : tests isolés de priorité, migration littérale, chargement
  ordonné et absence de la dépendance; ShellCheck et validation OpenSpec.
- État au 2026-11-03 : RÉALISÉ À VALIDER; suite globale et contrôles ciblés
  réussis, diagnostics ShellCheck bruts à qualifier. Attribution du code et
  normalisation finale : ACL.
