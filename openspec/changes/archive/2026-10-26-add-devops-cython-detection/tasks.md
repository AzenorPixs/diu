## 1. Spécification

- [x] 1.1 Formaliser et valider strictement le delta OpenSpec dans le périmètre approuvé.

## 2. Détection et inventaire conditionnels

- [x] 2.1 Implémenter le mode Cython et son insertion après pip, avec tests des déclarations, des états et de l’absence de sonde sans déclaration.
- [x] 2.2 Vérifier isolation, chemins, priorités, erreurs, absences et parcours de génération ; exécuter syntaxe Bash, ShellCheck et compilation des tests Python.

## 3. Documentation et validation finale

- [x] 3.1 Actualiser TECHNICAL.md, README.md et CHANGELOG.md ; vérifier la matrice documentaire.
- [x] 3.2 Exécuter la suite complète du générateur, valider le change et le canon, comparer les diagnostics globaux OpenSpec à l’état initial.

## 4. Clôture

- [x] 4.1 Vérifier critères, encodage UTF-8/LF, fichiers modifiés et tâches sur preuves, puis rendre le change éligible à l’archivage.

## Preuves de validation

- Delta strict valide avant code et après implémentation, sans diagnostic.
- 14 tests ciblés Cython réussis (9,818 s), puis suite complète de 140 tests réussis sans cas ignoré (105,113 s), avec Python DevOps et DIU_TEST_GO déclaré. Le parcours de création vérifie aussi le manifeste Cython transmis uniquement au projet Python concerné.
- bash -n, ShellCheck et py_compile réussis ; cache Python isolé dans le temporaire de session.
- UTF-8/LF et comparaison aux sauvegardes ciblées réussis. AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et openspec/config.yaml inchangés.
- Canon standard valide avec ses huit avertissements préexistants. Comparaison stricte globale avant archive : mêmes 22 échecs et mêmes diagnostics que l’état initial ; change ciblé valide.
- Matrice documentaire : TECHNICAL.md, README.md et CHANGELOG.md actualisés ; règles, architecture, packaging et inventaire réel daté préservés. Synchronisation du canon et archivage réalisés ensemble par OpenSpec ; leur résultat et le rapport d’archive sont contrôlés à la clôture.
