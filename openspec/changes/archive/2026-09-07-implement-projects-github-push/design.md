# Conception

Le dispatch `projects github push <ID PROJECT>` reste dans
`root-install-debian.sh` et délègue à `github_push()` dans
`modules/projects/git.sh`. La publication réutilise le flux commun de
`git_push()` avec le fournisseur GitHub sélectionné explicitement.

Le provider `lib/github-auth.sh` reprend le découpage GitLab : lecture et
initialisation interactive de `config/github.username` et
`config/github.token`, vérification du remote HTTPS configuré, puis appel à
`git_with_token`. Les identifiants restent en permissions 600 et le token ne
figure ni dans l'URL Git ni dans les sorties.

Le remote est construit à partir de `REMOTE_GITHUB_BASE_URL`,
`REMOTE_GITHUB_OWNER` et `REMOTE_GITHUB_REPOSITORY`, puis utilisé sous le nom
`REMOTE_GITHUB_NAME` pour publier la branche locale vers
`REMOTE_GITHUB_BRANCH`, ainsi que le tag pointant sur `HEAD` lorsqu'il existe.
