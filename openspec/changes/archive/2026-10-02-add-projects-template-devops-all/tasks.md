## 1. Spécification

- [x] 1.1 Valider le change ciblé avant le code et les tests. Validation stricte réussie avant implémentation.

## 2. Implémentation

- [x] 2.1 Ajouter la sélection sûre des cinq variables et le traitement groupé.
- [x] 2.2 Router all et mettre à jour les aides générales et terminales.
- [x] 2.3 Ajouter les tests de sélection, délégation, bilan, poursuite et aides.

## 3. Validation

- [x] 3.1 Exécuter les tests ciblés et de régression, bash -n et ShellCheck. Réussis : 37 tests du module (dont les cinq sondes réelles, aucun test ignoré) et 12 tests d'aide/création ciblés, soit 49 tests. Le test de configurations inaccessibles a été réexécuté après adaptation au contexte root et réussit sous le compte non privilégié actuel. bash -n et ShellCheck complets réussissent sur les trois scripts modifiés. Validation complémentaire sous devops avec les vrais binaires, dans des projets temporaires : 3 sélectionnés, 2 réussites après un échec contrôlé sur lien documentaire, 1 ignoré ; Go 1.27.1, manifeste Python minimal, fichier protégé et droits conservés. Le code final non nul attendu a été vérifié ; les fixtures ont été nettoyées. Aucun projet réel de l'hôte n'a été modifié. Le bootstrap rid complet en root n'a pas été exécuté ; son routage est testé isolément.
- [x] 3.2 Vérifier UTF-8/LF, syntaxe Python, cohérence et OpenSpec strict. Réussis : 10 fichiers UTF-8/LF, syntaxe des deux tests et des quatre scripts Python intégrés, nettoyage des fixtures et validation stricte du change. Les cadrages restent cohérents selon le design ; le cinquième critère est propre à ce lot. Aucun autre change modifié, aucune inspection Git.

Archivage ciblé réalisé sous devops avec la confirmation --yes autorisée :
`2026-10-02-add-projects-template-devops-all`. OpenSpec a synchronisé deux
exigences ajoutées et une modifiée. Les validations strictes de
projects-template-devops et rid-help réussissent ; l'objet de la capacité
inclut le traitement groupé. Les remarques informatives de longueur des
exigences ne bloquent pas la validation. Aucun autre change archivé.
