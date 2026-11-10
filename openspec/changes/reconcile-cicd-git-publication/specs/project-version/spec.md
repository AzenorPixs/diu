## MODIFIED Requirements

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

### Requirement: Rejeu isolé d'une version attribuée
Le CI/CD SHALL poursuivre le rejeu d'une version attribuée à partir du commit du tag, sans créer de commit vide ni modifier le tag local ou les modifications locales en attente.

#### Scenario: Version existante et arbre modifié
- **WHEN** la version est déjà attribuée et des modifications locales sont présentes
- **THEN** les étapes de construction et de publication utilisent le commit du tag dans un contexte isolé
- **AND THEN** les modifications locales restent disponibles et ne sont pas livrées sous cette version
