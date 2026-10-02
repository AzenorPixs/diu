## Context

Le bloc OPENSPEC du monolithe vérifie npm, installe OpenSpec si nécessaire,
génère son profil custom et vérifie la version. Les templates de projets
possèdent déjà un traitement init/update, mais leur chemin et leur API ne
correspondent pas à la cible /home/${ENV_DEVOPS_USER} demandée ici.

## Goals / Non-Goals

Préparer le domicile à la fin du bloc actif, avec un seul shell de connexion
su et les commandes validées. Préserver toutes les étapes antérieures et les
interfaces projets. Ne pas traiter datas/<ID PROJECT>, changer la
configuration OpenCode, ajouter une dépendance ou installer réellement des
outils pendant les validations.

## Decisions

Le shell enfant rejoint explicitement le domicile et ajoute les chemins Node
et npm DevOps à PATH. Il détecte le dossier openspec après le changement
d'utilisateur. La branche update ignore OPENCODE ; la branche init exige 0 ou
1. Les données interpolées sont protégées avec des apostrophes échappées.
Un échec de cd, su ou OpenSpec entraîne un diagnostic et un arrêt non nul
avant la suite du DIU. Aucun nettoyage des écritures OpenSpec n'est effectué.

## Validation

Les tests unittest extraient uniquement le bloc ajouté dans sa garde
OPENSPEC. su est simulé et exécute le shell enfant dans un domicile temporaire
contrôlé ; OpenSpec est simulé. Les tests contrôlent les arguments, le compte,
le répertoire, PATH, les branches, les erreurs et la désactivation.
Les vérifications comprennent bash -n, ShellCheck, py_compile sans artefact
hors du projet, les tests ciblés et openspec validate --strict.

## Risks / Trade-offs

Une future exécution réelle peut laisser des écritures OpenSpec partielles en
cas d'échec. Elles sont conservées pour diagnostic ; aucun retour automatique
n'est ajouté. Les tests simulés prouvent le routage et la propagation des
échecs, mais ne constituent pas une installation réelle d'OpenSpec.
