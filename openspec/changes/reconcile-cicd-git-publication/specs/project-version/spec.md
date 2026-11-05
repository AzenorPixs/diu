## MODIFIED Requirements

### Requirement: Push Git cohérent
Les pushes Forgejo, GitHub et GitLab SHALL sélectionner v<VERSION> et vérifier qu'il désigne HEAD avant publication lorsque PROJECT_VERSION est déclarée. Hors CI/CD, ils SHALL conserver les branches, transports et protections existants et SHALL NOT créer ni remplacer un tag. Dans le CI/CD, le tag distant MAY être remplacé avec protection par SHA attendu selon projects-cicd ; le tag local reste inchangé.

#### Scenario: Tag prioritaire
- **WHEN** HEAD possède le tag déclaré ainsi que d'autres tags
- **THEN** seul le tag déclaré est sélectionné pour publication

#### Scenario: Tag manquant ou incorrect
- **WHEN** le tag déclaré est absent ou ne désigne pas HEAD
- **THEN** aucun push de branche ni de tag n'est exécuté

### Requirement: Rejeu isolé d'une version attribuée
Le CI/CD SHALL poursuivre le rejeu d'une version attribuée à partir du commit du tag, sans créer de commit vide ni modifier le tag local ou les modifications locales en attente.

#### Scenario: Version existante et arbre modifié
- **WHEN** la version est déjà attribuée et des modifications locales sont présentes
- **THEN** les étapes de construction et de publication utilisent le commit du tag dans un contexte isolé
- **AND THEN** les modifications locales restent disponibles et ne sont pas livrées sous cette version
