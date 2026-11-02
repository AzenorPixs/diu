# Renommer l'activation de l'environnement IA

## Pourquoi

Le point d'entrée consulte `ENV_IA` sous `set -u`, mais aucune déclaration ne
l'initialise. Le lancement s'arrête au début du provisionnement IA.

## Changements

- Déclarer `ENVIRONMENT_IA` en `STATIC`, `ENABLE`, scope `environnements`,
  défaut `0`.
- Migrer exactement `ENV_IA=0|1` vers `environnements.env`, en respectant la
  priorité d'un `ENVIRONMENT_IA` déjà configuré.
- Remplacer les deux contrôles du provisionnement et de l'appartenance au
  groupe DevOps.
