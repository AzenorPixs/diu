## MODIFIED Requirements

### Requirement: Commande de synchronisation d'un projet

DIU MUST accepter `rid projects sync <ID PROJECT>` pour synchroniser le
projet désigné depuis `/home/${ENV_DEVOPS_USER}/datas/template`. La commande MUST
refuser un identifiant absent, un projet destination absent, un fichier
`project.env` absent ou une configuration dont `PROJECT_ID` ne correspond pas
à l'identifiant demandé. Elle MUST obtenir `PROJECT_NAME` depuis cette
configuration et échouer si cette valeur est absente ou vide, avant toute
copie.

#### Scenario: Synchronisation d'un projet configuré

- **WHEN** l'utilisateur exécute `rid projects sync mon-projet` pour un
  projet configuré valide
- **THEN** DIU synchronise les ressources gérées du modèle dans
  `mon-projet`

#### Scenario: Projet non configurable

- **WHEN** l'utilisateur exécute la commande pour un projet absent ou dont
  `project.env` est invalide
- **THEN** DIU échoue avec un code non nul
- **AND THEN** aucun élément de synchronisation n'est copié

### Requirement: Source de synchronisation contrôlée

Avant toute copie, DIU MUST vérifier l'existence du répertoire modèle
`/home/${ENV_DEVOPS_USER}/datas/template`, des fichiers `AGENTS.md` et
`.gitignore`. Une source conservée indisponible
ou de type incorrect MUST faire échouer la commande avec un code non nul
avant toute copie. Pour la synchronisation unitaire ou groupée, DIU MUST NOT
exiger `PROMPTS`, `DEVOPS.md`, les répertoires OpenCode du modèle ou la source CAB
`/home/devops/datas/cab/src`.

#### Scenario: Répertoire modèle indisponible

- **WHEN** le répertoire modèle n'est pas disponible
- **THEN** DIU échoue avec un code non nul avant toute copie

#### Scenario: Élément géré manquant du modèle

- **WHEN** AGENTS.md ou .gitignore est absent ou de type incorrect
- **THEN** DIU échoue avec un code non nul avant toute copie

#### Scenario: Modèle sans document d'environnement

- **WHEN** le modèle possède les éléments conservés mais aucun DEVOPS.md
- **THEN** la synchronisation unitaire ou groupée accepte ce modèle

#### Scenario: Modèle sans répertoire de prompts

- **WHEN** le modèle possède les éléments conservés mais PROMPTS est absent
  ou de type incorrect
- **THEN** la synchronisation unitaire ou groupée accepte ce modèle

#### Scenario: Sources OpenCode et CAB absentes

- **WHEN** les éléments conservés existent, les sources OpenCode du modèle
  sont absentes et la source CAB est indisponible
- **THEN** la synchronisation unitaire ou groupée peut réussir

### Requirement: Préservation des ressources OpenCode et CAB exclues

En mode unitaire ou groupé, DIU MUST NOT consulter les sources OpenCode/CAB
exclues, ni copier, créer, personnaliser, supprimer ou changer le contenu,
les droits ou le propriétaire des ressources projet
`.opencode/{commands,config,skills,broker}` ou du broker global
`/home/${ENV_DEVOPS_USER}/.opencode/broker`, caches `__pycache__` inclus.
Une destination absente MUST rester absente.

#### Scenario: Ressources exclues existantes

- **WHEN** les ressources OpenCode et CAB exclues existent dans un projet
  ou dans le broker global, avec des caches
- **THEN** la synchronisation unitaire ou groupée préserve leur contenu,
  leurs droits, leur propriétaire et leurs caches

#### Scenario: Ressources exclues absentes

- **WHEN** les ressources OpenCode et CAB exclues n'existent pas
- **THEN** la synchronisation unitaire ou groupée ne les crée pas

#### Scenario: Aucun projet valide pour la synchronisation groupée

- **WHEN** sync all ne trouve aucun projet valide
- **THEN** DIU conserve le message informatif et le code de succès existants
- **AND THEN** le broker global reste intact ou absent
