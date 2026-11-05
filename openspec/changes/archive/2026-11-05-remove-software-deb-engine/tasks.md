# Tâches

- [x] 1. Spécifier le retrait du moteur logiciel `deb` et la conservation des autres parcours.
- [x] 2. Retirer le moteur, son routage et ses entrées d'aide ; adapter les tests et la documentation.
- [x] 3. Vérifier la syntaxe, les tests ciblés et la validation globale.

## Sous-lots normalisés

Code non attribué ; repères provisoires sans identifiant définitif.

| Repère | Tâches | Périmètre et dépendances | Critères | État |
|---|---|---|---|---|
| Contrat | 1 | Spécification du retrait | Validation OpenSpec | VALIDÉ — 2026-11-05, validation stricte |
| Retrait | 2 | Code, aide, tests et documentation ; dépend de 1 | Commandes refusées, autres moteurs préservés | VALIDÉ — 2026-11-05, 31 tests logiciels et test de refus réussis |
| Qualification | 3 | Contrôles ; dépend de 2 | Tests et cohérence validés | VALIDÉ — 2026-11-05, 1 177 tests dont 2 ignorés sur état partagé, syntaxe et ShellCheck réussis |
