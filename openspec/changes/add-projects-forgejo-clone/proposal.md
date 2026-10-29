# GIT27 — Clonage des projets depuis Forgejo

## Why

La récupération d'un projet Forgejo impose aujourd'hui de créer le projet,
configurer Forgejo et fusionner son contenu manuellement. Ce flux répété peut
laisser des fichiers concurrents ou recopier des données Git non souhaitées.

## What Changes

- Ajouter la commande `rid projects forgejo clone <ID PROJECT>`.
- Créer un projet depuis le template, demander sa configuration Forgejo, puis
  fusionner son contenu avec la copie de travail du dépôt Forgejo distant.
- Donner priorité aux fichiers distants homonymes tout en conservant les
  fichiers template absents du dépôt distant.
- Exclure tout répertoire `.git` et toute donnée Git de la fusion.
- Étendre l'aide contextuelle aux commandes de clonage Forgejo.

## Capabilities

### New Capabilities

- `projects-forgejo-clone`: création et fusion sûre d'un projet depuis un
  dépôt Forgejo distant.

### Modified Capabilities

- `forgejo-auth`: prise en charge d'un clonage HTTPS Forgejo authentifié sans
  exposer ni persister le token.
- `rid-help`: exposition de la commande de clonage Forgejo dans l'aide
  contextuelle.

## Impact

Le routage des projets, les modules de projets et Git, le provider
d'authentification Forgejo, l'aide contextuelle et leurs tests ciblés sont
concernés. Aucun changement n'est apporté à la capacité de clonage local
existante ni aux dépendances du projet.
