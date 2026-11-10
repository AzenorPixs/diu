## Why

Les commandes du module softwares mêlent aujourd'hui mise à jour de versions et gestion de l'état des logiciels. La variable doit représenter l'état désiré et la convergence doit corriger les écarts avec l'état réel, sans perdre les logiciels déjà pris en charge.

## What Changes

- Exposer pour chaque moteur APT, Flatpak et GitHub trois opérations génériques : installation, désinstallation et convergence, fondées sur des déclarations propres aux logiciels et un détecteur d'état réel par logiciel.
- Persister l'état désiré lors des commandes install et remove ; initialiser seulement les variables absentes à partir de l'état réel. La convergence ne réécrit pas cet état.
- Nommer les variables `SOFTWARE_APT_<X>`, `SOFTWARE_FLATPAK_<X>` et `SOFTWARE_GITHUB_<X>` ; migrer les anciennes valeurs sans les écraser, y compris celle de Codex CLI.
- Faire converger un logiciel ou tous les logiciels d'un moteur par `diu softwares update <moteur> [logiciel]` ; signaler l'état réel et les erreurs, puis vérifier le résultat des corrections.
- Faire converger les moteurs activés dans l'ordre APT, Flatpak, GitHub par `diu softwares update`, appelé en dernier par `diu update`.
- Retirer la mise à jour de versions des parcours softwares ; maintenir cette responsabilité dans les commandes system et actualiser les aides.
- Préserver les logiciels et identifiants déjà pris en charge ainsi que les valeurs configurées existantes.

## Capacités

### Capacités nouvelles

- `software-desired-state`: état désiré, détection et convergence générique des logiciels.

### Capacités modifiées

- `software-management`: commandes et recettes APT et GitHub.
- `software-flatpak`: gestion et convergence des applications Flatpak.
- `universal-update`: placement de la convergence dans la playlist globale.
- `diu-help`: aide des commandes concernées.
- `system-update-engines`: mise à jour des versions Flatpak et GitHub dans les parcours système.
- `legacy-variable-cleanup` et `system-debian-apt`: migration des références aux états désirés vers les nouveaux noms.
- `software-apt-fastfetch`: migration de la déclaration et du consommateur Fastfetch.
- `software-apt-apache2`, `software-apt-crowdsec` et `system-crowdsec-agent`: migration des déclarations et préservation des comportements Apache2 et CrowdSec.
- `software-apt-jsvc`: migration de la déclaration et des consommateurs existants.
- `software-apt-lemonldap`: migration de la déclaration et des consommateurs existants.
- `software-apt-mongodb`: migration de la déclaration et des consommateurs existants.
- `software-apt-omada`: migration de la déclaration et des consommateurs existants.
- `software-apt-openjdk`: migration de la déclaration et des consommateurs existants.
- `software-apt-openvswitch`: migration de la déclaration et des consommateurs existants.
- `software-apt-postfix`: migration de la déclaration et des consommateurs existants.
- `software-apt-postgresql`: migration de la déclaration et des consommateurs existants.
- `software-apt-qemu-guest-agent`: migration de la déclaration et des consommateurs existants.
- `software-apt-ssh-server`: migration de la déclaration et des consommateurs existants.
- `software-apt-syncthing`: migration de la déclaration et des consommateurs existants.
- `software-apt-syslog-client`: migration de la déclaration et des consommateurs existants.
- `software-apt-syslog-server`: migration de la déclaration et des consommateurs existants.
- `software-apt-wazuh-agent`: migration de la déclaration et des consommateurs existants.
- `software-apt-wazuh-server`: migration de la déclaration et des consommateurs existants.
- `software-apt-webmin`: migration de la déclaration et des consommateurs existants.
- `software-apt-zoom`: migration de la déclaration et des consommateurs existants.
- `software-apt-zsh`: migration de la déclaration et des consommateurs existants.

## Impacts

Modules logiciels et système, déclarations de variables, persistance, répartiteur, aide, tests et documentation. Une convergence peut installer ou désinstaller un logiciel conformément à sa variable. Les configurations existantes et les traitements spécifiques nécessaires doivent être préservés. Code de lot non attribué.
