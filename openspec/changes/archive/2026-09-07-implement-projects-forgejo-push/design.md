# Conception

Le dispatch `projects forgejo push <ID PROJECT>` reste dans
`root-install-debian.sh` et délègue à `forgejo_push()` dans
`modules/projects/git.sh`. La fonction sélectionne explicitement le
fournisseur Forgejo et réutilise le flux commun de publication sans modifier
le `REMOTE_GIT_TYPE` des autres parcours.

La configuration dédiée est lue depuis `REMOTE_FORGEJO_BASE_URL`,
`REMOTE_FORGEJO_OWNER`, `REMOTE_FORGEJO_REPOSITORY`, `REMOTE_FORGEJO_NAME`,
`REMOTE_FORGEJO_BRANCH` et `REMOTE_FORGEJO_SSL_VERIFY`. Le remote configuré
est construit en HTTPS ; il est ajouté s'il est absent et la commande échoue
s'il existe avec une autre URL.

Le provider `lib/forgejo-auth.sh` conserve la gestion existante des fichiers
`config/forgejo.username` et `config/forgejo.token`, en acceptant le nom du
remote dédié et en transmettant le token au mécanisme temporaire
`git_with_token`. `REMOTE_FORGEJO_SSL_VERIFY=No` désactive la vérification TLS
pour les opérations Forgejo authentifiées ; la valeur `Yes` conserve le
comportement normal. Les valeurs invalides sont refusées.

