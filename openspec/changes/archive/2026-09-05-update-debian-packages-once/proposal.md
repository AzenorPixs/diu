# SW03 — Proposal: Mise à jour groupée des paquets Debian

## Why

`ridu` doit mettre à jour l'ensemble des paquets Debian provenant des dépôts
officiels en une seule transaction et rester lisible lorsque de nombreux
paquets sont déjà à jour.

## What Changes

- Conserver la collecte et le contrôle de tous les paquets Debian officiels.
- Exécuter leur mise à jour dans une transaction APT groupée unique.
- Supprimer les messages individuels pour les paquets non applicables ou déjà
  à jour.

## Out of Scope

Les paquets tiers restent exclus du moteur `deb` et les mises à jour APT
restent distinctes de la transaction Debian officielle.
