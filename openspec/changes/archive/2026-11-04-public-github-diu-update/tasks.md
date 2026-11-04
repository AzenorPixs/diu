## 1. Contrat et implémentation

- [x] 1.1 Définir et valider le contrat OpenSpec.
- [x] 1.2 Adapter le moteur et les tests de mise à jour anonyme et du secours.
- [x] 1.3 Mettre à jour la documentation concernée.
- [x] 1.4 Exécuter les validations ciblées et globales.

Preuves du 2026-11-04 : OpenSpec strict réussi ; 10 tests de mise à jour, 3 tests HTTP, 59 tests d’aide, `bash -n` et ShellCheck réussis. Suite globale avec Python DevOps : 1 147 tests réussis dont 2 ignorés ; les tests ciblés ont été rejoués après le dernier ajustement. Le blocage initial de fixture Python a été résolu avec l’interpréteur DevOps ; détail dans STATISTICS.md.

## Sous-lots normalisés

### public-github-diu-update — mise à jour publique — code non attribué

- Tâches : 1.1 à 1.4 ; objectif : mise à jour publique et anonyme.
- Périmètre : contrat, moteur, tests et documentation de mise à jour DIU.
- Dépendances : contrat validé avant implémentation.
- Critères : tests ciblés, syntaxe, ShellCheck et validation OpenSpec.
- État au 2026-11-04 : implémentation et validation réalisées ; archivé le 2026-11-04. Attribution du code : ACL.
