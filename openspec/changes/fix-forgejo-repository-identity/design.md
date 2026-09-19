# Design

## Context

`_forgejo_prepare_context` lit déjà `forgejo.username` avec les contrôles de
présence et de permissions applicables. La requête API `/user` ajoutée pour
retrouver cette même identité est incompatible avec l'instance Forgejo ciblée.

## Goals / Non-Goals

**Goals:**

- Utiliser `forgejo_username` comme identité du propriétaire personnel.
- Préserver la création dans une organisation lorsque le propriétaire diffère.
- Rendre le parcours sans effet lorsqu'un dépôt existe déjà.

**Non-Goals:**

- Ne pas modifier les identifiants, les permissions, l'API de création ou les
  paramètres Forgejo serveur.

## Decisions

La comparaison `forgejo_owner == forgejo_username` sélectionne
`POST /user/repos`. Sinon, la vérification de l'organisation et
`POST /orgs/<owner>/repos` sont conservées. Cette identité locale est déjà
utilisée pour l'authentification Git et évite une dépendance à `/user`.

## Risks / Trade-offs

- [Le fichier username ne reflète pas le token] → les contrôles existants de
  credentials interrompent le push avant toute création.
