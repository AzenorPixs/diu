# projects-sync Specification

## Purpose
Permettre de remettre à jour de manière déterministe les ressources communes
d'un projet géré depuis le modèle local de l'utilisateur DevOps.

## Requirements

### Requirement: Commande de synchronisation d'un projet

DIU MUST accepter `rid projects sync <ID PROJECT>` pour synchroniser le
projet désigné depuis `/home/${DEVOPS_USER}/datas/template`. La commande MUST
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
`/home/${DEVOPS_USER}/datas/template`, des fichiers `AGENTS.md` et
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

### Requirement: Copie ciblée et autoritaire du modèle

DIU MUST écraser AGENTS.md et .gitignore depuis le modèle, et MUST NOT consulter ni copier ORCHESTRATED_CODING.md.
DIU MUST copier DEVELOPMENT_MAP.md uniquement si sa destination est absente,
selon les règles de copie initiale. DIU MUST préserver les autres destinations
et MUST NOT copier, créer, personnaliser, supprimer ou modifier les droits ou
le propriétaire de DEVOPS.md à la racine, en mode unitaire ou groupé.

#### Scenario: Écrasement d'un élément géré

- **WHEN** un fichier géré existe déjà dans le projet destination
- **THEN** sa version issue du modèle devient la version présente après
  synchronisation, avec la personnalisation Markdown spécifiée

#### Scenario: Préservation d'un élément non géré

- **WHEN** le projet contient un élément hors de la sélection conservée
- **THEN** cet élément reste intact après la synchronisation

#### Scenario: Préservation du document d'environnement existant

- **WHEN** le projet destination possède un DEVOPS.md
- **THEN** son contenu, ses droits et son propriétaire restent inchangés

#### Scenario: Absence de création du document d'environnement

- **WHEN** le projet destination ne possède aucun DEVOPS.md
- **THEN** la synchronisation n'en crée pas, même si le modèle en contient un

#### Scenario: Copie du protocole pour un projet piloté

- **WHEN** la synchronisation unitaire ou groupée concerne un projet dont le mode vaut Yes
- **THEN** ORCHESTRATED_CODING.md n'est pas requis dans le modèle et toute destination existante reste intacte

#### Scenario: Préservation du protocole pour un projet autonome

- **WHEN** la synchronisation unitaire ou groupée concerne un projet dont le mode vaut No ou est absent ou vide
- **THEN** ORCHESTRATED_CODING.md n'est pas requis dans le modèle et toute destination existante reste intacte

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
`/home/${DEVOPS_USER}/.opencode/broker`, caches `__pycache__` inclus.
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

### Requirement: Copie initiale de la carte de développement

DIU MUST copier DEVELOPMENT_MAP.md du modèle à la racine du projet seulement
si aucune entrée de ce nom n'existe à destination. Une entrée existante,
y compris répertoire ou lien symbolique pendant, MUST rester intacte sans
personnalisation ni changement de droits ou de propriétaire. Cette décision
MUST être indépendante de PROJECT_ORCHESTRATED_CODING et prise pour chaque
projet en mode unitaire ou groupé.

#### Scenario: Carte absente du projet

- **WHEN** la destination est absente et le modèle contient DEVELOPMENT_MAP.md
  comme fichier régulier
- **THEN** DIU copie ce document, personnalise Template et template selon
  les règles Markdown et applique le propriétaire des ressources synchronisées

#### Scenario: Carte existante préservée après réexécution

- **WHEN** une carte existe déjà et la synchronisation est exécutée ou répétée
- **THEN** le contenu, les droits, le propriétaire, l'inode et la date de
  modification restent inchangés
- **AND THEN** la source de cette carte n'est pas requise

#### Scenario: Entrée destination de type différent

- **WHEN** DEVELOPMENT_MAP.md désigne un répertoire ou un lien symbolique,
  y compris un lien pendant
- **THEN** DIU préserve cette entrée et ne copie pas la carte du modèle

### Requirement: Source conditionnelle de la carte de développement

Si DEVELOPMENT_MAP.md est absent à destination, DIU MUST vérifier que la source
modèle est un fichier régulier avant toute copie dans ce projet. Une source
absente ou de type incorrect MUST provoquer un diagnostic explicite et un code
non nul avant la copie des ressources du modèle. En mode groupé, cet échec
MUST préserver le parcours des autres projets selon projects-sync-all.

#### Scenario: Source absente ou incorrecte et carte à initialiser

- **WHEN** la carte destination est absente et la source est absente ou désigne
  un répertoire
- **THEN** la synchronisation échoue sans copier de ressource dans ce projet

#### Scenario: Synchronisation groupée avec états mixtes

- **WHEN** certains projets possèdent une carte et d'autres n'en possèdent pas
- **THEN** chaque carte existante est préservée et seules les cartes absentes
  sont initialisées depuis une source régulière disponible

#### Scenario: Échec conditionnel pendant le parcours groupé

- **WHEN** la source est absente et un projet sans carte précède un projet
  possédant déjà une carte
- **THEN** le premier projet échoue avant copie, le second peut être synchronisé
  et le parcours groupé retourne un code non nul
