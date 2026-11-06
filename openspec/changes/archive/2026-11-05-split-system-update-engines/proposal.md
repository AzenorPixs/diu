# Séparer les mises à jour des moteurs système

## Pourquoi
Exposer séparément les étapes APT, GitHub et Flatpak de la mise à jour système.

## Changements
- Remplacer le parcours de `diu system apt update` par la phase APT et son bilan.
- Ajouter les parcours ciblés GitHub et Flatpak.
- Composer la mise à jour générale avec ces parcours puis le réseau, en conservant ses résultats.
- Supprimer les syntaxes historiques `system update apt [debian]`, `system update debian` et `system update flatpak`.

## Capacités
### Nouvelles capacités
- `system-update-engines`: parcours système ciblés et composition.

### Capacités modifiées
- `system-update-report`: conservation du bilan de la commande générale.

## Impact
Routage système, aide, tests et documentation ; les anciennes syntaxes supprimées deviennent invalides.
