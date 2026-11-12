## Purpose
Définir le raccourci Zsh de lancement graphique distant demandé pour hvp1.

## ADDED Requirements
### Requirement: Alias sshhvp1
La configuration Zsh DIU SHALL proposer un alias sshhvp1 qui prépare l’autorisation X11 depuis /run/user/1000, ouvre SSH X11 sans multiplexage vers root@hvp1 et lance /usr/bin/chatgpt sous ade avec les variables d’environnement demandées. Les définitions personnelles existantes SHALL être préservées.
#### Scenario: Utilisation du raccourci
- **WHEN** l’utilisateur invoque sshhvp1
- **THEN** DIU exécute le parcours SSH X11 et le lancement distant demandés
- **AND** les paramètres positionnels du shell interactif restent inchangés
#### Scenario: Alias personnel existant
- **WHEN** sshhvp1 est déjà défini par l’utilisateur
- **THEN** la configuration DIU ne remplace pas cet alias
