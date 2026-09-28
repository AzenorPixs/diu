## Decisions

- Conserver le bootstrap de configuration ; les fonctions infos elles-mêmes
  affichent les valeurs et ne modifient aucun service ni fichier.
- Appeler directement les fonctions des modules dans l'agrégateur infos,
  sans récursion ni invocation du programme rid. Ordre explicite : desktop,
  diu, environnements, ia, projects, softwares, system.
- Le dossier environments conserve son nom, la commande est environnements.
- system_info appelle debian puis network. Les agrégateurs continuent après
  une erreur et renvoient un statut non nul si une sous-fonction échoue.
- Les fonctions des autres modules sont des points d'extension avec titre.
  diu_infos réutilise diu_version : version du paquet installé, diagnostic
  explicite si elle n'est pas disponible, sans inventer une version de sources.
- Préserver l'appel réseau dans le parcours historique sous son nouveau nom.
- Rejeter les arguments excédentaires, les feuilles inconnues et les actions
  non reconnues des nouvelles classes, avec aide contextuelle.
- Afficher NOM=valeur ; variable absente -> UNSET, valeur vide conservée.
  Utiliser une liste explicite, sans exposer toute la configuration locale.

## Validation

Tests isolés : contenu/ordre Debian et global, interfaces UP/DOWN, valeurs
absentes/vides, version disponible/absente, propagation des échecs, routage
et absence de poursuite du parcours d'installation. Aide réelle testée avant
le bootstrap. Bash -n et ShellCheck, comparaison aux diagnostics préexistants
pour le monolithe. Aucun appel réel à l'installateur ou configuration locale.
