## 1. Spécification validée

- [x] 1.1 Décrire le périmètre approuvé et les exigences RFC 2119 avant le code.
- [x] 1.2 Valider strictement le change ciblé.

## 2. Implémentation et documentation

- [x] 2.1 Conditionner et renommer Docker ; ajouter la rubrique LXC indépendante.
- [x] 2.2 Adapter les tests et couvrir les critères d'acceptation et les trois parcours.
- [x] 2.3 Mettre à jour TECHNICAL.md, README.md et CHANGELOG.md.

## 3. Vérifications et clôture

- [x] 3.1 Exécuter syntaxe Bash/Python, ShellCheck, tests et contrôles UTF-8/LF.
- [x] 3.2 Vérifier la cohérence documentaire et valider OpenSpec.

## Clôture à constater

L'archivage de ce seul change, la synchronisation de son delta et la production
puis la vérification de STATISTIQUES.md restent obligatoires. Leurs preuves et
leur résultat effectif sont consignés dans le rapport après leur exécution ;
aucune opération future n'est cochée par anticipation.

Les 121 méthodes du générateur ont été lancées avec le Python DevOps :
119 réussies et deux ignorées car Go n'est pas disponible dans le PATH des tests
réels. Les neuf tests des déclarations passent. La syntaxe et ShellCheck passent.
Le change est valide en mode strict. Le global strict reste en échec sur
22 éléments préexistants, observés avant synchronisation ; ils sont hors périmètre.
