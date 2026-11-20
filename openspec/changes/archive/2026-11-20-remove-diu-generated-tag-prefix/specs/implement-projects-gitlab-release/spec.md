## ADDED Requirements

### Requirement: Tag GitLab sans préfixe
DIU SHALL exiger un tag Git sans v initial pour publier une release Debian GitLab.

#### Scenario: Seul un tag historique est présent
- **WHEN** la version ne dispose que d'un tag préfixé v sur HEAD
- **THEN** la publication GitLab est refusée avant création de la release
