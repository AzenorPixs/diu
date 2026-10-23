# STATISTIQUES — Préparation des exécutables DevOps avant le relevé des versions

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 23 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, périmètre autonome explicitement validé après
  proposition, avec implémentation, tests, documentation, archivage et rapport.
- Change : `ensure-devops-tool-executable-permissions`.
- Archive : `2026-10-23-ensure-devops-tool-executable-permissions`.
- Objet : préparer les droits d'exécution des sept outils DevOps connus
  avant les inventaires et sondes, sans installation ni parcours récursif.
- Sources de preuve : commandes et sorties de cette session,
  [tasks.md](tasks.md), [design.md](design.md) et
  [delta OpenSpec](specs/projects-template-devops/spec.md).

La session est exécutée directement. La compétence de télémétrie réservée aux
sessions SCMP n'est pas invoquée ; aucun pilotage CAB/OpenCode n'est lancé.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Capture des empreintes initiales | 2026-10-23T13:07:29.104Z |
| Point de mesure avant le rapport | 2026-10-23T13:20:36.250Z |
| Intervalle partiel mesuré | 787,146 s entre ces deux points ; hors exploration antérieure et contrôles suivant ce point |
| Durée globale complète | N/A : les échanges précédant cette reprise ne sont pas chronométrés globalement |
| Première suite unittest | 77,476 s ; 113 méthodes, un échec |
| Suite unittest finale | 77,948 s ; 113 méthodes, toutes réussies |
| Total des durées unittest | 155,424 s = 77,476 + 77,948 ; hors édition, lint et OpenSpec |
| Tokens, coût, CPU et mémoire | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie |
| Approbations CAB | N/A : SCM directe, sans protocole CAB |

## 3. Fichiers et contrat livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 5 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **11** | **1 + 1 + 3 + 1 + 5** |

Six fichiers existants sont modifiés et cinq documents sont présents dans
l'archive finale. Les quatre artefacts du change actif ont été déplacés par
OpenSpec ; le rapport a été ajouté ensuite. Aucun fichier préexistant hors
de ce déplacement OpenSpec n'est supprimé ou renommé.

La préparation traite uniquement, sous `/home/${ENV_DEVOPS_USER}` :

- `go/current/bin/go` ;
- `node/current/bin/node` ;
- `node/current/bin/npm` ;
- `.opencode/bin/opencode` ;
- `.local/npm/bin/openspec` ;
- `python/current/bin/python3` ;
- `python/current/bin/pip3`.

Elle ajoute les bits `ugo+x` manquants, conserve propriétaire et droits de
lecture et d'écriture, et ne réapplique pas chmod si les trois bits sont
déjà présents. Les liens sont conservés et leur cible ordinaire est confinée
au domicile canonique. Les outils absents ne sont pas créés ; les cibles
externes ou non ordinaires et les erreurs de préparation bloquent le rendu.
Le document précédent reste conservé ; les droits déjà ajoutés persistent
si une étape suivante échoue. Les sondes directes distinguent binaire absent
et binaire présent non exécutable sans corriger ses droits elles-mêmes.

Les outils hôte, les autres fichiers, le format documentaire 0.6, les
commandes, les utilisateurs et interpréteurs de sonde ainsi que la borne de
15 secondes sont préservés. Les parcours individuel, groupé et de création
utilisent le même rendu. Le code ne déploie pas cette modification dans
l'installation de production.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Première suite | 113 | 112 | 1 | 0 | 0 |
| Suite finale après correction de l'isolation | 113 | 113 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **226** | **225** | **1** | **0** | **0** |

Les 113 méthodes distinctes ont toutes réussi lors de la dernière exécution :
103 préexistantes et 10 nouvelles. Les sous-tests ne sont pas comptés comme
méthodes supplémentaires.

La nouvelle couverture vérifie les sept outils sans droit d'exécution avant
l'inventaire JavaScript et les versions, les propriétaires et modes, les
fichiers hôte et non listés, l'idempotence sans modification de ctime, les
liens de fichiers et de dossiers `current` internes, les liens externes, les
objets non ordinaires, les absences et liens cassés internes, les refus de
chmod, les erreurs de résolution et de lecture de mode, et les diagnostics
des sondes directes.

Commande de suite exécutée deux fois :

```bash
env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py
```

| Contrôle | État et résultat réellement observé |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, aucun diagnostic |
| Compilation du test Python | Exécutée et réussie avant les tests et après la correction de l'isolation, via py_compile.compile avec doraise=True ; cfile temporaire sous la racine, automatiquement nettoyé |
| Change OpenSpec strict avant le code | Première tentative échouée pour longueur d'exigence ; texte réparti en quatre exigences puis validation réussie avant toute écriture de code et de test |
| Change OpenSpec strict avant archivage | Exécuté et réussi |
| Delta archivé final en mode strict | Exécuté et réussi dans une fixture temporaire isolée, avec le canon initial reconstruit et vérifié par les empreintes de ses 45 exigences ; fixture nettoyée |
| Validation directe par l'ancienne commande change validate sur un chemin d'archive | Exécutée et échouée : archive non reconnue comme change actif ; remplacée par la validation isolée ci-dessus, sans réarchivage |
| Canon OpenSpec ordinaire | Exécuté et réussi avant et après synchronisation ; huit avertissements de longueur identiques |
| Contrôle OpenSpec global strict avant archivage | Exécuté et échoué : 46 éléments valides, 22 en échec, total 68 incluant le change actif |
| Contrôle global strict immédiatement après archivage | Exécuté et échoué : 45 éléments valides, 22 en échec ; un avertissement de longueur supplémentaire dans l'exigence modifiée a été détecté puis corrigé |
| Contrôle global strict final | Exécuté et échoué : 45 éléments valides, 22 en échec, total 67 ; les huit avertissements du canon initial sont retrouvés sans nouvel avertissement |
| Synchronisation du canon | Contrôle réussi : 45 exigences initiales, 49 finales ; quatre ajoutées, une modifiée, 44 préservées ; les cinq blocs du delta correspondent au canon final |
| Empreintes et périmètre | Contrôle réussi sur 77 fichiers de référence : six modifications prévues, 71 fichiers inchangés ; huit empreintes figées avant archivage restent identiques, le delta ayant reçu la correction rédactionnelle décrite |
| UTF-8/LF, absence de BOM | Contrôle réussi sur les dix fichiers avant le rapport ; contrôle final incluant le onzième fichier |
| Temporaires de test et compilation | Aucun résidu des préfixes propres à cette session |
| Installation de production, autres modules, test de génération sur le domicile réel | Non exécutés : hors périmètre |

Tous les appels OpenSpec utilisent explicitement le Node DevOps
`/home/devops/node/current/bin/node` et le programme
`/home/devops/.local/npm/bin/openspec`, avec `OPENSPEC_TELEMETRY=0`.
Les validations emploient `validate`, `--type change`, `--type spec`,
`--strict`, `--all` et `--json` selon le contrôle.

Un premier contrôle auxiliaire d'extraction d'empreintes a échoué en raison
d'une expression régulière trop large et d'une sortie tronquée. Il a été
corrigé et repris en lecture seule ; les contrôles finaux ci-dessus sont
réussis.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Fonction prepare_executables appelée dans le rendu après la capture temporelle et avant inventaires et sondes ; 113 méthodes distinctes réussies |
| AGENTS.md | Inchangé, empreinte et mode conservés ; périmètre approuvé, rapport d'archive et encodage respectés ; incident de test extérieur explicité en section 6 |
| PROJECT.md | Inchangé, empreinte et mode conservés ; responsabilités du module projects et architecture préservées |
| TECHNICAL.md | Mis à jour dans Traçabilité du document DevOps : sept outils, confinement, droits, échecs et reprise |
| BUILD.md | Inchangé, empreinte et mode conservés ; aucun changement de construction, dépendance ou installation |
| DEVOPS.md | Inchangé, empreinte et mode conservés ; aucune régénération du document courant, conformément au périmètre validé |
| README.md | Mis à jour dans la présentation de la génération DevOps : préparation, limites et adoption à la prochaine génération |
| CHANGELOG.md | Entrée Unreleased ajoutée, sans version ou date de publication inventée |
| openspec/specs/ | projects-template-devops synchronisée ; quatre exigences ajoutées, Écriture limitée et robuste modifiée pour autoriser la préparation connue hors du projet ciblé ; 44 exigences préservées |

Commande d'archivage réellement exécutée :

```bash
env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive ensure-devops-tool-executable-permissions --yes
```

Elle retourne zéro, confirme les tâches complètes, synchronise quatre ajouts et
une modification, puis annonce l'archive ciblée. Le change actif est absent
et les quatre artefacts archivés sont présents avant création du rapport.
Aucun autre change n'est archivé et aucun réarchivage n'est effectué.

L'exigence modifiée de 661 caractères produisait après synchronisation un
avertissement de longueur supplémentaire. Sa formulation a été ramenée à
498 caractères dans le canon et le delta archivé, sans changer le contrat ni
les scénarios. Le delta final a ensuite été validé strictement dans la fixture
isolée et sa concordance avec le canon a été vérifiée.

| Résultat | Nombre |
| --- | ---: |
| Tâches préalables cochées | 6 sur 6 |
| Exigences ajoutées | 4 |
| Exigences modifiées | 1 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Changes archivés | 1 |
| Documents finaux dans l'archive | 5 |

Les opérations d'archivage et de rapport sont décrites séparément des tâches
préalables pour éviter de les cocher avant leur réalisation. Le contrôle
final du rapport vérifie six sections, 11 fichiers, les totaux
226 = 225 + 1 + 0 + 0, 113 = 103 + 10 et 49 = 45 + 4, les six tâches cochées,
les empreintes témoins, l'encodage et l'absence de temporaires.

## 6. Limites, incident et état terminal

Le périmètre demandé est implémenté, testé, documenté, synchronisé et archivé.
Le contrôle global strict du dépôt reste en échec sur 22 éléments préexistants :
19 spécifications avec avertissements, un ancien change d'architecture avec
avertissement et deux anciens changes Forgejo omettant des scénarios du canon
(`modify-projects-forgejo-push-force-with-lease` et
`restore-forgejo-push-to-create`). Ces éléments restent hors périmètre.
Le canon ciblé est valide en mode ordinaire, avec ses huit avertissements de
longueur préexistants ; le delta final est valide en mode strict.

Lors de la première suite, un test préexistant de chemins de prompts simulait
l'identité DevOps mais conservait le domicile réel. La nouvelle préparation
a donc transitoirement passé le mode de l'OpenCode installé de 664 à 775,
avant l'échec du sous-test utilisant le domicile inexistant ci-builder.
Le mode initial 664 a été immédiatement restauré. Les six autres outils
réels possédaient déjà leurs trois bits d'exécution et ont conservé des
métadonnées de changement antérieures à la session. Le ctime d'OpenCode a été
modifié par cet ajout puis sa restauration et ne peut pas être rétabli.

Le test de chemins isole désormais la préparation, comme il isolait déjà les
sondes et identités ; ses assertions de chemins sont conservées. Les dix
nouveaux tests exercent la préparation réelle sur leurs seules fixtures dans
le dépôt. La suite complète finale réussit et le mode réel OpenCode 664 a été
revérifié. Aucun processus OpenCode n'a été lancé, fermé ou redémarré.

DEVOPS.md courant n'est pas régénéré et l'installation de production n'est
pas mise à jour. Les prochaines générations utilisant ces sources prépareront
les droits comme décrit. Aucun état Git n'est inspecté et aucun commit, push,
branche, tag ou release n'est créé. Aucun service partagé n'est modifié.

