## Why

OpenCode V2 ne doit plus être installé ni inventorié comme un outil propre au domicile DevOps. L'ancien binaire sous `/home/devops/.opencode` a été supprimé. Le moteur GitHub de DIU fournit déjà la persistance d'état désiré, la convergence et la vérification SHA-256 nécessaires à une gestion système idempotente.

## What Changes

- Retirer l'installation et la rubrique de l'outil OpenCode de l'inventaire `DEVOPS.md` généré, sans retirer les usages OpenCode des configurations propres aux projets.
- Gérer OpenCode V2 par le moteur GitHub avec `SOFTWARE_GITHUB_OPENCODE`, détecté exclusivement à `/usr/local/bin/opencode`.
- Sélectionner une release stable V2 du dépôt `anomalyco/opencode`, télécharger l'archive CLI Linux x64 et son manifeste `SHA256SUMS`, vérifier le digest puis installer le CLI sous `/usr/local/bin/opencode`.
- Mettre à jour les vues et parcours système qui présentent ou mettent à jour les logiciels GitHub gérés.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `software-management` : OpenCode V2 ajouté au moteur GitHub.
- `projects-template-devops` : retrait de l'outil OpenCode de l'environnement DevOps et de son inventaire.
- `system-update-engines` : mise à jour et présentation d'OpenCode avec les logiciels GitHub configurés.
- `devops-opencode` : retrait de l'ancien parcours d'installation OpenCode DevOps.

## Impacts

Le changement touche les recettes et déclarations du moteur GitHub, la génération de `DEVOPS.md`, les parcours de mise à jour système, leurs tests et leur documentation. Code de lot non attribué ; l'attribution ultérieure relève d'ACL.
