# SYS02 — Proposal: Moteur des dépôts Debian officiels

## Pourquoi

La configuration des dépôts Debian officiels est actuellement intégrée au
script monolithique et ne prend en charge que Trixie. Elle doit devenir une
responsabilité du module `system`, pilotée par les variables persistantes du
scope `system`.

## Changement

- Ajouter les variables `SYSTEM_APT_DEBIAN_UPDATES`, `BACKPORT`, `CONTRIB`,
  `NONFRFEE` et `SOURCES`.
- Utiliser `debian.sources` et le format deb822 à partir de Debian Trixie.
- Utiliser `/etc/apt/sources.list` pour Bookworm et les versions antérieures.
- Toujours générer la release et la sécurité ; conditionner updates,
  backports, contrib, non-free et les sources à leurs variables.
- Exposer `diu system update apt debian`, `diu system update apt` et
  `diu system update`, en conservant `diu update` pour la mise à jour du DIU.
- Retirer uniquement les dépôts Debian officiels du monolithe.

## Hors périmètre

Les dépôts tiers déjà présents dans le monolithe, leur recette et leur
authentification ne sont pas refactorisés dans ce changement.
