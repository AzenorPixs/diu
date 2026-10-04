## MODIFIED Requirements

### Requirement: Source de synchronisation contrôlée

Avant toute copie, DIU MUST vérifier l'existence du répertoire modèle
`/home/${DEVOPS_USER}/datas/template`, des fichiers `AGENTS.md` et
`.gitignore` et du répertoire `PROMPTS`. Une source conservée indisponible
ou de type incorrect MUST faire échouer la commande avec un code non nul
avant toute copie. Pour la synchronisation unitaire ou groupée, DIU MUST NOT
exiger `DEVOPS.md`, les répertoires OpenCode du modèle ou la source CAB
`/home/devops/datas/cab/src`.

#### Scenario: Répertoire modèle indisponible

- **WHEN** le répertoire modèle n'est pas disponible
- **THEN** DIU échoue avec un code non nul avant toute copie

#### Scenario: Élément géré manquant du modèle

- **WHEN** AGENTS.md, .gitignore ou PROMPTS est absent ou de type incorrect
- **THEN** DIU échoue avec un code non nul avant toute copie

#### Scenario: Modèle sans document d'environnement

- **WHEN** le modèle possède les éléments conservés mais aucun DEVOPS.md
- **THEN** la synchronisation unitaire ou groupée accepte ce modèle

#### Scenario: Sources OpenCode et CAB absentes

- **WHEN** les éléments conservés existent, les sources OpenCode du modèle
  sont absentes et la source CAB est indisponible
- **THEN** la synchronisation unitaire ou groupée peut réussir

### Requirement: Copie ciblée et autoritaire du modèle

Une synchronisation réussie MUST copier uniquement `AGENTS.md`,
`.gitignore` et le contenu récursif de `PROMPTS`. Pour chaque élément
copié dont une destination existe déjà, le contenu du modèle MUST l'écraser.
Les éléments destination hors de cette sélection MUST être préservés.
Pour la synchronisation unitaire ou groupée, DIU MUST NOT copier, créer,
personnaliser, supprimer ou changer les droits ou le propriétaire du fichier
`DEVOPS.md` à la racine du projet destination.

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

## ADDED Requirements

### Requirement: Préservation des ressources OpenCode et CAB exclues

Pour la synchronisation unitaire et groupée, DIU MUST NOT consulter les
sources OpenCode ou CAB exclues, ni copier, créer, personnaliser, supprimer
ou changer les droits ou le propriétaire des répertoires projet
`.opencode/commands`, `.opencode/config`, `.opencode/skills` et
`.opencode/broker`, de leur contenu ou du broker global
`/home/${DEVOPS_USER}/.opencode/broker`. Cette préservation MUST inclure
les caches `__pycache__`. L'absence de ces destinations MUST NOT provoquer
leur création.

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
