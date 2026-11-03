## MODIFIED Requirements

### Requirement: Cohérence de version et de Git
La publication SHALL appliquer le helper de version commun avec Forgejo. Le remote SHALL correspondre à la configuration et la branche locale attendue SHALL être courante. HEAD SHALL égaler la branche distante récupérée, sauf lors d'un rejeu isolé où il SHALL en être un ancêtre vérifié. Le tag existant SHALL désigner ce même HEAD et SHALL NOT être déplacé.

#### Scenario: Version prioritaire
- **WHEN** PROJECT_VERSION est déclarée
- **THEN** le paquet et le tag local attendu doivent lui correspondre

#### Scenario: Dépôt non synchronisé
- **WHEN** HEAD diffère de la branche distante hors rejeu isolé ou le tag distant désigne un autre commit
- **THEN** aucune release ni aucun asset n'est créé

#### Scenario: Rejeu d'un commit antérieur
- **WHEN** le rejeu isolé utilise un commit ancêtre de la branche distante et le tag distant désigne ce commit
- **THEN** la publication peut poursuivre sans modifier la branche distante
