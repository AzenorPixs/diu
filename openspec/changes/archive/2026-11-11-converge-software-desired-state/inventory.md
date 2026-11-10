# Inventaire de reprise — 2026-11-10

Sources : `root-install-debian.sh`, `modules/softwares/`, `modules/diu/variables/softwares/` et spécifications individuelles. Cet inventaire décrit les éléments observés et ne prouve pas l'intégration ou la validation globale.

| Contrôle | Traitement existant observé | État de la refonte isolée |
|---|---|---|
| Apache2 | Paquets APT et dépendances selon Debian | Catalogue et détection initiaux testés |
| ChatGPT | Paquet APT et dépôt CGPT | Catalogue, détection et préparation de dépôt testés ; retrait du dépôt à réexaminer en cas de paquet déjà absent |
| jsvc, Open vSwitch, qemu-guest-agent, Syncthing | Paquet APT | Catalogue et détection initiaux testés |
| LemonLDAP-NG | Paquet, documentation, dépendances et dépôt | Catalogue et détection initiaux testés ; intégration système à vérifier |
| Webmin | Paquet APT avec recommandations ; purge lorsque désactivé | Catalogue et détection initiaux testés |
| Fastfetch | neofetch ou fastfetch selon Debian ; configuration neofetch | À raccorder, dont configuration et détection par version |
| MongoDB | `mongodb-org`, service et vérifications | Serveur, dépôt, service et retrait simulé testés isolément ; raccordement global en attente |
| OpenJDK | JRE 17 ou 21, liens et proxy selon Debian | Détection des versions et configuration testées sur fichiers factices ; raccordement global en attente |
| Omada | Téléchargement d'un paquet `.deb`, règles réseau ailleurs | Détection du paquet `omadac` et validation du `.deb` testées isolément ; reprise des règles réseau à vérifier. La [documentation TP-Link](https://www.tp-link.com/pe/support/faq/4160/) identifie `omadac` pour la version 5.14.26.1 ; les autres versions restent à qualifier. |
| PostgreSQL | Métapaquet `postgresql` | Détection du serveur et retrait simulé des paquets serveur testés isolément |
| Postfix | Paquet, configuration de relais et redémarrage | Configuration et vérification testées sur fichiers factices ; raccordement global en attente |
| Syslog client et serveur | Paquet commun et configurations qui réécrivent toutes deux `rsyslog.conf` | À concevoir ensemble : paquet partagé, rôles séparés et coexistence des configurations |
| OpenSSH serveur | Paquet, clés et configuration SSH | Préservation des clés root et validation de configuration testées isolément ; comportement du compte Docker et raccordement global en attente |
| Wazuh agent | Paquet `.deb`, service et paramètres d'enregistrement | Détection, installation avec paramètres fournis sans journalisation et service testés isolément ; hypothèse de refus si paramètres absents. La [documentation Wazuh](https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-linux.html) confirme les paramètres de déploiement et le service. |
| Wazuh serveur | Mise à niveau conditionnelle de plusieurs paquets | Paquets et détection composite testés isolément ; Filebeat est préservé au retrait car potentiellement partagé |
| Zoom | Téléchargement `.deb` avec comparaison de version | À séparer : installation/convergence et mise à jour de version système |
| Zsh | Zsh, Fish, FZF, tmux, modification du shell et réécriture de `.zshrc` avec variables sensibles | Hypothèse conservatrice : contenu existant préservé sans recopier de clés ; bloc géré et protection du shell testés isolément ; raccordement global en attente |
| CrowdSec agent et bouncer | Paquets partagés, configuration et services ; clé API sensible | À concevoir ensemble : priorité API locale si les deux rôles sont actifs |
| Dépôt CrowdSec | Réglage de dépôt, distinct de l'état d'un logiciel installé | Migration de nom et intégration système à vérifier |
| Codex CLI | Release GitHub, archive vérifiée et lien | Détection, installation, retrait et mise à jour système isolés et testés ; raccordement en attente |
| Applications Flatpak | Identifiants arbitraires et portée système | Détection, convergence et reprise initiale isolées et testées ; raccordement en attente |

Les tests isolés ne constituent pas une preuve d'installation réelle ; aucune opération de ce type n'a été exécutée sur la machine.
