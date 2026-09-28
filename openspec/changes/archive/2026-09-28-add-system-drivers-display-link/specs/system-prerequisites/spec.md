## MODIFIED Requirements

### Requirement: Ordre dans le sous-module des prérequis

Dans `system_apt_update`, la fonction SHALL rester appelée après la mise à
jour des dépôts APT officiels et non officiels et le nettoyage APT.
Le parcours historique sans argument SHALL appeler la même fonction à la
place de ses listes générales, avant sa configuration APT.
Le bloc DisplayLink SHALL rester inchangé dans le monolithe, réservé à
PHYSICAL et conditionné par `SYSTEM_DRIVERS_DISPLAY_LINK=1` ; la fonction commune SHALL NOT
installer les paquets DisplayLink.

#### Scenario: Préparation des prérequis

- **WHEN** la mise à jour système est exécutée
- **THEN** les index, la transaction APT et le nettoyage sont terminés avant l'installation des prérequis

#### Scenario: Installation historique

- **WHEN** le parcours sans argument atteint son bloc de prérequis
- **THEN** il appelle system_install_prerequisites avant sa configuration APT
- **AND** il n'utilise plus aptitude comme témoin de toute la liste

#### Scenario: DisplayLink conservé

- **WHEN** le parcours historique s'exécute en PHYSICAL avec SYSTEM_DRIVERS_DISPLAY_LINK=1
- **THEN** après les prérequis communs, le bloc DisplayLink existant contrôle evdi-dkms et conserve son installation groupée

