# Conception

## Context

Git retourne notamment 128 pour des causes distinctes. Les appels API sont
parfois exécutés dans des substitutions de commandes : une variable Bash seule
ne permet pas de transmettre leur état au parent.

## Decisions

Un contexte temporaire de publication transporte un marqueur d'indisponibilité
sans secret, dans un répertoire privé. Les primitives réseau le renseignent
uniquement sur une cause reconnue. Les codes Git originaux restent inchangés.
Une enveloppe publique du push convertit le résultat marqué en état
`indisponible`, retourne zéro et supprime le contexte. Les diagnostics natifs
réseau sont retenus uniquement pendant ce contexte ; les autres diagnostics
restent visibles. Le logger d'erreur du sous-processus de publication masque
les cascades seulement après la détection d'une indisponibilité.

La classification repose sur les codes curl 5/6/7/28 et les statuts HTTP
502/503/504 ; Git utilise des diagnostics natifs ancrés, en locale C, pour
DNS, connexion, timeout et ces statuts HTTP. Un simple code 128, une erreur
TLS ou un message distant contenant un texte ressemblant à une panne ne
suffisent pas. Un échec non identifié reste bloquant.

Le statut interne PROJECTS_GIT_PUSH_STATUS est réinitialisé à chaque appel et
transmis à CI/CD, sans écriture de configuration. Le flux distingue un push
publié d'une publication non confirmée, poursuit les autres fournisseurs et
ignore les releases associées. Une panne pendant le tag peut laisser la
branche déjà publiée : aucune annulation automatique n'est tentée.

Les invites interactives existantes restent visibles ; seuls les diagnostics
natifs des primitives réseau sont capturés. Les interfaces publiques, scopes
TLS et mécanismes de credentials restent identiques. Les appels en dehors du
contexte de push tolérant conservent leur contrat d'erreur.

## Risks / Trade-offs

Les textes Git non reconnus échouent explicitement. Une publication perdant
sa connexion peut avoir été partiellement appliquée : le résultat est non
confirmé, jamais annoncé comme réussi. Pas de retry automatique ni de sondage
réseau préalable. Les tests simulent Git/curl/Docker et les credentials.

## Validation

DNS, connexion, timeout, 502/503/504 et panne au fetch/branche/tag/API sur les
trois fournisseurs ; erreurs 401/403, TLS, configuration, rejet et 128 générique
préservées ; poursuite, résumé, code zéro, releases ignorées, isolation des
appels, nettoyage et fonctionnement hors contexte vérifiés sur fixtures.
