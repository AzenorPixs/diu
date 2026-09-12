## ADDED Requirements

### Requirement: Aide racine et contextuelle

DIU SHALL accepter `rid help`, `rid ?`, `rid <contexte> help` et
`rid <contexte> ?`. L'aide SHALL être disponible avant le chargement de la
configuration de production. Elle SHALL afficher les commandes immédiatement
disponibles au contexte demandé, chacune avec une description concise, et
SHALL utiliser un alignement lisible des descriptions.

#### Scenario: Aide d'un contexte intermédiaire

- **WHEN** l'utilisateur exécute `rid softwares help`
- **THEN** DIU affiche les commandes disponibles sous `rid softwares`, dont
  les commandes `install`, `remove`, `update` et `apt`
- **AND THEN** aucune configuration de production ni opération système n'est
  chargée ou exécutée

#### Scenario: Aide d'un contexte terminal

- **WHEN** l'utilisateur exécute `rid projects github push help`
- **THEN** DIU affiche la commande terminale correspondante et sa description
- **AND THEN** aucune opération de publication n'est exécutée

### Requirement: Erreur de routage contextuelle

Lorsqu'un chemin de commande contient un élément inconnu, DIU SHALL échouer
avec un code de retour non nul avant toute opération métier. Le diagnostic
SHALL identifier l'élément inconnu et proposer la commande `help` du dernier
contexte de routage reconnu. DIU SHALL NOT corriger ni exécuter implicitement
une autre commande.

#### Scenario: Élément inconnu à un niveau intermédiaire

- **WHEN** l'utilisateur exécute `rid softwares inconnu`
- **THEN** DIU échoue sans exécuter d'opération système
- **AND THEN** le diagnostic propose `rid softwares help`

#### Scenario: Élément inconnu à la racine

- **WHEN** l'utilisateur exécute `rid inconnu`
- **THEN** DIU échoue sans exécuter d'opération système
- **AND THEN** le diagnostic propose `rid help`

### Requirement: Retrait de l'usage global historique

DIU SHALL remplacer `display_usage()` par l'aide contextuelle. Aucun chemin de
routage ne SHALL appeler l'ancienne fonction d'usage global.

#### Scenario: Erreur de routage après migration

- **WHEN** une commande non reconnue atteint un gestionnaire de domaine
- **THEN** DIU affiche une aide contextuelle plutôt que l'usage global
