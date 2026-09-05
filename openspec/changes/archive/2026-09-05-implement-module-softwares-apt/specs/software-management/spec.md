## ADDED Requirements

### Requirement: Commandes modulaires du moteur APT

DIU SHALL accepter les commandes `rid softwares install apt <SOFTWARE>`,
`rid softwares remove apt <SOFTWARE>`, `rid softwares update apt <SOFTWARE>`
et `rid softwares apt update`.

#### Scenario: Commande granulaire

- **WHEN** l'utilisateur invoque `rid softwares install apt <SOFTWARE>`
- **THEN** DIU route l'action vers le moteur APT du module `softwares`

### Requirement: Opérations granulaires idempotentes

Les opérations granulaires SHALL sélectionner une sous-fonction explicitement
déclarée pour le logiciel demandé. Aucune sous-fonction logicielle concrète
n'est déclarée par cette évolution. En l'absence de recette, DIU SHALL signaler
l'action comme non prise en charge sans appeler APT. Les opérations SHALL être
idempotentes, ne SHALL NOT pas construire une commande ou un nom de fonction
arbitraire depuis l'entrée utilisateur, et SHALL propager les erreurs.

#### Scenario: Recette absente

- **WHEN** aucun logiciel concret n'est déclaré pour l'identifiant demandé
- **THEN** DIU retourne une erreur sans appeler APT
- **AND** aucune mutation système n'est effectuée

#### Scenario: Logiciel non déclaré

- **WHEN** aucun sous-fonctionnaire explicite n'est déclaré pour le logiciel
- **THEN** DIU retourne une erreur sans appeler APT

### Requirement: Mise à jour globale APT

`rid softwares apt update` SHALL mettre à jour tous les paquets installés avec
APT. Elle SHALL être exécutée par `rid softwares update` et `rid update`.
Elle SHALL NOT rejouer les fonctions granulaires `install`, `remove` ou
`update` propres aux logiciels.

#### Scenario: Mise à jour globale

- **WHEN** l'utilisateur invoque `rid softwares apt update`
- **THEN** DIU met à jour les paquets installés avec APT une seule fois

#### Scenario: Mise à jour globale du DIU

- **WHEN** l'utilisateur invoque `rid update`
- **THEN** DIU inclut la mise à jour globale APT du module `softwares`
- **AND** il ne rejoue pas les actions granulaires des logiciels

### Requirement: Organisation des modules

Le chargement SHALL respecter l'ordre `diu`, `system`, `softwares`, puis les
autres modules. La configuration des dépôts reste fournie par `system`, mais
la mise à jour globale APT appartient au module `softwares`.

#### Scenario: Ordre de chargement

- **WHEN** DIU démarre
- **THEN** le module `system` est chargé avant `softwares`
- **AND** les modules suivants sont chargés après `softwares`
