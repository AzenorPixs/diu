## Context

`git_commit()` réalise déjà le commit et le tag d'un dépôt local après avoir
validé la configuration de son `project.env`. La commande demandée doit
appliquer ce comportement aux projets configurés, sans lancer les assistants
interactifs de configuration pour les autres répertoires.

## Goals / Non-Goals

**Goals:**

- Exposer `rid projects commit all`.
- Parcourir les répertoires directs de `${DEVOPS_PROJECTS_ROOT}`.
- Déléguer les commits au comportement existant de `git_commit()`.
- Continuer après l'échec d'un projet et restituer un échec global fidèle.

**Non-Goals:**

- Modifier le comportement de `git_commit()` pour un projet individuel.
- Initialiser ou compléter la configuration des projets ignorés.
- Pousser les commits, créer des branches ou contacter un fournisseur distant.
- Accepter un message ou un tag personnalisés pour l'opération groupée.

## Decisions

- Le routage introduit le contexte terminal `projects:commit:all`. Il génère
  un unique horodatage local au format existant `YYYY.MM.DD.HH.MM`, utilisé
  comme message et, avec le préfixe `v`, comme tag pour tous les projets.
- `git_commit_all()` ne considère qu'un sous-répertoire qui contient un
  `project.env`. Après chargement, il exige `PROJECT_ID`, `PROJECT_NAME`,
  `GIT_USER_NAME` et `GIT_USER_EMAIL`, et exige que `PROJECT_ID` corresponde
  au nom du répertoire. Un répertoire non conforme est annoncé puis ignoré.
- La fonction appelle `git_commit()` pour chaque projet sélectionné, ce qui
  conserve les validations de dépôt, l'ajout, le commit et le tag existants.
- L'échec d'un projet est mémorisé ; les projets suivants restent traités et
  la fonction retourne un code non nul après le parcours.

## Risks / Trade-offs

- Une configuration incomplète peut faire manquer un projet attendu ; le
  diagnostic d'ignorance identifie le projet et évite toute modification de
  sa configuration.
- Un même tag est créé dans chaque dépôt. Cette valeur reste locale à chaque
  dépôt et reprend la convention du commit individuel.
- L'opération est mutante pour les dépôts sélectionnés ; aucun mécanisme de
  repli automatique n'est possible après un commit réussi. Elle ne réalise
  toutefois aucune publication distante.

## Migration Plan

1. Ajouter les deltas OpenSpec, le routage et le traitement groupé.
2. Mettre à jour l'aide et les tests ciblés.
3. Vérifier la syntaxe Bash, ShellCheck, les tests et OpenSpec.

Le repli consiste à ne plus appeler la nouvelle commande ; elle ne modifie pas
les interfaces individuelles existantes.
