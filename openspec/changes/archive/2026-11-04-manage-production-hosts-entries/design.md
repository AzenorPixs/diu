## Conception

Les commandes utilisent exclusivement `/root/diu/config/hosts.json`, indépendamment du point d'entrée. Le validateur JSON existant est partagé et les mises à jour du JSON sont publiées atomiquement, sans exposition de données partielles. La génération du hosts continue de valider avant écriture. Les tests substituent des chemins isolés dans une copie des fonctions ; aucun fichier système réel n'est modifié.
