# Tâches

- [x] Spécifier la priorité des valeurs et le traitement sûr des anciennes affectations.
- [x] Déclarer les variables et migrer les consommateurs concernés, y compris
  les usages de `DEVOPS_USER` vers `ENV_DEVOPS_USER`.
- [x] Corriger les diagnostics ShellCheck des trois modules partagés en préservant leurs comportements et vérifier les tests ciblés.
  Preuves du 2026-11-04 : ShellCheck sans diagnostic et 127 tests ciblés réussis.
- [x] Vérifier la syntaxe, les migrations et les contrats OpenSpec.
  Preuves finales du 2026-11-04 : 1 164 tests, dont 2 ignorés, réussis avec le Python DevOps ; ShellCheck -x et bash -n réussis ; OpenSpec strict réussi.
  La suite globale a exécuté 1148 tests, dont 2 ignorés, sans échec. Les 219
  tests ciblés et OpenSpec strict réussissent; une synchronisation OpenSpec
  simulée réussit dans une copie temporaire. La forme historique présente sur
  l'hôte est acceptée par l'analyseur, sans exécution ni affichage de valeur.
  Au 2026-11-04, la suite complète avec le Python DevOps réussit : 1 160 tests,
  dont 2 ignorés ; syntaxe Bash des 21 scripts et validation OpenSpec stricte
  réussies. À cette étape ShellCheck -x signalait encore des diagnostics ;
  ils ont depuis été corrigés ou qualifiés, voir [STATISTICS.md](STATISTICS.md).
  Au 2026-11-03, ShellCheck brut des 21 scripts retournait 10 diagnostics sur
  `lib/docker.sh` et `lib/gitlab-auth.sh` (SC2009, SC2016, SC2034, SC2155,
  SC2295), alors laissés sans correction hors périmètre.

Le parcours CISMP mentionné dans le mandat antérieur est hors périmètre de
cette session SCM directe ; il n’a pas été exécuté. La publication reste
soumise aux étapes Git conditionnelles du processus SCM après archivage.

## Sous-lots normalisés

### migrate-env-devops-projects-root — ordre et migration — code non attribué

- Tâches : déclaration, migration des consommateurs, correction ShellCheck et validation ciblée.
- Dépendance : `ENV_DEVOPS_USER` pour le défaut lorsque les deux valeurs de
  racine sont absentes; sa déclaration unitaire existe désormais et son défaut
  validé est `root`.
- Contrôles : tests isolés de priorité, migration littérale, chargement
  ordonné et absence de la dépendance; ShellCheck et validation OpenSpec.
- État au 2026-11-04 : VALIDÉ ; suite globale, ShellCheck et tests ciblés
  réussis après finalisation du packaging concurrent. Voir
  [STATISTICS.md](STATISTICS.md). Attribution du code et normalisation finale : ACL.

Blocages historiques résolus ; voir [STATISTICS.md](STATISTICS.md).
