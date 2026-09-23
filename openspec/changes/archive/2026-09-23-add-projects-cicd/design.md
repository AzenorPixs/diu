## Context

Les fonctions unitaires de push et de release complètent actuellement une
configuration manquante de manière interactive. Le nouveau flux doit les
appeler seulement lorsque les variables nécessaires sont déjà renseignées, ce
qui préserve leurs comportements directs.

## Goals / Non-Goals

**Goals:**

- Fournir une commande CI/CD générique, sans initialisation interactive des
  fournisseurs optionnels.
- Publier l'image locale existante vers GHCR lorsque GitHub et Docker sont
  activés.
- Conserver les commandes individuelles existantes.

**Non-Goals:**

- Construire une image dans une fonction de release.
- Créer ou corriger automatiquement une configuration distante incomplète.
- Publier des paquets Debian vers GitHub.

## Decisions

- La valeur activant Docker pour ce flux est exactement `Yes`, conformément à
  la demande fonctionnelle. Les commandes Docker et release existantes
  conservent leur propre compatibilité `Yes|YES|1`.
- La complétude d'un fournisseur comprend les variables générales du projet,
  les cinq variables `REMOTE_<FOURNISSEUR>_*` requises par son push, et pour
  GitLab son registre explicite. Une configuration incomplète est ignorée sans
  sortie et sans appel à la fonction correspondante.
- `projects_github_release` reprend le mécanisme sécurisé des releases Docker
  existantes : image locale, tag Git unique sur `HEAD`, identifiants locaux,
  `DOCKER_CONFIG` temporaire puis tags versionné et `latest` vers GHCR.

## Risks / Trade-offs

- Un projet Dockerisé avec une image locale absente échoue lors de sa release,
  ce qui rend visible un build précédent manquant plutôt que de le relancer.
- Un token GitHub doit disposer des droits de publication de packages pour que
  Docker puisse publier vers GHCR.

## Migration Plan

La commande est additive. Supprimer son routage et ses fonctions restaure le
comportement antérieur sans migration de configuration.
