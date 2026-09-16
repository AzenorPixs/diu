## Context

Le dispatch de `projects` traite actuellement `gits` à son premier niveau,
tandis que `commit`, `init` et `update` sont déjà regroupés dans le
sous-contexte `git`. Les aides sont déclarées séparément par contexte dans
`lib/rid-help.sh`.

## Goals / Non-Goals

**Goals:**

- Router `status` dans le sous-contexte `projects git` vers le comportement
  de statut existant.
- Exposer la même syntaxe à chaque niveau d'aide concerné.

**Non-Goals:**

- Modifier la fonction de statut Git, sa sortie ou ses prérequis.
- Conserver un alias de compatibilité pour `gits`.

## Decisions

- Déplacer uniquement le routage public de `gits` vers le cas `status` du
  sous-contexte `git`, afin de préserver l'implémentation et les paramètres
  existants. Une nouvelle fonction ou un alias de compatibilité sont écartés,
  car ils élargiraient inutilement le périmètre et contrediraient le retrait
  explicite de l'ancienne commande.
- Déclarer la commande canonique dans les trois contextes d'aide concernés.
  Cette approche suit l'organisation existante de l'aide et permet à l'aide
  terminale de rester disponible avant le chargement de la configuration.

## Risks / Trade-offs

- [Les scripts utilisant `gits` échouent après le changement] → Le retrait est
  explicitement incompatible et l'aide indique la commande de remplacement.
- [Un niveau d'aide omet la nouvelle commande] → Les tests d'aide couvrent les
  contextes `projects`, `projects git` et `projects git status`.

## Migration Plan

Les utilisateurs remplacent `rid projects gits <ID PROJECTS>` par
`rid projects git status <ID PROJECTS>`. Le repli consiste à réintroduire le
cas de routage historique dans une évolution ultérieure explicitement validée.
