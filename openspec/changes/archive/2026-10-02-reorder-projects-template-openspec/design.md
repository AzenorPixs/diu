## Décisions

Dans manage_project_action, traiter d'abord le sélecteur openspec après
template et prendre le troisième argument comme identifiant. La branche
DevOps conserve template <ID PROJECT> devops et template all devops.
L'identifiant all reste un seul projet pour OpenSpec. Le projet devops reste
accessible par template openspec devops ; ce sélecteur est prioritaire sur
l'ancienne interprétation DevOps du projet nommé openspec.

Dans l'aide, interpréter openspec comme troisième composant du contexte,
puis un éventuel identifiant comme quatrième composant. Afficher le nouveau
libellé via ENV_DEVOPS_USER et garder les détails profil custom, OPENCODE et
update dans l'aide spécifique OpenSpec. Les contextes existants par projet
peuvent proposer la nouvelle commande complète, tandis qu'une ancienne
commande terminale OpenSpec est rejetée.

## Préservation et repli

La fonction projects_template_openspec garde son argument unique, son compte
et ses commandes. L'appel en fin de création est conservé. Aucun projet
existant ni configuration n'est migré ; le seul changement concerne la CLI.
Les scripts ou alias utilisant l'ancienne syntaxe doivent être adaptés.
Aucun nettoyage ni opération Git ne fait partie du changement.

## Validation

Tests de routage : nouvelle syntaxe, all, projet devops, rejet de l'ancienne
syntaxe, arguments manquants, surnuméraires et chemins invalides ; conservation
du routage DevOps. Tests help et ? généraux, intermédiaires et terminaux sans
configuration. Tests existants de la fonction et de la création. bash -n,
ShellCheck et validations strictes OpenSpec sous devops, hors sandbox.
