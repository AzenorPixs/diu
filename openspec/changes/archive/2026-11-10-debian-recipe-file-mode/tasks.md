# Tâches

- [x] 1. Valider le contrat OpenSpec du mode optionnel.
- [x] 2. Implémenter le mode générique et déclarer 0755 dans la recette DIU.
- [x] 3. Tester le paquet, les modes invalides et la compatibilité.
- [x] 4. Mettre à jour la documentation et valider globalement.

## Sous-lot provisoire — code non attribué

Tâches 1 à 4 : contrat, constructeur, recette et validations. Dépendances : aucune pour les tests locaux ; livraison après validations. Critères : mode 0755 dans le paquet, source inchangée et recettes existantes préservées. État : validé le 2026-11-10. Preuves : 15 tests ciblés ; suite globale 1 238 tests dont 2 ignorés ; syntaxe Bash, ShellCheck -x, compilation Python et OpenSpec strict réussis. Le contrôle ciblé a été rejoué après le renforcement de la validation du mode.
