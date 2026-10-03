## MODIFIED Requirements

### Requirement: Génération finale lors de la création

Après la préparation, la personnalisation et l'attribution des droits du
projet, create_project SHALL appeler projects_template_openspec puis
projects_template_devops avec l'identifiant du nouveau projet avant son message
final de succès. La copie SHALL exclure le pyproject.toml racine du modèle si
PROJECT_TYPE est différent de PYTHON ou absent ; un projet Python MAY conserver
le manifeste copié. Si une opération finale échoue, create_project SHALL rendre
un code non nul, signaler cet échec et conserver le projet déjà préparé. Un
échec OpenSpec SHALL empêcher l'appel DevOps et le message final de succès.

#### Scenario: Création réussie

- **WHEN** la préparation et les deux opérations finales réussissent
- **THEN** OpenSpec puis DevOps sont appelés une seule fois avec le bon identifiant après l'attribution des droits
- **AND THEN** DEVOPS.md est actualisé avant le message de succès

#### Scenario: Création non Python depuis un modèle Python

- **WHEN** le modèle contient pyproject.toml et le nouveau projet est non Python
- **THEN** ce fichier racine n'est pas copié ni généré

#### Scenario: Échec OpenSpec final

- **WHEN** projects_template_openspec échoue
- **THEN** DevOps n'est pas appelé et la création signale l'échec sans message final de succès
- **AND THEN** le dossier préparé est conservé

#### Scenario: Échec de génération finale

- **WHEN** projects_template_devops échoue
- **THEN** la création signale l'échec sans message final de succès
- **AND THEN** le dossier préparé est conservé
