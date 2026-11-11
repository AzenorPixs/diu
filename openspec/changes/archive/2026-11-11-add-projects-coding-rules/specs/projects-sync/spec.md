## MODIFIED Requirements

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

