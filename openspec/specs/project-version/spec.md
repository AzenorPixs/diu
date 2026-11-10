# project-version Specification

## Purpose
Unifier la sélection prioritaire de version des projets pour Git, Debian et
Docker tout en préservant les mécanismes antérieurs en absence de configuration.

## Requirements

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
- **THEN** la commande n'effectue aucun nouveau commit sous cette version et ne remplace pas le tag
- **AND THEN** elle informe que la version est déjà attribuée

#### Scenario: Arbre inchangé
- **WHEN** aucune modification n'est à enregistrer et que le tag de la version demandée est absent
- **THEN** aucun commit vide n'est créé et le tag peut être créé sur HEAD
- **AND THEN** un push direct ou CI/CD applique la règle d’autorité des versions avant toute modification distante

#### Scenario: Tag déjà présent sur HEAD
- **WHEN** le tag de la version demandée désigne déjà HEAD
- **THEN** le traitement l'indique sans recréer ni déplacer le tag

### Requirement: Push Git cohérent
Les pushes individuels Forgejo, GitLab et GitHub SHALL préparer commit et tag selon la version explicite ou un horodatage, puis réutiliser la réconciliation CI/CD protégée. Le tag sélectionné SHALL désigner HEAD avant transport. La sélection SHALL NOT modifier PROJECT_VERSION ni déplacer un tag local. Les appels internes CI/CD et `forgejo push all` SHALL conserver leur comportement.

#### Scenario: Version explicite
- **WHEN** un push direct reçoit une version valide
- **THEN** la version doit être valide au format x.y.z sans zéro initial et le commit et son tag v<VERSION> sont préparés avant publication

#### Scenario: Version omise
- **WHEN** un push direct ne reçoit pas de version, même si PROJECT_VERSION est définie
- **THEN** le tag vAAAA.MM.JJ.HH.MM est sélectionné pour le commit et la publication
- **AND THEN** une collision de ce tag arrête la publication

#### Scenario: Collision
- **WHEN** une version explicite est déjà attribuée et des modifications locales sont en attente
- **THEN** le commit du tag est rejoué dans un contexte isolé et les modifications locales sont conservées
- **AND THEN** les références distantes divergentes sont réconciliées selon CI/CD avec protection par valeur attendue et résultat signalé

#### Scenario: CI/CD
- **WHEN** CI/CD appelle un fournisseur
- **THEN** son parcours de sélection et de publication existant est conservé

#### Scenario: Tag prioritaire
- **WHEN** le commit sélectionné possède plusieurs tags
- **THEN** seul le tag sélectionné pour cette commande est publié

#### Scenario: Tag manquant ou incorrect
- **WHEN** le tag requis par un appel interne est absent ou ne désigne pas HEAD
- **THEN** aucun push de branche ni de tag n'est exécuté

#### Scenario: Push groupé Forgejo
- **WHEN** la commande `forgejo push all` est utilisée
- **THEN** le parcours groupé existant est conservé

### Requirement: Publications des artefacts
Les publications Debian et Docker SHALL utiliser PROJECT_VERSION en priorité. Un paquet Debian SHALL correspondre à cette version. Une publication Docker SHALL utiliser l'image locale versionnée et vérifier le tag Git correspondant avant transport, sans retaguer implicitement une ancienne image latest.

#### Scenario: Image absente
- **WHEN** PROJECT_VERSION est déclarée mais son image locale versionnée est absente
- **THEN** la publication échoue sans substitution par latest

#### Scenario: Paquet incohérent
- **WHEN** le paquet Debian porte une autre version que PROJECT_VERSION
- **THEN** la publication est refusée avant upload

### Requirement: Priorité des versions stables
Les sélecteurs de version DIU SHALL privilégier les versions stables x.y.z sur les versions horodatées. La comparaison native Debian SHALL rester inchangée et aucun epoch ne SHALL être ajouté.

#### Scenario: Versions stable et horodatée disponibles
- **WHEN** une version stable et une version horodatée sont candidates
- **THEN** DIU sélectionne la version stable

### Requirement: Rejeu isolé d'une version attribuée
Le CI/CD SHALL poursuivre le rejeu d'une version attribuée à partir du commit du tag, sans créer de commit vide ni modifier le tag ou les modifications locales en attente.

#### Scenario: Version existante et arbre modifié
- **WHEN** la version est déjà attribuée et des modifications locales sont présentes
- **THEN** les étapes de construction et de publication utilisent le commit du tag dans un contexte isolé
- **AND THEN** les modifications locales restent disponibles et ne sont pas livrées sous cette version

### Requirement: Identifiants des pushes directs en rejeu
Avant de créer le clone d'un push direct GitHub ou GitLab rejouant un tag existant, DIU SHALL préparer les identifiants dans le projet source. Les identifiants existants SHALL être réutilisés sans nouvelle saisie et la préparation SHALL échouer explicitement en cas d'erreur. Les secrets SHALL rester hors des diagnostics.

#### Scenario: Identifiants déjà présents
- **WHEN** un tag existant est rejoué et que les identifiants du fournisseur sont présents et valides dans le projet source
- **THEN** le rejeu utilise ces identifiants sans demander leur saisie

#### Scenario: Identifiants absents
- **WHEN** les identifiants nécessaires à un push direct GitHub ou GitLab sont absents
- **THEN** leur initialisation éventuelle a lieu dans le projet source avant le clonage et reste disponible après nettoyage du clone

#### Scenario: Échec de préparation
- **WHEN** la préparation des identifiants échoue
- **THEN** aucun clone de rejeu ni transport Git n'est lancé

#### Scenario: Autres parcours
- **WHEN** le push direct concerne Forgejo ou que CI/CD exécute son parcours habituel
- **THEN** ces parcours conservent leur comportement existant

### Requirement: Autorité de la version sur les fournisseurs
Avant un push individuel Forgejo, GitLab ou GitHub ou un push CI/CD, DIU SHALL comparer le tag demandé aux tags distants et refuser toute publication si un tag distant est supérieur ou non comparable. Une version stable SHALL primer sur un horodatage. Si les tags distants sont égaux ou inférieurs, la branche et le tag demandés SHALL désigner le commit local sélectionné avec protection par SHA attendu. Les autres tags SHALL être conservés.

#### Scenario: Version distante supérieure
- **WHEN** un tag distant est supérieur au tag demandé
- **THEN** aucun push de branche ou de tag n'est effectué sur ce fournisseur

#### Scenario: Version distante égale ou inférieure
- **WHEN** tous les tags distants sont égaux ou inférieurs au tag demandé
- **THEN** la branche distante et le tag demandé sont alignés sur le commit sélectionné, même si leur historique diffère

#### Scenario: Version stable et horodatage
- **WHEN** un tag stable est comparé à un tag horodaté
- **THEN** la version stable est supérieure

#### Scenario: Tag non comparable
- **WHEN** un tag distant ou demandé ne peut être comparé aux formats stables et horodatés reconnus
- **THEN** la publication est refusée avec un diagnostic

#### Scenario: Modification concurrente
- **WHEN** la branche ou le tag ciblé change après sa lecture
- **THEN** le lease refuse son écrasement et l'erreur est signalée

#### Scenario: Fournisseur d'un push direct
- **WHEN** un fournisseur est indiqué dans la commande directe
- **THEN** seul ce fournisseur est publié
