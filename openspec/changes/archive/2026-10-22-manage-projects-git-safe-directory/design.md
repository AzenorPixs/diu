## Décisions

La portée système est retenue pour couvrir les comptes DevOps et humains
qui partagent les dépôts. L'exception porte sur le chemin réel d'un seul
projet, obtenu par `realpath -e`. Aucun joker n'est ajouté. Un chemin dont
la représentation Git aurait un sens large (`/*` final) ou contient un saut
de ligne est refusé.

Un lecteur commun utilise `git config --system --includes --path --null
--get-all safe.directory`. Les séparateurs NUL préservent les valeurs vides
et empêchent de confondre une valeur multiligne avec plusieurs entrées.
Le code 1 signifie une clé absente ; les autres erreurs
sont propagées avec un diagnostic. Une valeur vide réinitialise la liste :
seule une entrée exacte après la dernière réinitialisation compte comme
présente. Une règle `*` ou une règle récursive ne remplace pas cette entrée.
L'ajout utilise `git config --system --add`, sans modifier les autres règles.
Une vérification après écriture interdit un faux succès. Si un include
système réinitialise la liste après la section modifiée par Git, la commande
échoue explicitement ; une entrée déjà présente dans le fichier principal
mais neutralisée n'est pas ajoutée à nouveau. Aucun déplacement ou changement
de priorité des règles administrateur n'est effectué.

`git_init` enregistre l'exception avant le contrôle du dépôt existant, après
les vérifications de configuration et d'accès. L'ajout reste silencieux.
`git_update` appelle le questionnaire local existant puis enregistre
l'exception si ce questionnaire a réussi. Une erreur laisse les écritures
déjà effectuées en place et renvoie un échec explicite ; aucune opération
Git de publication n'est déclenchée.

`git_status` affiche le diagnostic avant le chargement de la configuration
du projet et avant les opérations sur le dépôt. Ses replis de configuration
appellent directement `git_update_local`, afin de préserver leur comportement
sans ajouter indirectement une exception. Le diagnostic décrit la présence
de l'entrée système exacte, pas une garantie de confiance effective pour
tous les utilisateurs : des règles globales prioritaires peuvent la modifier.

## Vérifications et repli

Les tests isolent HOME, XDG_CONFIG_HOME, GIT_CONFIG_GLOBAL et
GIT_CONFIG_SYSTEM dans un répertoire temporaire du projet. Les appels
runuser, chown et les créations de commits sont simulés si nécessaire.
Les assertions couvrent les effets dans le fichier système, l'idempotence,
les réinitialisations, la conservation des autres règles, les chemins avec
espaces et liens symboliques, les erreurs et la lecture seule de status.

L'évolution ne migre aucun dépôt automatiquement. Un retour aux sources
précédentes n'efface pas les exceptions déjà installées ; une révocation
éventuelle se fait séparément en retirant uniquement l'entrée voulue de la
configuration système. Aucun repli n'est exécuté pendant cette session.

Le change actif `ensure-projects-git-commit-init` reste intact. Ses exigences
d'initialisation silencieuse et non interactive sont conservées.
