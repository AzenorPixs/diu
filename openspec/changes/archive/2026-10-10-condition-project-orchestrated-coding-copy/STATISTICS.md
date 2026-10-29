# STATISTIQUES — condition-project-orchestrated-coding-copy

Session SCM directe sur DIU, périmètre proposé puis explicitement validé par
le développeur avec « Je valide » le 2026-10-10 : spécification, code, tests,
documentation, réconciliation des chevauchements, archivage du seul change
dédié et rapport. Aucune compétence ni télémétrie de session pilotée utilisée.

## 1. Statistiques générales et décisions

| Mesure | Valeur |
| --- | ---: |
| Méthodes distinctes dans les exécutions finales | 214 |
| Méthodes finales réussies / échouées / ignorées | 212 / 0 / 2 |
| Exécutions de méthodes, répétitions comprises | 312 |
| Exécutions réussies / échouées / ignorées | 307 / 1 / 4 |
| Tâches du change prouvées et cochées | 7 / 7 |
| Archives réalisées | 1 |
| Exigences ajoutées / modifiées / retirées / renommées | 4 / 1 / 0 / 0 |
| Fichiers préexistants modifiés | 9 |
| Fichiers nouveaux livrés, rapport compris | 8 |
| Total des fichiers livrés | 17 |

Agent unique : Codex. Sous-agents : aucun. Durée globale, temps actif, tokens,
coût, quotas et modèle exact : N/A, aucun chronométrage global ni télémétrie
exploitable. Les durées des suites sont celles des sorties unittest, sans
estimation du temps global. Le changement documentaire ne lance aucun service.

## 2. Messages et outils

Comptages exhaustifs des messages et appels d'outils : N/A, aucun journal
exhaustif exporté. Écritures avec apply_patch ; validations par commandes
natives. Les témoins SHA-256 et les contenus canoniques avant synchronisation
ont été conservés en mémoire pour contrôler le périmètre sans Git.

La suite de copie conditionnelle a été exécutée deux fois (10 méthodes
chacune), la seconde après ajout des scénarios de défaut interactif et de
source non régulière à la création. La suite DevOps a été exécutée deux fois
(88 méthodes chacune) : échec sandbox puis relance hors sandbox réussie.
Les quatre autres suites totalisent 116 méthodes, exécutées une fois.
Aucun test n'a été affaibli ni diagnostic supprimé pour obtenir un succès.

## 3. Fichiers modifiés

Neuf fichiers préexistants modifiés :

- `modules/projects/projects.sh` : uniquement sync_project et create_project,
  lecture du mode destination, contrôle de la source requise, sélection des
  copies et propriété du document conditionnel ; exclusions existantes conservées ;
- `TECHNICAL.md` : Métadonnées générales, copie, préservation et échecs ;
- `README.md` : condition de copie à la création et à la synchronisation ;
- `CHANGELOG.md` : entrée Unreleased ;
- `openspec/specs/projects-sync/spec.md` : une exigence modifiée ;
- `openspec/specs/implement-projects-update/spec.md` : quatre exigences ajoutées ;
- `openspec/changes/add-projects-sync-broker/specs/projects-sync/spec.md` :
  même exception conditionnelle dans la sélection réduite déjà implémentée ;
- `openspec/changes/refactor-projects-template-copy/specs/projects-template-creation/spec.md` :
  même réserve conditionnelle dans l'exigence et les scénarios de copie ;
- `openspec/changes/refactor-projects-template-copy/proposal.md` : réserve
  conditionnelle explicitée.

Huit fichiers nouveaux livrés : `tests/test_projects_orchestrated_copy.py`
et les sept fichiers de cette archive : `.openspec.yaml`, `proposal.md`,
`design.md`, `tasks.md`, les deux deltas `specs/*/spec.md` et ce rapport.
Les six artefacts du change ont été déplacés par OpenSpec à l'archivage.
Aucun fichier métier n'a été supprimé.

Neuf témoins restent identiques : AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md,
root-install-debian.sh, modules/projects/template.sh, modules/projects/git.sh,
tests/test_projects.py et tests/test_projects_orchestrated_coding.py.
Dans les deux canons, les dix exigences antérieures non ciblées sont intactes.
Le contrôle porte sur les témoins ciblés, sans inventaire exhaustif du dépôt.

## 4. Commandes et validations

Les commandes utilisent les chemins déclarés par DEVOPS.md. Les suites sont
exécutées depuis la racine avec le Python DevOps :

```text
/home/devops/python/current/bin/python3 -B tests/test_projects_orchestrated_copy.py
/home/devops/python/current/bin/python3 -B tests/test_projects.py
/home/devops/python/current/bin/python3 -B tests/test_projects_orchestrated_coding.py
/home/devops/python/current/bin/python3 -B tests/test_rid_help.py
/home/devops/python/current/bin/python3 -B tests/test_projects_template_openspec.py
/home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py
```

| Suite finale | Réussis | Échecs | Ignorés |
| --- | ---: | ---: | ---: |
| test_projects_orchestrated_copy.py | 10 | 0 | 0 |
| test_projects.py | 26 | 0 | 0 |
| test_projects_orchestrated_coding.py | 17 | 0 | 0 |
| test_rid_help.py | 56 | 0 | 0 |
| test_projects_template_openspec.py | 17 | 0 | 0 |
| test_projects_template_devops.py, hors sandbox | 86 | 0 | 2 |
| Total | 212 | 0 | 2 |

Les deux cas DevOps ignorés exigent un utilisateur non root ; ils ne sont pas
revendiqués comme réussis. La première exécution DevOps a compté 85 réussites,
un échec sur chown d'un document temporaire et deux cas ignorés. Sa relance
hors sandbox a réussi sans modification de module ni de test (65,143 s).
La première exécution a duré 63,973 s. Les autres durées rapportées sont
1,166 s puis 1,076 s pour la copie conditionnelle, 1,805 s pour les projets,
0,780 s pour le mode, 1,491 s pour l'aide et 1,204 s pour le modèle OpenSpec.

| Validation | État et preuve |
| --- | --- |
| `bash -n modules/projects/projects.sh` | Exécutée et réussie |
| `python3 -m py_compile tests/test_projects_orchestrated_copy.py` | Exécutée et réussie avec le Python DevOps ; cache temporaire sous la racine, supprimé automatiquement |
| ShellCheck des fonctions sync_project et create_project | Exécutée et réussie, sans exclusion de règle |
| ShellCheck du fichier complet | Exécutée et échouée avant/après sur le seul SC2004 préexistant de keys[${index}], hors périmètre |
| Change dédié strict avant code et avant archive | Exécutée et réussie après découpage de l'exigence initiale trop longue |
| Changes actifs réconciliés stricts | Exécutée et réussie pour add-projects-sync-broker et refactor-projects-template-copy |
| Archivage avec synchronisation | Exécutée et réussie, specsUpdated: true ; 4 ajouts et 1 modification |
| Canon implement-projects-update strict, avant/après | Exécutée et réussie |
| Canon projects-sync strict avant | Exécutée et échouée avec deux avertissements préexistants de longueur, requirements[1] et requirements[2] |
| Canon projects-sync strict après | Exécutée et échouée avec le seul avertissement préexistant requirements[1], inchangé |
| Canon projects-sync non strict après | Exécutée et réussie avec cet avertissement signalé |
| Deltas archivés et canons | Concordance exacte des cinq blocs ciblés ; dix anciens blocs non ciblés identiques |
| UTF-8/LF et périmètre | Contrôles ciblés réussis avant archive ; rapport et fichiers livrés contrôlés à la clôture |
| Construction Debian, navigateur, déploiement | Non exécutés, non pertinents pour cette sélection de fichiers Bash |

L'exigence modifiée de projects-sync a été raccourcie sous 500 caractères ;
l'avertissement requirements[2] est donc éliminé. requirements[1] concerne
Source de synchronisation contrôlée, inchangée. Aucune réussite stricte globale
du dépôt n'est revendiquée ; les blocs de ce change sont valides.

OpenSpec a utilisé `/home/devops/.local/npm/bin/openspec` :

```text
openspec validate condition-project-orchestrated-coding-copy --type change --strict
openspec validate add-projects-sync-broker --type change --strict
openspec validate refactor-projects-template-copy --type change --strict
openspec archive condition-project-orchestrated-coding-copy --yes --json
openspec validate implement-projects-update --type spec --strict
openspec validate projects-sync --type spec --strict
openspec validate projects-sync --type spec
```

L'archivage autorisé a utilisé OPENSPEC_TELEMETRY=0 et DO_NOT_TRACK=1,
sans --skip-specs ni --no-validate. Le rapport clôt la tâche d'archivage ;
les autres changes actifs restent hors archivage.

## 5. Accès web et effets externes

Aucun outil web, appel API métier, installation, publication, migration,
activation OpenCode/CAB ni synchronisation d'un projet réel n'a été exécuté.
Les nouvelles fixtures et le cache de compilation sont sous la racine et
nettoyés automatiquement. Les suites existantes emploient leurs temporaires
habituels. Les opérations externes des nouvelles fixtures sont simulées,
y compris chown, OpenSpec et génération DevOps ; les assertions de propriété
vérifient les arguments transmis, pas une qualification de propriétaire en
production. Les attributs préservés en mode No sont contrôlés sur disque.

Écart de protocole : une inspection initiale git status --short a précédé
la lecture de l'interdiction SCM. Elle a été signalée et n'a pas été répétée.
Aucune écriture Git, préparation de commit, branche, commit ou push réalisée.
La relance hors sandbox a été acceptée par le contrôle de la plateforme ;
aucun rejet automatique d'approbation ni contournement de demande interactive.

## 6. Synthèse globale et cohérence documentaire

Le protocole racine du modèle est copié et personnalisé uniquement pour Yes
lu dans la configuration destination. Pour No, absence ou vide : pas de copie
ni de suppression, préservation d'un document destination et de ses attributs.
Un mode invalide ou une source requise absente/non régulière échoue avant la
copie du modèle. À la création, la configuration préparée reste disponible
en cas d'échec. sync all décide par projet et poursuit après une erreur.

| Élément | État et preuve |
| --- | --- |
| Projet réel | Sources livrées, 212 réussites finales ; aucune synchronisation réelle ni installation |
| AGENTS.md | Inchangé, empreinte identique ; règles générales et distinction SCM/pilotage conservées |
| PROJECT.md | Inchangé, empreinte identique ; Architecture fonctionnelle / Module projects couvre le périmètre |
| TECHNICAL.md | Mis à jour dans Projets et configuration Git / Métadonnées générales |
| BUILD.md | Inchangé, empreinte identique ; Objet concerne la construction du paquet, aucun impact sur son contenu ou sa chaîne |
| DEVOPS.md | Inchangé, empreinte identique ; inventaire généré et chemins des runtimes réutilisés |
| README.md | Mis à jour : condition Yes, préservation en No et source requise |
| CHANGELOG.md | Entrée Unreleased ajoutée ; aucune version ou date de publication inventée |
| OpenSpec | 4 ajouts, 1 modification, 7 tâches closes, 1 archive ; deux changes actifs réconciliés et conservés |
| ORCHESTRATED_CODING.md racine | Absent, facultatif pour SCM ; non créé ni restauré |

Le canon projects-sync historique cite encore les ressources OpenCode alors
que leur retrait est déjà implémenté et couvert par le change actif
add-projects-sync-broker. Ce retrait n'est ni annulé ni archivé ici ; son delta
conserve maintenant la nouvelle condition pour un futur archivage. De même,
l'exclusion Git prévue dans refactor-projects-template-copy n'est pas
implémentée dans cette session. Ces écarts préexistants sont explicites et ne
remettent pas en cause la cohérence ciblée de la condition documentaire.

Totaux vérifiés : 10 + 26 + 17 + 56 + 17 + 88 = 214 méthodes finales ;
212 réussies + 2 ignorées = 214. Répétitions : 214 + 10 + 88 = 312 ;
307 réussies + 1 échec sandbox + 4 ignorées = 312. Fichiers : 9 préexistants
+ 8 nouveaux = 17, dont 7 dans cette archive. Exigences : 4 ajoutées
+ 1 modifiée = 5. Aucun retrait ni renommage d'exigence.

Limites conservées : SC2004 hors périmètre, avertissement canonique de longueur,
deux tests nécessitant non-root non exécutés, aucune qualification de production.
Les six sections, les totaux, UTF-8/LF, tâches et concordance des deltas font
l'objet du contrôle final du rapport et de l'archive.
