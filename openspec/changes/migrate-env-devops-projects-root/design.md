# Conception

Le chargement lit la configuration historique, puis les fichiers de scope,
avant de découvrir les déclarations triées. La racine des projets dépend de
`ENV_DEVOPS_USER` uniquement si aucune nouvelle valeur ni ancienne valeur n'est
fournie. Cette dépendance doit être disponible avant son initialisation; une
absence produit un diagnostic explicite.

La valeur par défaut est développée une seule fois en `/home/<utilisateur>/datas`
et persistée comme littéral shell sûr. Le rechargement d'une ancienne expression
persistée respecte sa dépendance indépendamment de l'ordre alphabétique.
Une ancienne affectation littérale est reprise exactement, sauf si la nouvelle
valeur est déjà configurée; une affectation ambiguë bloque la migration sans
interprétation. Les consommateurs utilisent le nouveau nom.

Pour une déclaration persistée qui référence `ENV_DEVOPS_USER`, le chargeur
lit d'abord sa déclaration littérale éventuelle, indépendamment de l'ordre du
fichier. Une déclaration ambiguë ou une dépendance absente bloque le chargement
avec un diagnostic, avant l'initialisation de la racine des projets. Cette règle
ne prétend pas résoudre automatiquement toutes les dépendances possibles entre
variables `ENV_*`.

Si `environnements/env_devops_user.sh` existe, le générateur le source une seule
fois avant `environnements/env_devops_projects_root.sh`, même si le tri
alphabétique les présente dans l'ordre inverse. En son absence, une valeur
utilisateur déjà chargée reste utilisable; sinon le diagnostic prévu s'applique.

La déclaration `ENV_DEVOPS_USER` est `STATIC/ENABLE`, scope `environnements`,
avec `root` par défaut; une valeur déjà définie reste prioritaire, puis la
valeur historique `DEVOPS_USER` est reprise si elle existe. Si une
expression persistée requiert cet utilisateur avant le générateur, la
déclaration utilisateur est chargée en amont et ne sera pas relue dans ce
même cycle. Le défaut de racine issu de `root` vaut `/home/root/datas`.

Le modèle historique de racine contenant `${DEVOPS_USER}` est accepté sans
`eval` ni substitution de commande : il reste en place au premier passage,
sa valeur est produite par le chargement historique puis persistée sous le
nouveau nom; un passage ultérieur retire l'ancienne affectation. Les autres
expressions nécessitant une interprétation restent refusées.

L'inventaire ciblé des déclarations `modules/diu/variables/` au 2026-11-03
identifie cette dépendance au sein des variables `ENV_*`; les autres
déclarations repérées ne calculent pas leur défaut à partir d'une autre
variable `ENV_*`.
