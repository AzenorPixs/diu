## MODIFIED Requirements

### Requirement: Commande générique et activation

DIU SHALL accepter rid projects build debian <ID PROJECT> et son alias compatible
rid projects build deb <ID PROJECT> pour un enfant direct non symbolique de
ENV_DEVOPS_PROJECTS_ROOT. Il SHALL lire PROJECT_DEBIAN_PACKAGE sans exécuter
project.env et SHALL construire uniquement pour Yes, YES ou 1.

#### Scenario: Projet désactivé
- **WHEN** la variable est absente, vide ou différente des trois valeurs actives
- **THEN** la commande informe que le projet ne produit aucun paquet Debian, réussit sans construction et ne recherche pas la recette

#### Scenario: Arguments invalides
- **WHEN** l'identifiant manque, est invalide ou des arguments supplémentaires sont fournis
- **THEN** la commande échoue avec une aide avant le bootstrap

#### Scenario: deux syntaxes équivalentes
- **WHEN** debian ou deb est utilisé avec le même identifiant de projet
- **THEN** le même moteur reçoit les mêmes arguments et produit le même paquet
