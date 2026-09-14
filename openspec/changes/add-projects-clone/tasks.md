## 1. Routage et clonage

- [x] 1.1 Ajouter le routage `rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>` et l'aide associée, puis vérifier que `clone help` ne lance aucune copie.
- [x] 1.2 Ajouter `clone_project` avec la validation préalable des deux identifiants, du projet source, de son `project.env` et de l'absence de destination.
- [x] 1.3 Préparer puis installer une copie récursive du projet source qui exclut tout répertoire `.git`, préserve les autres fichiers et met à jour uniquement `PROJECT_ID` dans le `project.env` destination.

## 2. Tests et validation

- [x] 2.1 Étendre les tests de projets afin de vérifier la copie du contenu ordinaire et caché, l'absence des `.git` racine et imbriqué, la mise à jour de `PROJECT_ID`, la préservation des autres variables et les échecs sans destination partielle.
- [x] 2.2 Étendre les tests d'aide pour vérifier `rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>` et `rid projects clone help`.
- [x] 2.3 Exécuter `bash -n`, ShellCheck, les tests ciblés et la validation stricte OpenSpec, puis vérifier l'absence de modification hors périmètre.
