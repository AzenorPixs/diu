# projects-sync Specification

## Purpose
Permettre de remettre à jour de manière déterministe les ressources communes
d'un projet géré depuis le modèle local de l'utilisateur DevOps.

## Requirements

### Requirement: Commande de synchronisation d'un projet

DIU MUST accepter `diu projects sync <ID PROJECT>` pour synchroniser le
projet désigné depuis `/home/${ENV_DEVOPS_USER}/datas/template`. La commande MUST
refuser un identifiant absent, un projet destination absent, un fichier
`project.env` absent ou une configuration dont `PROJECT_ID` ne correspond pas
à l'identifiant demandé. Elle MUST obtenir `PROJECT_NAME` depuis cette
configuration et échouer si cette valeur est absente ou vide, avant toute
copie.

#### Scenario: Synchronisation d'un projet configuré

- **WHEN** l'utilisateur exécute `diu projects sync mon-projet` pour un
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
`/home/${ENV_DEVOPS_USER}/datas/template`, des fichiers `AGENTS.md`, `CODING_RULES.md` et
`.gitignore`. Une source conservée indisponible
ou de type incorrect MUST faire échouer la commande avec un code non nul
avant toute copie. Pour la synchronisation unitaire ou groupée, DIU MUST NOT
exiger `PROMPTS`, `DEVOPS.md`, les répertoires OpenCode du modèle ou la source CAB
`/home/devops/datas/cab/src`.

#### Scenario: Répertoire modèle indisponible

- **WHEN** le répertoire modèle n'est pas disponible
- **THEN** DIU échoue avec un code non nul avant toute copie

#### Scenario: Élément géré manquant du modèle

- **WHEN** AGENTS.md, CODING_RULES.md ou .gitignore est absent ou de type incorrect
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

### Requirement: Copie ciblée et autoritaire du modèle

DIU MUST synchroniser exclusivement AGENTS.md, CODING_RULES.md et .gitignore depuis le modèle,
en les écrasant. DIU MUST NOT consulter ni copier les autres fichiers du modèle
et MUST préserver les autres destinations. La création de `.cab-tests` suit les
règles spécifiques ci-dessous.

#### Scenario: Écrasement d'un élément géré

- **WHEN** un fichier géré existe déjà dans le projet destination
- **THEN** sa version issue du modèle devient la version présente après
  synchronisation, avec la personnalisation Markdown spécifiée

#### Scenario: Préservation d'un élément non géré

- **WHEN** le projet contient un élément hors de la sélection conservée
- **THEN** cet élément reste intact après la synchronisation

#### Scenario: Historique des évolutions absent ou présent

- **WHEN** CHANGELOG.md est absent ou présent dans le projet
- **THEN** la synchronisation ne le crée pas et préserve toute entrée existante
- **AND THEN** sa source dans le modèle n'est pas requise

#### Scenario: Dossiers non synchronisés

- **WHEN** `.git`, `.worktree` ou `output` est présent ou absent dans le projet
- **THEN** la synchronisation préserve toute entrée existante et ne crée pas ces dossiers
- **AND THEN** leurs sources dans le modèle ne sont pas requises

#### Scenario: Préservation du document d'environnement existant

- **WHEN** le projet destination possède un DEVOPS.md
- **THEN** son contenu, ses droits et son propriétaire restent inchangés

#### Scenario: Absence de création du document d'environnement

- **WHEN** le projet destination ne possède aucun DEVOPS.md
- **THEN** la synchronisation n'en crée pas, même si le modèle en contient un

#### Scenario: Copie du protocole pour un projet piloté

- **WHEN** la synchronisation unitaire ou groupée concerne un projet dont le mode vaut Yes
- **THEN** ancien protocole local n'est pas requis dans le modèle et toute destination existante reste intacte

#### Scenario: Préservation du protocole pour un projet autonome

- **WHEN** la synchronisation unitaire ou groupée concerne un projet dont le mode vaut No ou est absent ou vide
- **THEN** ancien protocole local n'est pas requis dans le modèle et toute destination existante reste intacte

### Requirement: Répertoire local de tests CAB

Pour chaque projet synchronisé, DIU MUST créer `.cab-tests` à la racine s'il
est absent, sans consulter ni copier son contenu depuis le modèle. Un dossier
existant et son contenu MUST rester inchangés. Un dossier nouvellement créé
MUST recevoir le propriétaire prévu pour le projet. Si la création ou
l'attribution du propriétaire échoue, la synchronisation MUST signaler l'échec
et retourner un code non nul ; les écritures précédentes restent en place.

#### Scenario: Dossier absent

- **WHEN** le projet valide ne contient pas `.cab-tests`
- **THEN** la synchronisation crée un dossier vide, y compris en mode groupé

#### Scenario: Dossier existant

- **WHEN** `.cab-tests` existe comme dossier et contient des données locales
- **THEN** son contenu, ses droits et son propriétaire restent inchangés

#### Scenario: Création impossible

- **WHEN** une entrée incompatible empêche la création de `.cab-tests`
- **THEN** la synchronisation signale l'erreur et retourne un code non nul

### Requirement: Préservation des prompts exclus

En mode unitaire ou groupé, DIU MUST NOT consulter la source PROMPTS du
modèle, ni copier, créer, personnaliser, supprimer ou modifier les droits
ou le propriétaire de PROMPTS dans le projet destination.

#### Scenario: Préservation des prompts existants

- **WHEN** le projet destination possède un répertoire PROMPTS
- **THEN** la synchronisation unitaire ou groupée préserve son contenu et
  celui de ses descendants, leurs droits et leur propriétaire
- **AND THEN** aucun Markdown de ce répertoire n'est personnalisé

#### Scenario: Absence de création des prompts

- **WHEN** le projet destination ne possède aucun PROMPTS
- **THEN** la synchronisation unitaire ou groupée n'en crée pas, même si le
  modèle en contient un

### Requirement: Personnalisation des Markdown synchronisés

Pour chaque fichier `*.md` provenant des éléments synchronisés, DIU MUST
remplacer toutes les occurrences de `Template` par `PROJECT_NAME` et toutes
les occurrences de `template` par `PROJECT_ID`. DIU MUST NOT appliquer ces
transformations aux fichiers Markdown qui existaient déjà dans le projet et
ne proviennent pas de la synchronisation.

#### Scenario: Personnalisation d'un Markdown du modèle

- **WHEN** un fichier Markdown copié depuis le modèle contient `Template` et
  `template`
- **THEN** le fichier destination contient respectivement `PROJECT_NAME` et
  `PROJECT_ID`

#### Scenario: Markdown destination non géré

- **WHEN** un fichier Markdown existant du projet n'appartient pas aux
  éléments synchronisés
- **THEN** son contenu n'est pas transformé par la commande

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

### Requirement: Préservation de la carte de développement

DIU MUST NOT consulter, copier, créer ou modifier DEVELOPMENT_MAP.md pendant
la synchronisation unitaire ou groupée, quel que soit le mode de pilotage.
La source modèle n'est pas requise. Toute entrée existante à destination,
y compris un répertoire ou un lien symbolique, MUST rester intacte.

#### Scenario: Carte absente du projet

- **WHEN** la carte est absente du projet, que la source modèle existe ou non
- **THEN** la synchronisation ne crée pas de carte et peut réussir

#### Scenario: Carte existante

- **WHEN** une entrée DEVELOPMENT_MAP.md existe dans le projet
- **THEN** la synchronisation la préserve sans changement de contenu, droits ou propriétaire
