# Mise à jour DIU depuis le dépôt GitHub public

## Pourquoi

La mise à jour dépend d’un checkout et peut utiliser des identifiants GitHub, absents des machines cibles.

## Changements

- Consulter anonymement les releases publiques de AzenorPixs/diu sans configuration locale GitHub.
- Conserver le secours Forgejo public configuré, les contrôles du paquet et la sélection existante.

## Capacités

### Capacités modifiées

- `diu-package-update`: source GitHub publique et anonyme par défaut.

## Impacts

Moteur de mise à jour, tests, documentation et contrat OpenSpec. La prise en charge GitHub privé pour cette commande est retirée.
