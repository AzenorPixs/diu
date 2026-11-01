## MODIFIED Requirements

### Requirement: Nettoyage de la configuration historique

Le DIU SHALL fournir `config_cleanup` dans `modules/system/variables-cleanup.sh`, appelée avant le chargement de `/root/diu/variables.sh`. Elle SHALL supprimer les lignes d’affectation simple de `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE` ou `PROXY_CA`, avec espaces initiaux et `export` optionnel, sans afficher leur valeur ni affecter les autres lignes. Elle SHALL accepter un chemin optionnel pour les tests et utiliser `/root/diu/variables.sh` par défaut.

#### Scenario: Anciennes déclarations présentes

- **WHEN** le fichier contient une ou plusieurs affectations de `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE` ou `PROXY_CA`
- **THEN** toutes ces affectations SHALL être supprimées avant le chargement
- **AND** les nouveaux noms, noms voisins, commentaires et autres variables SHALL être conservés

#### Scenario: Absence et répétition

- **WHEN** le fichier ou une déclaration à supprimer est absent, ou le nettoyage est répété
- **THEN** le nettoyage SHALL réussir sans réécrire le fichier

#### Scenario: Erreur de lecture ou écriture

- **WHEN** une lecture ou suppression échoue
- **THEN** le nettoyage SHALL retourner un code non nul avec un diagnostic sur stderr sans contenu de configuration
- **AND** le démarrage SHALL NOT poursuivre le chargement de la configuration
