## Décisions

Conserver projects_template_devops et ses sondes. Ajouter un argument projet
obligatoire ; résoudre la racine depuis DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas.
Refuser identifiants vides, chemins, . et .., caractères de contrôle et liens
symboliques du dossier cible. Conserver les noms de projet contenant espaces
ou accents déjà utilisables par les autres commandes.

Adapter le titre avec l'identifiant, en conservant Template pour template.
Utiliser les fichiers locaux du projet sans charger project.env dans le shell
de la génération. Un parseur littéral de PROJECT_TYPE décide uniquement de
la création du manifeste absent ; les valeurs sensibles ne sont jamais rendues.
Créer ce manifeste avec le Python système sous l'utilisateur DevOps, sans
installation de paquet ; conserver tout fichier déjà existant.

Dans create_project, ne copier le manifeste racine du modèle que pour PYTHON.
Le projet Python conserve un manifeste copié ; en son absence, la génération
finale crée le manifeste minimal. L'appel final intervient après chown et
avant le succès. En cas d'échec, conserver le projet et signaler la génération
non finalisée ; aucune suppression de repli.

Les sondes Go restent exécutées depuis le domicile DevOps ; les paramètres
PostgreSQL et les dépendances correspondent au projet ciblé. La structure,
la version documentaire 0.2, la propriété, les permissions et l'écriture
protégée de DEVOPS.md restent conservées. Aucune inspection Git.

## Validation et cohérence

Tests isolés de deux projets, racine configurée et repli, arguments invalides,
création et mise à jour, manifeste conditionnel et existant, configuration
littérale, erreur de génération finale et aides sans configuration.
Régression Go avec binaire réel, Bash, ShellCheck, UTF-8/LF, validation OpenSpec
stricte, génération réelle limitée au projet template.
PROJECT.md et TECHNICAL.md décrivent déjà le module projects et la racine
DEVOPS_PROJECTS_ROOT. BUILD.md concerne le packaging, README.md les publications,
DEVOPS.md l'environnement : aucun de ces cadrages ne nécessite de modification.
Le change refactor-projects-template-copy reste indépendant et non modifié.
