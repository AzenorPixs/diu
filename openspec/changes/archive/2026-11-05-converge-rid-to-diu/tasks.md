# Tâches — convergence des commandes DIU

## Réalisation
- [x] 1. Spécifier les noms publics et les exigences de convergence.
- [x] 2. Migrer le code, les alias, les fonctions et les fichiers d’aide avec leurs tests.
- [x] 3. Harmoniser les spécifications et la documentation courantes, sans réécrire les archives.
- [x] 4. Exécuter et vérifier les contrôles ciblés et la validation globale.
- [x] 5. Vérifier l’éligibilité à l’archivage et préparer le bilan de session.

## Sous-lots normalisés

Code non attribué ; repères provisoires, sans identifiants SL définitifs.

| Repère | Tâches | Périmètre et dépendances | Critères | État et preuves |
|---|---|---|---|---|
| Spécification | 1 | Contrats de convergence et liens ; périmètre validé le 2026-11-05 | Validation OpenSpec stricte | VALIDÉ — 2026-11-05, `openspec validate converge-rid-to-diu --strict --no-interactive` |
| Convergence intégrée | 2, 3 | Renommages et références indissociables ; dépend de 1 | Aides, alias, cohérence des chemins, archives préservées | VALIDÉ — 2026-11-05, 311 cas ciblés exécutés ; 26 erreurs de fixtures résolues par reprise réussie avec le Python DevOps ; 2 ignorés. Syntaxe et ShellCheck réussis ; archives comparées par SHA-256 |
| Qualification et clôture | 4, 5 | Dépend de 2 et 3 | Syntaxe, ShellCheck, régression, éligibilité et bilan préparé | VALIDÉ — 2026-11-05 : 1 177 tests globaux, 2 ignorés, aucun échec ; sources stables. OpenSpec ciblé strict réussi ; 47 échecs globaux stricts préexistants inchangés. Voir review.md et STATISTICS.md ; archivage `2026-11-05-converge-rid-to-diu` réussi, spécifications synchronisées et rapport vérifié |
