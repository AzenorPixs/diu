## Décisions

La fonction projects_update, déjà appelée par update_all mais actuellement
vide, appelle directement projects_template_all_all sans lancer une nouvelle
CLI ou recharger la configuration. Elle refuse les arguments et transmet
le code de retour du traitement. Les fonctions de modèles ne sont pas modifiées.

La branche update de manage_project_action distingue l'absence d'identifiant
du cas existant update <ID PROJECT>. La fonction update_projects et son
questionnement des variables restent inchangés. Un identifiant all conserve
son sens de projet ciblé dans cette commande. Les arguments supplémentaires
et identifiants explicitement vides sont refusés avant traitement.

update_all conserve l'ordre des six modules. Il mémorise l'échec projects,
appelle ensuite softwares comme prévu et rend un code non nul si projects
a échoué. Lorsque projects réussit, le code de retour final softwares reste
celui du comportement actuel. Pas de nouvelle politique pour les échecs des
autres modules, ni de refonte du parcours global.

Les aides projects, projects update, projects update <ID PROJECT> et update
expliquent la nouvelle action et la distinction ciblée. Elles restent
accessibles sans configuration et sans effet de bord.

## Validation et limites

Tests isolés des fonctions et gestionnaires réels : appels uniques, absence
d'argument, branche ciblée/all, erreurs de routage, sélection et ordre par
projet hérités du traitement all all, code de retour individuel et global,
préservation de softwares et de la suite des modules, aide help/? sans
configuration. Aucun vrai rid update système ni modèle réel ne sera lancé.
Bash -n, ShellCheck, suites ciblées et OpenSpec strict, puis archive ciblée.

La description d'un orchestrateur global enrichi dans TECHNICAL.md dépasse
le code actuel. Elle n'est pas une implémentation à ajouter dans ce change ;
la documentation de cette évolution identifie explicitement le parcours
effectivement conservé et l'écart préexistant. Aucun besoin de migration,
nouvelle dépendance, variable ou suppression. Les fichiers partiellement
écrits restent conservés selon le contrat des modèles.
