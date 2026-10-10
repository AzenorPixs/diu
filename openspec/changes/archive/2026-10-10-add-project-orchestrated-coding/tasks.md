## 1. Spécification

- [x] 1.1 Décrire et valider strictement le change dans le périmètre approuvé avant le code et les tests.

## 2. Implémentation et documentation

- [x] 2.1 Ajouter le lecteur, le questionnement, la persistance et la conservation dans le parcours historique.
- [x] 2.2 Ajouter les tests ciblés et mettre à jour TECHNICAL.md, README.md et CHANGELOG.md.

## 3. Validation avant archivage

- [x] 3.1 Exécuter syntaxe, ShellCheck et compilation Python ; distinguer les diagnostics hérités.
- [x] 3.2 Réussir les tests ciblés et les tests de non-régression applicables.
- [x] 3.3 Vérifier la cohérence documentaire, le périmètre, UTF-8/LF et la validation stricte du change.

Preuves : 17 + 26 + 9 + 17 = 69 tests finaux réussis, aucun échec ni ignoré.
Syntaxe Bash et py_compile réussis. ShellCheck des quatre fonctions modifiées
réussi ; les fichiers complets conservent seulement SC2004, SC2034, SC2269
et SC2086 déjà observés avant modification. Change strict valide. Le canon
projects-general-update présente déjà un avertissement de longueur pour sa
première exigence non modifiée ; cet avertissement est hors périmètre.
Contrôle sans Git : cinq cibles préexistantes modifiées, neuf témoins
inchangés avant synchronisation ; modifications Bash limitées aux quatre
fonctions prévues. Documentation revue et ajouts UTF-8/LF contrôlés.

L'archivage synchronise les deux canons après ces prérequis. Il est suivi
de la validation des canons et de la production et vérification des six
sections de STATISTIQUES.md dans cette seule archive.
