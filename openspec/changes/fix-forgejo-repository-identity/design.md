# Design

## Context

`_forgejo_prepare_context` lit déjà `forgejo.username` avec les contrôles de
présence et de permissions applicables. La requête API `/user` ajoutée pour
retrouver cette même identité est incompatible avec l'instance Forgejo ciblée.
Les helpers API construisaient également leurs URL sans le préfixe `/api/v1`.

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

Le helper commun ajoute `/api/v1` entre l'hôte Forgejo et l'endpoint demandé.
Les appelants conservent des endpoints relatifs à cette API, ce qui évite les
chemins divergents entre vérification, création et publication.

## Succession du parcours de création

Les objectifs et décisions de création API ci-dessus décrivent l'intention
initiale de cette correction. Le change actif
`restore-forgejo-push-to-create` remplace ensuite ce parcours : le provider
vérifie l'existence du dépôt et délègue la création d'un dépôt absent au
premier push Git, sans appel API de création ni fetch préalable.

Le code actuel suit ce parcours successeur. La réutilisation de l'identité
locale et le préfixe `/api/v1` restent pertinents pour le contexte
authentifié et les appels API conservés. Les mentions de création API dans
ce design ne prescrivent donc pas sa réintroduction.

## Risks / Trade-offs

- [Le fichier username ne reflète pas le token] → les contrôles existants de
  credentials interrompent le push avant toute création.
