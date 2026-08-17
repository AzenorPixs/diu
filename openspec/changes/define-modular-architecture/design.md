# Design: Architecture modulaire du DIU

## Context

Le DIU actuel est un script monolithique (`root-install-debian.sh`, 5000+ lignes)
accompagné d'un fichier de variables (`variables.sh`). L'objectif est de formaliser
l'architecture cible décidée par le développeur, sans modifier le code.

## Architecture cible

### Structure générale

Le projet tend vers la structure suivante :

    /workspace/
    ├── config/
    ├── deb/
    ├── lib/
    │   ├── logging.sh
    │   ├── filesystem.sh
    │   ├── network.sh
    │   ├── packages.sh
    │   └── utils.sh
    ├── modules/
    │   ├── desktop/
    │   │   ├── gnome.sh
    │   │   └── applications.sh
    │   ├── environments/
    │   │   ├── docker.sh
    │   │   ├── devops.sh
    │   │   └── proxmox.sh
    │   ├── projects/
    │   │   ├── bash.sh
    │   │   ├── git.sh
    │   │   ├── forgejo.sh
    │   │   ├── opencode.sh
    │   │   └── openspec.sh
    │   ├── softwares/
    │   │   ├── vscode.sh
    │   │   ├── geany.sh
    │   │   └── syncthing.sh
    │   └── system/
    │       ├── apt.sh
    │       ├── locale.sh
    │       ├── users.sh
    │       ├── network.sh
    │       └── security.sh
    ├── root-install-debian.sh
    └── variables.sh

### Rôle des composants

**`root-install-debian.sh`** — Point d'entrée principal. Conserve le dispatch
des arguments et la logique d'exécution principale.

**`variables.sh`** — Fichier de configuration. Reste à la racine tant qu'aucune
évolution ne spécifie son déplacement.

**`lib/`** — Fonctions génériques et réutilisables communes aux domaines :
- `logging.sh` : journalisation, affichage de messages
- `filesystem.sh` : manipulation de fichiers et répertoires
- `network.sh` : fonctions réseau génériques
- `packages.sh` : gestion de paquets
- `utils.sh` : utilitaires transverses

**`modules/`** — Domaines fonctionnels du DIU :
- `desktop/` : environnement de bureau
- `environments/` : environnements d'exécution
- `projects/` : gestion de projets
- `softwares/` : installation de logiciels
- `system/` : configuration système

### Principes de migration

1. **Progressive** : la migration s'effectue par changements limités et cohérents
2. **Limitée** : chaque étape fait l'objet d'un changement OpenSpec distinct,
   pouvant concerner une partie seulement d'un futur module
3. **Validée** : chaque changement est explicitement validé par le développeur
4. **Compatible** : le comportement existant est préservé
5. **Atomique** : les commits réalisés pendant chaque étape restent atomiques
   et respectent les règles définies dans `AGENTS.md`

### Contraintes

- Aucune modification fonctionnelle pendant la migration
- `root-install-debian.sh` reste le point d'entrée
- `variables.sh` reste à la racine
- L'architecture cible est imposée par le développeur
- Aucun répertoire supplémentaire n'est ajouté sans validation
