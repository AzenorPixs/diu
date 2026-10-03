## Décisions

Le routage template exige exactement un sélecteur devops ou openspec suivi
d'un identifiant valide. Avec devops all, appeler la fonction groupée existante ;
avec un autre identifiant, appeler directement projects_template_devops.
Avec openspec, conserver projects_template_openspec, y compris pour all.

L'aide template présente les deux sélecteurs. Devops help présente les
commandes individuelle et groupée ; devops <projet> help présente le projet
ciblé et devops all help conserve les cinq critères de sélection. Les anciens
contextes par projet sans sélecteur sont rejetés. Help et ? restent sans
configuration ni génération. OpenSpec conserve ses aides et détails.

## Compatibilité

La fonction de génération garde son argument unique et la fonction groupée
ses critères, sa boucle et ses bilans. Le projet nommé devops reste accessible
par template devops devops ; le projet openspec par template devops openspec.
Template openspec devops conserve sa signification OpenSpec. Le groupe all
reste réservé dans la CLI DevOps, avec la génération directe de son éventuel
dossier depuis la boucle existante. Aucune migration de données ni repli
automatique n'est nécessaire ; les appelants CLI anciens doivent être adaptés.

## Validation

Tests de sélection du bon outil, nouvelle syntaxe individuelle et groupée,
anciens ordres rejetés, arguments absents ou invalides, aide help/?, et
préservation OpenSpec. Suites projets et aide sous devops, hors sandbox,
bash -n, ShellCheck, validation stricte du change avant code puis validation
des capacités synchronisées après archivage ciblé.
