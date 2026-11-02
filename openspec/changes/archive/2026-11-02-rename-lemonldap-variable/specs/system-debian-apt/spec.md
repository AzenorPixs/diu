## ADDED Requirements

### Requirement: Repli du dépôt APT LemonLDAP depuis le réglage logiciel

`SYSTEM_APT_LEMONLDAP` SHALL rester le réglage système explicite du dépôt APT.
Si aucune source LemonLDAP n’est détectée et si `SYSTEM_APT_LEMONLDAP` n’est
pas déjà configurée, sa valeur initiale SHALL être activée lorsque
`SOFTWARES_APT_LEMONLDAP=1`.

#### Scenario: Installation logicielle active sans dépôt configuré

- **WHEN** aucune source LemonLDAP APT n’est détectée
- **AND** `SOFTWARES_APT_LEMONLDAP` vaut `1`
- **THEN** le DIU SHALL persister `SYSTEM_APT_LEMONLDAP=1` dans `system.env`

#### Scenario: Réglage système explicite prioritaire

- **WHEN** `SYSTEM_APT_LEMONLDAP` est déjà configurée
- **THEN** sa valeur SHALL rester prioritaire sur `SOFTWARES_APT_LEMONLDAP`
