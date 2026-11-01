## MODIFIED Requirements

### Requirement: Nettoyage de la configuration historique

Le DIU SHALL fournir `config_cleanup` dans
`modules/system/variables-cleanup.sh`, appelée avant le chargement de
`/root/diu/variables.sh`. Elle SHALL supprimer les affectations historiques
simples de `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE`,
`PROXY_CA` et `PROXY`, avec espaces initiaux et `export` optionnel, sans
afficher leur valeur ni affecter les autres lignes. Pour `PROXY`, elle SHALL
transférer la dernière valeur littérale `0` ou `1` vers
`/root/diu/config/system.env` uniquement si `SYSTEM_PROXY` n’y est pas déjà
déclarée ; une forme non littérale ou ambiguë SHALL échouer sans mutation.
Elle SHALL accepter un chemin optionnel pour les tests et utiliser
`/root/diu/variables.sh` par défaut.

#### Scenario: Anciennes déclarations présentes

- **WHEN** le fichier contient une ou plusieurs affectations de
  `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE`, `PROXY_CA`
  ou `PROXY`
- **THEN** les affectations historiques SHALL être supprimées avant le
  chargement
- **AND** si `PROXY` est affectée uniquement par des valeurs littérales
  `0` ou `1`, sa dernière valeur SHALL être persistée dans `SYSTEM_PROXY`
  avant sa suppression, sauf si `system.env` déclare déjà `SYSTEM_PROXY`
- **AND** les nouveaux noms, noms voisins, commentaires et autres variables
  SHALL être conservés

#### Scenario: Absence et répétition

- **WHEN** le fichier ou une déclaration à supprimer est absent, ou le
  nettoyage est répété
- **THEN** le nettoyage SHALL réussir sans réécrire le fichier

#### Scenario: Erreur de lecture ou écriture

- **WHEN** une lecture ou suppression échoue, ou qu’une affectation `PROXY`
  ne respecte pas le format littéral simple `0` ou `1`
- **THEN** le nettoyage SHALL retourner un code non nul avec un diagnostic
  sur stderr sans contenu de configuration
- **AND** le démarrage SHALL NOT poursuivre le chargement de la configuration

