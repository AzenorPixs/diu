# Tasks

## 1. Contrat OpenSpec

- [x] 1.1 Ajouter le delta à `projects-template-devops` et vérifier le change en mode strict.

## 2. Génération et documentation

- [x] 2.1 Ajouter `Accès TPM OK` après l’image Docker, étendre les tests d’ordre et d’omission, puis exécuter la suite ciblée.
- [x] 2.2 Mettre à jour `README.md`, `TECHNICAL.md` et `CHANGELOG.md`, puis vérifier leur cohérence et UTF-8/LF.
- [x] 2.3 Régénérer le `DEVOPS.md` du projet avec le rendu commun, puis vérifier la rubrique Docker générée.

## 3. Validation finale

- [x] 3.1 Exécuter les validations Bash, ShellCheck, tests et OpenSpec applicables, puis vérifier la cohérence finale avant archivage.

## Workflow follow-up

- Archiver ce change après réussite de ses critères et validations.
- Produire et vérifier `STATISTICS.md` dans l’archive, puis appliquer les maintenances globales conditionnelles prévues par SCM/SGS.
- Mettre à jour les états provisoires de la Development Map et du registre sans attribuer de code de lot.
- Exécuter les étapes Git conditionnelles de SCM après vérification de l’archive et des rapports.

Validations : OpenSpec strict du change et de la capacité réussis ; 152 tests
ciblés réussis (2 ignorés) et 8 tests des parcours de modèle réussis ;
`bash -n`, ShellCheck, `py_compile` et contrôle UTF-8/LF réussis. Le rendu du
DEVOPS.md confirme les six puces Docker et conserve l’inventaire TPM.
