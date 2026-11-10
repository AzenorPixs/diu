## 1. Spécification

- [x] 1.1 Définir et valider les deltas RFC 2119 et réconcilier les deux changes actifs sans les archiver.

## 2. Implémentation et documentation

- [x] 2.1 Conditionner la copie, la personnalisation et les droits à la synchronisation unitaire et groupée.
- [x] 2.2 Conditionner la copie racine lors de la création en préservant les exclusions existantes.
- [x] 2.3 Couvrir les scénarios avec des projets synthétiques et mettre à jour les trois documents concernés.

## 3. Validation et clôture

- [x] 3.1 Vérifier syntaxe Bash/Python, ShellCheck du périmètre et suites ciblées.
- [x] 3.2 Vérifier UTF-8/LF, périmètre et matrice documentaire, puis valider les changes et capacités concernés.
- [x] 3.3 Synchroniser et archiver uniquement ce change, puis produire et vérifier STATISTIQUES.md.

## Preuves de validation

- Change validé en mode strict avant code, après découpage d'une exigence
  initialement trop longue ; quatre exigences ajoutées et une modifiée.
- bash -n réussi ; compilation du nouveau test avec le Python DevOps et un
  cache temporaire sous la racine, supprimé automatiquement.
- ShellCheck des deux fonctions modifiées réussi sans exclusion de règle.
  ShellCheck complet échoue avant/après sur le seul SC2004 préexistant de
  project_env_set_variables, conservé hors périmètre.
- Suites finales : copie conditionnelle 10, projets 26, mode de développement
  17, aide CLI 56, modèle OpenSpec 17, modèle DevOps 88 dont 2 ignorés
  car nécessitant un utilisateur non root. Soit 214 méthodes, 212 réussies,
  aucun échec final et 2 ignorées. Le nouveau test a été exécuté deux fois.
- La suite DevOps a initialement échoué dans le sandbox sur chown d'un
  document temporaire ; sa relance autorisée hors sandbox réussit. Le module
  template.sh n'a pas changé (empreinte identique).
- Les deux changes actifs réconciliés sont strictement valides ; leurs
  autres tâches et leur archivage restent hors périmètre.
- La capacité implement-projects-update est strictement valide avant
  synchronisation. projects-sync possède deux avertissements de longueur
  préexistants en validation stricte ; l'exigence modifiée ici a été raccourcie
  sans changer les autres copies spécifiées. Le premier avertissement, dans
  Source de synchronisation contrôlée, n'est pas corrigé hors périmètre.

## Revue documentaire avant archivage

| Document | État et preuve |
| --- | --- |
| Projet réel | Sources adaptées, tests sur fixtures ; aucune synchronisation réelle |
| AGENTS.md | Inchangé, empreinte identique ; règles générales et protocole SCM conservés |
| PROJECT.md | Inchangé, empreinte identique ; Architecture fonctionnelle / Module projects couvre la gestion des projets |
| TECHNICAL.md | Métadonnées générales : condition de copie, défaut, échecs et distinction des commandes template |
| BUILD.md | Inchangé, empreinte identique ; Objet limité au paquet Debian, sans impact sur sa construction |
| DEVOPS.md | Inchangé, empreinte identique ; inventaire et chemins des outils réutilisés |
| README.md | Présentation de Yes/No complétée avec la copie et la préservation du protocole |
| CHANGELOG.md | Entrée Unreleased ajoutée sans version ni date de publication inventée |
| OpenSpec | Deltas conditionnels cohérents avec les deux changes actifs réconciliés ; aucune reprise de leurs autres objectifs |
| ancien protocole local racine | Absent, optionnel pour SCM, non créé |

Les témoins du routage, des modules git.sh et template.sh et des deux suites
de tests existantes sont identiques. Le contrôle est ciblé, sans inspection Git
ni prétention d'inventaire exhaustif du dépôt. La sélection réduite de sync
est déjà couverte par le change actif add-projects-sync-broker ; ce change
conditionnel ne rétablit pas les copies OpenCode/CAB encore citées par le canon
historique. Leur retrait canonique reste à l'archivage de l'autre change.
