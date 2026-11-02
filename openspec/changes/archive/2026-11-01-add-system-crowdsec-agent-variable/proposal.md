# Déclaration modulaire de SYSTEM_CROWDSEC_AGENT

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`CROWDSEC_AGENT: unbound variable`. Le contrôle de l’agent CrowdSec n’est pas
déclaré dans le mécanisme modulaire.

## What Changes

- Déclarer `SYSTEM_CROWDSEC_AGENT` en `STATIC`, `ENABLE`, scope `system`,
  défaut `0`.
- Remplacer le consommateur historique `CROWDSEC_AGENT`.
- Migrer la dernière valeur littérale historique `CROWDSEC_AGENT=0|1` sans
  altération, sauf si `SYSTEM_CROWDSEC_AGENT` est déjà configurée.
- Refuser les formes qui nécessitent une interprétation shell.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Les traitements CrowdSec et bouncer existants ainsi que les variables
distinctes `CROWDSEC_BOUNCER` et `CROWDSEC_BOUNCER_API_KEY` ne sont pas modifiés.

## Critères d’acceptation

1. `SYSTEM_CROWDSEC_AGENT=0` est persistée et exportée par défaut.
2. Une valeur historique simple `0` ou `1` est transférée exactement, avec
   priorité à une valeur nouvelle déjà présente.
3. Une affectation ambiguë bloque sans mutation ni exposition de son contenu.
4. Le consommateur utilise le nouveau nom et garde un repli désactivé.
5. Tests, contrôles shell et validations OpenSpec réussissent.
