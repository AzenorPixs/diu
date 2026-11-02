# Design

La déclaration migre vers `modules/diu/variables/desktop/desktop.sh` et
`/root/diu/config/desktop.env`. Avant de charger les variables, `config_cleanup`
transfère `SOFTWARES_APT_DESKTOP=0|1` vers `DESKTOP=0|1` si le nouveau nom
n'existe pas déjà dans le fichier de scope desktop, puis supprime l'ancien
export logiciels. Une ancienne affectation `DESKTOP` dans `variables.sh` est
également migrée vers `desktop.env`; l'export `SOFTWARES_APT_DESKTOP` déjà
persisté prévaut sur cette valeur historique lorsqu'il n'y a pas encore de
`DESKTOP` dans `desktop.env`.

Les deux consommateurs continuent de consulter `DESKTOP`, désormais fourni par
le chargeur du scope desktop. Le rapport des informations de module l'affiche
sous le titre DESKTOP.
