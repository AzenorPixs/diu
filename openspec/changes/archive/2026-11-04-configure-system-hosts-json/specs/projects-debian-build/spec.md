## ADDED Requirements

### Requirement: Fichiers de configuration dans la recette Debian

Chaque copie MAY déclarer `conffile: true` pour inscrire sa destination dans `DEBIAN/conffiles` ; la source SHALL être un fichier régulier. Chaque copie MAY déclarer `empty_json: true` pour exiger un tableau JSON vide dans le fichier copié. Les contrôles SHALL précéder la publication du paquet.

#### Scenario: Conffile déclaré
- **WHEN** une copie de fichier valide déclare `conffile: true`
- **THEN** sa destination absolue est inscrite dans `DEBIAN/conffiles`.

#### Scenario: Modèle JSON non vide
- **WHEN** une copie déclarant `empty_json: true` ne contient pas un tableau JSON vide
- **THEN** la construction échoue sans remplacer le paquet précédent.

#### Scenario: Recette sans nouveaux attributs
- **WHEN** une recette existante ne déclare aucun de ces attributs
- **THEN** son comportement et sa validation restent inchangés.
