# Statistiques — remove-orchestrated-coding-from-sync

## 1. Périmètre

Correction de la synchronisation unitaire et groupée ; code de lot non attribué.

## 2. Résultat

Le document ORCHESTRATED_CODING.md est exclu de la synchronisation ; la création de projet reste inchangée.

## 3. Fichiers

Code : modules/projects/projects.sh ; tests : tests/test_projects_orchestrated_copy.py ; documentation : README.md, CHANGELOG.md, DEVELOPMENT_MAP.md ; spécification : openspec/specs/projects-sync/spec.md et archive du change.

## 4. Validations

Le 2026-11-03 : 10 tests orchestrated copy, 8 tests development map et 32 tests projects réussis ; bash -n et ShellCheck réussis ; validation stricte du change réussie. Total : 50 tests.

## 5. Mesures de session

Durée, jetons, appels et télémétrie : N/A, mesures non disponibles.

## 6. Limites

La commande réelle sync all n'a pas été lancée sur les projets utilisateur. Aucun commit, push ou incrément de version.
