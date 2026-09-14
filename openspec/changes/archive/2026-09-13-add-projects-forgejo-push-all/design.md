## Context

`forgejo_push()` réalise déjà la publication d'un projet, dont la validation
du dépôt, du remote, des identifiants et la confirmation utilisateur. La
commande groupée doit réutiliser ce comportement sans lancer les assistants
interactifs de configuration pour les répertoires non configurés.

## Goals / Non-Goals

**Goals:**

- Exposer `rid projects forgejo push all`.
- Parcourir les sous-répertoires directs de `/home/${DEVOPS_USER}/datas`.
- Déléguer chaque publication sélectionnée à `forgejo_push()`.
- Continuer après l'échec d'un projet et restituer un échec global fidèle.

**Non-Goals:**

- Modifier le comportement de `forgejo_push()` pour un projet individuel.
- Initialiser ou compléter la configuration des projets ignorés.
- Supprimer ou modifier un remote existant.
- Automatiser ou contourner la confirmation de chaque push.

## Decisions

- `forgejo_push_all()` emploie `DEVOPS_PROJECTS_ROOT` lorsqu'il est défini,
  dont la valeur attendue est `/home/${DEVOPS_USER}/datas`, et utilise ce
  chemin comme valeur de repli. Cette cohérence avec les autres commandes de
  projets permet des tests isolés sans modifier le répertoire DevOps.
- La fonction ne sélectionne qu'un sous-répertoire avec un `project.env`.
  Après chargement, elle exige `PROJECT_ID`, `PROJECT_NAME`, `PROJECT_TYPE`,
  `PROJECT_DOCKERED`, `REMOTE_FORGEJO_BASE_URL`, `REMOTE_FORGEJO_OWNER`,
  `REMOTE_FORGEJO_REPOSITORY`, `REMOTE_FORGEJO_NAME`,
  `REMOTE_FORGEJO_BRANCH` et `REMOTE_FORGEJO_SSL_VERIFY`. `PROJECT_ID` doit
  correspondre au nom du répertoire.
- Un répertoire non conforme est annoncé puis ignoré. Aucun assistant de mise
  à jour Forgejo ne lui est appliqué.
- La fonction appelle `forgejo_push()` pour chaque projet sélectionné. Un
  échec est mémorisé, mais les projets suivants restent traités.
- Le routage interprète exclusivement l'argument `all` comme l'opération
  groupée ; les autres identifiants continuent à utiliser `forgejo_push()`.

## Risks / Trade-offs

- La commande est mutante et chaque publication réussie est irréversible par
  le DIU. Les confirmations existantes de `forgejo_push()` sont conservées.
- Une configuration incomplète peut faire ignorer un projet attendu. Le
  diagnostic indique le projet et évite de modifier sa configuration.

## Migration Plan

1. Ajouter les deltas OpenSpec, le routage et le traitement groupé.
2. Mettre à jour l'aide et les tests ciblés.
3. Vérifier la syntaxe Bash, ShellCheck, les tests et la validation stricte
   OpenSpec.

Le repli consiste à ne plus appeler la nouvelle commande ; les interfaces de
publication unitaire restent inchangées.
