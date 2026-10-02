# Why

Le message générique sudoers ne précise pas quels comptes sont autorisés.
Le développeur demande leurs noms pour DevOps et Docker. Son signalement du
message Docker absent a également révélé un appel placé dans la branche else
de ENV_DOCKER : la politique était générée lorsque l'environnement était
désactivé, contrairement à l'objectif précédemment validé.

# What Changes

- Déplacer l'appel Docker en fin de branche active, avant le else existant.
- Préserver la branche réelle dans les tests isolés et vérifier le placement.
- Afficher après publication les comptes effectivement présents dans le
  candidat validé : `Sudoers DevOps configuré pour humain1 humain2.` et son
  équivalent Docker ; signaler explicitement une sélection vide.
- Mettre à jour TECHNICAL.md et synchroniser les spécifications existantes
  devops-sudoers et docker-sudoers après validations, puis archiver ce change.

# Impact

Le périmètre comporte uniquement root-install-debian.sh, TECHNICAL.md, les
deux suites sudoers et ce cycle OpenSpec. La sélection, les droits accordés,
les modes et la publication atomique restent identiques. La correction Docker
rétablit le périmètre déjà validé ; le développeur a également validé
explicitement les messages nominaux et l'archivage dans la session SCM.
Aucune installation réelle, opération Docker ou action Git n'est incluse.
