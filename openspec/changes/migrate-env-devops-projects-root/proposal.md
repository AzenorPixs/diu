# Migrer la racine des projets DevOps

## Pourquoi

`DEVOPS_PROJECTS_ROOT` n'est pas déclarée par le mécanisme de variables DIU et
son absence empêche la mise à jour du paquet dans CISMP.

## Changements

- Déclarer `ENV_DEVOPS_PROJECTS_ROOT` en `STATIC`, `ENABLE`, scope
  `environnements`.
- Initialiser sa valeur absente à `/home/${ENV_DEVOPS_USER}/datas`, avec
  diagnostic explicite si `ENV_DEVOPS_USER` reste indisponible après son
  initialisation.
- Déclarer `ENV_DEVOPS_USER` en `STATIC`, `ENABLE`, scope `environnements`,
  avec `root` comme défaut, conservation d'une valeur déjà définie et reprise
  de l'ancienne valeur `DEVOPS_USER` lorsqu'elle existe.
- Remplacer les usages de `DEVOPS_USER` par `ENV_DEVOPS_USER` dans le code DIU;
  la compatibilité reconnaît encore l'ancien nom dans les configurations.
- Préserver exactement une ancienne valeur explicite et donner priorité à la
  nouvelle valeur déjà configurée.
- Accepter le modèle historique de racine contenant `${DEVOPS_USER}` sans
  l'évaluer pendant le nettoyage; le migrer après chargement normal.
- Migrer les consommateurs et les contrats applicables. La publication et le
  parcours CISMP sont différés selon le mandat courant.

## Limite de déploiement

La déclaration du chemin ne crée pas le checkout `diu/project.env` requis par
la mise à jour DIU dans le conteneur.
