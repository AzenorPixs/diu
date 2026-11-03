# Tâches

- [x] Spécifier la priorité des valeurs et le traitement sûr des anciennes affectations.
- [x] Déclarer la variable et migrer les consommateurs concernés.
- [ ] Vérifier la syntaxe, les migrations et les contrats OpenSpec.
  Les 1142 tests globaux exécutés comprennent 2 tests ignorés; les tests ciblés
  et OpenSpec strict réussissent. ShellCheck brut des modules projets émet 46
  diagnostics informatifs SC1091 pour des sources non suivies; un contrôle
  complémentaire excluant ce seul diagnostic ne relève aucune autre alerte.
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
- État au 2026-11-03 : EN COURS; 1142 tests exécutés dont 2 ignorés, tests
  ciblés et OpenSpec strict réussis; ShellCheck brut reste à consolider pour
  les inclusions dynamiques. Attribution du code et normalisation finale : ACL.
