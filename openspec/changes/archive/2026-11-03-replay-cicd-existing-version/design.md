# Conception

## Contexte

Le CI/CD courant s'arrête dès qu'une version est attribuée. Les builders et publishers utilisent les chemins et les références du projet courant ; le builder Docker résout notamment un chemin fixe. Le rejeu exige donc un contexte isolé sur le commit du tag et un traitement explicite des références distantes.

## Décisions

- Résoudre le tag local en commit avant toute opération. Préserver l'index, l'arbre de travail et les modifications non suivies ; les sources de build proviennent exclusivement de ce commit.
- Préparer un contexte temporaire privé pour chaque rejeu. Fournir au contexte les seuls éléments de configuration nécessaires et nettoyer les temporaires en cas de succès, d'échec ou d'interruption.
- Vérifier chaque branche et tag distant avant publication. Ne jamais déplacer un tag existant ni ramener une branche distante en arrière ; les étapes non applicables sont expliquées dans le bilan.
- Construire les artefacts dans le contexte isolé et traiter les releases Debian existantes sans remplacement. Si l'immutabilité distante d'un tag Docker ne peut pas être confirmée, ignorer sa publication et l'indiquer ; les publications Debian restent indépendantes.
- Tester les interactions sur dépôts et transport simulés, avec fichiers indexés, non indexés et non suivis, sans publication de production.

## Risques et limites

- Les fichiers non versionnés peuvent être nécessaires à certains projets. Leur absence dans le commit est signalée comme erreur de construction, sans importer les modifications en attente.
- Une publication distante peut échouer ou changer entre la vérification et l'écriture. Les contrôles de concurrence restent bloquants et aucune réussite n'est annoncée sans confirmation.
