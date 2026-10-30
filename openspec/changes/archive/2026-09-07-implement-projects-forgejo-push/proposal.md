# GIT06 — Proposition : publication des projets vers Forgejo

## Contexte

DIU dispose d'un parcours historique de publication Forgejo associé aux
variables générales `REMOTE_*`, mais ne propose pas de commande Forgejo
dédiée. Il faut pouvoir sélectionner Forgejo explicitement sans dépendre du
fournisseur par défaut déjà enregistré dans `project.env`.

## Objectif

Ajouter `rid projects forgejo push <ID PROJECT>` avec une configuration
Forgejo dédiée, une authentification locale sécurisée et une aide CLI
cohérente.

## Périmètre

- variables `REMOTE_FORGEJO_*` dans `project.env` ;
- remote Forgejo ajouté ou vérifié sans écraser une URL incohérente ;
- identifiants `config/forgejo.username` et `config/forgejo.token` ;
- publication HTTPS de la branche courante et du tag associé via le
  mécanisme Git temporaire existant ;
- option explicite de vérification TLS `REMOTE_FORGEJO_SSL_VERIFY` ;
- aides `rid`, `rid projects`, `rid projects forgejo` et ses sous-commandes ;
- conservation des parcours Forgejo historique, GitLab et GitHub.

