## Conception

Le chemin de configuration est relatif au chemin réel du point d'entrée `BASH_SCRIPT_PATH`. Le tableau contient des objets `ip` et `fqdn`. La validation complète précède la publication du fichier hosts. Le modèle de développement doit rester vide et le paquet n'embarque que ce fichier du répertoire config. Debian gère le fichier installé comme conffile ; aucune installation réelle n'est effectuée par les tests.

Les copies de la recette générique acceptent deux indicateurs booléens facultatifs : `conffile` et `empty_json`. Ils s'appliquent uniquement aux fichiers ordinaires et sont contrôlés avant publication.
