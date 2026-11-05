## MODIFIED Requirements

### Requirement: Commande rid proj deb

DIU SHALL accepter rid proj deb <project_id> et rid projects deb [project_id]. Sans identifiant, projects SHALL cibler diu. L'identifiant SHALL sélectionner un enfant direct de ENV_DEVOPS_PROJECTS_ROOT contenant les sources DIU requises, sans chemin ni lien symbolique. Le paquet SHALL rester nommé diu. Les arguments supplémentaires SHALL être refusés.

#### Scenario: Construction depuis la commande rid

WHEN l'utilisateur exécute `rid proj deb monprojet`
THEN le DIU valide que le projet `$ENV_DEVOPS_PROJECTS_ROOT/monprojet` existe
AND le DIU valide que le projet contient les éléments requis pour le packaging
AND le DIU vérifie les prérequis de construction
AND le DIU construit le paquet Debian dans `dist/` du projet

#### Scenario: Projet inexistant

WHEN l'utilisateur exécute `rid proj deb projetinexistant`
THEN un message d'erreur indique que le projet n'existe pas
AND le DIU se termine avec le code 1
#### Scenario: Projet par défaut

- **WHEN** rid projects deb est demandé
- **THEN** le projet diu est construit sans modifier cicddiu

#### Scenario: Cache deb absent

- **WHEN** le projet contient le script principal, lib/ et modules/ mais pas deb/
- **THEN** la construction est permise sans lire ni créer ce cache

#### Scenario: Identifiant ou chemin invalide

- **WHEN** l'identifiant est vide, un chemin, un lien symbolique ou sort de la racine
- **THEN** la commande échoue sans écriture ni construction
