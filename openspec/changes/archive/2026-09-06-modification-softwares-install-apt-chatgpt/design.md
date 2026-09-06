# Conception

La recette `software_apt_chatgpt_*` ne fera plus référence au fichier desktop
ni au chemin de configuration utilisateur. La variable statique conserve
uniquement `SOFTWARES_APT_CHATGPT` pour l'état de prise en charge. Les tests
vérifieront que les opérations APT restent inchangées et qu'aucun fichier
desktop n'est modifié.

