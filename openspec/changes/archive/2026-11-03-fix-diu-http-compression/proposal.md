# Corriger la décompression HTTP de la mise à jour DIU

## Why

Les réponses Forgejo peuvent être encodées en Zstandard. Les appels `curl`
actuels transmettent alors des octets comprimés à `jq` ou à `dpkg-deb`.

## What Changes

- Demander à `curl` la décompression HTTP des réponses d'API et des paquets.
- Vérifier avec des réponses locales compressées et une installation simulée.
- Signaler les échecs de décodage sans installer de paquet.

## Capabilities

### Modified Capabilities

- `diu-package-update`: réception des réponses et paquets encodés en HTTP.

## Impact

Mise à jour DIU, tests et documentation. Aucun changement de sélection de
version, de routage, d'authentification ou de dépendance n'est prévu. La prise
en charge effective d'un encodage dépend du `curl` installé.
