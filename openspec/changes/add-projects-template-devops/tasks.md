## 1. Spécifications

- [x] 1.1 Valider le change ciblé et sa cohérence avec le périmètre accepté.

## 2. Implémentation

- [x] 2.1 Ajouter le module de génération, les sondes hôte/DevOps, Python et PostgreSQL, et l'écriture protégée.
- [x] 2.2 Charger le module, ajouter le routage et les aides contextuelles.
- [x] 2.3 Ajouter les tests isolés des comportements et de l'aide.

## 3. Validation et archivage

- [x] 3.1 Exécuter bash -n, ShellCheck et les tests ciblés. Réussis : 17 tests de génération/routage et 7 tests d'aide, bash -n et ShellCheck sur les trois scripts concernés.
- [x] 3.2 Vérifier UTF-8/LF, le périmètre des fichiers et la cohérence documentaire et OpenSpec. Réussis : 10 fichiers UTF-8/LF, syntaxe Python des tests et des deux scripts intégrés, validation stricte du change. Les cadrages existants restent cohérents ; aucune inspection Git réalisée.
- [ ] 3.3 Effectuer la génération réelle du modèle et constater les limites éventuelles des sondes. Bloquée : sudo demande un mot de passe pour exécuter les sondes et la génération sous devops ; aucun document réel modifié.
- [ ] 3.4 Archiver uniquement le change finalisé et valider les spécifications synchronisées. En attente de la génération réelle prévue en 3.3, conformément à SCM ; aucune archive créée.
