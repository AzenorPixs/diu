## Context

Deux chemins exécutent actuellement des installations de prérequis : le
parcours sans argument et `system_apt_update`. Le premier emploie des listes
répétées et un contrôle sur `aptitude` ; le second vérifie chaque paquet.

## Goals / Non-Goals

Centraliser la composition des listes générales tout en conservant le socle
initial, les compléments historiques et l'ordre d'exécution des appelants.
Les autres installations, les dépôts, le paquet DIU et DisplayLink restent
hors périmètre.

## Decisions

Un tableau commun conserve tous les paquets initiaux. Un `case` sur
`SYSTEM_DEBIAN_ENVIRONNEMENT`, avec une branche distincte par famille, ajoute
les paquets historiques : `acl` pour
LXC, PHYSICAL, VM et DOCKER ; `acl conntrack glances rsync` pour PROXMOX.
Une valeur absente, vide, UNSET ou inconnue conserve uniquement le socle
initial. Aucun nouveau paramètre de configuration n'est introduit.

La boucle conserve `dpkg-query`, le tri `LC_ALL=C sort -u` et une transaction
APT par paquet absent. Un échec APT est signalé et propagé immédiatement,
y compris si la fonction est appelée dans une condition Bash.

Le monolithe appelle la fonction à la place de ses listes générales, avant
la configuration APT comme précédemment. Le bloc PHYSICAL DisplayLink est
conservé tel quel. `system_apt_update` continue d'appeler la fonction après
la mise à jour et le nettoyage APT.

## Risks / Trade-offs

- Les paquets manquants sont désormais rétablis même si `aptitude` existe.
- Les mises à jour système installent les compléments de la famille.
- La disponibilité réelle des paquets dépend des dépôts de la machine ; les
  tests simulés ne constituent pas une installation Debian réelle.
- Les diagnostics ShellCheck historiques du monolithe sont préexistants et
  hors périmètre. La validation compare les diagnostics avant et après pour
  vérifier l'absence de nouveaux diagnostics.

## Migration Plan

Aucune migration de configuration. Les modifications locales sont réversibles.
Aucune désinstallation automatique des paquets installés n'est prévue.

## Validation

Tests simulés des cinq familles, du repli, de l'égalité DOCKER/VM, du contrôle
individuel malgré la présence d'aptitude, du silence lorsque tout est installé,
du tri, de la déduplication, de l'arrêt sur erreur et du parcours historique
avec DisplayLink activé ou désactivé. Vérifications Bash, ShellCheck,
régressions logicielles et validation stricte OpenSpec. Revue limitée de
cohérence : PROJECT, BUILD, DEVOPS, README et AGENTS restent applicables sans
modification ; TECHNICAL et system-prerequisites sont mis à jour.
