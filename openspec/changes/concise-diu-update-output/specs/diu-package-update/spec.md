## ADDED Requirements

### Requirement: Résultat synthétique de la mise à jour DIU

La commande SHALL signaler un résultat réussi avec une coche et masquer les détails techniques des opérations réussies. En cas d'échec, elle SHALL afficher les diagnostics utiles et retourner un état d'échec.

#### Scenario: Version déjà à jour
- **WHEN** aucune version explicite n'est demandée et le candidat n'est pas supérieur à la version installée
- **THEN** la commande affiche une coche et les versions installée et disponible sans installer le paquet

#### Scenario: Installation réussie
- **WHEN** le paquet sélectionné est vérifié et installé
- **THEN** la commande affiche une coche et les versions avant et après installation sans les détails de téléchargement ou de dpkg

#### Scenario: Échec d'une opération
- **WHEN** la sélection, le téléchargement, la vérification ou l'installation échoue
- **THEN** la commande affiche les diagnostics disponibles et retourne un échec

#### Scenario: Secours réussi
- **WHEN** GitHub échoue mais que le secours Forgejo réussit
- **THEN** les détails de l'échec de GitHub restent masqués et seul le résultat réussi est affiché
