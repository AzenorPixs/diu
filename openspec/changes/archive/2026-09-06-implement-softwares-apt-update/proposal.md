# Proposition : mise à jour globale du module softwares

## Pourquoi

Le module `softwares` sait lancer la mise à jour APT, mais il ne rejoue pas
les mises à jour sélectives propres aux logiciels APT installés. Les
configurations post-installation peuvent donc ne pas être réappliquées après
la mise à jour des paquets.

## Ce qui change

Ajouter la commande :

```text
rid softwares update apt
```

Elle exécute obligatoirement, dans cet ordre :

1. `rid softwares apt update` ;
2. les mises à jour sélectives des logiciels APT installés et reconnus.

La même séquence sera utilisée par `rid softwares update` et `rid update`.
Les logiciels non installés ou non déclarés sont ignorés. Aucun nouveau
logiciel n'est ajouté par cette évolution.

## Hors périmètre

- ajout de nouvelles recettes logicielles ;
- modification des dépôts APT ;
- rejouement des opérations d'installation ou de désinstallation ;
- changement des mises à jour sélectives existantes.

