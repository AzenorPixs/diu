# Design

Le module `software_apt_desktop.sh` déclare un booléen statique et activé,
initialisé à `0`. `config_cleanup` lit uniquement les affectations littérales
`0` ou `1` de `DESKTOP`, transfère la dernière valeur vers `softwares.env` et
supprime les anciennes affectations après migration réussie. Une valeur déjà
déclarée sous `SOFTWARES_APT_DESKTOP` reste prioritaire. Une forme ambiguë
bloque le démarrage sans modifier les fichiers.

Les deux consommateurs du point d'entrée utilisent le nouveau nom avec un
repli `0`; les traitements de bureau existants restent inchangés lorsque la
valeur est `1`.
