## Décisions

La commande all délègue à projects_template_devops_all, qui appelle directement
projects_template_devops avec l'identifiant du dossier pour chaque projet
retenu. Elle ne relance pas le bootstrap rid et ne modifie pas ses fonctions
de génération. Un dossier nommé all peut être traité dans la boucle sans
récursion, mais le mot all dans la commande publique désigne le lot.

Utiliser DEVOPS_PROJECTS_ROOT ou le repli /home/${ENV_DEVOPS_USER}/datas.
Parcourir les seuls dossiers directs, y compris les dossiers cachés, sans
suivre les liens symboliques des dossiers ou des fichiers project.env.
Lire uniquement les cinq affectations nécessaires dans un parseur Python
littéral, sans source/eval, sans héritage des variables de l'appelant et sans
retourner leurs valeurs. Les valeurs 0 et No sont renseignées, une valeur
vide ne l'est pas. PROJECT_ID doit correspondre au nom du dossier.

Signaler les dossiers ignorés sans valeurs de configuration. Garder les
compteurs ignorés, sélectionnés, réussis et échoués locaux. Continuer après
un échec individuel ; bilan final et retour 1 si au moins une génération
échoue. Racine absente, Python système indisponible ou utilisateur invalide :
erreur avant traitement. Aucun projet sélectionné : message et succès.

## Validation et cohérence

Tests contrôlés de chaque variable manquante/vide, exports/commentaires,
valeurs 0/No, identifiants discordants, injection non exécutée, absence
d'héritage, dossiers cachés/symboliques, racine configurée et repli, lot vide,
échec suivi d'un succès et absence de récursion sur all. Tester le routage
et les aides sans configuration ainsi que la génération de documents sur
des projets temporaires via la fonction individuelle réelle.

Exécuter bash -n, ShellCheck sur les trois scripts concernés, tests de
régression applicables, UTF-8/LF et OpenSpec strict avant l'archivage ciblé.
Les cadrages PROJECT/TECHNICAL décrivent déjà le module et la racine des
projets. BUILD porte le packaging, DEVOPS l'environnement et README les
publications : aucune modification nécessaire de ces cadrages.
PROJECT_DEBIAN_PACKAGE est un critère propre à ce lot ; la liste des quatre
variables générales dans TECHNICAL reste applicable aux autres parcours.
Aucune génération massive sur les projets réels de l'hôte pour les tests.
