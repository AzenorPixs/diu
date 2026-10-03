## 1. Spécification

- [x] 1.1 Définir le comportement validé et valider le change avec OpenSpec strict.

## 2. Implémentation

- [x] 2.1 Ajouter init/update à la fin du bloc OPENSPEC sous le compte DevOps.
- [x] 2.2 Documenter la cible domicile dans TECHNICAL.md.
- [x] 2.3 Ajouter les tests isolés des branches, de la garde et des erreurs.

## 3. Vérifications et clôture

- [x] 3.1 Réussir bash -n, ShellCheck, la syntaxe Python et les tests ciblés.
- [x] 3.2 Vérifier la cohérence, le périmètre, l'encodage et OpenSpec strict.

## Preuves de validation

- bash -n root-install-debian.sh : réussi.
- shellcheck root-install-debian.sh : réussi sans diagnostic.
- py_compile sur tests/test_devops_openspec.py dans un cache temporaire du
  projet : réussi, cache supprimé.
- python3 -B tests/test_devops_openspec.py : 9 tests réussis.
- python3 -B tests/test_projects_template_openspec.py : 14 tests réussis.
- OpenSpec validate configure-devops-home-openspec --strict via le Node et
  le binaire définis dans DEVOPS.md : réussi avant et après implémentation.
- Les 7 fichiers du périmètre sont UTF-8/LF ; aucun artefact temporaire restant.
- La matrice de cohérence a été revue : ajout compatible avec AGENTS.md,
  PROJECT.md, BUILD.md, DEVOPS.md et README.md ; TECHNICAL.md actualisé et
  templates de projets inchangés. Les écritures concernent seulement le
  monolithe, le test, le cadrage technique et ce change. Git non inspecté
  conformément à SCM ; aucun commit ni opération Git.
- Aucun su, OpenSpec init/update, téléchargement ou installation réel du
  traitement DevOps n'a été exécuté : ces opérations sont simulées en tests.
- Archivage OpenSpec autorisé effectué le 2 octobre 2026 :
  2026-10-02-configure-devops-home-openspec, trois exigences ajoutées et
  aucune exigence existante modifiée ou supprimée.
- OpenSpec validate devops-home-openspec --strict après synchronisation :
  réussi ; conseil informatif sur la longueur de l'exigence de sélection.
