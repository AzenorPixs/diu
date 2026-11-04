## ADDED Requirements

### Requirement: Génération du fichier hosts système

Le DIU SHALL fournir `system_network_hosts` dans `modules/system/network.sh`. Il SHALL reconstruire `/etc/hosts` avec localhost, les noms de la machine associés à la première interface admissible et les entrées IPv6 historiques. Une interface est admissible si son état est `UP`, son adresse est différente de `NONE` et suit la forme IPv4 historique. Les entrées préexistantes et Docker SHALL NOT être conservées automatiquement.

#### Scenario: Première interface admissible
- **WHEN** les deux interfaces sont admissibles
- **THEN** la première adresse est associée à `HOSTNAME_FQDN` et `HOSTNAME` dans le fichier reconstruit.

#### Scenario: Seconde interface admissible
- **WHEN** la première interface n'est pas admissible et la seconde l'est
- **THEN** la seconde adresse est associée aux noms de la machine.

#### Scenario: Aucune interface admissible
- **WHEN** aucune des deux interfaces n'est admissible
- **THEN** la ligne des noms de la machine est omise et les entrées de boucle locale et IPv6 sont présentes.

### Requirement: Commandes et intégration

Le DIU SHALL exposer les commandes `diu` et `rid` `system network hosts update` et `system network update`. Les mises à jour système et globale SHALL déclencher la génération par cette chaîne. L'installation SHALL utiliser la nouvelle fonction et l'ancienne fonction SHALL être retirée. Les aides SHALL décrire les commandes et la reconstruction du fichier.

#### Scenario: Mise à jour ciblée
- **WHEN** une commande `system network hosts update` est invoquée
- **THEN** elle reconstruit le fichier hosts.

#### Scenario: Mises à jour englobantes
- **WHEN** une commande `system network update`, `system update` ou `update` est invoquée
- **THEN** elle appelle la génération du fichier hosts par la chaîne prévue.
