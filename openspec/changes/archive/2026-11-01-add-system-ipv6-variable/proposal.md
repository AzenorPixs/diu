# Déclaration modulaire de SYSTEM_IPV6

## Why

L’exécution de `root-install-debian.sh` dans CISMP s’arrête sur
`IPv6: unbound variable`. Le contrôle historique IPv6 n’est pas déclaré dans
le mécanisme modulaire.

## What Changes

- Déclarer `SYSTEM_IPV6` en `STATIC`, `ENABLE`, scope `system`.
- Lorsque la valeur est absente, lire l’état effectif avec
  `sysctl -n net.ipv6.conf.all.disable_ipv6`, en déduire l’état IPv6,
  persister la valeur et l’exporter.
- Remplacer le consommateur historique `IPv6` dans le point d’entrée.
- Migrer la dernière valeur littérale historique `IPv6=0|1` sans altération,
  sauf si `SYSTEM_IPV6` est déjà configurée.
- Réviser le contrat ShellCheck pour spécifier l’initialisation depuis l’état
  réel du noyau sans introduire de défaut littéral.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Non-Goals

Le traitement sysctl et le fichier `/etc/sysctl.d/70-disable-ipv6.conf`
restent inchangés. Le comportement de `GATEWAY` n’est pas modifié.

## Critères d’acceptation

1. La valeur initiale est calculée depuis `disable_ipv6` et persistée comme
   `SYSTEM_IPV6`.
2. Une ancienne valeur littérale `0` ou `1` est transférée exactement; une
   valeur nouvelle déjà présente est prioritaire.
3. Une sonde sysctl échouée ou invalide ne persiste ni n’exporte de valeur.
4. Une affectation historique ambiguë bloque le nettoyage sans mutation ni
   exposition de son contenu.
5. Le consommateur utilise `SYSTEM_IPV6` et conserve le traitement existant.
6. Tests ciblés, contrôles shell et validations OpenSpec réussissent.
