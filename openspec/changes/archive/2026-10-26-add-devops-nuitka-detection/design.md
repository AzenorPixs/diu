## Context

Le mode Cython du helper de dépendances lit [build-system].requires puis réutilise les sondes isolées de venv. Un ajout par appel séparé produirait deux rubriques et dupliquerait recherche et sondes.

## Decisions

- Généraliser ce mode en compilation avec deux distributions autorisées : cython et nuitka. Conserver l’alias interne cython pour les appels existants ; le rendu utilise compilation.
- Analyser le manifeste avant toute découverte. Retenir seulement les outils déclarés ; le nom exclut les extras et contraintes. Une autre table ou un commentaire ne déclenche pas cet inventaire. Les références directes restent masquées et les marqueurs déclaratifs sans résolution.
- Faire une seule découverte et partager les sondes pour les noms encore recherchés. Conserver les limites 3 secondes par sonde et 12 secondes de recherche/sondes, sans import ni .pth.
- Émettre un seul titre, puis Cython et Nuitka selon leur déclaration. L’état, les métadonnées et la provenance de chaque outil restent indépendants, même avec plusieurs venv ou une métadonnée ambiguë pour l’autre outil.
- Garder version observée, non installé si l’absence est prouvée, installation non vérifiable sinon. Sans venv, le résultat reste non vérifiable. Aucun paquet global en repli. Les erreurs de déclaration impossibles à attribuer à un outil utilisent un diagnostic commun explicite.

## Risks and rollback

Les risques sont une rubrique double, l’affichage ou la sonde d’un outil non déclaré et la contamination de l’état d’un outil par celui de l’autre. Des tests dédiés couvrent les quatre combinaisons de déclarations, les provenances distinctes, les absences, erreurs et limites. La suite Cython existante reste applicable. Aucun état métier à migrer ; les changements de source sont réversibles en rétablissant les seuls fichiers de cette évolution.

## Documentary consistency

TECHNICAL.md, README.md et CHANGELOG.md décrivent les deux outils. La spécification adapte les clauses Cython qui conditionnaient toute la rubrique à sa seule présence. AGENTS.md, PROJECT.md, BUILD.md et le relevé DEVOPS.md réel restent inchangés. L’archive Cython antérieure reste inchangée.
