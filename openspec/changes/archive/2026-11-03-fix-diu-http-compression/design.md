## Choix

Les deux appels `curl` de `update_diu` utilisent `--compressed` afin de
négocier et décoder les encodages HTTP pris en charge par la bibliothèque
locale. Les autres options, les délais, les contrôles et la sélection des
fournisseurs restent inchangés. Une réponse avec un encodage non pris en charge
doit échouer sans installation ; le diagnostic existant reste explicite.

Les tests utilisent des données et un serveur locaux contrôlés, avec `curl`
réel pour valider la décompression de l'API et du paquet, ainsi qu'une
installation simulée. Une absence de support Zstandard est signalée plutôt que
présentée comme une validation réussie. Aucune installation réelle ni appel
réseau distant n'est nécessaire.
