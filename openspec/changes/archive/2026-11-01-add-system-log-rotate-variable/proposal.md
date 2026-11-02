# Déclaration modulaire de SYSTEM_LOG_ROTATE

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`LOG_ROTATE: unbound variable`. Le contrôle historique de logrotate n’est pas
déclaré dans le mécanisme modulaire.

## What Changes

- Déclarer `SYSTEM_LOG_ROTATE` en `STATIC`, `ENABLE`, scope `system`, défaut
  `0`.
- Remplacer le consommateur historique `LOG_ROTATE` dans le point d’entrée.
- Migrer la dernière valeur littérale historique `LOG_ROTATE=0|1` sans
  altération, sauf si `SYSTEM_LOG_ROTATE` est déjà configurée.
- Bloquer le nettoyage si l’ancienne affectation nécessite une interprétation
  shell.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

La valeur `LOG_ROTATE_DAILY` et le contenu existant du bloc logrotate ne sont
pas modifiés. Lorsque le drapeau est actif, le comportement actuel continue
d’écrire `/etc/logrotate.conf`.

## Critères d’acceptation

1. `SYSTEM_LOG_ROTATE=0` est persistée et exportée par défaut.
2. Une valeur historique simple `0` ou `1` est transférée exactement et la
   nouvelle déclaration garde la priorité.
3. Une affectation ambiguë bloque sans mutation ni exposition de contenu.
4. Le consommateur utilise `SYSTEM_LOG_ROTATE` avec un repli désactivé.
5. Tests, contrôles shell et validations OpenSpec réussissent.
