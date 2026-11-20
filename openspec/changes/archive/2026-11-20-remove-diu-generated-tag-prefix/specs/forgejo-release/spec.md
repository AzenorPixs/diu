## MODIFIED Requirements

### Requirement: Vérification de l'existence de la Release

Avant création, la fonction SHALL vérifier si le tag `VERSION` et la Release correspondante existent déjà sur Forgejo.

#### Scenario: Tag et Release inexistants
- **WHEN** le tag VERSION n'existe pas sur Forgejo et aucune Release correspondante n'existe
- **THEN** la fonction continue vers la création de la Release

#### Scenario: Tag déjà existant
- **WHEN** le tag VERSION existe déjà sur Forgejo et désigne HEAD
- **THEN** la fonction réutilise le tag sans le déplacer, le recréer ou le modifier

#### Scenario: Tag distant incohérent
- **WHEN** le tag VERSION existe déjà sur Forgejo et désigne un autre commit
- **THEN** aucune publication n'est effectuée et le tag reste inchangé

#### Scenario: Release déjà existante
- **WHEN** une Release cohérente pour le tag VERSION et son asset attendu existent déjà
- **THEN** la fonction indique que l'asset est présent, sans prétendre vérifier son contenu ni rien écraser

#### Scenario: Release incomplète
- **WHEN** une Release cohérente existe sans l'asset attendu
- **THEN** la fonction peut ajouter cet asset sans remplacer les autres

### Requirement: Création de la Release

La fonction SHALL créer la Release Forgejo par API REST avec le tag ciblant exactement HEAD déjà vérifié, les métadonnées et l’artefact décrits ci-dessous.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Release créée avec succès

WHEN toutes les vérifications préalables passent
AND le tag et la Release n'existent pas
THEN la fonction crée le tag VERSION pointant sur HEAD via l'API
AND la fonction crée la Release avec le tag, le titre et les notes
AND la fonction récupère l'identifiant de la Release créée

#### Scenario: Identité du commit et métadonnées de la Release

- **WHEN** la fonction crée une Release Forgejo
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

La fonction SHALL créer une Release Forgejo via l'API REST.

Le tag `VERSION` SHALL cibler exactement le commit HEAD. HEAD ayant
déjà été vérifié comme identique à `origin/main`, ou ancêtre en rejeu isolé ou après réconciliation CI/CD, le tag ne SHALL donc jamais pointer vers un commit différent de celui validé lors de ces contrôles.

La chaîne de vérification attendue est :

```
HEAD == origin/main (ou ancêtre en rejeu isolé ou après réconciliation CI/CD)
        ↓
tag VERSION
        ↓
Release DIU <VERSION>
        ↓
asset diu_<VERSION>_all.deb
```

La Release utilisera :

- Tag : `VERSION` ciblant exactement HEAD
- Titre : `DIU <VERSION>`
- Notes de Release : version, SHA du commit HEAD, message du dernier commit

### Requirement: Sélection cohérente de la version de release

La release SHALL appliquer PROJECT_VERSION en priorité lorsqu’elle est déclarée, sinon la sélection historique commune avec le builder. Sans clé ni tag, elle SHALL conserver la version du paquet sans nouvel horodatage. La version retenue SHALL égaler celle du paquet et le tag SHALL être VERSION, sans déplacement d’un tag existant.

#### Scenario: Release et paquet concordants

- **GIVEN** PROJECT_VERSION est absente de project.env

- **WHEN** une release est préparée
- **THEN** une version ambiguë, invalide ou différente du paquet arrête la publication ; aucun tag existant n’est déplacé
