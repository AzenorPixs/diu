## Why

La synchronisation unitaire impose de répéter une commande pour chaque projet
géré. Une commande groupée permet de réaligner les projets configurés sur le
modèle local en une seule opération, sans traiter les répertoires qui ne sont
pas des projets valides.

## What Changes

- Ajouter la commande `rid projects sync all`.
- Ajouter une synchronisation groupée des projets valides présents dans
  `/home/${DEVOPS_USER}/datas`.
- Réutiliser le modèle autoritaire
  `/home/${DEVOPS_USER}/datas/template` et exclure ce répertoire du parcours
  des projets.
- Continuer le traitement des autres projets si une synchronisation échoue,
  puis signaler un échec global fidèle.
- Mettre à jour l'aide publique de la gestion des projets.

## Capabilities

### New Capabilities

- `projects-sync-all`: synchronisation groupée des projets configurés depuis
  le modèle local.

### Modified Capabilities

- `rid-help`: exposition de la commande de synchronisation groupée dans
  l'aide contextuelle.

## Impact

Le routage des projets, le module `modules/projects/projects.sh`, l'aide
`rid` et leurs tests ciblés sont concernés. Cette évolution dépend de la
synchronisation unitaire définie par l'évolution `add-projects-sync`. Aucune
dépendance, opération réseau ou modification Git n'est ajoutée.
