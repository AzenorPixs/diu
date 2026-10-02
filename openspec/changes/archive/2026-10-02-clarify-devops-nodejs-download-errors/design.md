## Context

Le monolithe s'exécute avec `set -Eeuo pipefail` et un piège ERR. Le curl
actuellement intégré à la substitution `NODE_LATEST` provoque un rapport pour
le pipeline puis un second pour l'affectation lorsque le téléchargement échoue.

## Decisions

Capturer le résultat de curl dans une variable de travail `NODE_INDEX_CONTENT`
à l'intérieur d'un `if`. En cas d'échec, capturer immédiatement `$?`, écrire
sur stderr un message Node.js contenant l'URL et le code curl, puis quitter
avec ce même code. Le diagnostic curl reste visible ; le contenu téléchargé
n'est jamais affiché. Ce traitement évite le piège ERR pour l'erreur attendue.

Après un téléchargement réussi, appliquer au contenu capturé les mêmes
commandes `awk`, `sort -V` et `tail -n 1`. Conserver le contrôle de version
vide, avant le premier `mkdir` du bloc Node.js.

Utiliser `--connect-timeout 10 --max-time 60`, sans désactivation TLS, changement
de proxy, forçage IPv4, modification de configuration ou nouvelle dépendance.
Ces valeurs sont des paramètres internes de l'appel et non une nouvelle
configuration persistante.

## Validation

Extraire le bloc réel de résolution de version et le piège ERR pour les
exécuter avec le mode strict et un curl simulé. Vérifier les codes 60, 6, 22
et 28, y compris un contenu partiel retourné avant échec. Vérifier le tri
numérique et le filtrage de série sur succès, ainsi que la série absente et
l'index vide. Simuler le premier mkdir pour détecter toute poursuite après
échec. Contrôler la syntaxe, ShellCheck, les tests existants du monolithe et
la conformité OpenSpec.

## Risks and rollback

Un transfert qui excède les délais échoue et conserve le code curl. Le bloc
Node.js n'effectue aucune mutation après cet échec. Les étapes antérieures de
rid ne sont pas annulées. Aucun repli automatique n'est prévu. Le retour au
comportement précédent nécessiterait une modification distincte autorisée.

Les cadrages généraux, le packaging et le README restent exacts. Seul le
cadrage technique reçoit la description du traitement ajouté.
