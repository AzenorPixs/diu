# STATISTIQUES — Alignement des indicateurs de tests DevOps

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`).
- Racine : `/home/devops/datas/diu`.
- Date : 24 octobre 2026, Europe/Paris.
- Session : correction SCM directe, dans la continuité du périmètre autonome
  approuvé avec cycle OpenSpec et rapport d'archive.
- Change : `align-devops-tests-environment-flags`.
- Archive : `2026-10-24-align-devops-tests-environment-flags`.
- Demande : aligner les deux nouvelles variables sur les lignes existantes,
  plutôt que reformater toutes les variables. L'exemple fourni précise un
  retrait de huit espaces avant `export`.
- Preuves : [proposition](proposal.md), [conception](design.md),
  [tâches](tasks.md), [delta](specs/devops-tests-environment-flags/spec.md),
  [canon](../../../specs/devops-tests-environment-flags/spec.md) et sorties
  des commandes de cette session.

Aucune configuration locale réelle n'est lue ou modifiée. Les exemples et
tests ne conservent que le format demandé et des données synthétiques.
L'archive initiale reste historique et n'est pas réécrite.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Suite ciblée unittest | 0,174 s selon unittest |
| Durée complète de la correction | N/A : absence de chronométrage global |
| Tokens, coût, CPU et mémoire | N/A : absence de collecte instrumentée |
| Messages et outils exhaustifs | N/A : absence d'export de télémétrie |
| Approbations CAB | N/A : session SCM directe sans pilotage |

La compétence de statistiques SCMP n'est pas invoquée. Les sous-tests ne
sont pas comptés comme méthodes unittest supplémentaires.

## 3. Fichiers et comportement livré

| Catégorie | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 2 | modules/diu/variables/environnements/env_devops_tests_docker.sh ; env_devops_tests_lxc.sh |
| Tests existants modifiés | 1 | tests/test_env_devops_tests.py |
| Documents existants modifiés | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/devops-tests-environment-flags/spec.md |
| Documents de la nouvelle archive | 5 | proposal.md ; design.md ; tasks.md ; specs/devops-tests-environment-flags/spec.md ; STATISTIQUES.md |
| **Total du périmètre de cette correction** | **12** | **2 + 1 + 3 + 1 + 5** |

Sept fichiers existants sont modifiés et cinq nouveaux documents composent
l'archive. Les quatre artefacts actifs sont déplacés par OpenSpec ; le rapport
est ajouté ensuite. Aucun autre fichier n'est supprimé ou renommé par l'agent.

Les nouvelles lignes de `ENV_DEVOPS_TESTS_DOCKER` et `ENV_DEVOPS_TESTS_LXC`
commencent par huit espaces ASCII avant `export`. La désactivation reconnaît
les lignes sans retrait, avec espaces ou avec tabulations, en conservant les
noms voisins et l'autre indicateur. Les défauts restent `0`, les valeurs
existantes sont préservées et les lignes déjà présentes ne sont pas migrées.

`DEVOPS.md` a changé en parallèle : son en-tête généré indique un nouveau
relevé UTC, `2026-10-24T14:03:49Z`. Ce fichier n'est pas modifié par l'agent et
reste hors du total de ses écritures. Sa version documentaire est `0.7` et
son chemin OpenSpec reste `/home/devops/.local/npm/bin/openspec`.

## 4. Tests et vérifications

| Suite | Méthodes | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| tests/test_env_devops_tests.py | 10 | 10 | 0 | 0 | 0 |

```bash
python3 -B -m unittest discover -s tests -p test_env_devops_tests.py -v
```

Les neuf méthodes préexistantes sont conservées et une méthode est ajoutée
pour la suppression des lignes indentées. Le test d'initialisation exige
exactement huit espaces. Les suppressions sont vérifiées avec retrait vide,+huit espaces et tabulation. Les tests existants continuent de vérifier les
valeurs configurées, l'export, l'idempotence, les erreurs et le chargeur.

| Vérification | État et résultat |
| --- | --- |
| bash -n de chaque déclaration | Exécutée et réussie, deux commandes distinctes |
| ShellCheck des deux déclarations | Exécutée et réussie, aucun diagnostic |
| python3 -m py_compile du test | Exécutée et réussie, cache isolé sous le dépôt puis nettoyé |
| Change OpenSpec strict | Exécutée et réussie avant code/tests, puis avant archivage |
| Canon OpenSpec strict | Exécutée et réussie après archivage |
| OpenSpec global strict initial et final | Exécutée et échouée : 68 éléments, 46 valides et 22 en échec ; mêmes éléments et mêmes diagnostics avant/après |
| OpenSpec global standard | Non exécutée pour cette correction ; aucun résultat historique présenté comme actuel |
| Concordance delta/canon | Exécutée et réussie : deux exigences modifiées identiques au delta, six exigences et neuf scénarios finaux |
| Intégrité des artefacts archivés | Exécutée et réussie : quatre empreintes conservées après déplacement |
| Intégrité code/tests/documents avant et après archivage | Exécutée et réussie : les six fichiers qualifiés sont inchangés par l'archivage |
| UTF-8/LF sans BOM | Exécutée et réussie sur les onze fichiers précédant le rapport ; contrôle final incluant le rapport |
| Temporaires | Aucun résidu des préfixes tests devops et compile align |
| Suite complète et tests Docker/LXC réels | Non exécutés : hors périmètre de cette correction de format |

Les commandes OpenSpec emploient `OPENSPEC_TELEMETRY=0` et le chemin explicite
`/home/devops/.local/npm/bin/openspec`. Le contrôle global utilise
`validate --all --strict --json --no-interactive` ; le canon ciblé utilise
`validate devops-tests-environment-flags --type spec --strict --no-interactive`.

Un premier contrôle des empreintes a signalé la modification concurrente de
DEVOPS.md. Son en-tête et son chemin OpenSpec ont été relus sans écrasement.
Un contrôle auxiliaire de concordance a également échoué à cause d'une
expression régulière trop large dans le vérificateur ; sa correction limitée
au vérificateur a permis de confirmer les deux blocs d'exigences. Aucun de
ces échecs de contrôle n'a modifié les sources ou les attentes des tests.

## 5. Cohérence documentaire et archivage

| Élément SCM | État et preuve |
| --- | --- |
| Projet réel | Deux générateurs alignés, suppression compatible avec les retraits ; dix méthodes réussies |
| AGENTS.md | Inchangé par l'agent ; règles de périmètre et rapport respectées |
| PROJECT.md | Inchangé ; responsabilités des modules et architecture préservées |
| TECHNICAL.md | Section Indicateurs de tests DevOps complétée avec le retrait, la suppression et l'absence de migration |
| BUILD.md | Inchangé ; aucune modification de construction, de dépendance ou de packaging |
| DEVOPS.md | Régénération concurrente constatée, conservée sans intervention de l'agent ; chemin OpenSpec inchangé |
| README.md | Présentation des deux indicateurs complétée avec les huit espaces et la conservation des lignes existantes |
| CHANGELOG.md | Entrée Unreleased ajoutée sans nouvelle version de publication |
| openspec/specs/ | Initialisation et Désactivation modifiées ; quatre autres exigences conservées |

Commande d'archivage exécutée avec succès :

```bash
OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive align-devops-tests-environment-flags --yes
```

La commande constate les tâches complètes, annonce deux exigences modifiées,
zéro ajout/suppression/renommage, synchronise le canon puis confirme l'archive
ciblée. Le change actif est absent après l'opération.

| Résultat | Nombre |
| --- | ---: |
| Tâches de réalisation et qualification terminées | 6 sur 6 |
| Exigences finales | 6 |
| Exigences modifiées | 2 |
| Exigences conservées | 4 |
| Scénarios finaux | 9 |
| Changes archivés | 1 |
| Documents finaux de l'archive | 5 |

Le contrôle final porte sur les six sections, les liens locaux, UTF-8/LF sans
BOM, l'intégrité des sources et artefacts, les tâches cochées et les totaux :
12 = 2 + 1 + 3 + 1 + 5 = 7 + 5 ; 10 = 9 + 1 ; 10 = 10 + 0 + 0 + 0 ;
6 = 2 + 4. Aucun archivage futur n'est coché par anticipation.

## 6. Limites et état terminal

Correction réalisée, testée, documentée, synchronisée et archivée. Le rapport
accompagne cette seule correction ; l'archive initiale reste historique.

Les 22 éléments en échec OpenSpec strict sont préexistants et leurs
diagnostics restent identiques. Ils concernent notamment les deux changes
Forgejo incomplets, le change d'architecture avec avertissement et 19
spécifications avec avertissements. Aucun n'est corrigé dans ce périmètre.
La spécification ciblée est valide en mode strict.

Seules les futures lignes générées adoptent les huit espaces. Les valeurs
et lignes déjà présentes dans la configuration réelle restent intactes.
Il n'y a pas de reformatage global, migration, déploiement, exécution de tests
Docker/LXC réels, inspection Git, commit, push, branche, tag ou release.
Aucun service partagé ou processus OpenCode n'est redémarré ou arrêté.
