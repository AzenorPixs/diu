# Design

## Context

Forgejo est configuré pour créer un dépôt lors du premier push Git. Le flux
DIU actuel interrompt ce mécanisme en tentant une création API, puis en
effectuant un fetch avant le push.

## Goals / Non-Goals

**Goals:**

- Déléguer la création d'un dépôt absent à Forgejo.
- Conserver la protection `--force-with-lease` après un fetch pour les dépôts
  existants.

**Non-Goals:**

- Ne pas créer de token, de dépôt ou de ressource Forgejo via l'API.

## Decisions

La vérification du dépôt retourne un statut distinct lorsqu'il est absent.
Le flux de push utilise ce statut pour omettre le fetch, qui ne peut réussir
avant la création, puis effectue le push explicite existant.

## Risks / Trade-offs

- [Le serveur désactive push-to-create] → le push Git échoue avec son erreur
  Forgejo native, sans création API de repli.
