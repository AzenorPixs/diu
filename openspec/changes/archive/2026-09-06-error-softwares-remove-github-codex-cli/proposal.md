## Why

La recette GitHub de Codex CLI modifie la variable d'état dans le processus
courant, mais ne persiste pas cette modification dans la configuration des
logiciels. Après une désinstallation, une exécution ultérieure peut donc
retrouver un état incohérent et tenter une mise à jour d'un logiciel absent.

Cette évolution rend la persistance de `SOFTWARES_APT_CODEX_CLI` cohérente avec
les mutations d'installation et de désinstallation, et rend la mise à jour
ciblée sans effet lorsque Codex CLI n'est pas installé.

## What Changes

- persister l'état `SOFTWARES_APT_CODEX_CLI` après les mutations de Codex CLI ;
- rendre l'update ciblé sans effet lorsque Codex CLI est absent.

## Hors périmètre

- modification du profil utilisateur Codex CLI ;
- modification de la gestion de `SOFTWARES_APT_CODEX_CLI_HOME` ;
- modification du téléchargement ou de la vérification des releases GitHub.
