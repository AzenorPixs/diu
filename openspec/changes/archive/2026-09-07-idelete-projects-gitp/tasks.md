# Tasks

- [x] Créer et valider la spécification du remplacement par `forgejo_push`.
- [x] Retirer l'ancien parcours générique du dispatch et de tous les niveaux
      d'aide sans retirer `gitpdiu` ni `gitpdi`.
- [x] Extraire le parcours commun vers une fonction interne et rebrancher les
      publications Forgejo, GitLab et GitHub.
- [x] Rebrancher les flux CI/CD concernés sur le parcours Forgejo explicite.
- [x] Migrer les usages des variables distantes génériques vers Forgejo dans
      les fonctions de projet et de release.
- [x] Adapter `git_update` pour migrer les anciennes valeurs, supprimer les
      anciennes lignes et générer uniquement la configuration cible.
- [x] Vérifier que les parcours commit, init, release et update restent
      syntaxiquement cohérents et ne dépendent plus de `git_push`.
- [x] Exécuter les validations Bash, OpenSpec et les tests disponibles.
- [x] Archiver la spécification après validation complète.
