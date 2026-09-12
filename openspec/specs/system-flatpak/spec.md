# system-flatpak Specification

## Purpose
Permettre au module system de faire converger explicitement et sans effet de
bord les composants système nécessaires à Flatpak.

## Requirements

### Requirement: État persisté du moteur Flatpak

Le DIU SHALL déclarer `SYSTEM_FLATPAK` dans le scope `system`. Ses seules
valeurs valides sont `0`, `1` et `UNSET`. Lorsqu'elle est absente, sa valeur
SHALL être déterminée à partir du statut du paquet Debian `flatpak`, puis
persistée ; `UNSET` SHALL être persisté si ce statut ne peut pas être lu. Une
valeur déjà présente, y compris `UNSET`, SHALL être conservée. Une valeur
invalide SHALL provoquer un échec explicite sans mutation système.

#### Scenario: Détection initiale

- **WHEN** `SYSTEM_FLATPAK` est absente et que le statut du paquet est lisible
- **THEN** elle vaut `1` pour un paquet installé ou `0` pour un paquet absent et est persistée dans `system.env`

#### Scenario: Statut indéterminable

- **WHEN** `SYSTEM_FLATPAK` est absente et que le statut du paquet ne peut pas être déterminé fiablement
- **THEN** elle vaut `UNSET` et est persistée dans `system.env`

#### Scenario: Valeur existante ou invalide

- **WHEN** `SYSTEM_FLATPAK` contient déjà `UNSET`
- **THEN** le DIU ne la redétecte ni ne l'écrase
- **WHEN** elle contient une autre valeur non valide
- **THEN** le DIU échoue avant toute opération système

### Requirement: Convergence du moteur Flatpak

Le module system SHALL appliquer `SYSTEM_FLATPAK` de manière idempotente.
`1` SHALL installer le paquet Debian `flatpak` puis garantir le remote
`flathub`; `0` SHALL retirer uniquement le paquet Debian `flatpak`; `UNSET`
SHALL n'effectuer aucune action. La suppression SHALL préserver les
applications Flatpak, leurs données utilisateur et le remote. Un échec de
l'installation ou de la configuration de Flathub SHALL être propagé et ne
SHALL pas persister l'état `1`.

#### Scenario: État activé

- **WHEN** `SYSTEM_FLATPAK=1` est appliqué
- **THEN** le paquet Debian est installé et Flathub est présent via `remote-add --if-not-exists`

#### Scenario: État désactivé ou indéterminé

- **WHEN** `SYSTEM_FLATPAK=0` est appliqué
- **THEN** seul le paquet Debian Flatpak est retiré
- **WHEN** `SYSTEM_FLATPAK=UNSET` est appliqué
- **THEN** aucune commande système n'est exécutée

### Requirement: Commandes ciblées Flatpak

Le DIU SHALL accepter `rid system install flatpak`, `rid system remove
flatpak` et `rid system update flatpak`. L'installation SHALL persister `1`
uniquement après l'installation et la configuration de Flathub réussies ; la
suppression SHALL persister `0` uniquement après succès. La mise à jour SHALL
cibler uniquement le paquet Debian installé et SHALL ne jamais exécuter
`flatpak update`; son absence SHALL être signalée sans installation implicite.
Les commandes et leurs parents SHALL être accessibles par le mécanisme d'aide
existant.

#### Scenario: Installation ciblée

- **WHEN** `rid system install flatpak` réussit
- **THEN** `SYSTEM_FLATPAK=1` est persisté après la configuration de Flathub

#### Scenario: Mise à jour ciblée absente

- **WHEN** `rid system update flatpak` est invoqué alors que le paquet est absent
- **THEN** le DIU signale cet état et ne l'installe pas

#### Scenario: Aide des commandes

- **WHEN** l'aide de la commande Flatpak ou de son parent system est demandée
- **THEN** elle décrit les commandes install, remove et update Flatpak
