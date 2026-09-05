# Proposal: Gestion des logiciels et mise à jour universelle

## Why

DIU doit exposer un cycle de vie commun pour les logiciels officiels Debian et
les logiciels tiers. La commande actuelle `rid update` ne met à jour que DIU ;
elle doit devenir une mise à jour universelle des modules et de leurs
sous-fonctions de mise à jour.

## What Changes

- Définir le module fonctionnel `software` dans `modules/softwares/`, conformément
  au nom de répertoire déjà prévu par l'architecture.
- Ajouter `rid install deb <SOFTWARE>`, `rid remove deb <SOFTWARE>`,
  `rid update deb <SOFTWARE>` et `rid update deb`.
- Définir les commandes équivalentes pour le futur moteur `apt`, dédié aux
  logiciels tiers, avec ou sans dépôt.
- Déléguer la préparation des dépôts tiers au futur moteur de dépôts DIU.
- Prévoir des fonctions propres au logiciel pour les trois opérations lorsque
  le logiciel tiers ne dépend pas d'un dépôt.
- Étendre `rid update` à tous les modules et à leurs sous-fonctions de mise à jour,
  en incluant la mise à jour du DIU lui-même.

## Capabilities

### New Capabilities

- `software-management` : routage et cycle de vie des logiciels par moteur.
- `universal-update` : orchestration globale des mises à jour.

## Impact

Le dispatch et l'aide de `root-install-debian.sh` devront évoluer, ainsi que les
composants concernés sous `modules/softwares/` et le mécanisme de mise à jour DIU.
`rid update` change explicitement de portée : cette évolution fonctionnelle
n'est pas un simple refactoring de l'architecture modulaire.

## Scope

La première étape implémente le moteur `deb` et la mise à jour universelle.
Le contrat du moteur `apt` et son intégration restent définis pour une étape
ultérieure ; ses commandes retournent actuellement une indisponibilité explicite.

## Out of Scope

- Implémentation du moteur de dépôts DIU.
- Catalogue initial de logiciels tiers et recettes propres à chaque logiciel.
- Changement de version majeure de Debian, purge ou nettoyage automatique.
- Renommage des répertoires existants, commit, push ou installation réelle.
