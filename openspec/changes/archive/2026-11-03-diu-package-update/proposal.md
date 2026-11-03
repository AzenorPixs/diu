# Mise à jour du paquet DIU depuis les dépôts configurés

## Pourquoi

La mise à jour actuelle utilise une seule release Forgejo codée en dur. La commande dédiée doit rechercher les paquets publiés dans les dépôts du projet et précéder les autres mises à jour.

## Changements

- Ajouter `rid diu update` et conserver `rid update diu` comme alias.
- Rechercher les paquets Debian des releases des fournisseurs configurés dans le `project.env` du projet DIU, comparer leurs versions Debian et installer uniquement une version supérieure après vérification.
- Appeler cette mise à jour en premier dans `rid update` et actualiser les aides et la documentation.

## Capacités

### Nouvelles capacités
- `diu-package-update`: sélection et installation du paquet DIU.

### Capacités modifiées
- `universal-update`: ordre de la mise à jour générale et alias ciblé.

## Impacts

Routage, module de mise à jour, aides, tests et documentation. Les dépôts non configurés sont ignorés ; un dépôt configuré inaccessible empêche la sélection comme dernière version globale. Aucun paquet n'est installé pendant les tests automatisés.
