## Context

projects_template_devops construit déjà devops_home avec
/home/${ENV_DEVOPS_USER} après validation du compte. Le rendu commun est
utilisé par la génération individuelle, groupée et finale de création.
DEVOPS_PROJECTS_ROOT peut désigner une autre racine pour les projets ; il
ne détermine pas l'emplacement des prompts communs.

## Goals / Non-Goals

- Afficher une seule rubrique Prompts avec deux chemins absolus calculés
  depuis devops_home et augmenter la version documentaire à 0.6.
- Ne pas sonder, créer ou lire prompts ni INDEX.md.
- Préserver les sondes, l'ordre relatif existant, les droits et les commandes.
- Ne pas régénérer le relevé DEVOPS.md existant du dépôt.

## Decisions

Ajouter un printf dans projects_template_devops_render, après le gestionnaire
de paquets Python et avant les tests navigateurs. Réutiliser devops_home,
déjà issu de ENV_DEVOPS_USER, sans variable de configuration supplémentaire.
La section contient « Dossier des prompts » et « Index des prompts ».

Les tests existants contrôlent la structure, la génération groupée et la
création. Un scénario isolé vérifiera un autre utilisateur, une racine de
projets distincte et l'absence de mutation du dossier des prompts.

## Risks / Trade-offs

L'ajout est documentaire et sans nouvelle sonde. Les emplacements indiqués
peuvent être absents : le document décrit leur convention, pas leur existence.
Le contrôle strict de la structure doit être adapté à la nouvelle rubrique.

## Migration / Rollback

Aucune migration. Les prochains rendus utilisent 0.6 ; les relevés antérieurs
restent des instantanés. Le repli consiste à retirer l'ajout ciblé et rétablir
les attentes documentaires, sans modifier les prompts ni les projets générés.
