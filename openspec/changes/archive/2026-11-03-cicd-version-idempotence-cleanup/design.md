# Conception

## Contexte

La sélection des versions et les publications traversent plusieurs modules. Le contrat Debian natif compare les versions numériques indépendamment de DIU.

## Objectifs

Garantir la reprise des opérations satisfaites, la sélection stable en priorité et la sauvegarde avant nettoyage des seules références concernées. Les installations et constructions de production restent hors de cette intervention.

## Décisions

- La valeur optionnelle est validée avant toute modification ; seule l'affectation PROJECT_VERSION est modifiée dans une configuration existante, sans évaluation de son contenu.
- Un tag existant ne change jamais de commit. Une version déjà attribuée à un autre commit interrompt la publication de manière informative ; les erreurs effectives restent des erreurs.
- Les versions stables sont prioritaires dans les sélecteurs DIU. Les métadonnées Debian ne contiennent aucun epoch ajouté par DIU.
- Une release et son artefact déjà présents sont conservés. Une publication incomplète peut être reprise uniquement sans remplacement.
- Avant suppression, conserver les objets Git, les métadonnées et les fichiers joints dans une sauvegarde privée vérifiée. Utiliser les références et identifiants inventoriés avec contrôle de concurrence ; ne pas réécrire les branches.

## Risques et migration

- Une version horodatée déjà installée reste supérieure selon dpkg/APT : la priorité DIU ne modifie pas cet ordre natif.
- Les identifiants et compteurs de releases supprimées ne sont pas restaurables à l'identique. Les données et artefacts sauvegardés permettent une recréation manuelle.
- Une référence modifiée depuis l'inventaire ne doit pas être supprimée ; elle est signalée pour examen.
