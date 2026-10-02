## 1. Spécification

- [x] 1.1 Confirmer le périmètre autonome validé par le développeur et écrire les artefacts du change ciblé.
- [x] 1.2 Valider strictement le change avant toute écriture de code ou de test. Réussi : openspec validate install-devops-psycopg --strict.

## 2. Implémentation

- [x] 2.1 Ajouter l'installation avec mise à jour, le contrôle d'import et les diagnostics dans le bloc Python du monolithe.
- [x] 2.2 Ajouter les tests isolés : première installation, répétition, version plus récente, activation et erreurs.
- [x] 2.3 Documenter la dépendance gérée par le DIU dans TECHNICAL.md.

## 3. Vérification et archivage

- [x] 3.1 Exécuter bash -n, ShellCheck et les tests ciblés sans installation réelle ni accès réseau. Réussis : bash -n root-install-debian.sh ; shellcheck root-install-debian.sh ; python3 -I -B -m unittest discover -s tests -p 'test_devops_python.py' -v (6 tests), 'test_root_shellcheck.py' (9 tests), 'test_devops_sudoers.py' (15 tests).
- [x] 3.2 Vérifier les fichiers touchés, UTF-8/LF et la cohérence des cadrages et des spécifications. Réussis : 7 fichiers UTF-8/LF, compilation en mémoire du test Python, nettoyage des artefacts temporaires et comparaison par empreinte du contenu préexistant après retrait des seuls ajouts autorisés, sans inspection Git.
- [x] 3.3 Valider strictement le change final et confirmer son éligibilité à l'archivage. Réussi : openspec validate install-devops-psycopg --strict ; tous les critères couverts par les validations ciblées, sans blocage connu.

L'archivage de clôture et la synchronisation de `devops-python` sont autorisés
et sont exécutés après l'achèvement prouvé des tâches ci-dessus.

## Cohérence et limites

- Code : ajout limité au bloc Python ; compilation, profils et droits existants préservés.
- AGENTS.md : écritures limitées au périmètre validé ; aucun secret consulté ni opération Git.
- PROJECT.md : ajout dans le monolithe existant, sans modification de l'architecture.
- TECHNICAL.md : comportement et limites de cette dépendance documentés.
- BUILD.md : contenu et mécanisme du paquet inchangés, le monolithe est déjà distribué.
- README.md : présentation générale compatible, aucune modification nécessaire.
- DEVOPS.md : inventaire statique inchangé ; écart préexistant signalé entre Python 3.14.7 documenté et 3.14.8 observé avant cette implémentation. Aucune actualisation de versions hors périmètre.
- OpenSpec : capacité nouvelle isolée, sans modification d'autres changes actifs ni des dépendances propres aux projets.
- Installation réelle : non exécutée, hors du périmètre de validation ; les tests contrôlent le bloc avec un interpréteur et un index simulés. Connexion PostgreSQL : non pertinente pour le contrôle d'import.

## Clôture

- Archivage exécuté et réussi : `openspec archive install-devops-psycopg --yes`, avec création de `openspec/specs/devops-python/spec.md` et transfert de ce seul change dans `archive/2026-10-02-install-devops-psycopg`.
- Première validation stricte de la spécification synchronisée : exécutée et échouée, car OpenSpec avait généré une description Purpose provisoire. Description remplacée par l'objet de la capacité dans le périmètre validé.
- Validation après correction : exécutée et réussie, `openspec validate devops-python --type spec --strict`. Une information non bloquante signale la longueur de la première exigence.
- Aucun échec non résolu ni travail d'implémentation en attente dans le périmètre validé.
