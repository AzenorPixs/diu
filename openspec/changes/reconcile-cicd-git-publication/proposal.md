# Réconciliation des publications Git CI/CD — code non attribué

## Pourquoi

Les historiques indépendants et les tags distants divergents empêchent ou limitent la reprise d'une publication CI/CD.

## Changements

- Contrôler les tags distants et aligner la branche sur le commit local sélectionné lorsque la version demandée fait autorité.
- Publier les tags locaux, y compris en remplaçant un tag distant divergent avec protection contre les changements concurrents.
- Préserver les modifications locales en attente lors du rejeu et signaler séparément les indisponibilités et les échecs réels.
- Ne pas remplacer les artefacts publiés sans preuve de cohérence.

## Capacités modifiées

- `projects-cicd` : publication et rejeu des références Git.

## Impact

CI/CD, transports Git, tests et documentation. Les références distantes peuvent être modifiées ; les artefacts existants ne sont pas remplacés automatiquement.
