## Context

Le chargeur découvre variables/<scope>/*.sh. SYSTEM_DEBIAN_RELEASE fournit le
modèle dynamique : génération seulement en cas d'absence, sans persistance.
config_cleanup s'exécute avant le sourcing de /root/diu/variables.sh.

## Decisions

- Conserver le nom demandé SYSTEM_DEBIAN_ENVIRONNEMENT et le fichier
  modules/diu/variables/system/system_debian_environnement.sh.
- Employer systemd-detect-virt --container puis --vm, outils du socle systemd.
  Accepter uniquement une réponse reconnue avec un statut cohérent. Un retour
  1 accompagné de none signifie absence de virtualisation dans cette catégorie.
- Priorité au conteneur courant : docker -> DOCKER, lxc/lxc-libvirt -> LXC.
  Les autres conteneurs restent UNSET, sans les confondre avec l'hôte.
- Une VM reconnue reste VM même avec pve-manager installé. Sur un système sans
  virtualisation détectée, dpkg-query doit confirmer pve-manager en état
  install ok installed pour produire PROXMOX. Paquet absent ou non installé :
  PHYSICAL. Échec inattendu ou outil absent : UNSET avec diagnostic stderr.
- Le nom du noyau ou un dépôt Proxmox ne suffisent pas pour identifier Proxmox VE.
- Étendre le nettoyage exact existant aux affectations simples DEBIAN_TYPE.
  Aucun affichage ni transfert de valeur locale ; préserver les autres lignes.

## Risks and limitations

La détection dépend des informations exposées à systemd ; un hyperviseur masqué
ne peut pas être identifié avec certitude. Les tests simulent les environnements,
ils ne constituent pas une validation sur toutes les plateformes réelles.
Les valeurs déjà définies sont conservées selon la convention dynamique actuelle.
La migration retire les anciennes affectations à la prochaine exécution DIU ;
elle ne fournit pas de restauration automatique de leur valeur. Les erreurs de
nettoyage bloquent le chargement. Aucune configuration locale réelle n'est modifiée
pendant les tests et aucun comportement spécifique DOCKER/UNSET n'est inventé.

## Validation

Tests déterministes : six sorties, priorité conteneur/VM sur Proxmox, conteneurs
inconnus, statuts incohérents, outils absents, absence de persistance, export et
valeurs déjà définies. Tests de nettoyage : préservation, permissions, répétition,
erreurs et ordre de démarrage. Bash -n, ShellCheck avec comparaison du point
d'entrée à son état initial, contrôles de portée et validation OpenSpec stricte.
