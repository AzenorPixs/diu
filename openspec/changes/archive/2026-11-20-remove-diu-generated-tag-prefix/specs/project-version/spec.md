## MODIFIED Requirements

### Requirement: Commits et traitements groupés
Les commits et CICD SHALL utiliser le tag VERSION sans préfixe lorsque PROJECT_VERSION est déclarée. Leur nom automatique SHALL utiliser VERSION et une description explicite SHALL rester utilisable. La version SHALL être relue pour chaque projet sans fuite entre projets.

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
- **THEN** une version x.y.z ou x.y.z.w sans zéro initial est acceptée et le commit et son tag VERSION sont préparés avant publication

#### Scenario: Version à quatre composants supérieure
- **WHEN** un push ou une CI/CD compare le tag demandé 1.2.3.4 à un tag distant stable v1.2.3.5
- **THEN** la version distante supérieure bloque la publication de branche et de tag
- **AND** les versions stables à trois ou quatre composants sont comparées par ordre de version

#### Scenario: Version omise
- **WHEN** un push direct ne reçoit pas de version, même si PROJECT_VERSION est définie
- **THEN** le tag AAAA.MM.JJ.HH.MM est sélectionné pour le commit et la publication
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

## ADDED Requirements

### Requirement: Tags projet sans préfixe
DIU SHALL utiliser des noms sans v initial pour les tags projet nouvellement créés ou envoyés. DIU SHALL refuser un tag explicite préfixé avant écriture. Les tags historiques restent lisibles et leur version reste protégée lors des contrôles d’attribution.

#### Scenario: Tag historique déjà attribué
- **WHEN** une version demandée existe déjà sous la forme historique v<VERSION>
- **THEN** son commit est vérifié et un tag de même version ne peut désigner un autre commit
- **AND** la référence historique est conservée

#### Scenario: Publication sans préfixe
- **WHEN** le DIU publie le tag d'un projet ou crée une release
- **THEN** le nom envoyé ne commence pas par v
