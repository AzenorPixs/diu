# Proposition: publication GitLab des projets DIU

Le projet DIU permet déjà de publier un dépôt GitLab (`rid projects gitlab push`) et
une release Forgejo (`rid projects forgejo release`), mais ne permet pas encore de
publier ses artefacts (image Docker, paquet Debian) vers GitLab en une seule
commande de release.

Ajouter `rid projects gitlab release <ID PROJECT>` pour publier, selon la
configuration du projet, l'image Docker et/ou le paquet Debian local déjà
construit.
