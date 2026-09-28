## MODIFIED Requirements

### Requirement: Ordre dans le sous-module des prérequis

Dans `system_apt_update`, la fonction SHALL rester appelée après la mise à
jour des dépôts APT officiels et non officiels et le nettoyage APT.
Le parcours historique sans argument SHALL appeler la même fonction à la
place de ses listes générales, avant sa configuration APT.
Le parcours historique et la fonction commune SHALL NOT installer DisplayLink ; seules les commandes explicites system drivers SHALL gérer ce pilote.

#### Scenario: Préparation des prérequis

- **WHEN** la mise à jour système est exécutée
- **THEN** les index, la transaction APT et le nettoyage sont terminés avant l'installation des prérequis

#### Scenario: Installation historique

- **WHEN** le parcours sans argument atteint son bloc de prérequis
- **THEN** il appelle system_install_prerequisites avant sa configuration APT
- **AND** il n'utilise plus aptitude comme témoin de toute la liste

#### Scenario: DisplayLink conservé

- **WHEN** le parcours historique s'exécute, quel que soit l'environnement ou la valeur statique DisplayLink
- **THEN** aucun paquet DisplayLink n'est installé automatiquement
