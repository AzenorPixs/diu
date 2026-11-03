# Authentifier les mises à jour DIU depuis GitHub privé

## Why

L'API GitHub répond 404 aux appels anonymes sur le dépôt DIU privé. Les
identifiants GitHub du projet existent déjà et sont gérés par le DIU.

## What Changes

- Réutiliser le lecteur GitHub existant pour consulter les releases privées et
  télécharger le paquet via l'API GitHub, sans exposer le jeton.
- Préserver l'accès anonyme aux dépôts publics sans identifiant et les autres
  fournisseurs ; refuser l'installation en cas d'échec d'authentification.
- Ajouter des tests isolés de l'API privée, des assets et des erreurs.

## Capabilities

### Modified Capabilities

- `diu-package-update` : accès GitHub authentifié et téléchargement privé.

## Impact

Module de mise à jour, tests, spécification et documentation. Aucun changement
des publications, de l'ordre des fournisseurs ou des comparaisons de versions.
