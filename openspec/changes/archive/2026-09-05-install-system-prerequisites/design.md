# Conception

La fonction sera définie dans `modules/system/apt.sh`, à proximité du flux
APT global. Elle recevra la liste statique des noms de paquets, la triera avec
`sort -u`, vérifiera chaque paquet avec `dpkg-query`, puis installera les
paquets manquants en une opération `apt-get install -y`.

`system_apt_update` appellera cette fonction après `apt-get update` et
`apt-get dist-upgrade -y`. Le parcours universel réutilisant cette fonction,
`rid update` conservera le même ordre ; `rid system update` l'exécutera aussi.
