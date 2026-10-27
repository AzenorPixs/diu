# Tâches

## 1. Spécification

- [x] 1.1 Valider le delta OpenSpec correspondant au périmètre approuvé.

## 2. Réalisation et validation ciblée

- [x] 2.1 Ajouter la sonde locale et le rendu commun, avec tests déterministes et documentation cohérente.
- [x] 2.2 Examiner les fichiers et réussir syntaxe Bash, ShellCheck, compilation Python et tests ciblés.

## 3. Validation globale et clôture

- [x] 3.1 Réussir la régression des parcours concernés et revoir la matrice documentaire, UTF-8/LF et le périmètre.
- [x] 3.2 Valider OpenSpec pour le change et comparer les diagnostics globaux avant synchronisation et archivage.
Opérations de clôture après validation : synchroniser et archiver ce seul change, produire et vérifier STATISTIQUES.md à six sections, puis nettoyer uniquement les bilans de blocage obsolètes éventuels.

Preuve 1.1 : `openspec validate add-devops-openssh-sshpass --type change --strict --no-interactive` exécuté sous devops, code 0 avant écriture du code et des tests.

Preuves 2.1–2.2 : revue des différences ciblées ; bash -n et shellcheck du module, compilation avec le Python DevOps et cinq tests test_ssh exécutés et réussis. Les assertions sur les rubriques de conteneurs sont adaptées au nouvel ordre, sans affaiblir les contrôles de contenu.

Preuves 3.1–3.2 : suite complète du générateur, 126 tests en 88,647 s, succès avec deux sondes Go ignorées faute de résolution dans PATH. Ces deux tests ont ensuite été exécutés avec DIU_TEST_GO=/home/devops/go/current/bin/go : 2/2 réussis. Les 126 cas sont ainsi couverts avec succès. Les cinq nouveaux tests SSH sont inclus. Sondes réelles SSH : 10.0p2 et 1.10 aux chemins /usr/bin/ssh et /usr/bin/sshpass.

Validation stricte globale avant archivage : 47 éléments valides, 22 échecs identiques au contrôle initial (46 valides, 22 échecs avant ajout du change). Change ciblé strict valide. La validation globale stricte reste en échec pour ces causes préexistantes hors périmètre.

Matrice documentaire revue : AGENTS.md (règles), PROJECT.md (module projects et architecture), BUILD.md (construction du paquet), DEVOPS.md (inventaire daté au format 0.7) et openspec/config.yaml inchangés octet pour octet par comparaison aux sauvegardes ciblées. TECHNICAL.md, section Traçabilité, et README.md, inventaire DevOps, documentent désormais les quatre puces, les sondes et l’ordre ; CHANGELOG.md contient l’entrée Unreleased. La capacité canonique sera synchronisée par archivage. Aucun autre cadrage ne nécessite de modification. Le rôle de Codex décrit par PROJECT.md ne modifie pas la nature directe de cette session SCM explicitement demandée.
