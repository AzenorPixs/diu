# Proposition

## Pourquoi

Les configurations associées aux logiciels doivent pouvoir être réappliquées à chaque convergence, indépendamment de l'installation des paquets. Le nettoyage doit être distingué de la convergence d'un logiciel déjà absent.

## Changements

- Ajouter un contrat de configuration et de nettoyage pour chaque logiciel des moteurs APT, Flatpak et GitHub, avec des traitements sans effet quand rien n'est nécessaire.
- Exécuter la configuration après installation et à chaque convergence d'un logiciel désiré et installé, sans mettre à jour sa version.
- Exécuter le nettoyage après une désinstallation effective, sans le rejouer pour un logiciel déjà absent.
- Réconcilier les configurations et nettoyages existants en préservant les rôles partagés et les réglages personnels.

## Capacités

### Nouvelles capacités

Aucune.

### Capacités modifiées

- `software-desired-state` : cycle de configuration et de nettoyage des logiciels gérés.

## Impact

Moteurs logiciels, déclarations et recettes associées, tests, documentation et spécifications. Les logiciels et les syntaxes existants restent pris en charge.
