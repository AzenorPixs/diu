# Déclaration modulaire de SYSTEM_NO_SLEEP

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`NO_SLEEP: unbound variable`. Le contrôle historique de veille n’est pas
déclaré dans le mécanisme modulaire.

## What Changes

- Déclarer `SYSTEM_NO_SLEEP` en `STATIC`, `ENABLE`, scope `system`, défaut `0`.
- Remplacer le consommateur historique `NO_SLEEP` dans le point d’entrée.
- Migrer la dernière valeur littérale historique `NO_SLEEP=0|1` sans
  altération, sauf si `SYSTEM_NO_SLEEP` est déjà configurée.
- Bloquer le nettoyage si l’ancienne affectation nécessite une interprétation
  shell.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Les traitements systemd existants restent inchangés. Quand le réglage vaut
`0`, ce change n’efface pas un éventuel fichier `nosleep.conf` déjà créé.

## Critères d’acceptation

1. `SYSTEM_NO_SLEEP=0` est persistée et exportée par défaut.
2. Une ancienne valeur littérale `0` ou `1` est transférée exactement et la
   nouvelle déclaration garde la priorité.
3. Une affectation ambiguë bloque sans mutation ni exposition de son contenu.
4. Le consommateur utilise `SYSTEM_NO_SLEEP` avec un repli désactivé.
5. Tests, contrôles shell et validations OpenSpec réussissent.
