## ADDED Requirements

### Requirement: Résultat commun de la mise à jour réseau

La mise à jour réseau SHALL exécuter le même parcours de reconstruction et de résultat que `system network hosts update`, une seule fois, et transmettre son statut.

#### Scenario: Mise à jour réseau réussie
- **WHEN** `system network update` reconstruit hosts avec succès
- **THEN** elle affiche la même ligne de succès que `system network hosts update` et retourne zéro

#### Scenario: Mise à jour réseau échouée
- **WHEN** la reconstruction de hosts échoue pendant `system network update`
- **THEN** elle affiche la même erreur que `system network hosts update` et retourne un code non nul

#### Scenario: Mise à jour système ou globale
- **WHEN** `system update` ou `update` exécute la mise à jour réseau
- **THEN** le résultat de reconstruction de hosts est affiché une seule fois et l'échec est propagé
