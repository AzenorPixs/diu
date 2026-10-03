## Décisions

Ajouter une fonction OpenSpec groupée dans le module existant. Réutiliser
projects_template_devops_project_is_configured sans renommer ni modifier
l'implémentation DevOps. La dépendance Python système est déjà présente.
La sélection lit les cinq seules affectations nécessaires sans exécuter
project.env et sans afficher ses valeurs.

Parcourir les dossiers directs, cachés compris, sans suivre les liens.
Utiliser DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas. Après
validation du compte, de la racine et du Python système, compter les projets
ignorés, sélectionnés, réussis et échoués. Appeler directement
projects_template_openspec pour chaque projet éligible, y compris all,
afin d'éviter une récursion via la CLI. Les trois commandes existantes,
OPENCODE et l'exécution via su sont conservés.

## Erreurs et compatibilité

Un échec individuel est signalé mais ne bloque pas les projets suivants.
Au moins un échec produit un code final non nul ; aucun projet éligible
produit un bilan vide et un succès. Une erreur de prérequis provoque un
échec avant traitement. Les écritures partielles d'OpenSpec sont conservées.
La CLI openspec all passe d'un seul projet nommé all à tous les projets
configurés ; aucune migration ni suppression de données n'est nécessaire.
La fonction individuelle et l'appel lors de create sont conservés.

## Validation

Tests isolés avec su et OpenSpec simulés : sélection identique à DevOps,
racine et compte, dossiers cachés, 0 et No, configuration invalide ou
discordante, liens, absence de projet, init avec et sans OpenCode, update,
réexécution, poursuite après échec, bilan et all sans récursion. Tests de
routage, help/?, découverte générale et préservation de DevOps et create.
Bash -n, ShellCheck et validations strictes sous devops hors sandbox.
