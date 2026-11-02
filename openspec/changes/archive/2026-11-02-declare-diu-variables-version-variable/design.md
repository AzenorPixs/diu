# Conception

Le module `diu_variables_version.sh` génère la version avec
`dpkg-query -W -f='${Version}' diu` quand `DIU_VARIABLES_VERSION` n’est pas
déjà définie. Une commande absente, une erreur ou une valeur vide provoque un
diagnostic stderr et un statut non nul. Le résultat n’est pas persisté.

`config_cleanup` retire l’affectation historique simple `VERSION_VARIABLES`
avant de charger la configuration, sans évaluer ni transférer sa valeur.
Une affectation qui exige une interprétation shell bloque le nettoyage sans
modifier les fichiers. `VERSION` reste conservée.
