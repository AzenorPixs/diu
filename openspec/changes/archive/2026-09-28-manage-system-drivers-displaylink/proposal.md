# SYS15 — Why
Le bloc automatique ne prend pas en charge EVDI pour Linux 7.x et ne valide pas le fonctionnement du pilote. Le développeur a validé son remplacement par deux commandes explicites.

# What Changes
- Retirer uniquement le bloc DisplayLink du monolithe.
- Ajouter installation et désinstallation idempotentes dans modules/system/drivers.sh, routage et aide.
- Installation limitée à PHYSICAL/PROXMOX, traitement EVDI 7.x, validation avant persistance.
- Tests isolés, documentation et synchronisation/archivage inclus. Aucune installation réelle ni opération Git.

# Capabilities
## Modified Capabilities
- system-drivers-display-link
- system-prerequisites
- rid-help
- legacy-variable-cleanup (alignement du scénario du consommateur déplacé)

# Impact
APT peut avoir effectué une transaction partielle en cas d'échec ; aucune annulation automatique n'est promise. Les bibliothèques partagées, DKMS et headers sont conservés à la suppression. Aucun dépôt testing/sid ajouté.
