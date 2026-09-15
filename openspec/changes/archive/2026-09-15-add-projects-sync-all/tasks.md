## 1. Routage et parcours groupé

- [x] 1.1 Ajouter le routage `rid projects sync all` et l'aide associée, puis vérifier que `sync help` ne lance aucune synchronisation.
- [x] 1.2 Ajouter le parcours des sous-répertoires directs de `/home/${DEVOPS_USER}/datas`, avec exclusion de `template` et sélection des seuls `project.env` valides.
- [x] 1.3 Prévalider le modèle puis déléguer chaque projet sélectionné à la synchronisation unitaire ; vérifier la poursuite du parcours et le code de retour global en cas d'échec individuel.

## 2. Tests et validation

- [x] 2.1 Étendre les tests de projets pour couvrir les projets valides, les configurations ignorées, l'exclusion du modèle, son indisponibilité, l'absence de candidat et la poursuite après un échec.
- [x] 2.2 Étendre les tests d'aide pour vérifier les syntaxes `rid projects sync <ID PROJECT>` et `rid projects sync all`.
- [x] 2.3 Exécuter `bash -n`, ShellCheck, les tests ciblés et la validation stricte OpenSpec, puis vérifier l'absence de modification hors périmètre.
