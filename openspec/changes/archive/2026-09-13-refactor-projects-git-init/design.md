## Context

Le dispatch des projets traite actuellement `giti` au premier niveau, alors
que le sous-contexte `git` traite déjà `update`. L'aide est centralisée dans
`lib/rid-help.sh`. Voir `proposal.md` pour la motivation et les spécifications
de cette évolution pour le comportement contractuel.

## Goals / Non-Goals

**Goals:**

- Regrouper l'initialisation et la mise à jour Git sous le même sous-contexte.
- Maintenir l'aide et le routage synchronisés par des tests d'aide ciblés.

**Non-Goals:**

- Modifier l'implémentation ou les contrôles internes de `git_init`.
- Conserver une compatibilité implicite avec `giti`.
- Modifier les autres commandes Git historiques ou de fournisseur.

## Decisions

- Ajouter `init` au `case` existant de `git` plutôt qu'un nouveau
  gestionnaire : le sous-contexte existe déjà et cette approche limite le
  changement au routage. L'alternative, conserver `giti` comme alias, est
  écartée car elle contredirait le retrait validé de la commande historique.
- Déclarer explicitement la nouvelle commande aux deux niveaux d'aide : l'aide
  racine annonce le chemin complet et l'aide contextuelle expose les actions
  directement disponibles.
- Tester les sorties d'aide sans appeler l'initialisation Git, afin de ne pas
  dépendre d'une configuration de production ni produire de mutation.

## Risks / Trade-offs

- [Scripts appelant encore `giti`] → la rupture est documentée dans
  `proposal.md` et la commande inconnue échoue sans initialiser de dépôt.
- [Écart futur entre aide et routage] → les assertions ciblées couvrent les
  deux aides concernées.

## Migration Plan

Déployer les fichiers ensemble. Le repli consiste à réintroduire le cas de
routage et la ligne d'aide `giti` dans une évolution ultérieure explicitement
autorisée ; aucune donnée ni configuration n'est migrée.
