## Context

Le projet crée déjà une arborescence depuis le template et dispose d'un
assistant de configuration Forgejo. Une fonction de clonage et de fusion Git
historique existe, mais elle dépend d'une configuration `REMOTE_CLONE_*`,
conserve un `project.env` local et ne correspond pas au flux Forgejo demandé.

## Goals / Non-Goals

**Goals:**

- Ajouter un flux Forgejo explicite qui réutilise la création et la
  configuration existantes.
- Isoler le clonage dans un répertoire temporaire avant toute fusion.
- Transférer les fichiers de travail distants sans données Git.
- Réutiliser l'authentification Forgejo sans exposer ni persister de token.

**Non-Goals:**

- Modifier le clonage local `diu projects clone`.
- Transformer le projet résultant en dépôt Git local.
- Supprimer les fichiers template non présents dans le dépôt distant.
- Ajouter une dépendance de synchronisation ou modifier les politiques Git
  globales.

## Decisions

### Flux en trois phases

La nouvelle opération appelle successivement la création du projet, la mise à
jour Forgejo, puis le clonage temporaire et la fusion. Cette séparation
réutilise les validations de création et garantit que les paramètres Forgejo
sont présents avant la construction de l'URL distante. Réemployer directement
le flux `REMOTE_CLONE_*` est écarté : il représente un autre fournisseur et
une autre configuration.

### Copie de travail temporaire sans `.git`

Le dépôt est cloné dans un répertoire temporaire appartenant à
`DEVOPS_USER`. Avant la fusion, tout répertoire nommé `.git` est exclu. La
copie vers le projet utilise une sémantique de remplacement uniquement pour
les chemins fournis par le dépôt ; elle ne supprime pas les chemins locaux
absents de cette copie. Un remplacement complet du projet est écarté, car il
supprimerait indûment les fichiers du template.

### Authentification déléguée

Le provider Forgejo expose une opération de clonage qui délègue au mécanisme
Git authentifié existant. Les informations temporaires d'authentification sont
nettoyées quel que soit le résultat. Insérer le token dans l'URL distante est
écarté car cette URL pourrait être affichée ou enregistrée par Git.

### Échec avant fusion

Le clonage et la validation de sa sortie ont lieu avant la copie dans le
projet. En cas d'échec précédent la fusion, le projet issu du template reste
utilisable. La fusion réutilise les mécanismes de copie vérifiant chaque
échec et nettoie les fichiers temporaires.

## Risks / Trade-offs

- [Une erreur pendant une fusion peut laisser certains fichiers distants déjà
  remplacés] → vérifier chaque copie et conserver la copie temporaire jusqu'à
  la fin ; signaler l'erreur explicitement.
- [Le dépôt distant peut contenir `project.env`] → sa version remplace celle
  du template conformément à la priorité demandée pour les chemins
  homonymes ; la configuration Forgejo saisie avant clonage est utilisée pour
  l'opération en cours.
- [Un dépôt privé nécessite des credentials valides] → déléguer au provider
  Forgejo et interrompre avant la fusion si les credentials sont absents ou
  invalides.

## Migration Plan

La commande est additive et ne modifie aucun appel existant. En cas de
régression, retirer le routage et la fonction associés restaure le
comportement antérieur ; les projets déjà créés ne sont pas modifiés par ce
retrait.
