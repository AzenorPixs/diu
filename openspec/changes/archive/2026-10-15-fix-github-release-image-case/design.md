# Conception

## Context

Les variables `REMOTE_GITHUB_OWNER` et `REMOTE_GITHUB_REPOSITORY` servent
également aux opérations Git/API et conservent leur casse native.
Le chemin d'une référence Docker doit être en minuscules.

## Goals / Non-Goals

Corriger uniquement les références GHCR et leur représentation dans le résumé
CI/CD. Ne modifier ni les variables chargées, ni les fichiers de configuration,
ni les identifiants, ni les références des autres fournisseurs. La version
déduite du tag Git conserve sa casse ; l'image locale reste inchangée.

## Decisions

Utiliser les expansions Bash `${REMOTE_GITHUB_OWNER,,}` et
`${REMOTE_GITHUB_REPOSITORY,,}` aux trois points de construction : références
versionnée et `latest` de `projects_github_release`, puis résumé CI/CD.
Aucun helper, dépendance ou nouvelle variable de configuration n'est nécessaire.

## Risks / Trade-offs

La conversion conserve le comportement des valeurs déjà en minuscules.
Elle ne valide pas les autres caractères interdits par Docker ; cette
validation reste assurée par Docker comme précédemment.
La qualification utilise Git et Docker simulés et ne prouve pas les droits
d'accès à un registre réel. Aucune migration ni publication n'est nécessaire.

## Validation

Tester le propriétaire et le dépôt déjà en minuscules, le propriétaire seul
avec majuscules, le dépôt seul avec majuscules et les deux avec majuscules.
Vérifier les commandes tag/push versionnée et `latest`, la conservation d'un
suffixe de version en majuscules, des variables chargées et du fichier fixture.
Vérifier également la cible GHCR du résumé CI/CD avec une configuration mixte.
