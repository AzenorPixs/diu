## 1. Spécification

- [x] 1.1 Valider strictement les exigences Nuitka et la coexistence avec Cython dans le périmètre approuvé.

## 2. Inventaire commun

- [x] 2.1 Implémenter la sélection conditionnelle des deux outils et leurs états indépendants avec les tests ciblés.
- [x] 2.2 Vérifier les quatre combinaisons, isolation, absence de repli, erreurs, provenances et génération groupée/finale ; exécuter syntaxe Bash, ShellCheck et py_compile.

## 3. Documentation et contrôle final

- [x] 3.1 Actualiser TECHNICAL.md, README.md et CHANGELOG.md, et vérifier la matrice documentaire.
- [x] 3.2 Exécuter la suite complète du générateur, valider le change et le canon, comparer les diagnostics globaux à l’état initial.

## 4. Clôture

- [x] 4.1 Vérifier périmètre, UTF-8/LF, critères et preuves pour rendre le change éligible à l’archivage, puis contrôler la synchronisation et le rapport d’archive.

## Preuves de validation

- Change OpenSpec strict valide avant code et après implémentation, sans diagnostic. Les six contrats du delta restent sous la limite de longueur.
- 25 tests ciblés Cython/Nuitka réussis (18,752 s), puis un nouveau cas de découverte/sonde partagées réussi (0,144 s) : 26 cas ciblés uniques.
- Suite complète finale : 152 tests réussis en 114,953 s, aucun ignoré, avec Python DevOps et DIU_TEST_GO déclaré. Inclut les trois parcours et le modèle Python déclarant Cython et Nuitka en création.
- bash -n, ShellCheck, py_compile, UTF-8/LF et comparaison au périmètre initial réussis. Cache Python isolé dans le temporaire de session.
- Comparaison stricte globale avant archive : mêmes 22 échecs et mêmes diagnostics que l’état initial ; change ciblé valide.
- Matrice documentaire : TECHNICAL.md, README.md et CHANGELOG.md mis à jour ; AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et openspec/config.yaml inchangés.
- Synchronisation du canon et archivage réalisés ensemble par OpenSpec ; contrôle des six blocs, des diagnostics finaux et du rapport effectué à la clôture.
