# Conception

Après résolution du fichier réel et avant le traitement de l’aide, le bootstrap installé exécuté en root charge le helper existant et vérifie le lien de production. Il signale toute erreur. Le script du dépôt et les appels non root ne créent pas de lien de production. Les autres initialisations restent inchangées.
