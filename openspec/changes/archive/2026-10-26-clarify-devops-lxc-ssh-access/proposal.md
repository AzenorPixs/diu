# Préciser l’accès SSH au conteneur LXC et conserver ses dépendances de test

## Why

Le bloc LXC de DEVOPS.md ne précise pas que son accès se fait en SSH.
Le développeur demande aussi de conserver les binaires et bibliothèques installés pour les tests.
Périmètre validé dans cette session SCM le 26 octobre 2026, avec ajout explicite de la cinquième puce.

## What Changes

- Ajouter « accessible en SSH » au titre LXC.
- Remplacer la première puce par « Variables d'accès disponible dans project.env pour l'accès SSH ».
- Ajouter en cinquième position « Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests. ».
- Conserver intégralement la puce commune d’autorisation, quatrième pour LXC et dernière pour Docker.
- Aligner les tests existants, le cadrage technique, README et CHANGELOG.

## Capabilities

### Modified Capabilities

- `projects-template-devops` : titre SSH, cinq puces LXC et ordre de l’autorisation commune.

## Impact

Générateur commun des parcours individuel, groupé et final de création ; format 0.7 conservé.
Activation ENV_DEVOPS_TESTS_LXC=1 et comportement Docker inchangés.
Aucune connexion distante, lecture d’identifiants, installation ou désinstallation pendant la génération.
Les documents déjà générés adoptent le texte à leur prochaine génération normale.
Archivage, rapport STATISTIQUES.md et commit local conditionnel inclus ; aucun push.
