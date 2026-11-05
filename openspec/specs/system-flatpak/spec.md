# system-flatpak Specification

## Purpose
Permettre au module system de faire converger explicitement et sans effet de
bord les composants système nécessaires à Flatpak.

## Requirements

### Requirement: État persisté du moteur Flatpak

Le DIU SHALL déclarer `SYSTEM_FLATPAK_ENGINE` dans le scope `system`, avec les valeurs `0`, `1` et `UNSET`. Si elle est absente, le DIU SHALL reprendre `SYSTEM_FLATPAK` si présente, sinon détecter l’état du paquet Flatpak, puis persister le résultat. Une valeur existante SHALL être conservée. Une valeur invalide SHALL provoquer un échec explicite sans mutation système.

#### Scenario: Détection initiale

- **WHEN** `SYSTEM_FLATPAK_ENGINE` et `SYSTEM_FLATPAK` sont absentes et que le statut du paquet est lisible
- **THEN** elle vaut `1` pour un paquet installé ou `0` pour un paquet absent et est persistée dans `system.env`

#### Scenario: Reprise de l’état historique

- **WHEN** `SYSTEM_FLATPAK_ENGINE` est absente et `SYSTEM_FLATPAK` est présente avec une valeur valide
- **THEN** cette valeur est reprise et persistée dans `SYSTEM_FLATPAK_ENGINE`

#### Scenario: Priorité de la nouvelle variable

- **WHEN** les deux variables sont présentes
- **THEN** `SYSTEM_FLATPAK_ENGINE` est conservée

#### Scenario: Statut indéterminable

- **WHEN** `SYSTEM_FLATPAK_ENGINE` et `SYSTEM_FLATPAK` sont absentes et que le statut du paquet ne peut pas être déterminé fiablement
- **THEN** elle vaut `UNSET` et est persistée dans `system.env`

#### Scenario: Valeur existante ou invalide

- **WHEN** `SYSTEM_FLATPAK_ENGINE` contient déjà `UNSET`
- **THEN** le DIU ne la redétecte ni ne l'écrase
- **WHEN** elle contient une autre valeur non valide
- **THEN** le DIU échoue avant toute opération système

### Requirement: Convergence du moteur Flatpak

Le module system SHALL appliquer `SYSTEM_FLATPAK_ENGINE` de manière idempotente.
`1` SHALL installer le paquet Debian `flatpak` puis garantir le remote
`flathub`; `0` et `UNSET` SHALL ne retirer aucun paquet et ne SHALL effectuer aucune action de désinstallation. La désactivation SHALL préserver les applications Flatpak, leurs données utilisateur et le remote. Un échec de
l'installation ou de la configuration de Flathub SHALL être propagé et ne
SHALL pas persister l'état `1`.

#### Scenario: État activé

- **WHEN** `SYSTEM_FLATPAK_ENGINE=1` est appliqué
- **THEN** le paquet Debian est installé et Flathub est présent via `remote-add --if-not-exists`

#### Scenario: État désactivé ou indéterminé

- **WHEN** `SYSTEM_FLATPAK_ENGINE=0` est appliqué
- **THEN** le moteur est désactivé sans retrait de paquet
- **WHEN** `SYSTEM_FLATPAK_ENGINE=UNSET` est appliqué
- **THEN** aucune commande système n'est exécutée

### Requirement: Commandes ciblées Flatpak

DIU SHALL exposer les commandes Flatpak ciblées, persister l’état après succès seulement, limiter l’update au paquet Debian installé et fournir les aides prévues.
Les modalités normatives détaillées ci-dessous SHALL être respectées.

#### Scenario: Installation ciblée

- **WHEN** `diu system engine install flatpak` réussit
- **THEN** `SYSTEM_FLATPAK_ENGINE=1` est persisté après la configuration de Flathub

#### Scenario: Mise à jour ciblée absente

- **WHEN** `diu system update flatpak` est invoqué alors que le paquet est absent
- **THEN** le DIU signale cet état et ne l'installe pas

#### Scenario: Aide des commandes

- **WHEN** l'aide de la commande Flatpak ou de son parent system est demandée
- **THEN** elle décrit les commandes install, remove et update Flatpak

#### Scenario: Actions Flatpak ciblées et persistance

- **WHEN** une installation, suppression, mise à jour ciblée ou aide Flatpak est demandée
- **THEN** les règles suivantes s’appliquent dans les cas qu’elles décrivent :

Le DIU SHALL accepter `diu system engine install flatpak`, `diu system engine remove
flatpak` et `diu system update flatpak`. L'installation SHALL persister `1`
uniquement après l'installation et la configuration de Flathub réussies ; la
désactivation SHALL persister `0` sans désinstaller les dépendances. La mise à jour SHALL
cibler uniquement le paquet Debian installé et SHALL ne jamais exécuter
`flatpak update`; son absence SHALL être signalée sans installation implicite.
Les commandes et leurs parents SHALL être accessibles par le mécanisme d'aide
existant.

