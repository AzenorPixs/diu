## Context

Le projet est d'abord créé avec `create_project`, puis configuré avec
`gitlab_update`. Le dépôt est cloné avec le mécanisme d'authentification
GitLab existant dans un répertoire temporaire détenu par `DEVOPS_USER`.

## Decisions

- La commande d'aide ne déclenche aucune opération.
- La fusion est préparée dans un second répertoire temporaire : le contenu
  distant remplace les chemins homonymes, les fichiers uniquement présents
  dans le modèle sont conservés et les répertoires `.git` sont retirés.
- Le remplacement final conserve une sauvegarde temporaire du projet afin de
  restaurer l'état cohérent précédent si l'installation de la fusion échoue.

## Risks

Un échec de création ou de configuration laisse le projet modèle créé par le
flux existant. Les échecs de clonage ou de fusion nettoient leurs artefacts
temporaires sans modifier ce projet.
