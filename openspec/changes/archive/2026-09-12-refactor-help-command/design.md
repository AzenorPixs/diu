## Context

Le point d'entrée possède trois systèmes d'aide concurrents : sorties avant le
chargement de la configuration, `display_help_context()` après ce chargement,
et `display_usage()`. Le dernier présente un catalogue global obsolète et est
appelé par de nombreux gestionnaires.

## Goals / Non-Goals

### Goals

- Une seule source d'aide, utilisable avant les sources de production.
- Une aide limitée au contexte de routage et stablement formatée.
- Des erreurs qui guident vers le dernier contexte connu sans action métier.

### Non-Goals

- Modifier le routage métier, les moteurs logiciels ou Flatpak.
- Ajouter une correction orthographique automatique.
- Réorganiser les modules du projet.

## Decisions

La déclaration des commandes d'aide reste dans `root-install-debian.sh`, car
le routage public y est actuellement centralisé. Une fonction d'aide unique
est définie avant tout chargement de configuration afin que les invocations
`help` et `?` soient sûres même lorsque `/root/diu/variables.sh` est absent.

Une fonction d'erreur dédiée reçoit le chemin connu et l'élément inconnu. Les
gestionnaires existants l'appellent à la place de `display_usage()`. Elle
conserve le code de retour d'erreur et fournit une commande `help` explicite.

## Risks / Trade-offs

Le catalogue des commandes demeure déclaratif et doit être maintenu lors de
l'ajout d'une route. Cette responsabilité est explicitement couverte par la
spécification `rid-help` et évite un refactoring risqué du routeur existant.

## Validation

Les tests exécutent uniquement les chemins d'aide et d'erreur avant le
chargement de la configuration. Ils vérifient les sorties contextuelles, les
codes de retour et l'absence d'opération système.
