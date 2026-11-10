# Adapter les ressources locales synchronisées

La synchronisation unitaire et groupée crée le dossier local `.cab-tests` lorsqu'il est absent et préserve les données existantes. Elle ne copie ni ne modifie `DEVELOPMENT_MAP.md`.

## Capabilities

### Modified Capabilities
- `projects-sync` : créer le dossier local de tests et exclure la carte de développement.

## Impact

Fonction de synchronisation, tests, documentation et spécification. Aucun projet existant n'est synchronisé par ce change ; la création de projet reste inchangée.
