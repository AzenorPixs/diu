# Design: Moteur APT Debian du module system

Le module `modules/system/apt.sh` produit une configuration déterministe et
idempotente. Il lit le nom de code fourni par `SYSTEM_DEBIAN_RELEASE` et le
format de la distribution dans `/etc/os-release`. `VERSION_ID` majeur >= 13
sélectionne le format deb822 ; les versions antérieures utilisent le format
historique.

Les sections release et security sont toujours présentes. La section
`<release>-updates` dépend de `SYSTEM_APT_DEBIAN_UPDATES`, les backports de
`SYSTEM_APT_DEBIAN_BACKPORT`, les composants `contrib` et `non-free*` de leurs
variables respectives. `SYSTEM_APT_DEBIAN_SOURCES` ajoute les sources
`deb-src` ou `deb-src` dans le champ `Types` deb822.

Le fichier Debian officiel est limité à `debian.sources`; les fichiers des
dépôts tiers ne sont ni supprimés ni réécrits par le moteur. La configuration
est appelée pendant l'initialisation APT historique et par le contexte de mise
à jour Debian. `diu system update apt` exécute ensuite la mise à jour de tous
les index APT, tandis que `diu system update apt debian` limite l'action aux
dépôts Debian officiels.
