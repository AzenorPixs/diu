# universal-update Specification

## Purpose
Décrire l’orchestration des mises à jour DIU, de ses modules et des moteurs
logiciels, avec un bilan global et une propagation explicite des échecs.

## Requirements

### Requirement: Mise à jour universelle

`rid update` sans argument SHALL déclencher la mise à jour de tous les modules
DIU et de leurs sous-fonctions de mise à jour applicables, y compris la mise à
jour de DIU lui-même. Il SHALL NOT se limiter à l'ancien appel `update_diu`.
La commande SHALL NOT déclencher les fonctions d'installation ou de
configuration sans rapport avec une mise à jour.

#### Scenario: Invocation globale

- **WHEN** `rid update` est invoqué sans argument
- **THEN** DIU orchestre la mise à jour de tous ses modules et de leurs sous-fonctions applicables
- **AND** la mise à jour de DIU lui-même fait partie du traitement

### Requirement: Participation des moteurs logiciels

La mise à jour universelle SHALL inclure la portée de `rid update deb` et,
une fois disponible, celle de `rid update apt`.
Une mise à jour avec moteur explicite SHALL rester limitée à ce moteur.

#### Scenario: Moteurs disponibles

- **WHEN** les moteurs `deb` et `apt` sont disponibles et `rid update` est invoqué
- **THEN** les logiciels installés relevant de chacun des deux moteurs sont traités

#### Scenario: Mise à jour limitée à deb

- **WHEN** `rid update deb` est invoqué
- **THEN** DIU ne déclenche ni le moteur `apt` ni les mises à jour des autres modules

### Requirement: Couverture et absence de doublons

Chaque module SHALL identifier ses sous-fonctions de mise à jour et leur
applicabilité. L'orchestration SHALL éviter les appels en double d'une même
opération et SHALL respecter les dépendances entre opérations.
Un composant sans traitement disponible SHALL être signalé explicitement.

#### Scenario: Opération partagée

- **WHEN** plusieurs parcours conduisent à une même opération de mise à jour
- **THEN** cette opération n'est exécutée qu'une fois pendant l'invocation globale

#### Scenario: Module sans traitement

- **WHEN** un module ne dispose pas de traitement de mise à jour applicable
- **THEN** le bilan indique son état sans prétendre l'avoir mis à jour

### Requirement: Bilan global et propagation des échecs

La mise à jour universelle SHALL présenter un bilan des composants traités,
déjà à jour, non applicables, non pris en charge, bloqués ou en échec.
Elle SHALL retourner un code non nul si une opération requise échoue ou reste
bloquée. Elle SHALL NOT annoncer un succès global après un tel échec.

#### Scenario: Échec partiel

- **WHEN** une sous-fonction requise échoue
- **THEN** le bilan identifie le composant en échec
- **AND** la commande globale retourne un code non nul

#### Scenario: Tous les composants sont à jour

- **WHEN** toutes les opérations applicables réussissent ou constatent un état à jour
- **THEN** DIU fournit le bilan et retourne un code nul

### Requirement: Mise à jour ciblée de DIU et isolation du processus

`rid update diu` SHALL conserver une portée limitée au DIU lui-même.
La mise à jour universelle SHALL confiner le remplacement de processus utilisé
par la mise à jour DIU afin de pouvoir produire son bilan final.

#### Scenario: Mise à jour de DIU uniquement

- **WHEN** `rid update diu` est invoqué
- **THEN** seule la mise à jour de DIU est exécutée

#### Scenario: Installation du paquet DIU dans une mise à jour globale

- **WHEN** update_diu remplace son processus par dpkg
- **THEN** l'orchestrateur attend le résultat dans un sous-processus
- **AND** il produit le bilan global après la fin de ce sous-processus
