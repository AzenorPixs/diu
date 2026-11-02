# Retirer DIU_VARIABLES_VERSION du DIU

## Pourquoi

Le contrat `DIU_VARIABLES_VERSION` n’est plus souhaité dans le DIU.

## Changements

- Supprimer la déclaration et son affichage dans le résumé.
- Supprimer les tests et la spécification canonique dédiés.
- Conserver `DIU_VERSION`, qui affiche la version du paquet DIU installé.
- Conserver le nettoyage de l’affectation historique `VERSION_VARIABLES`,
  sans transfert de sa valeur.
