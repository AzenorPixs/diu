## MODIFIED Requirements

### Requirement: Nettoyage de la configuration historique

Le DIU SHALL appeler `config_cleanup` de
`modules/system/variables-cleanup.sh` avant de sourcer
`/root/diu/variables.sh`. La fonction SHALL supprimer les affectations simples
de `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE`, `PROXY_CA`,
`PROXY` et `DRIVERS_NVIDIA`, sans exposer leur valeur ni altérer les autres
lignes. Pour `PROXY` et `DRIVERS_NVIDIA`, elle SHALL migrer `0` ou `1` vers
leur nouveau nom système si celui-ci n’est pas déclaré. Elle SHALL accepter un
chemin optionnel ; le défaut est `/root/diu/variables.sh`.

#### Scenario: Anciennes déclarations présentes

- **WHEN** le fichier contient une ou plusieurs affectations de
  `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE`, `PROXY_CA`,
  `PROXY` ou `DRIVERS_NVIDIA`
- **THEN** les affectations historiques SHALL être supprimées avant le
  chargement
- **AND** les dernières valeurs littérales `PROXY=0|1` et
  `DRIVERS_NVIDIA=0|1` SHALL être persistées sous leurs nouveaux noms
  respectifs lorsqu’aucune déclaration correspondante n’existe dans
  `system.env`
- **AND** les nouveaux noms, noms voisins, commentaires et autres variables
  SHALL être conservés

#### Scenario: Absence et répétition

- **WHEN** le fichier ou une déclaration à supprimer est absent, ou le
  nettoyage est répété
- **THEN** le nettoyage SHALL réussir sans réécrire le fichier

#### Scenario: Erreur de lecture ou écriture

- **WHEN** une lecture ou suppression échoue, ou une affectation historique
  `PROXY` ou `DRIVERS_NVIDIA` ne respecte pas le format littéral simple `0`
  ou `1`
- **THEN** le nettoyage SHALL retourner un code non nul avec un diagnostic
  sur stderr sans contenu de configuration
- **AND** le démarrage SHALL NOT poursuivre le chargement de la configuration
