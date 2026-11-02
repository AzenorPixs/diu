# Déclaration modulaire de DOCKER_STACK_DEVOPS

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`DOCKER_STACK_DEVOPS: unbound variable`. Le nom est déjà préfixé Docker, mais
aucune déclaration modulaire ne le fournit.

## What Changes

- Déclarer `DOCKER_STACK_DEVOPS` en `STATIC`, `ENABLE`, scope `docker`, défaut
  `0`.
- Conserver le nom et le consommateur existants.
- Préserver une valeur déjà fournie par l’environnement ou la configuration
  Docker; persister le défaut seulement si aucune valeur n’existe.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

La stack et ses noms d’hôtes ne sont pas modifiés. La variable
`DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN` reste distincte.

## Critères d’acceptation

1. La valeur absente initialise et persiste `DOCKER_STACK_DEVOPS=0`.
2. Une valeur existante `0` ou `1` est conservée.
3. Une valeur préconfigurée invalide bloque avec un diagnostic.
4. Le consommateur existant conserve le nom déclaré.
5. Tests, contrôles shell et validations OpenSpec réussissent.
