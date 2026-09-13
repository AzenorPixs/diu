# Conception : analyse Git sous `projects git`

Le sous-dispatch `projects git` de `manage_project_action` reconnaît l'action
`analyse` et appelle directement `git_analyse` avec l'identifiant de projet.
Le cas historique `gita` est retiré du dispatch supérieur.

L'aide de premier niveau référence la syntaxe canonique. L'aide
`projects git` liste la sous-commande `analyse`. Les tests d'aide vérifient la
présence de la nouvelle syntaxe et l'absence de l'ancienne.
