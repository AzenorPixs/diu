## 1. Spécification et implémentation

- [x] 1.1 Réorienter et valider le change pour la synchronisation limitée.
- [x] 1.2 Limiter les contrôles, copies et droits à AGENTS.md, .gitignore
      et PROMPTS, sans copie OpenCode ou CAB locale ou globale.
- [x] 1.3 Couvrir les variantes unitaire et groupée, l'absence des sources
      exclues et la préservation des destinations existantes ou absentes.

## 2. Validation

- [x] 2.1 Exécuter bash -n, ShellCheck et la compilation Python.
- [x] 2.2 Exécuter les tests projets et d'aide CLI.
- [x] 2.3 Vérifier le périmètre, UTF-8/LF, les sources et cadrages applicables
      et la conformité des exigences à la RFC 2119.
- [x] 2.4 Valider le change et la capacité projects-sync en mode strict
      et vérifier l'éligibilité à l'archivage du seul change ciblé.

## Preuves historiques (avant la reprise RSM)

- Périmètre autonome validé le 2026-10-03 : retrait des copies OpenCode et
  CAB des projets et du broker global, avec spécification et archivage ciblé.
- `openspec validate add-projects-sync-broker --strict` : exécutée et réussie
  avant l'implémentation, via `/home/devops/.local/npm/bin/openspec`.
- `bash -n modules/projects/projects.sh` : exécutée et réussie.
- `python3 -m py_compile tests/test_projects.py` : exécutée et réussie,
  également avec `/home/devops/python/current/bin/python3`.
- Tests projets : 26 tests exécutés et réussis, y compris les variantes
  unitaire et groupée et les ressources exclues existantes ou absentes.
- Tests d'aide CLI : 56 tests exécutés et réussis.
- Revue sans Git : fonctions et tests hors synchronisation inchangés ;
  empreintes du routage, de l'aide et des cadrages inchangées. Les huit fichiers
  prévus sont UTF-8/LF ; les exigences du delta respectent la RFC 2119.
- Matrice de cohérence : AGENTS.md gouverne les accès ; PROJECT.md conserve
  son architecture ; TECHNICAL.md distingue sync des commandes de templates ;
  DEVOPS.md fournit les chemins des outils ; README.md décrit les publications.
  Aucun de ces cadrages ne devient inexact du fait du retrait. BUILD.md conserve
  des exemples historiques avec `proj`, contrairement à la CLI actuelle :
  écart préexistant hors périmètre, non corrigé.
- Validation finale du change en mode strict : exécutée et réussie.
- Validation de la capacité principale projects-sync en mode strict : exécutée
  et réussie avant synchronisation ; deux conseils informatifs de longueur
  sont signalés sur des exigences préexistantes, sans erreur.
- `shellcheck modules/projects/projects.sh` : exécutée et échouée sur
  SC2004 dans `project_env_set_variables`, hors synchronisation. Le même
  diagnostic est observé sur la version initiale conservée en mémoire.
  La correction d'une ligne attend une extension explicite du périmètre.
- Aucune synchronisation réelle, opération Git ou mise à jour de production
  n'a été exécutée. L'archivage reste non exécuté tant que la validation
  applicable n'est pas réussie.

## Reprise RSM du 2026-10-10

### Sélection et limites validées

Le développeur a validé la reprise du seul change add-projects-sync-broker
dans six fichiers : README.md, proposal.md, design.md, tasks.md et
specs/projects-sync/spec.md de ce change, ainsi que
openspec/specs/projects-sync/spec.md. Le code et les tests existants restent
inchangés. L'archivage est interdit tant que le blocage ShellCheck subsiste.
Les neuf autres changes actifs restent hors sélection.

La cible est DIU, conformément à la demande et à AGENTS.md, malgré les
variables Pixs restées dans le modèle PROMPTS/RSM.md. Cette reprise est
directe ; aucun pilotage OpenCode, démarrage CAB ou changement d'infrastructure
n'a été effectué.

### Corrections spécificatives effectuées

- Le delta conserve les six scénarios de l'exigence principale de copie,
  dont « Copie du protocole pour un projet piloté » et « Préservation du
  protocole pour un projet autonome », auparavant omis.
- README.md, proposal.md et design.md précisent la copie conditionnelle de
  ORCHESTRATED_CODING.md selon implement-projects-update : Yes copie le
  document requis ; No, une valeur absente ou vide préserve la destination
  sans exiger la source.
- L'exigence principale « Source de synchronisation contrôlée » est
  raccourcie sans changer ses sources requises ni ses comportements. Le
  retrait OpenCode/CAB reste porté par le delta actif, non synchronisé.
- Aucun scénario ou comportement fonctionnel nouveau n'est introduit.

### Validations observées pendant cette reprise

OpenSpec est exécuté hors sandbox sous devops, via sudo, avec le PATH Node
DevOps explicite, DO_NOT_TRACK=1 et OPENSPEC_TELEMETRY_DISABLED=1.

| Validation | Résultat |
| --- | --- |
| /home/devops/.local/npm/bin/openspec validate add-projects-sync-broker --type change --strict | Exécutée et réussie, code 0 |
| /home/devops/.local/npm/bin/openspec validate projects-sync --type spec --strict | Exécutée et réussie, code 0 |
| bash -n modules/projects/projects.sh | Exécutée et réussie, code 0 |
| shellcheck modules/projects/projects.sh | Exécutée et échouée, code 1 : SC2004 ligne 237 dans project_env_set_variables |
| env TMPDIR=/tmp /home/devops/python/current/bin/python3 -B tests/test_projects.py | Exécutée et réussie : 26 tests |
| env TMPDIR=/tmp /home/devops/python/current/bin/python3 -B tests/test_rid_help.py | Exécutée et réussie : 56 tests |
| env TMPDIR=/tmp /home/devops/python/current/bin/python3 -B tests/test_projects_orchestrated_copy.py | Exécutée et réussie : 10 tests |
| Compilation syntaxique des trois fichiers de tests par py_compile.compile avec doraise=True, via le Python DevOps | Exécutée et réussie ; fichiers compilés temporaires sous /tmp, supprimés en fin de contrôle |
| Comparaison des six scénarios de copie entre la spécification principale et le delta | Exécutée et réussie : aucun scénario omis |
| Contrôle UTF-8/LF, absence d'octet NUL et revue des corrections | Exécuté et réussi ; aucune valeur de secret ajoutée |

Les 92 tests utilisent des projets et modèles synthétiques, avec des fixtures
temporaires sous /tmp ou dans le projet, nettoyées par les tests. Aucune
synchronisation de projet réel, publication distante ou modification du dépôt
Git du projet n'a été réalisée. Les résultats historiques ci-dessus ne
remplacent pas ces preuves actuelles ; notamment, les deux validations
OpenSpec échouaient avant les corrections de cette reprise.

### Matrice de cohérence revue

| Élément | État constaté |
| --- | --- |
| Projet réel | Le code conserve la copie conditionnelle du protocole et exclut OpenCode/CAB ; les tests isolés réussissent ; ShellCheck reste bloquant |
| AGENTS.md | Six fichiers autorisés ; aucun code ni autre change modifié |
| PROJECT.md | Architecture et responsabilités préservées |
| TECHNICAL.md | Copie conditionnelle et distinction sync/templates cohérentes avec le delta ; aucune correction supplémentaire nécessaire |
| BUILD.md | Les exemples CLI ont été corrigés lors du CGP précédent ; la mention contraire des preuves historiques n'est plus un constat actuel |
| DEVOPS.md | Chemins explicites OpenSpec et Python utilisés ; inventaire non assimilé à une qualification fonctionnelle |
| README.md du projet | Copie conditionnelle du protocole déjà décrite, sans modification nécessaire |
| openspec/specs/ | Capacité principale valide ; ancien contrat OpenCode conservé jusqu'à une synchronisation autorisée du delta |

### État à la clôture de la reprise RSM

État : BLOQUÉ pour la finalisation et l'archivage, sans effet inconnu.

La tâche 2.1 reste ouverte : syntaxe et compilation réussissent, mais
ShellCheck échoue. La tâche 2.4 reste ouverte malgré les deux validations
strictes réussies : le change n'est pas éligible à l'archivage tant que ce
contrôle obligatoire échoue. Aucun diagnostic n'a été désactivé et aucun
critère de qualité n'a été abaissé.

La correction SC2004 concerne une ligne de code hors du périmètre RSM ; elle
nécessite une session de codage distincte explicitement autorisée. Après cette
correction, réconcilier les sources et les preuves, puis reprendre au premier
contrôle non prouvé. Ne pas rejouer les corrections spécificatives déjà
effectuées. Aucun archivage, synchronisation du delta ou rapport statistique
d'archive n'a été produit pendant cette reprise.

## Session SCM du 2026-10-10 — correction SC2004

### Mandat et modification

Le développeur a explicitement autorisé la correction de SC2004 ligne 237
dans modules/projects/projects.sh et la vérification des contrôles de ce
change, sans archivage. La session SCM est directe et limitée à cette
correction statique ; les variables Pixs du modèle ne changent pas la cible
DIU. Aucun agent piloté ni service CAB n'a été démarré.

La seule ligne de code modifiée remplace keys[${index}] par keys[index]
dans project_env_set_variables. L'indice d'un tableau indexé Bash est déjà
arithmétique : la variable locale index, son initialisation et son incrément
sont inchangés. Les affectations, interfaces et comportements de configuration
sont préservés. Aucun test ni autre fichier de code n'a été modifié.

La correction lève le contrôle ShellCheck obligatoire de la tâche 2.1 du
change existant ; elle n'ajoute aucune capacité ni exigence fonctionnelle.
CHANGELOG.md reçoit une entrée Unreleased pour cette correction, conformément
à SCM. Le présent fichier conserve les preuves RSM historiques et consigne
les résultats SCM qui les actualisent.

### Contrôles exécutés et résultats

Les tests sont exécutés hors sandbox avec fixtures contrôlées. OpenSpec est
exécuté hors sandbox sous devops, avec le chemin et le PATH Node documentés
dans DEVOPS.md, DO_NOT_TRACK=1 et OPENSPEC_TELEMETRY_DISABLED=1.

| Commande ou contrôle | Résultat |
| --- | --- |
| bash -n modules/projects/projects.sh | Exécuté et réussi, code 0 |
| shellcheck modules/projects/projects.sh | Exécuté et réussi, code 0, aucun diagnostic |
| env TMPDIR=/tmp /home/devops/python/current/bin/python3 -B tests/test_projects.py | Exécuté et réussi : 26 tests |
| env TMPDIR=/tmp /home/devops/python/current/bin/python3 -B tests/test_rid_help.py | Exécuté et réussi : 56 tests |
| env TMPDIR=/tmp /home/devops/python/current/bin/python3 -B tests/test_projects_orchestrated_copy.py | Exécuté et réussi : 10 tests |
| Compilation des trois fichiers de tests par py_compile.compile avec doraise=True, via le Python DevOps | Exécutée et réussie ; fichiers compilés temporaires sous /tmp supprimés en fin de contrôle |
| /home/devops/.local/npm/bin/openspec validate add-projects-sync-broker --type change --strict | Exécuté et réussi, code 0 |
| /home/devops/.local/npm/bin/openspec validate projects-sync --type spec --strict | Exécuté et réussi, code 0 |

Les 92 tests réussissent. Aucun diagnostic n'a été désactivé, aucun test
affaibli et aucun critère de qualité abaissé. Les scénarios et exigences
OpenSpec n'ont pas été modifiés par SCM.

### Bilan documentaire et cohérence

| Document | État et justification |
| --- | --- |
| AGENTS.md | Inchangé : correction limitée et contrôles Bash/Python/OpenSpec respectés ; aucun état Git du projet inspecté |
| PROJECT.md | Inchangé : architecture et fonctionnalités préservées |
| TECHNICAL.md | Inchangé : section Validation technique appliquée ; correction syntaxique sans changement de contrat |
| BUILD.md | Inchangé : aucun changement du packaging ni exécution de build |
| DEVOPS.md | Inchangé : chemins documentés utilisés ; aucun inventaire régénéré |
| README.md du projet | Inchangé : comportements publics et copie conditionnelle préservés |
| CHANGELOG.md | Mis à jour : entrée Unreleased concise sur SC2004, sans version ni date de publication inventée |
| openspec/specs/projects-sync/spec.md | Inchangé pendant SCM : validation stricte réussie ; ancien contrat principal conservé jusqu'à la synchronisation du delta |
| openspec/changes/add-projects-sync-broker/tasks.md | Mis à jour : tâches 2.1 et 2.4 cochées après réussite des contrôles, preuves et limite d'archivage explicites |

### État final SCM et limite volontaire

État de la session SCM : TERMINÉ pour la correction SC2004 et les contrôles
demandés. Les sept tâches du change sont cochées et le blocage ShellCheck
constaté pendant RSM est levé.

Le change reste actif et NON ARCHIVÉ, sur instruction explicite du
développeur. Ses contrôles techniques applicables réussissent ; aucune
commande d'archivage ou de synchronisation OpenSpec n'a été exécutée.
La différence entre l'ancien contrat principal OpenCode et le delta actif
de retrait reste explicitement en attente de synchronisation. Ce constat
ne vaut ni autorisation d'archiver ni déclaration de livraison du cycle
OpenSpec complet.

Aucune synchronisation de projet réel, publication distante, installation,
modification d'infrastructure, opération sur le dépôt Git du projet ou
production de statistiques d'archive n'a été effectuée.
