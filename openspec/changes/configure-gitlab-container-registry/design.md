## Context

La publication Docker extrait actuellement l'hôte de
`REMOTE_GITLAB_BASE_URL`, qui représente le dépôt Git et les API GitLab. Cette
valeur ne permet pas de représenter un registre Docker séparé ou un port dédié.
Voir `proposal.md` pour la motivation et les deltas de spécification pour le
contrat observable.

## Goals / Non-Goals

**Goals:**

- Séparer l'autorité du registre Docker de l'URL GitLab.
- Préserver les ports explicites dans les commandes Docker.
- Réemployer la mise à jour interactive GitLab pour les configurations
  existantes sans registre.

**Non-Goals:**

- Modifier les remotes Git, les publications de paquets Debian ou les flux
  Forgejo et GitHub.
- Déduire automatiquement un port ou un hôte de registre à partir de l'URL
  GitLab.
- Exécuter une publication ou un accès réseau dans les tests.

## Decisions

### Variable de registre explicite

`REMOTE_GITLAB_REGISTRY` contient l'autorité Docker sans protocole, par
exemple `git.ec-nantes.fr:5050`. Elle est distincte de
`REMOTE_GITLAB_BASE_URL`, qui reste utilisée pour Git et l'API GitLab.

Le codage en dur de `:5050` est écarté : GitLab autorise un domaine ou un port
de registre différent selon l'instance. La déduction de l'autorité depuis
l'URL GitLab est aussi écartée car elle est la cause du défaut constaté.

### Reconfiguration contrôlée

`gitlab_update()` devient l'unique point d'écriture de cette variable dans
`project.env`. La release GitLab traite son absence comme toute autre
configuration GitLab incomplète : elle appelle `gitlab_update()`, recharge le
fichier, puis valide la variable avant de déléguer à la publication Docker.

La fonction de publication Docker conserve un contrôle défensif de la variable
afin qu'aucune authentification, aucun tag et aucun push ne soient construits
avec un registre implicite.

### Validation sans réseau

Les tests remplacent les commandes Docker et les fonctions de configuration
par des doubles contrôlés. Ils vérifient les arguments produits et l'ordre de
reconfiguration sans conserver ni afficher d'identifiant GitLab.

## Risks / Trade-offs

- [Les projets existants n'ont pas la nouvelle variable] → la première release
  relance la configuration GitLab avant toute publication.
- [Une valeur de registre invalide est saisie] → Docker échoue explicitement à
  l'authentification ou à la publication ; aucune valeur n'est inventée.
- [Les tests ne contactent pas GitLab] → ils couvrent la construction des
  commandes, tandis que la disponibilité du registre reste un contrôle manuel
  de l'opérateur.

## Migration Plan

1. Mettre à jour DIU et lancer une release GitLab d'un projet Dockerisé.
2. Renseigner l'adresse affichée par l'interface Container Registry, par
   exemple `git.ec-nantes.fr:5050`, lorsque `gitlab_update()` la demande.
3. En cas de repli, retirer `REMOTE_GITLAB_REGISTRY` de `project.env` et
   revenir à la version DIU précédente ; aucun artefact distant n'est modifié
   par la migration de configuration elle-même.
