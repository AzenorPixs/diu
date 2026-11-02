## MODIFIED Requirements

### Requirement: Version et construction locale

PROJECT_VERSION SHALL être prioritaire sur la version littérale de la recette. Sans cette clé, la recette MAY fournir une version ; sinon le moteur SHALL sélectionner l’unique version valide des tags de HEAD sans préfixe v, ou l’heure locale sans Git ou tag. Le moteur SHALL construire avec dpkg-deb --root-owner-group depuis les fichiers de travail.

#### Scenario: Version ambiguë
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** HEAD porte plusieurs versions distinctes, un tag invalide ou sa consultation échoue
- **THEN** la construction échoue sans modifier dist

#### Scenario: Publication réussie
- **WHEN** dpkg-deb réussit
- **THEN** dist reçoit package_version_architecture.deb et seuls les anciens paquets de même nom et architecture sont supprimés

#### Scenario: Construction échouée
- **WHEN** la préparation, la construction ou le déplacement échoue
- **THEN** la commande échoue, nettoie les temporaires et ne lance pas la rotation

