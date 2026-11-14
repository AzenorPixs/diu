# Design : OpenCode V2 dans le moteur GitHub

## Décisions

- Utiliser la release CLI `opencode-linux-x64.tar.gz` et son entrée de `SHA256SUMS`. Le `.deb` publié est l'application desktop et ne convient pas au chemin CLI demandé.
- Rechercher les releases du dépôt `anomalyco/opencode` et retenir une release non brouillon, non préliminaire, avec un tag stable `v2.x.y` et les deux artefacts attendus. L'API globale `/releases/latest` n'est pas une source suffisante : elle peut désigner la branche V1.
- Extraire le binaire dans un répertoire géré sous `/usr/local/lib/opencode`, puis exposer `/usr/local/bin/opencode` par un lien contrôlé par DIU.
- Initialiser le désir absent depuis l'existence du seul binaire `/usr/local/bin/opencode`. Une installation sous `/home/devops/.opencode` ou un autre emplacement du `PATH` ne détermine pas l'état réel.
- Refuser de remplacer un chemin système déjà occupé par un fichier ou un lien qui n'appartient pas à DIU. Le retrait supprime seulement le lien attendu et le répertoire d'installation géré ; les configurations des utilisateurs et des projets restent préservées.
- Retirer OpenCode de l'inventaire des outils DevOps. Les configurations OpenCode propres aux projets ne sont pas migrées ni supprimées par cette évolution.

## Validation prévue

Des tests isolés couvrent la sélection V2, le manifeste et son digest, la plateforme, l'installation, le retrait, la détection exclusive du chemin système, les états désirés et les parcours DevOps/système. Aucun test ne contacte la release réelle ni ne modifie `/usr/local/bin`.
