# Conception

`modules/projects/docker.sh` expose `projects_docker_build`. La fonction
conserve le chemin de projet et le Dockerfile par défaut existants, charge
`project.env`, puis valide immédiatement `PROJECT_DOCKERED` avec les trois
valeurs autorisées (`Yes`, `YES`, `1`). Elle vérifie ensuite le Dockerfile et
`entrypoint.sh` avant de lancer `docker build` sous `DEVOPS_USER`.

Le dispatch de `manage_project_action` traite `docker build` comme une
sous-commande de `projects docker`. Les chemins d'aide anticipée et
`display_help_context` présentent `docker`, puis `build`, et ne présentent
plus `dockerb`. Le parcours CI/CD Docker appelle également le nouveau nom de
fonction.
