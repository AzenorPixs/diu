## MODIFIED Requirements

### Requirement: Cohérence de version et de Git
La publication SHALL appliquer le helper de version commun avec Forgejo. Le remote SHALL correspondre à la configuration et la branche locale attendue SHALL être courante. HEAD SHALL égaler la branche distante récupérée, sauf lors d'un rejeu isolé ou d'une branche réconciliée par le CI/CD où il SHALL en être un ancêtre vérifié. Le tag existant SHALL désigner ce même HEAD et SHALL NOT être déplacé.

#### Scenario: Version prioritaire
- **WHEN** PROJECT_VERSION est déclarée
- **THEN** le paquet et le tag local attendu doivent lui correspondre

#### Scenario: Dépôt non synchronisé
- **WHEN** HEAD diffère de la branche distante hors rejeu isolé et hors réconciliation CI/CD ou le tag distant désigne un autre commit
- **THEN** aucune release ni aucun asset n'est créé

#### Scenario: Rejeu d'un commit antérieur
- **WHEN** le rejeu isolé utilise un commit ancêtre de la branche distante et le tag distant désigne ce commit
- **THEN** la publication peut poursuivre sans modifier la branche distante

### Requirement: Protection des releases existantes
Une release existante SHALL être conservée sans remplacement d'asset ni suppression. Un asset attendu déjà présent SHALL être indiqué comme présent avec cohérence du contenu non vérifiée. Un asset attendu absent MAY être ajouté à une release cohérente. Un tag absent MAY être créé sur HEAD après vérification des conditions, comme Forgejo.

#### Scenario: Release déjà présente
- **WHEN** une release et son asset attendu existent pour le tag de version cohérent
- **THEN** la commande indique que l'asset est présent sans prétendre vérifier son contenu et sans POST de release ou d'asset

#### Scenario: Release incomplète
- **WHEN** une release cohérente existe mais ne contient pas l'asset attendu
- **THEN** la commande peut ajouter cet asset sans remplacer les autres

#### Scenario: Tag absent
- **WHEN** le tag distant est absent et HEAD est synchronisé
- **THEN** le tag puis la release sont créés sur ce HEAD, sans écrasement concurrent
