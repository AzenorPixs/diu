## Context

`create_project` copie le contenu du modèle local
`/home/${DEVOPS_USER}/datas/template` dans le répertoire du nouveau projet. Le
modèle est une source de fichiers, pas une source de dépôt Git ; voir
`proposal.md` pour la motivation.

## Goals / Non-Goals

**Goals:**

- Empêcher la copie de `.git` situé à la racine du modèle.
- Conserver la copie des fichiers cachés et des autres éléments du modèle.
- Conserver l'exclusion de `project.env` et les substitutions Markdown.

**Non-Goals:**

- Initialiser, configurer ou supprimer un dépôt Git dans le projet créé.
- Modifier le contenu du modèle local.
- Changer les commandes publiques de gestion Git.

## Decisions

- Ajouter `.git` aux exclusions de la sélection des entrées de premier niveau
  du modèle. Cette approche conserve la copie récursive des répertoires utiles
  et évite d'introduire une dépendance supplémentaire.
- Contrôler le résultat au moyen d'un modèle de test contenant `.git` et un
  fichier caché ordinaire. Cela vérifie l'exclusion précise sans supprimer
  involontairement les fichiers cachés légitimes.

## Risks / Trade-offs

- [Un répertoire `.git` imbriqué dans un sous-répertoire du modèle est copié]
  → Le périmètre est limité au dépôt du modèle à sa racine ; une exclusion
  récursive nécessiterait une évolution distincte.
- [Une future modification de la logique de copie omet les exclusions]
  → Le test de création vérifie explicitement l'absence de `.git`.

## Migration Plan

Déployer la modification avec son test. Aucun projet existant n'est modifié.
Le retour arrière consiste à restaurer la sélection antérieure dans une
évolution explicitement validée.
