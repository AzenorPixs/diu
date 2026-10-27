# STATISTIQUES — Nom d'hôte de développement et format DEVOPS.md 0.7

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 23 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe ; le développeur a validé le périmètre proposé et
  demandé explicitement la version documentaire 0.7.
- Change : `add-devops-development-hostname`.
- Archive : `2026-10-23-add-devops-development-hostname`.
- Objet : afficher le résultat dynamique de hostname -f après l'OS, comme
  deuxième puce de Système d'exploitation.
- Preuves : commandes et sorties de cette session,
  [tasks.md](tasks.md), [design.md](design.md) et
  [delta OpenSpec](specs/projects-template-devops/spec.md).

SCM est exécuté directement, sans compétence de télémétrie SCMP et sans
pilotage CAB/OpenCode. Le cycle spécification, implémentation, tests,
documentation, synchronisation, archivage et rapport appartient au périmètre
autonome validé.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Capture des références initiales | 2026-10-23T14:30:24.025Z |
| Point de mesure avant le rapport | 2026-10-23T14:36:25.094Z |
| Intervalle partiel mesuré | 361,069 s entre ces points ; hors exploration du tour précédent et contrôles suivants |
| Durée globale complète | N/A : les échanges antérieurs ne sont pas chronométrés globalement |
| Suite unittest complète | 79,678 s selon unittest |
| Tokens, coût, CPU et mémoire | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie |
| Approbations CAB | N/A : SCM directe, protocole non applicable |

## 3. Fichiers et comportement livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 5 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **11** | **1 + 1 + 3 + 1 + 5** |

Six fichiers existants sont modifiés et cinq documents composent l'archive.
OpenSpec a déplacé les quatre artefacts du change actif ; le rapport est
ensuite ajouté. Aucun autre fichier préexistant n'est supprimé ou renommé.

Le rendu produit la version documentaire 0.7. Sous Système d'exploitation,
la première puce reste le nom de l'OS et la deuxième devient le résultat de
`hostname -f`. Le binaire est recherché dans le PATH système contrôlé et
appelé une seule fois par rendu avec le seul argument -f et une borne de
15 secondes. La sortie acceptée est une ligne de 1 à 253 caractères ASCII
alphanumériques, points ou tirets, commençant par un caractère alphanumérique.
Un nom court retourné par la commande est conservé sans suffixe inventé.

Une commande absente, une sonde échouée ou expirée, ou une sortie invalide
produisent un diagnostic fixe dans la deuxième puce. La sortie rejetée et
stderr ne sont pas publiés ; la génération des autres rubriques se poursuit.
Aucun nom n'est codé en dur dans le générateur et aucune configuration du
nom d'hôte ou du réseau n'est modifiée.

Les parcours individuel, groupé et de création conservent le rendu commun.
Leur structure, les autres sondes, la préparation existante des exécutables
DevOps et les règles de publication du document sont préservées.

## 4. Tests et vérifications

| Suite unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Suite complète finale | 119 | 119 | 0 | 0 | 0 |

Les 119 méthodes distinctes comprennent 113 méthodes préexistantes et six
nouvelles. Les sous-tests ne sont pas comptés comme méthodes supplémentaires.
Les nouveaux tests couvrent l'ordre exact OS/nom d'hôte/Matériel, l'argument
-f et l'appel unique, le remplacement d'une ancienne valeur, les noms courts
et la longueur maximale, l'absence et l'échec de commande, les sorties vides,
multilignes, trop longues ou invalides, ainsi que l'expiration. Le test de
délai remplace en mémoire la borne exacte de 15 secondes par 0,05 seconde et
vérifie que le rendu se poursuit. Les tests existants de création et de
génération groupée vérifient aussi la nouvelle puce et le format 0.7.

Commande de suite réellement exécutée :

```bash
env DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node /home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py
```

| Contrôle | État et résultat réellement observé |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, aucun diagnostic |
| Compilation du test Python | Exécutée et réussie avec py_compile.compile et doraise=True ; cfile temporaire sous le dépôt puis nettoyé |
| Change OpenSpec strict | Exécuté et réussi avant toute écriture de code ou test, puis de nouveau avant archivage |
| Canon OpenSpec ordinaire final | Exécuté et réussi, avec huit avertissements de longueur préexistants |
| Contrôle global strict avant archivage | Exécuté et échoué : 46 éléments valides, 22 en échec, total 68 incluant le change actif |
| Contrôle global strict après archivage | Exécuté et échoué : 45 éléments valides, 22 en échec, total 67 ; liste et contenu des diagnostics en échec identiques |
| Concordance delta/canon | Contrôle réussi : une exigence ajoutée, Structure et version documentaire modifiée, 48 exigences préservées |
| Périmètre et empreintes | Contrôle réussi sur 77 fichiers de référence : six modifications prévues, 71 références inchangées ; neuf empreintes figées avant archivage identiques après archivage |
| Binaires réellement installés | Modes, UID, GID et ctime des sept outils DevOps préservés ; aucun rendu réel susceptible de préparer leurs droits n'est lancé |
| Références de version | Code, attentes de tests et documentation courante en 0.7 ; versions de dépendances et anciennes entrées de changelog conservées |
| UTF-8/LF, absence de BOM | Contrôle réussi sur dix fichiers avant le rapport ; contrôle final incluant le onzième |
| Temporaires de tests et compilation | Aucun résidu des préfixes propres à la session |
| Sonde réelle du nom d'hôte | Helper exécuté directement en lecture seule : succès, résultat hvp1.pixs.fr |
| Autres modules, déploiement et génération du DEVOPS.md courant | Non exécutés : hors périmètre |

Le premier audit des métadonnées a échoué sur une comparaison d'entiers ctime
en nanosecondes transférés par JSON/JavaScript. La comparaison a été reprise à
la précision disponible de 256 ns, avec modes et identités comparés exactement :
aucun changement des sept binaires n'est observé. Cet échec du contrôle
auxiliaire ne correspond pas à une modification réelle des fichiers.

Tous les appels OpenSpec utilisent `OPENSPEC_TELEMETRY=0`, le Node explicite
`/home/devops/node/current/bin/node` et le programme
`/home/devops/.local/npm/bin/openspec`.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Helper hostname et rendu commun modifiés ; 119 méthodes distinctes réussies ; sonde réelle hvp1.pixs.fr |
| AGENTS.md | Inchangé, empreinte et mode conservés ; périmètre validé, OpenSpec, rapport et encodage respectés |
| PROJECT.md | Inchangé, empreinte et mode conservés ; responsabilités du module projects et architecture inchangées |
| TECHNICAL.md | Mis à jour dans Traçabilité du document DevOps : version 0.7, deuxième puce, source, validation, délai et diagnostics |
| BUILD.md | Inchangé, empreinte et mode conservés ; aucune modification de construction, dépendance ou installation |
| DEVOPS.md | Inchangé, empreinte et mode conservés ; l'inventaire existant reste à sa version observée 0.6 et adoptera 0.7 à sa prochaine génération normale |
| README.md | Génération documentée en 0.7, avec hostname -f, position et limites de la sonde |
| CHANGELOG.md | Entrée Unreleased ajoutée pour 0.7 ; anciennes entrées historiques préservées |
| openspec/specs/ | projects-template-devops synchronisée : Nom d'hôte dans la rubrique système ajouté et Structure et version documentaire passée à 0.7 |

Commande d'archivage réellement exécutée :

```bash
env OPENSPEC_TELEMETRY=0 /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive add-devops-development-hostname --yes
```

La commande retourne zéro, confirme les tâches complètes, synchronise un ajout
et une modification, puis annonce l'archive ciblée. L'absence du change actif,
les quatre artefacts archivés et leur identité avec les empreintes figées
avant archivage sont vérifiées. Aucun autre change n'est archivé.

| Résultat | Nombre |
| --- | ---: |
| Tâches préalables cochées | 6 sur 6 |
| Exigences initiales | 49 |
| Exigences finales | 50 |
| Exigences ajoutées | 1 |
| Exigences modifiées | 1 |
| Exigences préservées | 48 |
| Exigences supprimées ou renommées | 0 |
| Changes archivés | 1 |
| Documents finaux dans l'archive | 5 |

Le rapport est contrôlé après écriture : six sections, 11 fichiers,
119 = 119 + 0 + 0 + 0, 119 = 113 + 6, 50 = 49 + 1 et
49 = 48 + 1, six tâches cochées, UTF-8/LF sans BOM, empreintes témoins et
absence de temporaires. Les opérations de livraison sont prouvées après
exécution, sans avoir été cochées par anticipation.

## 6. Limites et état terminal

L'ajout du nom d'hôte et le passage à la version documentaire 0.7 sont
implémentés, testés, documentés, synchronisés et archivés.

Le contrôle OpenSpec global strict reste en échec sur les mêmes 22 éléments
préexistants : 19 spécifications avec avertissements, un ancien change
d'architecture avec avertissement et deux anciens changes Forgejo incomplets
(`modify-projects-forgejo-push-force-with-lease` et
`restore-forgejo-push-to-create`). Les diagnostics avant/après sont identiques.
Le canon ciblé est valide en mode ordinaire avec ses huit avertissements de
longueur préexistants ; le delta ciblé est valide en mode strict.

Le nom relevé est celui du contexte où DIU s'exécute ; hostname -f utilise les
mécanismes de résolution habituels de ce contexte. Aucun résultat n'est
inventé lorsque la résolution échoue. La lecture réelle isolée du helper
réussit avec hvp1.pixs.fr ; elle ne régénère aucun document.

DEVOPS.md courant n'est pas modifié manuellement ni régénéré ; l'installation
de production n'est pas mise à jour. Les prochaines générations utilisant ces
sources adopteront 0.7. Aucun état Git n'est inspecté ; aucun commit, push,
branche, tag ou release n'est créé. Aucun processus OpenCode ni service
partagé n'est lancé, fermé ou redémarré.

