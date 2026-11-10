# Correction des identifiants en rejeu — code non attribué

## Pourquoi

Lors d'un push direct rejouant un tag existant, l'initialisation interactive des identifiants GitHub ou GitLab peut avoir lieu dans le clone temporaire supprimé en fin de traitement. Les identifiants créés ne sont alors pas conservés pour les appels suivants.

## Changements

Préparer les identifiants GitHub ou GitLab dans le projet source avant la création du clone isolé. Réutiliser les identifiants existants sans saisie, préserver les contrôles de permissions et les erreurs, et conserver le parcours Forgejo et le rejeu CI/CD existants. Les tests utilisent des valeurs fictives sans publication.
