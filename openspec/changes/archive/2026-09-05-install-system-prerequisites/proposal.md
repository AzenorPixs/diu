# Installation des prérequis système

Ajouter au module `system` une fonction idempotente d'installation des
prérequis système obligatoires. Elle est appelée après l'actualisation des
dépôts APT officiels et tiers par `rid update` et `rid system update`.

La liste est traitée dans l'ordre alphabétique. Les paquets déjà installés ne
produisent aucune sortie ; chaque paquet absent fait l'objet d'un message puis
d'une installation.

## Hors périmètre

- aucune modification de la configuration des dépôts ;
- aucune suppression ou mise à niveau forcée des paquets déjà installés ;
- aucun changement du parcours `rid update diu` ciblé.
