## Context

Les déclarations unitaires sont sourcées par config_generator. Elles conservent les
variables déjà définies et ne persistent pas les valeurs DYNAMIC.

## Goals / Non-Goals

Fournir le nom de code courant sans modifier le moteur de configuration ni les
consommateurs existants. Ne pas convertir un numéro Debian en nom de code.

## Decisions

Lire /etc/os-release dans le sous-processus du générateur, avec VERSION_CODENAME
initialisé vide pour éviter toute valeur héritée. Convertir avec Bash ${value,,}.
Le résultat doit être un nom de code non vide composé de lettres ASCII, chiffres,
points, tirets ou underscores et commençant par une lettre. En cas d'absence,
d'erreur de lecture ou de valeur invalide, écrire sur stderr et retourner un échec,
sans exporter de valeur inventée. default_value reste vide, sans repli trompeur.
Conserver le modèle STATIC/DYNAMIC et ENABLE/DISABLE des déclarations existantes.

## Risks / Trade-offs

Une distribution sans VERSION_CODENAME ne peut pas être identifiée : échec explicite.
Une valeur préexistante est conservée, conformément au mécanisme actuel.
