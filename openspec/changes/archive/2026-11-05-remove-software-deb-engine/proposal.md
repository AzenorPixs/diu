# Suppression du moteur logiciel deb

## Pourquoi

Le moteur logiciel `deb` et ses commandes dédiées sont retirés. Le moteur APT existant conserve son comportement.

## Changements

- Retirer le moteur logiciel `deb`, son chargement et les commandes qui y routent.
- Retirer les références correspondantes dans l'aide et les contrats applicables.
- Préserver le moteur APT, les autres moteurs et les commandes de construction de paquets Debian.

## Capacités

### Capacités modifiées
- `software-management` : retrait du moteur logiciel `deb` et de son contrat.

## Impact

Les commandes `diu install deb`, `diu remove deb` et `diu update deb` ne sont plus disponibles. Le filtrage propre au moteur `deb` disparaît avec lui. Les paquets installés ne sont pas supprimés par cette évolution.
