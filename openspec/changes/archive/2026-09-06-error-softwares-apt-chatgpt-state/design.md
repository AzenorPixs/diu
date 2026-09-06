# Conception

La recette `apt/chatgpt` réutilisera la fonction
`software_apt_chatgpt_persist` déjà fournie par la déclaration de variable
ChatGPT. Après chaque mutation réussie, elle exportera la nouvelle valeur puis
appellera cette fonction.

La persistance restera tolérante lorsque le répertoire de configuration n'est
pas accessible, comme lors de l'initialisation actuelle. Aucun changement ne
sera apporté aux appels APT, à l'ordre de gestion du dépôt ou à la mise à jour
du fichier desktop.
