# Version optionnelle des projets

## Purpose

Unifier la sélection prioritaire de version des projets pour Git, Debian et
Docker tout en préservant les mécanismes antérieurs en absence de configuration.

## ADDED Requirements

### Requirement: Lecture littérale et optionnelle
DIU SHALL lire uniquement PROJECT_VERSION dans project.env sans exécuter le fichier. Une affectation unique x.y.z, avec trois entiers sans zéro initial sauf 0 et au plus 128 caractères, SHALL être acceptée. Une clé présente invalide SHALL provoquer un échec explicite.

#### Scenario: Clé absente
- **WHEN** PROJECT_VERSION n'est pas déclarée
- **THEN** chaque opération conserve son mécanisme de sélection précédent

#### Scenario: Valeur ambiguë
- **WHEN** la clé est vide, dupliquée, invalide ou nécessite une interprétation
- **THEN** l'opération échoue sans repli silencieux et sans exposer d'autre variable

### Requirement: Commits et traitements groupés
Les commits et CICD SHALL utiliser le tag v<VERSION> lorsque PROJECT_VERSION est déclarée. Leur nom automatique SHALL utiliser VERSION et une description explicite SHALL rester utilisable. La version SHALL être relue pour chaque projet sans fuite entre projets.

#### Scenario: Collision
- **WHEN** un nouveau commit versionné est nécessaire et le tag existe déjà
- **THEN** la commande échoue avant création du commit, sans remplacer le tag

#### Scenario: Arbre inchangé
- **WHEN** aucune modification n'est à enregistrer
- **THEN** aucun commit vide ni nouveau tag n'est créé

### Requirement: Push Git cohérent
Les pushes Forgejo, GitHub et GitLab SHALL sélectionner v<VERSION> et vérifier qu'il désigne HEAD avant publication lorsque PROJECT_VERSION est déclarée. Ils SHALL conserver les branches, transports et protections existants et SHALL NOT créer ni remplacer un tag.

#### Scenario: Tag prioritaire
- **WHEN** HEAD possède le tag déclaré ainsi que d'autres tags
- **THEN** seul le tag déclaré est sélectionné pour publication

#### Scenario: Tag manquant ou incorrect
- **WHEN** le tag déclaré est absent ou ne désigne pas HEAD
- **THEN** aucun push de branche ni de tag n'est exécuté

### Requirement: Publications des artefacts
Les publications Debian et Docker SHALL utiliser PROJECT_VERSION en priorité. Un paquet Debian SHALL correspondre à cette version. Une publication Docker SHALL utiliser l'image locale versionnée et vérifier le tag Git correspondant avant transport, sans retaguer implicitement une ancienne image latest.

#### Scenario: Image absente
- **WHEN** PROJECT_VERSION est déclarée mais son image locale versionnée est absente
- **THEN** la publication échoue sans substitution par latest

#### Scenario: Paquet incohérent
- **WHEN** le paquet Debian porte une autre version que PROJECT_VERSION
- **THEN** la publication est refusée avant upload
