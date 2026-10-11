## Context

`create_project` appelle `update_projects` avant copie du modèle, dont le
`project.env` est déjà exclu. Le setter existant préserve les lignes non
ciblées. `git_update_legacy`, utilisé par `git_init_clone`, réécrit en revanche
le fichier entier. Le point d'entrée public Git local reste distinct.

## Goals / Non-Goals

Déclarer le mode avec `Yes` (piloté) ou `No` (autonome), partager le
questionnement et fournir un accès commun au défaut rétrocompatible.
Ne pas lancer de session, adapter la synchronisation des modèles, migrer les
projets réels ou modifier les autres changes actifs.

## Decisions

- `project_orchestrated_coding_get <fichier>` lit uniquement l'affectation
  littérale ciblée, sans `source` ni `eval`. Il retourne `No` pour un fichier
  absent ou une variable absente ou vide. Les formes générées par `%q`, les
  valeurs entre guillemets simples/doubles et `export` sont reconnues. Une
  valeur non vide invalide, un fichier illisible ou non ordinaire provoque
  un diagnostic sans reproduire son contenu et un code non nul.
- `project_orchestrated_coding_prompt <défaut>` demande la valeur, conserve
  le défaut pour une entrée vide et redemande après une saisie invalide.
  Une fin d'entrée échoue avant persistance. Seuls `Yes` et `No` sont stockés.
- Les deux parcours de configuration lisent ce défaut depuis leur propre
  fichier, indépendamment des variables du shell, puis utilisent le même
  questionnement. L'ordre relatif des anciennes questions est conservé.
- La mise à jour ciblée réutilise l'écriture différentielle existante ; le
  parcours historique inclut la valeur dans son résumé et sa réécriture.
  Le clonage local conserve la valeur copiée, ou son absence historique.
- `projects-general-update` doit préciser que la nouvelle question étend
  uniquement le questionnaire ciblé ; le routage général reste inchangé.

## Risks / Trade-offs

L'héritage d'un précédent projet et la perte de la valeur à la réécriture sont
couverts par des tests dédiés. Le lecteur n'interprète pas les expressions
shell : seules les valeurs littérales sont un contrat de configuration.
Les diagnostics ShellCheck déjà observés hors périmètre sont rapportés sans
refactoring. Les tests utilisent des projets synthétiques et des doubles
pour les commandes système, les modèles et les opérations externes.

## Migration Plan

Pas de migration immédiate : une absence conserve le mode autonome. La
prochaine création ou mise à jour interactive enregistre explicitement la
valeur. Un retour à l'ancien DIU laisse cette métadonnée supplémentaire
inutilisée ; aucune transformation de données ou ressource distante n'a lieu.
