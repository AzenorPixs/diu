# Conception

Le module `software_apt_fastfetch.sh` déclarera la variable statique dans le
scope logiciels. Le nettoyage migrera les anciennes affectations littérales
`FASTFETCH=0|1`, sans évaluer leur contenu et en donnant priorité au nouveau
nom déjà persisté dans `softwares.env`. Les consommateurs du point d’entrée
utiliseront `SOFTWARES_APT_FASTFETCH`; les branches APT existantes pour
neofetch sur Debian bullseye/bookworm et fastfetch sur trixie restent intactes.
