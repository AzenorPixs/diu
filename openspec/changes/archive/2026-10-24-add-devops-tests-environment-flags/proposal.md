## Why

Le scope `environnements` est déjà chargé par le DIU, mais aucune déclaration
unitaire ne fournit `ENV_DEVOPS_TESTS_DOCKER` ou `ENV_DEVOPS_TESTS_LXC`.
Le développeur demande leur initialisation à `0` lorsqu'elles sont absentes.

## What Changes

- Déclarer les deux variables statiques actives dans le scope `environnements`.
- Persister puis exporter `0` seulement pour chaque variable absente.
- Conserver les valeurs existantes, même vides, et éviter les doublons lors
  des réexécutions normales avec chargement de la configuration.
- Signaler les erreurs de persistance sans exporter de nouvelle valeur.
- Documenter et tester ce contrat sans lancer Docker, LXC ou l'installateur.

## Capabilities

### New Capabilities

- `devops-tests-environment-flags`: initialisation persistante des deux
  indicateurs de tests DevOps.

## Impact

- Deux fichiers dans `modules/diu/variables/environnements/`, découverts par
  `config_generator` sans modification du chargeur.
- Tests isolés dans `tests/test_env_devops_tests.py`.
- Mises à jour de `TECHNICAL.md`, `README.md` et `CHANGELOG.md`.
- Cycle OpenSpec complet, archivage et rapport `STATISTIQUES.md`.
- Aucun déploiement, accès à la configuration réelle, lancement de tests
  Docker/LXC, changement d'infrastructure ou opération Git.

## Validation du développeur

Le 24 octobre 2026, le développeur a validé explicitement le périmètre
autonome proposé, incluant la spécification, l'implémentation, les tests,
la documentation, le cycle OpenSpec complet et le rapport d'archive.
