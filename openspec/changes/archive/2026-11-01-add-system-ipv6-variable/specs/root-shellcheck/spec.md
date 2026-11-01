## ADDED Requirements

### Requirement: Initialisation statique de SYSTEM_IPV6 depuis sysctl

Lorsque `SYSTEM_IPV6` et l’ancienne variable `IPv6` ne sont pas configurées,
le DIU SHALL initialiser `SYSTEM_IPV6` depuis l’état courant de sysctl, puis
persister la valeur détectée. Aucun défaut littéral IPv6 SHALL être imposé.

#### Scenario: Initialisation IPv6 sans valeur configurée

- **WHEN** aucune ancienne valeur `IPv6` ni nouvelle valeur `SYSTEM_IPV6`
  n’est configurée
- **THEN** l’initialisation statique de `SYSTEM_IPV6` SHALL refléter l’état de
  `net.ipv6.conf.all.disable_ipv6` lu par sysctl
- **AND** SHALL persister le réglage déduit sans imposer de valeur littérale
  par défaut

#### Scenario: Valeur IPv6 existante

- **WHEN** une valeur `SYSTEM_IPV6` existe dans la configuration ou est migrée
  depuis `IPv6`
- **THEN** elle SHALL rester prioritaire et sysctl SHALL ne pas la remplacer
