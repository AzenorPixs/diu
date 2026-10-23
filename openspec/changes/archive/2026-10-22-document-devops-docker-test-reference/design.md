# Conception

## Décision

La fonction `projects_template_devops_section` reste le point commun de rendu.
Elle ajoute uniquement pour son titre interne `Docker` le complément de titre
et les deux puces fixes. La boucle de collecte garde le nom interne `Docker`
et ses sondes existantes. Les autres appels produisent exactement leur rendu
antérieur, y compris les lignes blanches finales.

Les références sont constantes, sans nouvelle variable de configuration :
`/var/run/docker.sock` et `debian:stable-slim`. Elles décrivent le contexte de
test demandé, sans prétendre prouver l'existence ou l'accès au socket,
la présence locale de l'image ou son fonctionnement. Le tag suit Debian
stable ; aucune version Debian ni aucun digest ne sont figés.

## Validation

Adapter le test existant de structure pour vérifier le titre, les quatre
puces dans l'ordre et l'absence de duplication des deux références. Adapter
le test existant des outils absents pour conserver les diagnostics et ces
références. Exécuter la suite DevOps isolée, sans solliciter Docker réel.
Contrôler la syntaxe Bash et Python, ShellCheck, OpenSpec strict et UTF-8/LF.

Les tâches restent séquentielles : preuve et validation technique de la
première avant toute édition de documentation de la seconde. Les résultats,
l'état courant et la prochaine action sont consignés dans `review.md`.

## Revue documentaire et limites

`TECHNICAL.md` porte les détails du contrat ; `README.md` le résume et
`CHANGELOG.md` consigne l'évolution sous `Unreleased`. `AGENTS.md`,
`PROJECT.md`, `BUILD.md` et `openspec/config.yaml` ne sont pas modifiés.
Le `DEVOPS.md` existant conserve son relevé historique ; aucune régénération
réelle n'est lancée dans cette session. Aucun autre change n'est traité.
