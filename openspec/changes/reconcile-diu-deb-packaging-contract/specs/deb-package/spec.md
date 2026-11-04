## MODIFIED Requirements

### Requirement: Version du paquet

PROJECT_VERSION, lorsqu'elle est déclarée et valide, SHALL déterminer la version du paquet. Sinon la version SHALL être l'unique version Debian valide déduite des tags de HEAD après priorité des versions stables sur les horodatages, en retirant un préfixe v éventuel. Sans métadonnées Git ou sans tag, elle SHALL être l'horodatage local YYYY.MM.DD.HH.MM. Un tag inexploitable ou plusieurs versions distinctes après cette priorité SHALL provoquer un échec. Une erreur de consultation Git SHALL NOT être traitée comme une absence de tag.

#### Scenario: Version générée

WHEN aucun tag de HEAD n'est disponible
THEN le champ Version et le nom du paquet utilisent le même horodatage local YYYY.MM.DD.HH.MM
AND la version est affichée lors de la construction

#### Scenario: Version issue du tag

- **WHEN** HEAD possède v1.2.3 ou 1.2.3 comme unique version valide
- **THEN** le paquet utilise 1.2.3 ; des variantes équivalentes ne créent pas d’ambiguïté

#### Scenario: Versions de tags ambiguës

- **WHEN** HEAD possède plusieurs versions distinctes après application de la priorité stable ou un tag inexploitable
- **THEN** le build échoue avant publication et préserve dist/

#### Scenario: Tag stable et horodaté

- **WHEN** HEAD porte une seule version stable et un ou plusieurs tags horodatés
- **THEN** le constructeur retient la version stable

### Requirement: Commande rid proj deb

DIU SHALL accepter rid proj deb <project_id> et rid projects deb [project_id]. Sans identifiant, projects SHALL cibler diu. L'identifiant SHALL sélectionner un enfant direct de DEVOPS_PROJECTS_ROOT contenant les sources DIU requises, sans chemin ni lien symbolique. Le paquet SHALL rester nommé diu. Les arguments supplémentaires SHALL être refusés.

#### Scenario: Construction depuis la commande rid

WHEN l'utilisateur exécute `rid proj deb monprojet`
THEN le DIU valide que le projet `$DEVOPS_PROJECTS_ROOT/monprojet` existe
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

