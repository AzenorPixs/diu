# Conception : recette APT ChatGPT

La recette `chatgpt` est enregistrée explicitement par
`software_apt_recipe`; l'identifiant utilisateur ne sert jamais à construire
un nom de fonction ou une commande.

`SOFTWARES_APT_CHATGPT` est une variable dynamique initialisée par détection
de l'état `dpkg` du paquet `chatgpt`. `SOFTWARES_APT_CHATGPT_HOME` est une
variable statique dont la valeur par défaut est `~/.codex`. La valeur tilde est
résolue avec le `HOME` du compte qui exécute DIU uniquement au moment de
modifier le fichier desktop.

Le paquet distribué par le dépôt OpenAI place son lanceur dans
`/usr/share/applications/chatgpt.desktop` et son entrée initiale est
`Exec=chatgpt %U`. La recette remplace cette ligne par
`Exec=env CODEX_HOME=<HOME résolu> chatgpt %U`, en conservant les arguments
desktop d'origine.

Les actions suivent ces séquences :

1. installation : préparer le dépôt si nécessaire, exécuter `apt update`,
   installer `chatgpt`, puis modifier le desktop ;
2. désinstallation : supprimer `chatgpt`, supprimer le dépôt, puis exécuter
   `apt update` ;
3. mise à jour : exécuter une mise à jour limitée à `chatgpt`, puis réappliquer
   la modification desktop.

Les tests remplacent APT, dpkg et le chemin desktop par des doublures afin de
   ne jamais modifier le système hôte.
