## 1. Spécification approuvée

- [x] 1.1 Vérifier UTF-8/LF, RFC 2119, scénarios préservés et validation OpenSpec ciblée avant code/test.

## 2. Générateur et tests

- [x] 2.1 Ajouter capture UTC bornée, contexte contrôlé, en-tête 0.3 et légende en préservant sondes et écriture.
- [x] 2.2 Prouver par tests déterministes provenance, UTC/capture unique, contexte, refus, réexécution et parcours individuel/groupé/création.
- [x] 2.3 Réussir syntaxe Bash, ShellCheck, compilation Python et régressions ciblées des modèles.

## 3. Cohérence et clôture

- [x] 3.1 Mettre à jour TECHNICAL.md, README.md et CHANGELOG.md ; justifier les autres documents inchangés.
- [x] 3.2 Vérifier UTF-8/LF, modifications limitées, absence de valeurs sensibles ajoutées et validations finales ; distinguer les diagnostics préexistants.

## 4. Opérations après les prérequis

Après preuve des tâches ci-dessus, synchroniser le seul canon et archiver le change finalisé, puis produire et vérifier STATISTIQUES.md : six sections et N/A motivé pour les mesures indisponibles. Ces opérations sont prouvées séparément après leur exécution ; elles ne sont pas des prérequis auto-référents à l'archivage.

Cocher uniquement après preuve. L'archivage du seul change est inclus dans le périmètre validé.

## Preuves avant archivage

- Change strict avant code puis final : code 0, aucune issue.
- Generateur : bash -n et ShellCheck finaux code 0 ; py_compile final code 0, cache temporaire supprime.
- Tests finaux : 49 DevOps, 17 OpenSpec, 8 tous-modeles et 9 mise-a-jour generale, soit 83 reussis, aucun echec ni ignore.
- Premier passage DevOps : un jeu de binaires aux chemins espaces ne fournissait pas encore date ; fixture corrigee. Deux sondes Go initialement ignorees faute de PATH ont ete executees avec le chemin declare.
- Diff sans Git : originaux reconstruits identiques aux empreintes ; seules les cinq cibles preexistantes approuvees sont modifiees, plus les cinq artefacts du change. UTF-8/LF verifies, temporaires absents.
- Global strict avant/apres implementation : 3 ERROR, 55 WARNING et 1 INFO preexistants identiques, hors de ce change ; code natif 1 conserve, jamais presente comme succes global.
- Archivage et rapport statistique restent a prouver apres leur execution.
