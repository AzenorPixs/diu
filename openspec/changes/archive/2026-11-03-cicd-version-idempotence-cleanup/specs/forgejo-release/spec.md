## MODIFIED Requirements

### Requirement: Vérification de l'existence de la Release

Avant création, la fonction SHALL vérifier si le tag `v<VERSION>` et la Release correspondante existent déjà sur Forgejo.

#### Scenario: Tag et Release inexistants
- **WHEN** le tag v<VERSION> n'existe pas sur Forgejo et aucune Release correspondante n'existe
- **THEN** la fonction continue vers la création de la Release

#### Scenario: Tag déjà existant
- **WHEN** le tag v<VERSION> existe déjà sur Forgejo et désigne HEAD
- **THEN** la fonction réutilise le tag sans le déplacer, le recréer ou le modifier

#### Scenario: Tag distant incohérent
- **WHEN** le tag v<VERSION> existe déjà sur Forgejo et désigne un autre commit
- **THEN** aucune publication n'est effectuée et le tag reste inchangé

#### Scenario: Release déjà existante
- **WHEN** une Release cohérente pour le tag v<VERSION> et son asset attendu existent déjà
- **THEN** la fonction indique que l'asset est déjà publié sans rien écraser ni modifier

#### Scenario: Release incomplète
- **WHEN** une Release cohérente existe sans l'asset attendu
- **THEN** la fonction peut ajouter cet asset sans remplacer les autres

### Requirement: Immutabilité des Releases

Une Release publiée SHALL être conservée. La fonction SHALL NOT écraser un asset ni supprimer automatiquement une Release ou un tag.

#### Scenario: Version déjà publiée
- **WHEN** une Release et l'asset attendu existent pour la version demandée
- **THEN** la fonction signale que la publication est déjà réalisée et ne modifie rien
