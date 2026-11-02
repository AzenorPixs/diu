# Déclaration modulaire de SOFTWARES_APT_APACHE2

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`APACHE2: unbound variable`. Le contrôle APT d’Apache2 n’est pas déclaré dans
le mécanisme modulaire.

## What Changes

- Déclarer `SOFTWARES_APT_APACHE2` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Remplacer le consommateur historique `APACHE2` dans le point d’entrée.
- Migrer la dernière valeur littérale historique `APACHE2=0|1` vers
  `softwares.env`, sauf si `SOFTWARES_APT_APACHE2` est déjà configurée.
- Bloquer le nettoyage si l’ancienne affectation nécessite une interprétation
  shell.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Les paquets Apache2 installés, le contenu des listes APT et les dépendances
installées quand le contrôle vaut `1` ne sont pas modifiés.

## Critères d’acceptation

1. `SOFTWARES_APT_APACHE2=0` est persistée et exportée par défaut.
2. Une valeur historique simple `0` ou `1` est transférée exactement dans
   `softwares.env`, avec priorité au nouveau nom.
3. Une affectation ambiguë bloque sans mutation ni exposition de son contenu.
4. Le consommateur utilise `SOFTWARES_APT_APACHE2` et garde un repli désactivé.
5. Tests, contrôles shell et validations OpenSpec réussissent.
