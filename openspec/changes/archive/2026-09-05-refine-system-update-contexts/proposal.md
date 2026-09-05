# Proposal: Clarifier les contextes de mise à jour

## Why

Les commandes de mise à jour ne distinguent pas suffisamment la transaction
Debian officielle, la mise à jour globale APT et la mise à jour du DIU.

## What Changes

- `diu system update apt debian` configure les dépôts Debian officiels et met
  à jour leurs paquets, avec un détail paquet par paquet.
- `diu system update apt` exécute `apt-get update` puis une unique transaction
  `apt-get dist-upgrade -y` sur tous les dépôts.
- `diu system update` délègue à la mise à jour APT globale.
- `diu update` délègue la partie APT à cette même mise à jour globale puis
  poursuit la mise à jour de DIU.
