## Context

Le module `modules/projects/projects.sh` contient déjà la création et la
configuration d'un projet ; le routeur des projets est dans
`root-install-debian.sh` et l'aide contextuelle dans `lib/rid-help.sh`.
La synchronisation demandée est distincte de la création : elle doit copier
une sélection fermée d'éléments et ne modifier que les Markdown issus de cette
sélection. Voir `proposal.md` et les deltas de spécification pour le contrat
fonctionnel.

## Goals / Non-Goals

**Goals:**

- Synchroniser une liste explicite de ressources du modèle autoritaire.
- Vérifier tous les prérequis avant de modifier le projet destination.
- Personnaliser les Markdown du modèle sans réécrire les Markdown existants.
- Préserver les autres fichiers du projet, y compris ses métadonnées Git.

**Non-Goals:**

- Modifier `create_project` ou son comportement de copie global.
- Ajouter, supprimer ou initialiser un dépôt Git.
- Synchroniser `project.env`, des éléments non listés ou des secrets.
- Modifier le modèle local.

## Decisions

- La commande publique est `rid projects sync <ID PROJECT>` et délègue au
  nouveau traitement de synchronisation du module projets. Le routage traite
  `help` et `?` comme une demande d'aide avant toute synchronisation.
- Le traitement charge `project.env` pour vérifier que `PROJECT_ID` est égal à
  l'argument et obtenir `PROJECT_NAME`. Cela réutilise la convention actuelle
  de métadonnées de projet et évite toute valeur demandée interactivement.
- La liste des trois fichiers et quatre répertoires est codée explicitement.
  Les sources sont toutes validées avant les copies ; une ressource manquante
  est donc une erreur plutôt qu'une synchronisation silencieusement partielle.
- Les éléments du modèle sont d'abord copiés dans un répertoire temporaire,
  puis les seuls Markdown de cette copie y sont personnalisés avant leur
  installation dans la destination. Cette isolation garantit que la recherche
  de Markdown ne peut pas atteindre un fichier préexistant du projet.
- La copie vers la destination fusionne les répertoires gérés et écrase leurs
  fichiers homonymes, sans suppression des éléments destination non fournis
  par le modèle. Cette règle applique la priorité du modèle sans introduire
  un nettoyage non demandé.
- La propriété des éléments synchronisés est attribuée à
  `${DEVOPS_USER}:${DEVOPS_GROUP}`, conformément aux autres opérations de
  projets. `cp -a` est retenu pour préserver le contenu et les métadonnées
  utiles ; aucune dépendance supplémentaire n'est requise.

## Risks / Trade-offs

- [Une erreur lors de l'installation destination intervient après les
  prérequis] → les prérequis et la préparation sont terminés avant la copie ;
  un échec d'écriture reste signalé explicitement, sans prétendre à une
  transaction multi-fichiers que le système de fichiers ne fournit pas.
- [Le modèle contient un contenu non souhaité dans un répertoire géré] → le
  modèle est explicitement la source de vérité pour cette sélection ; les
  autres chemins ne sont pas parcourus.
- [Les substitutions contiennent des caractères spéciaux] → les valeurs sont
  échappées avant la substitution afin de conserver leur contenu littéral.

## Migration Plan

1. Ajouter les deltas OpenSpec et les tests ciblés.
2. Ajouter le routage, le traitement de synchronisation et l'aide.
3. Vérifier la syntaxe Bash, ShellCheck, les tests ciblés et OpenSpec.

Le repli consiste à ne plus exécuter la nouvelle commande ; elle n'altère pas
les commandes existantes.
