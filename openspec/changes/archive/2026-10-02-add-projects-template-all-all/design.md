## Décisions

Une nouvelle fonction groupée utilise le sélecteur statique DevOps existant,
les mêmes chemins, prérequis et motifs de dossiers directs et cachés.
La boucle travaille par projet : OpenSpec puis DevOps, directement via les
fonctions individuelles. Elle ne lance pas deux boucles groupées successives.
DevOps reste l'étape finale après les autres modèles, actuellement OpenSpec.
Les commandes et le compte su de la fonction OpenSpec sont conservés.

Si OpenSpec échoue, DevOps n'est pas exécuté pour ce projet, conformément
à sa dépendance et au comportement de create. Si DevOps échoue, le projet
est également compté échoué. Dans les deux cas le projet suivant est traité.
Un projet ne compte comme réussi que si les deux modèles réussissent.
Aucun projet éligible produit un succès et un bilan vide ; au moins un projet
échoué produit un code non nul. Les écritures partielles sont conservées.

La CLI accepte seulement les deux sélecteurs all pour cette nouvelle voie,
sans élargir all à un projet individuel. Les aides all et all all, help et ?,
fonctionnent avant configuration et sans effet de bord. Aucune dépendance
ni variable de configuration nouvelle n'est nécessaire.

## Validation et repli

Tests avec fixtures contrôlées, doubles OpenSpec/su et binaires DevOps
simulés : ordre par projet, sélection inchangée, all sans récursion,
init/update, OPENCODE 0/1, échec de chaque étape, prérequis, bilan, routage
et aide sans configuration. Régressions individuelles, groupées et create,
Bash -n, ShellCheck et validations OpenSpec strictes.
Pas de migration ni suppression ; les fichiers existants et écritures
partielles sont conservés en cas d'échec, comme dans les fonctions existantes.
