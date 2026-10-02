## 1. Spécifications

- [x] 1.1 Valider le change ciblé et sa cohérence avec le périmètre accepté.

## 2. Implémentation

- [x] 2.1 Ajouter le module de génération, les sondes hôte/DevOps, Python et PostgreSQL, et l'écriture protégée.
- [x] 2.2 Charger le module, ajouter le routage et les aides contextuelles.
- [x] 2.3 Ajouter les tests isolés des comportements et de l'aide.
- [x] 2.4 Corriger le répertoire des sondes DevOps et renforcer les tests avec de vrais interpréteurs ; prouver la régression Go depuis un dossier inaccessible. Le test réel Go échouait avant la correction et passe après ; Node réel, Python en venv, délai réel et permissions réelles également vérifiés. L'enveloppe runuser est exécutée avec un changement d'identité simulé, sans prétendre à un test root effectif.
- [x] 2.5 Préciser les diagnostics PostgreSQL sans divulgation et préserver les caractères spéciaux des mots de passe cités sans expansion shell. Tests des catégories d'erreur, des mots de passe littéraux, de l'absence d'exécution et du port standard réussis.

## 3. Validation et archivage

- [x] 3.1 Exécuter bash -n, ShellCheck et les tests ciblés. Réussis : 24 tests de génération/sondes/routage, sans test ignoré, et 7 tests d'aide ; bash -n et ShellCheck sur les trois scripts concernés.
- [x] 3.2 Vérifier UTF-8/LF, le périmètre des fichiers et la cohérence documentaire et OpenSpec. Réussis : 10 fichiers UTF-8/LF, syntaxe Python des tests et des deux scripts intégrés, validation stricte du change. Les cadrages existants restent cohérents ; aucune inspection Git réalisée.
- [x] 3.3 Effectuer la génération réelle du modèle et constater les limites éventuelles des sondes. Accès sudo sans mot de passe à devops confirmé ; génération réelle sous devops réussie : Go 1.27.1, PostgreSQL serveur 16.15 sur 127.0.0.1:5432, Python 3.14.8 et venv disponible. La configuration PostgreSQL a été actualisée par le développeur ; aucun contenu sensible lu ou affiché par l'agent. Une seconde génération conserve contenu, propriété et permissions. Le modèle ne contient pas de pyproject.toml, absence indiquée explicitement. L'accès sudo root nécessite encore un mot de passe ; aucun lancement root réel effectué par l'agent.

Archivage ciblé et validation des spécifications synchronisées : en attente de
la confirmation demandée par OpenSpec. La commande `openspec archive
add-projects-template-devops --json`, exécutée sous devops, a répondu
`archive_confirmation_required` sans effectuer l'archivage ; elle demande
`--yes` pour synchroniser les deux spécifications. SCM impose d'attendre la
décision du développeur face à cette confirmation.
