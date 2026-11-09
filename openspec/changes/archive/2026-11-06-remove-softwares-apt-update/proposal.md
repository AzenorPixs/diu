# Retirer la commande softwares apt update

## Pourquoi
La syntaxe `diu softwares apt update` expose une commande redondante et doit disparaître.

## Modifications
- Refuser cette syntaxe sans effet et la retirer des aides.
- Préserver les mises à jour APT des parcours `softwares update apt` et `softwares update`.
- Adapter les tests et la documentation ; aucune migration automatique.

## Non-objectifs
Modifier les autres commandes, les moteurs ou la configuration.

## Capacités concernées
- `software-management` : contrat de routage et de mise à jour APT.
