## Décision
Retirer uniquement la branche de routage publique et ses entrées d’aide. Conserver la fonction interne de mise à jour APT utilisée par la mise à jour globale. La syntaxe supprimée est une rupture pour les scripts appelants ; aucun alias ni migration ne sont ajoutés.

## Validation
Tester le refus sans effet et les commandes conservées avec des fonctions simulées, puis vérifier aide, syntaxe et tests applicables.
