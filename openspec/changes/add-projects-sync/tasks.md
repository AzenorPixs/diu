## 1. Routage et synchronisation

- [x] 1.1 Ajouter le routage `rid projects sync <ID PROJECT>` et son aide, puis vérifier que `sync help` ne lance aucune synchronisation.
- [x] 1.2 Ajouter la synchronisation ciblée dans le module projets, avec validation préalable du projet, de sa configuration et de toutes les sources modèle.
- [x] 1.3 Préparer les éléments sélectionnés, personnaliser uniquement leurs Markdown, puis les copier avec écrasement sans modifier les éléments non gérés.

## 2. Tests et validation

- [x] 2.1 Étendre les tests de projets afin de vérifier la copie, l'écrasement, les substitutions Markdown, la préservation d'un Markdown non géré et l'échec sans copie si le modèle est incomplet ou absent.
- [x] 2.2 Étendre les tests d'aide pour vérifier `rid projects sync <ID PROJECT>` et `rid projects sync help`.
- [x] 2.3 Exécuter `bash -n`, ShellCheck, les tests ciblés et la validation stricte OpenSpec, puis vérifier l'absence de modifications hors périmètre.
