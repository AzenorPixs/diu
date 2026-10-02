## ADDED Requirements

### Requirement: Compte rendu des autorisations publiées
Après publication réussie, DIU SHALL afficher `Sudoers DevOps configuré pour
humain1 humain2.` avec les noms réellement inscrits dans le candidat validé,
séparés par un espace, dans l'ordre des règles et sans espace final. Une
sélection vide SHALL produire `Sudoers DevOps : aucun compte humain retenu.`.
Un échec ou un compte cible absent SHALL NOT produire de message de succès.
Un préfixe visuel MAY précéder ces messages.

#### Scenario: Plusieurs comptes autorisés
- **WHEN** le fragment est publié avec les règles pour alice puis bob
- **THEN** le message est Sudoers DevOps configuré pour alice bob.
- **AND** les comptes exclus ne sont pas affichés

#### Scenario: Aucun compte sélectionné
- **WHEN** le fragment commenté est publié sans autorisation
- **THEN** le message indique aucun compte humain retenu

#### Scenario: Publication impossible ou cible absente
- **WHEN** la génération échoue ou le compte cible est absent
- **THEN** le diagnostic correspondant est affiché sans message de succès
