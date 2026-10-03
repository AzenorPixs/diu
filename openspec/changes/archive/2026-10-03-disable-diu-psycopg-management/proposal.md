## Why

Psycopg relève désormais des dépendances des projets et non du DIU. Le bloc
Python DevOps et le lancement OpenCode en écriture installent encore ce paquet.
Le développeur a validé le 3 octobre 2026 la désactivation par commentaires,
les tests, la documentation et le cycle OpenSpec jusqu'à l'archivage.

## What Changes

- Commenter le bloc d'installation, de mise à jour et de contrôle Psycopg du
  Python DevOps, sans désinstaller les paquets existants.
- Conserver en commentaire, hors de la commande exécutée par `launch_ocrw`,
  l'installation Psycopg du conteneur OpenCode.
- Préserver Python, pip, leurs liens et profil, les droits DevOps ainsi que
  les autres outils, paramètres et protections du conteneur.
- Adapter les tests isolés et le cadrage technique à cette responsabilité.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `devops-python`: exclure la gestion automatique de Psycopg dans le Python
  DevOps et le lancement OpenCode, tout en préservant les préparations existantes.

## Impact

Fichiers concernés : `root-install-debian.sh`, `tests/test_devops_python.py`,
`TECHNICAL.md`, ce change et `openspec/specs/devops-python/spec.md`.
Les projets doivent déclarer et installer Psycopg eux-mêmes. Aucun paquet
présent n'est désinstallé ; aucun effet système, réseau, Docker ou Git réel
n'est inclus. Aucun autre change n'est synchronisé ou archivé.
