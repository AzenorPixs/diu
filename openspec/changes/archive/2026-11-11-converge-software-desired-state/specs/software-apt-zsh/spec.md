# Spec Delta

## MODIFIED Requirements

### Requirement: Déclaration statique de SOFTWARES_APT_ZSH

DIU SHALL déclarer `SOFTWARE_APT_ZSH` dans le scope `softwares`, migrer la valeur existante avant de désactiver l'ancienne déclaration GLOBAL et initialiser la nouvelle valeur depuis l'état réel uniquement en l'absence de valeur récupérable. Les valeurs non binaires SHALL provoquer une erreur explicite.

#### Scenario: Initialisation de la valeur absente

- **WHEN** aucune valeur nouvelle ou ancienne n'est disponible et que l'état réel est déterminable
- **THEN** DIU initialise et persiste `SOFTWARE_APT_ZSH` à partir de cet état réel

#### Scenario: Valeur préconfigurée valide ou invalide

- **WHEN** la valeur cible ou la valeur ancienne migrable vaut `0` ou `1`
- **THEN** DIU conserve cette valeur et la rend disponible sous le nouveau nom
- **WHEN** une valeur nécessaire à la migration est invalide ou ambiguë
- **THEN** DIU refuse la migration et signale l'erreur

### Requirement: Consommateur Zsh renommé

Le point d’entrée SHALL utiliser `SOFTWARE_APT_ZSH` à la place de `ZSH`. Une
valeur absente SHALL être traitée comme `0`. Une valeur `1` SHALL conserver
l’installation de Zsh, Fish et des outils associés, ainsi que la configuration
des shells.

#### Scenario: Zsh désactivé ou absent

- **WHEN** la variable est absente ou vaut `0`
- **THEN** le bloc d’installation et de configuration SHALL être ignoré sans
  erreur de variable non définie

#### Scenario: Zsh activé

- **WHEN** la variable vaut `1`
- **THEN** le DIU SHALL conserver les installations APT et la configuration
  Zsh/Fish existantes

## ADDED Requirements

### Requirement: Préservation de la configuration Zsh
DIU SHALL conserver le contenu existant de `/root/.zshrc`, y maintenir uniquement un bloc identifié pour les extensions Zsh et SHALL NOT y recopier les clés API. Il SHALL préserver un shell root personnalisé autre que Bash ou Zsh.

#### Scenario: Configuration existante
- **WHEN** la configuration Zsh est convergée
- **THEN** les lignes extérieures au bloc DIU restent présentes et aucune clé API n'est recopiée

#### Scenario: Shell root personnalisé
- **WHEN** le shell root est différent de Bash et de Zsh
- **THEN** DIU ne le remplace pas automatiquement et signale l'écart

### Requirement: Retrait Zsh sans casser les comptes
DIU SHALL refuser le retrait automatique si un autre compte utilise Zsh. Si root utilise Zsh et qu'aucun autre compte ne l'utilise, DIU SHALL vérifier le retour à Bash avant la désinstallation.

#### Scenario: Autre compte utilisant Zsh
- **WHEN** un compte autre que root utilise Zsh comme shell
- **THEN** DIU refuse le retrait automatique sans modifier les comptes

#### Scenario: Root utilise Zsh
- **WHEN** seul root utilise Zsh et que son retrait est demandé
- **THEN** DIU bascule root vers Bash avant le retrait du paquet
