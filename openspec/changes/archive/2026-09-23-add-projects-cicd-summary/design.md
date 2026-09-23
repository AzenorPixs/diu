## Context

`cicd_project` possède déjà les informations de commit, de tag et de
configuration distante nécessaires au bilan. Les étapes conditionnelles doivent
rester silencieuses pendant le parcours lorsqu'elles ne sont pas configurées.

## Decisions

- Le bilan est affiché à la terminaison réussie et avant tout retour d'échec
  après le commit.
- Il utilise le tag Git transmis au flux pour la version Docker, sans nouvelle
  interrogation Git.
- Une étape ignorée n'affiche aucun message pendant l'exécution, mais apparaît
  dans le bilan final avec son motif.

## Non-Goals

- Ne pas modifier les publications, le build ou les politiques d'échec.
- Ne pas afficher de token ou de donnée d'authentification.
