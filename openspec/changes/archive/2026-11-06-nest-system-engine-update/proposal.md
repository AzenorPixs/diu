# Regrouper les mises à jour des moteurs système

## Pourquoi
Rassembler les commandes de mise à jour des moteurs sous `diu system engine` et permettre leur exécution groupée.

## Changements
- Exposer `diu system engine update` et `diu system engine <apt|github|flatpak> update`.
- Composer `diu system update` avec la mise à jour groupée des moteurs puis le réseau.
- Retirer les anciennes commandes ciblées directement sous `system`.

## Capacités
### Capacités modifiées
- `system-update-engines` : routage et composition des mises à jour.

## Impact
Aide, tests et documentation ; les anciens appels ciblés doivent être migrés.
