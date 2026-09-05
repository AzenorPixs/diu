# Proposal: Réappliquer les composants Debian avant une mise à jour globale

## Why

La mise à jour globale appelée par `ridu` utilisait la configuration APT
existante sans la régénérer depuis les variables du scope system. Les dépôts
`contrib`, `non-free` et `backports` pouvaient donc ne pas être pris en compte
malgré des variables activées.

## What Changes

Le moteur APT global régénère désormais les dépôts Debian officiels avant
`apt-get update` et `apt-get dist-upgrade -y`, en appliquant toutes les
variables `SYSTEM_APT_DEBIAN_*`.
