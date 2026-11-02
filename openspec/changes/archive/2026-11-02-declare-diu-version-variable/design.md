# Conception

Le module `diu_version.sh` calcule la version à chaque initialisation où
`DIU_VERSION` n’est pas déjà fournie. `variable_generator()` interroge
`dpkg-query -W -f='${Version}' diu`, retourne une erreur explicite si la
commande ou la version installée manque, et ne persiste pas la valeur
dynamique. Le nettoyage retire l’ancien `VERSION_ALIAS` littéral sans
l’évaluer, car la source de vérité devient la version du paquet installé.
