# Conception

La recette `github/codex-cli` réutilise la fonction de persistance déjà
déclarée par le fichier de variable Codex CLI lorsque celui-ci est chargé par
DIU. Après chaque changement d'état, elle appelle cette fonction après avoir
exporté la nouvelle valeur.

La mise à jour ciblée vérifie l'état avant tout appel réseau. Si l'état vaut
`0`, elle affiche une information et retourne avec succès. La mise à jour
globale reste protégée par la sélection des seuls logiciels installés.

Les tests exécutent la recette avec un fichier `softwares.env` temporaire afin
de vérifier à la fois la valeur du processus et la valeur relue après une
nouvelle initialisation.
