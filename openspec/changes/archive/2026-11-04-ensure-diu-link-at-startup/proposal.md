# Vérifier le lien diu au démarrage — code non attribué

## Why

Le paquet générique installé peut ne pas créer le lien `diu`. Le script installé doit le vérifier lui-même à chaque exécution.

## What Changes

Lors du démarrage en root du script installé, vérifier `/usr/local/bin/diu` puis le créer vers `/root/diu/root-install-debian.sh` uniquement si son nom est libre. Préserver toute entrée existante, l’aide et le comportement de développement.
