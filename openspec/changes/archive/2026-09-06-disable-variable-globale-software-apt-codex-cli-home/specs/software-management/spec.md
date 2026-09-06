# Gestion logicielle

### Requirement: Variable HOME désactivée

Le fichier déclaratif Codex CLI SHALL avoir l'état `DISABLE` et SHALL NOT
créer, utiliser ou persister `SOFTWARES_APT_CODEX_CLI_HOME`.

### Requirement: Lancement direct

L'installation GitHub de Codex CLI SHALL exposer directement le binaire
extrait par un lien symbolique et SHALL NOT générer de wrapper shell.

### Requirement: Conservation des opérations

Les commandes d'installation, de mise à jour et de désinstallation SHALL
conserver la gestion des artefacts Codex CLI et de la variable d'état
`SOFTWARES_APT_CODEX_CLI`.

