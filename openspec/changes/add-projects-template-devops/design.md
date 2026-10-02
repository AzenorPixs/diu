## Context

Le modèle observé à `/home/devops/datas/template/DEVOPS.md` définit l'ordre
des rubriques et la version documentaire 0.2. La CLI charge ses modules avant
le dispatch projects, tandis que l'aide intervient avant la configuration de
production. Aucun change actif consulté ne couvre cette génération.

## Goals / Non-Goals

**Goals:**

- Vérifier les versions lors de chaque génération ou actualisation.
- Isoler les binaires DevOps du PATH hôte et exécuter leurs sondes sous cet utilisateur.
- Documenter explicitement les données absentes ou invérifiables.
- Préserver le document existant si la préparation ou l'écriture échoue.

**Non-Goals:**

- Installer ou mettre à jour des outils ou dépendances.
- Modifier project.env, pyproject.toml ou les projets créés depuis le modèle.
- Gérer Git, Docker, l'infrastructure ou d'autres changes OpenSpec.

## Decisions

- Ajouter un module dédié, sans refactoriser les modules projects existants.
- Conserver la version documentaire 0.2, indépendante des versions logicielles.
- Utiliser les exécutables `go/current/bin/go`, `node/current/bin/node`,
  `node/current/bin/npm`, `.opencode/bin/opencode`, `.local/npm/bin/openspec`,
  `python/current/bin/python3` et `python/current/bin/pip3` sous le domicile
  DevOps. NPM et OpenSpec sont exécutés avec son Node explicite ; pip avec son
  Python explicite, indépendamment du shebang des scripts. Les sondes Go
  utilisent GOTOOLCHAIN=local pour empêcher un téléchargement de toolchain.
- Résoudre les outils hôte avec un PATH système. Docker désigne la version
  du client installé. Compose accepte le binaire autonome ou un plugin système.
- Tester venv et ensurepip sans créer d'environnement virtuel.
- Lire `[project].dependencies` avec tomllib et interroger importlib.metadata
  dans le Python DevOps. L'absence du manifeste ne justifie aucune dépendance
  implicite, notamment psycopg.
- Pour PostgreSQL, parser uniquement des affectations littérales ciblées de
  project.env, sans source ni eval. Accepter PG_HOST (ou PG_SERVER), PG_PORT,
  PG_DATABASE, PG_USERNAME (ou PG_USER), PG_PASSWORD et PG_SSLMODE. PG_SERVER
  peut également contenir un hôte suivi de son port. Une configuration absente
  ou invalide est indiquée explicitement, sans connexion par défaut à l'hôte.
- Le Python système, déjà présent dans le socle Debian, réalise ce parsing
  local et appelle psql avec les identifiants dans son environnement, jamais
  dans les arguments. Seules la version et l'adresse non sensible sont rendues.
- Borner les sondes et la connexion ; utiliser `SHOW server_version` en lecture
  seule, sans mot de passe interactif ni affichage des erreurs du serveur.
- Préparer le Markdown dans le dossier cible et le remplacer seulement après
  succès, avec conservation des permissions et de la propriété du fichier existant.

## Risks / Trade-offs

- Un outil absent, un serveur inaccessible ou un format de manifeste non pris
  en charge entraîne une mention explicite plutôt qu'une ancienne version.
- Les expressions shell et DSN dans project.env ne sont pas exécutés. Les
  paramètres PostgreSQL doivent être des affectations littérales ; une autre
  convention nécessiterait une décision distincte.
- Les tests simulent les outils et le serveur ; la génération réelle reste
  dépendante des droits sur le modèle et des services disponibles.

## Migration Plan

Aucune migration. Les appels existants restent inchangés. La préparation
temporaire protège l'ancien document en cas d'échec ; aucune suppression ou
restauration Git n'est utilisée.
