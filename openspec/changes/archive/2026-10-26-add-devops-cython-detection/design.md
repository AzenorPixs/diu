## Context

Le helper Python embarqué de projects_template_devops_dependencies possède déjà découverte ordonnée des venv et sondes isolées de métadonnées. Son inventaire d’exécution conserve son repli Python DevOps. Le nouveau mode compilation partage ces mécanismes mais n’utilise que les venv du projet.

## Decisions

1. Un paramètre interne optionnel sélectionne Cython, sans modifier les appels d’exécution existants. Le rendu commun appelle ce mode après pip ; le helper émet le titre seulement après analyse TOML et détection dans [build-system].requires.
2. Seuls le nom de distribution Cython et ses contraintes déclarées sont retenus. Commentaires, autres tables et distributions portant un autre nom ne déclenchent aucune sonde Cython. Les références directes sont masquées selon le diagnostic existant ; les contraintes et marqueurs sont déclaratifs, sans résolution.
3. La priorité reste .venv, venv, env, puis les autres chemins triés. Les sondes -I -B -S réutilisent les bornes de 3 secondes par sonde et 12 secondes pour découverte/sondes, sans importer Cython ni charger de .pth. Aucun repli de paquet global ne fournit une installation au projet.
4. Une observation valide fournit version, interpréteur, environnement et installation. Une recherche achevée avec sondes valides sans Cython donne « non installé », avec environnements vérifiés. Un venv absent, brisé, inaccessible, ambigu, une limite ou un échec donne « installation non vérifiable » ; aucune sortie rejetée n’est publiée.
5. Un manifeste absent, illisible, invalide ou un analyseur absent n’autorise jamais la rubrique : le diagnostic de déclaration non vérifiable reste explicite hors de cette rubrique, lorsque nécessaire. L’absence du manifeste est déjà signalée par l’inventaire d’exécution.

## Risks and rollback

Les risques sont une fausse déclaration, une fausse absence, un repli global trompeur ou une régression d’ordre. Les tests isolés vérifient ces frontières, l’absence d’effets de bord et les trois parcours. Les changements sont limités aux sources ; aucune migration ni régénération de document réel n’est nécessaire. Le retour consiste à rétablir les fichiers de ce seul change depuis leur état antérieur, sans toucher aux autres travaux.

## Documentary consistency

AGENTS.md et PROJECT.md : règles et architecture préservées. BUILD.md : packaging inchangé. DEVOPS.md : relevé daté conservé, non régénéré. TECHNICAL.md et README.md : expliquer déclenchement, emplacement, provenance et limites. CHANGELOG.md : entrée Unreleased. Canon OpenSpec : adapter structure, portée Python et provenance, puis ajouter les exigences conditionnelles.
