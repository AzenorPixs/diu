# ENV04 — Préparation OpenSpec du domicile DevOps

## Why

Le bloc OPENSPEC=1 installe l'outil et son profil custom, mais ne prépare pas
les commandes OpenSpec dans le domicile DevOps. Le développeur a validé le
2 octobre 2026 un ajout ciblé dans /home/${ENV_DEVOPS_USER}, indépendant des
templates de projets.

## What Changes

- À la fin du bloc actif, exécuter sous ENV_DEVOPS_USER via su une
  initialisation ou une actualisation dans son domicile.
- Initialiser avec le profil custom, avec --tools opencode seulement lorsque
  OPENCODE=1 ; actualiser lorsque le dossier openspec existe.
- Propager les erreurs sans annoncer de succès ni supprimer les écritures
  partielles ; vérifier les branches avec des outils simulés.

## Capabilities

### New Capabilities
- `devops-home-openspec`: préparation OpenSpec dans le domicile DevOps.

### Modified Capabilities
Aucune.

## Impact

Fichiers concernés : root-install-debian.sh, tests/test_devops_openspec.py,
TECHNICAL.md et ce change OpenSpec. L'installation existante et les templates
de projets restent inchangés. Aucun effet système réel, aucune migration,
aucune dépendance ni opération Git ne sont requis pendant cette session.
Les écritures de l'outil lors d'une future exécution du DIU n'ont pas de retour
automatique ; elles sont conservées en cas d'échec.
