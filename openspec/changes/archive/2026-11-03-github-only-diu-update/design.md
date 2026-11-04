## Contexte

Le moteur compare actuellement les releases de trois fournisseurs. Le projet DIU fournit les paramètres GitHub dans son fichier local de configuration.

## Décisions

Limiter l’extraction aux trois paramètres GitHub et supprimer les branches de sélection propres aux autres fournisseurs. Conserver la pagination, les règles de priorité des versions, les accès publics ou authentifiés et la validation du paquet. La configuration GitHub absente ou partielle provoque une erreur ; aucune requête vers Forgejo ou GitLab n’est effectuée. Les opérations de publication sont indépendantes.

## Validation

Tests isolés simulant les API et l’installation, y compris configurations étrangères invalides, pagination, indisponibilité GitHub et régressions de sécurité. Contrôles syntaxiques et suite globale.
