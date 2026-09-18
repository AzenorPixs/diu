## ADDED Requirements

### Requirement: Synchronisation contrôlée des ressources CAB

Avant la copie CAB, DIU MUST vérifier que le répertoire
`/home/devops/datas/cab/src` existe et est un répertoire. Pour une
synchronisation valide, DIU MUST créer si nécessaire
`${DEVOPS_PROJECTS_ROOT}/<ID PROJECT>/.opencode/broker`, puis y copier
récursivement le contenu de la source CAB. Lorsqu'un fichier de même chemin
existe déjà dans la destination, la version source MUST l'écraser. Les
ressources destination absentes de la source MUST être préservées. Les
fichiers CAB, y compris les Markdown, MUST être copiés sans personnalisation.

#### Scenario: Copie CAB dans un projet configuré

- **WHEN** l'utilisateur synchronise un projet valide et que la source CAB
  contient une ressource
- **THEN** `.opencode/broker` est créé si nécessaire
- **AND THEN** la ressource source est présente dans cette destination

#### Scenario: Écrasement d'une ressource CAB gérée

- **WHEN** la source CAB et `.opencode/broker` contiennent un fichier au même
  chemin
- **THEN** le fichier destination contient la version issue de la source CAB

### Requirement: Exclusion des caches Python CAB

DIU MUST exclure de la copie tout répertoire source nommé `__pycache__` et
son contenu. DIU MUST supprimer
`${DEVOPS_PROJECTS_ROOT}/<ID PROJECT>/.opencode/broker/__pycache__` lorsqu'il
existe après la préparation de la destination.

#### Scenario: Cache Python source exclu et cache destination supprimé

- **WHEN** la source CAB contient un répertoire `__pycache__` et que la
  destination contient `.opencode/broker/__pycache__`
- **THEN** aucun fichier issu du cache source n'est présent dans la
  destination
- **AND THEN** le cache direct de la destination est absent

### Requirement: Synchronisation globale des ressources CAB

Avant la synchronisation globale, DIU MUST vérifier que le répertoire
`/home/devops/datas/cab/src` existe et est un répertoire. Pour une commande
`rid projects sync all` valide, DIU MUST créer si nécessaire
`/home/devops/.opencode/broker`, puis y copier récursivement le contenu de la
source CAB. Lorsqu'un fichier de même chemin existe déjà dans la destination,
la version source MUST l'écraser. Les ressources destination absentes de la
source MUST être préservées. Les fichiers CAB, y compris les Markdown, MUST
être copiés sans personnalisation.

#### Scenario: Copie CAB globale

- **WHEN** l'utilisateur exécute `rid projects sync all` et que la source CAB
  contient une ressource
- **THEN** `/home/devops/.opencode/broker` est créé si nécessaire
- **AND THEN** la ressource source est présente dans cette destination

#### Scenario: Écrasement d'une ressource CAB globale gérée

- **WHEN** la source CAB et `/home/devops/.opencode/broker` contiennent un
  fichier au même chemin
- **THEN** le fichier destination contient la version issue de la source CAB

### Requirement: Exclusion des caches Python CAB globaux

DIU MUST exclure de la copie globale tout répertoire source nommé
`__pycache__` et son contenu. DIU MUST supprimer
`/home/devops/.opencode/broker/__pycache__` lorsqu'il existe après la
préparation de la destination.

#### Scenario: Cache Python global source exclu et cache destination supprimé

- **WHEN** la source CAB contient un répertoire `__pycache__` et que la
  destination contient `/home/devops/.opencode/broker/__pycache__`
- **THEN** aucun fichier issu du cache source n'est présent dans la destination
- **AND THEN** le cache direct de la destination est absent
