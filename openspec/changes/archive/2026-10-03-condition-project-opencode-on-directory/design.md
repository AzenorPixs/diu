## Context

La CLI délègue à `projects_template_openspec`. Les parcours groupés et la
création de projets réutilisent cette fonction. Le choix init/update est
indépendant de la génération DevOps et du traitement du domicile DevOps.

## Goals / Non-Goals

- Traiter un projet sans dossier `.opencode` comme `OPENCODE=0`.
- Préserver la valeur configurée pour les appels suivants.
- Préserver update, les arguments, les chemins littéraux, les erreurs de su
  et d'OpenSpec, ainsi que les écritures partielles.
- Exclure toute modification des configurations, du domicile DevOps,
  du routage, des dépendances, de Git et des autres changes actifs.

## Decisions

Une variable locale `opencode` reprend `${OPENCODE:-}`. Dans la branche
d'initialisation, le test Bash `-d` sur `${project_path}/.opencode` détermine
si cette valeur est conservée ou remplacée par 0. Un fichier ordinaire ou un
lien pendant n'est pas un dossier ; le test suit un lien vers un dossier,
selon la sémantique habituelle de `-d`, sans lire son contenu.

Si le dossier est présent, seules les valeurs 0 et 1 sont acceptées comme
auparavant. Si OpenSpec existe, `openspec update` reste indépendant de la
valeur et de la présence du dossier OpenCode.

Les tests simulent intégralement su et OpenSpec dans des fixtures sous la
racine du dépôt. Un traitement groupé mélange des projets avec et sans
`.opencode` et vérifie la conservation de la variable configurée.

## Risks / Trade-offs

Les projets sans `.opencode` n'activent plus l'intégration lors d'un init,
même si la configuration globale demande OpenCode. Il s'agit du changement
explicitement demandé. Les intégrations déjà présentes ne sont pas supprimées.

## Migration Plan

Aucune migration ni mutation des projets réels pendant la validation. Les
écritures partielles restent conservées en cas d'échec. Un retour arrière
nécessiterait une nouvelle décision autorisant le rétablissement de la règle
précédente ; aucun retour arrière automatique n'est introduit.
