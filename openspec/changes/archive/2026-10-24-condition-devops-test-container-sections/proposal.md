## Pourquoi

Le document DevOps affiche actuellement Docker sans condition. Les indicateurs
ENV_DEVOPS_TESTS_DOCKER et ENV_DEVOPS_TESTS_LXC existent déjà ; le développeur
valide leur utilisation indépendante pour les rubriques des conteneurs de test.

## Changements

- Afficher Docker uniquement pour ENV_DEVOPS_TESTS_DOCKER=1, avec le titre
  « Conteneur Docker, pour tests nécessitant des droits root ».
- Afficher LXC uniquement pour ENV_DEVOPS_TESTS_LXC=1, après Docker s'il est
  présent, sinon après Matériel, et toujours avant Docker-Compose.
- Conserver les sondes version/binaire Docker et ses références fixes quand
  la rubrique est activée ; ne pas sonder Docker lorsqu'elle est omise.
- Ajouter les trois puces LXC demandées, en tant que déclaration documentaire.
- Conserver le format 0.7, les autres rubriques et les trois parcours de génération.

## Capacités

### Capacités modifiées

- `projects-template-devops` : sélection indépendante des rubriques de test.

## Impacts

Modification limitée au générateur, à ses tests et à la documentation associée.
Les valeurs initiales et persistantes des indicateurs restent inchangées.
Aucun environnement réel n'est activé, aucune configuration n'est migrée et aucun
secret d'accès LXC n'est lu. Les documents existants évoluent à leur prochaine
génération normale. Aucun déploiement ni effet Git n'appartient à cette session.
