## 1. Spécifications

- [x] 1.1 Valider le change ciblé et sa cohérence avec le périmètre accepté.

## 2. Implémentation

- [x] 2.1 Ajouter le module de génération, les sondes hôte/DevOps, Python et PostgreSQL, et l'écriture protégée.
- [x] 2.2 Charger le module, ajouter le routage et les aides contextuelles.
- [x] 2.3 Ajouter les tests isolés des comportements et de l'aide.
- [x] 2.4 Corriger le répertoire des sondes DevOps et renforcer les tests avec de vrais interpréteurs ; prouver la régression Go depuis un dossier inaccessible. Le test réel Go échouait avant la correction et passe après ; Node réel, Python en venv, délai réel et permissions réelles également vérifiés. L'enveloppe runuser est exécutée avec un changement d'identité simulé, sans prétendre à un test root effectif.

## 3. Validation et archivage

- [x] 3.1 Exécuter bash -n, ShellCheck et les tests ciblés. Réussis : 23 tests de génération/sondes/routage, sans test ignoré, et 7 tests d'aide ; bash -n et ShellCheck sur les trois scripts concernés.
- [x] 3.2 Vérifier UTF-8/LF, le périmètre des fichiers et la cohérence documentaire et OpenSpec. Réussis : 10 fichiers UTF-8/LF, syntaxe Python des tests et des deux scripts intégrés, validation stricte du change. Les cadrages existants restent cohérents ; aucune inspection Git réalisée.
- [ ] 3.3 Effectuer la génération réelle du modèle et constater les limites éventuelles des sondes. La génération initiale en root a été rapportée par le développeur ; le document observé contient Go indisponible. La sonde est corrigée et prouvée par un test réel, mais la génération sur l'hôte avec ce correctif reste à vérifier. Sudo nécessite un mot de passe dans la session de l'agent ; aucune écriture du modèle réel par l'agent.
- [ ] 3.4 Archiver uniquement le change finalisé et valider les spécifications synchronisées. En attente de la génération réelle prévue en 3.3, conformément à SCM ; aucune archive créée.
