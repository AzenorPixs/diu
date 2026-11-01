# legacy-variable-cleanup Specification

## Purpose
Retirer de manière idempotente les déclarations historiques de distribution, d'environnement, de DisplayLink et de fuseau horaire avant le chargement de la configuration. Utiliser SYSTEM_DEBIAN_RELEASE, SYSTEM_DEBIAN_ENVIRONNEMENT, SYSTEM_DRIVERS_DISPLAY_LINK et SYSTEM_TIME_ZONE dans les consommateurs du DIU.

## Requirements

### Requirement: Nettoyage de la configuration historique

Le DIU SHALL appeler `config_cleanup` de
`modules/system/variables-cleanup.sh` avant de sourcer
`/root/diu/variables.sh`. La fonction SHALL supprimer les affectations simples
de `DEBIAN_RELEASE`, `DEBIAN_TYPE`, `DISPLAY_LINK`, `TIME_ZONE`, `PROXY_CA`
et `PROXY`, sans exposer leur valeur ni altérer les autres lignes. Pour
`PROXY`, elle SHALL migrer `0` ou `1` vers `SYSTEM_PROXY` si ce nom est absent.
Elle SHALL accepter un chemin optionnel ; le défaut est
`/root/diu/variables.sh`.

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

### Requirement: Consommateurs migrés

Les consommateurs du projet SHALL utiliser SYSTEM_DEBIAN_RELEASE à la place de DEBIAN_RELEASE et SYSTEM_DEBIAN_ENVIRONNEMENT à la place de DEBIAN_TYPE et SYSTEM_DRIVERS_DISPLAY_LINK à la place de DISPLAY_LINK et SYSTEM_TIME_ZONE à la place de TIME_ZONE. Les mentions de l’ancien nom SHALL être limitées à la migration, sa documentation et ses tests. La valeur historique SHALL ne pas être transférée vers la nouvelle variable.

#### Scenario: Sélection de distribution

- **WHEN** une opération choisit un comportement selon la distribution Debian
- **THEN** elle utilise SYSTEM_DEBIAN_RELEASE selon la déclaration dynamique existante

#### Scenario: Sélection de l’environnement

- **WHEN** une opération choisit un comportement selon le type d’environnement
- **THEN** elle utilise SYSTEM_DEBIAN_ENVIRONNEMENT selon sa déclaration dynamique
- **AND** les branches existantes LXC, PHYSICAL, PROXMOX et VM sont conservées

#### Scenario: Préférence DisplayLink migrée
- **WHEN** une commande explicite DisplayLink valide son installation ou sa suppression
- **THEN** elle met à jour SYSTEM_DRIVERS_DISPLAY_LINK sans transférer la valeur historique
- **AND** le parcours historique ne consomme plus cette préférence pour installer automatiquement le pilote

#### Scenario: Fuseau horaire migré
- **WHEN** le parcours historique configure le fuseau horaire
- **THEN** il utilise SYSTEM_TIME_ZONE sans transférer TIME_ZONE
