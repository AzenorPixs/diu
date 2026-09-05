# legacy-variable-cleanup Specification

## Purpose
Retirer de manière idempotente la déclaration historique de distribution avant le chargement de la configuration et utiliser SYSTEM_DEBIAN_RELEASE dans les consommateurs du DIU.

## Requirements

### Requirement: Nettoyage de la configuration historique

Le DIU SHALL fournir config_cleanup dans `modules/system/variables-cleanup.sh`, appelée avant le chargement de /root/diu/variables.sh. Elle SHALL supprimer les lignes d’affectation simple de DEBIAN_RELEASE, avec espaces initiaux et export optionnel, sans lire leur valeur dans les journaux et sans affecter les autres lignes. Elle SHALL accepter un chemin optionnel pour les tests et utiliser /root/diu/variables.sh par défaut.

#### Scenario: Anciennes déclarations présentes

- **WHEN** le fichier contient une ou plusieurs affectations de DEBIAN_RELEASE
- **THEN** toutes ces affectations sont supprimées avant le chargement
- **AND** SYSTEM_DEBIAN_RELEASE, les noms voisins, commentaires et autres variables sont préservés

#### Scenario: Absence et répétition

- **WHEN** le fichier ou la déclaration est absent, ou le nettoyage est répété
- **THEN** le nettoyage réussit sans réécrire le fichier

#### Scenario: Erreur de lecture ou écriture

- **WHEN** une lecture ou suppression échoue
- **THEN** le nettoyage retourne un code non nul avec un diagnostic sur stderr sans contenu du fichier
- **AND** le démarrage ne poursuit pas le chargement de la configuration

### Requirement: Consommateurs migrés

Les consommateurs du projet SHALL utiliser SYSTEM_DEBIAN_RELEASE à la place de DEBIAN_RELEASE. Les mentions de l’ancien nom SHALL être limitées à la migration, sa documentation et ses tests. La valeur historique SHALL ne pas être transférée vers la nouvelle variable.

#### Scenario: Sélection de distribution

- **WHEN** une opération choisit un comportement selon la distribution Debian
- **THEN** elle utilise SYSTEM_DEBIAN_RELEASE selon la déclaration dynamique existante
