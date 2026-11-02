# Déclaration modulaire de DOCKER_STACK_TRAEFIK_DOCKHAND

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`DOCKER_STACK_TRAEFIK_DOCKHAND: unbound variable`. Le nom est déjà explicite
et préfixé par son scope Docker, mais aucune déclaration modulaire ne le
fournit.

## What Changes

- Déclarer `DOCKER_STACK_TRAEFIK_DOCKHAND` en `STATIC`, `ENABLE`, scope
  `docker`, défaut `0`.
- Conserver le nom et les consommateurs existants.
- Préserver une valeur déjà fournie par l’environnement ou la configuration
  Docker; persister le défaut seulement si aucune valeur n’existe.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Les variables distinctes `DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN`,
`DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE` et les traitements de la stack ne sont
pas modifiés.

## Critères d’acceptation

1. La valeur absente initialise et persiste `DOCKER_STACK_TRAEFIK_DOCKHAND=0`.
2. Une valeur existante `0` ou `1` est conservée.
3. Une valeur préconfigurée invalide bloque avec un diagnostic.
4. Les consommateurs existants utilisent toujours le nom déclaré.
5. Tests, contrôles shell et validations OpenSpec réussissent.
