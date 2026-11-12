# zsh-sshhvp1 Specification

## Purpose
Définir le raccourci Zsh de lancement graphique distant demandé pour hvp1.

## Requirements

### Requirement: Alias sshhvp1
La configuration Zsh DIU SHALL proposer un alias sshhvp1 qui prépare l’autorisation X11 depuis /run/user/1000, ouvre SSH X11 en arrière-plan sans multiplexage vers root@hvp1 avec ExitOnForwardFailure=yes, et lance /usr/bin/chatgpt sous ade avec les variables demandées. Les sorties standard et erreur de SSH SHALL être redirigées vers /dev/null. Les définitions personnelles existantes SHALL être préservées.
#### Scenario: Utilisation du raccourci
- **WHEN** l’utilisateur invoque sshhvp1
- **THEN** DIU exécute le parcours SSH X11 en arrière-plan et le lancement distant demandés avec contrôle du transfert
- **AND** les paramètres positionnels du shell interactif restent inchangés
#### Scenario: Alias personnel existant
- **WHEN** sshhvp1 est déjà défini par l’utilisateur
- **THEN** la configuration DIU ne remplace pas cet alias
