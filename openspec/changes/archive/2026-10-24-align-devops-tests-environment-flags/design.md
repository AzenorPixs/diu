## Décision

Le format généré devient huit espaces ASCII suivis de `export NOM=0` et LF.
L'exemple collé dans la conversation est interprété littéralement : huit
espaces, et non un caractère de tabulation dont la largeur varie selon
l'éditeur. Seules les deux nouvelles déclarations sont concernées.

Le motif de suppression devient `^[[:blank:]]*export NOM=` afin de reconnaître
les versions antérieures sans retrait, le nouveau retrait et les tabulations
éventuellement ajoutées manuellement. Le nom exact suivi de `=` conserve la
protection des variables voisines.

Les valeurs existantes, même vides, restent conservées sans réécriture. Les
lignes déjà persistées ne sont pas migrées. La configuration réelle n'est ni
lue ni modifiée par cette session. Aucun mécanisme partagé n'est modifié.

## Vérification

Le test d'initialisation vérifie exactement les huit espaces. Le parcours de
configuration partielle accepte ce retrait. Le test de désactivation couvre
les préfixes vide, huit espaces et tabulation, en conservant les voisins et
l'autre indicateur. Tous les autres tests ciblés restent exécutés.

Syntaxe Bash, ShellCheck, compilation Python, validation stricte du change et
du canon, concordance delta/canon, UTF-8/LF et contrôle du rapport complètent
la qualification. Les diagnostics OpenSpec globaux préexistants restent
distincts du résultat ciblé.

## Repli

Pas de migration ni déploiement. Un retour ultérieur au format sans retrait
ne changerait pas la valeur des variables ; aucune réécriture automatique du
fichier local n'est incluse. Le chargeur Bash accepte les deux présentations.
