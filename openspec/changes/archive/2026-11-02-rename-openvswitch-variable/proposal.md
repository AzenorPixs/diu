# Renommer le contrôle Open vSwitch

## Pourquoi

Le point d’entrée consulte `OPENVSWITCH` sous `set -u`, mais cette variable ne
correspond pas au mécanisme déclaratif DIU.

## Changements

- Déclarer `SOFTWARES_APT_OPENVSWITCH` en `STATIC`, `ENABLE`, scope `softwares`,
  défaut `0`.
- Migrer exactement la dernière valeur littérale `OPENVSWITCH=0|1` vers
  `softwares.env`, sauf si la nouvelle variable y est déjà configurée.
- Utiliser le nouveau nom pour conserver l’installation APT existante de
  `openvswitch-switch`.
