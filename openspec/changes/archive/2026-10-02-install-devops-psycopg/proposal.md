# ENV05 — Installation de Psycopg dans Python DevOps

## Why

Le bloc Python du monolithe prépare le Python DevOps mais n'installe pas
`psycopg`. Son installation dans le conteneur OpenCode ne rend pas le module
disponible dans `/home/${ENV_DEVOPS_USER}/python/current`.

## What Changes

- Installer `psycopg[binary]>=3.2,<4` avec le Python DevOps après la préparation
  des liens Python/pip, à chaque passage dans le bloc `PYTHON=1`.
- Utiliser `pip install --upgrade --no-user` pour rechercher une version plus
  récente compatible et conserver les paquets déjà à jour sans réinstallation.
- Vérifier l'import et afficher la version, avec arrêt explicite en cas d'échec.
- Tester le bloc avec un index et un interpréteur simulés, sans installation
  réelle ni accès réseau, et documenter le comportement dans TECHNICAL.md.

## Capabilities

### New Capabilities

- `devops-python`: Installation et mise à jour idempotente de Psycopg dans le
  Python DevOps géré par le monolithe.

### Modified Capabilities

Aucune.

## Impact

Fichiers concernés : `root-install-debian.sh`, `tests/test_devops_python.py`,
`TECHNICAL.md` et les artefacts du seul change `install-devops-psycopg`.
Le développeur a validé ce périmètre autonome, sa synchronisation et son
archivage. L'exécution réelle du DIU contacte l'index configuré pour pip et
modifie uniquement les paquets Python concernés dans le préfixe DevOps.
Une erreur bloque le bloc ; aucun retour automatique à l'ancienne version
n'est prévu. La session ne réalise aucune installation sur l'hôte, aucune
opération Git et aucune modification d'OpenCode ou d'autres changes.
