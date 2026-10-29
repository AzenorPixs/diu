# STATISTIQUES — Section Prompts du document DevOps

## 1. Identification et périmètre

Date : 19 octobre 2026, Europe/Paris.
Change : `add-devops-prompts-section`.
Archive : `2026-10-19-add-devops-prompts-section`.

Session SCM directe. Le périmètre couvre la rubrique Prompts du générateur
DevOps, les chemins issus de ENV_DEVOPS_USER, la version documentaire 0.6,
les tests ciblés, la documentation et le cycle OpenSpec jusqu'à l'archivage.
Le périmètre initial a été validé, avec l'incrément de version de 0.1.

Le dossier prompts et son index ne sont ni lus ni créés par cette nouvelle
rubrique. Les lectures initiales de PROMPTS/INDEX.md et PROMPTS/SCM.md
relèvent uniquement du lancement de la session demandé. Aucun fichier de
prompts n'est modifié. Aucun état Git n'est inspecté ; aucun commit, push,
changement de branche, déploiement ou installation n'est exécuté.

## 2. Durées et mesures disponibles

| Exécution de la suite ciblée | Durée, secondes |
| --- | ---: |
| Python système 3.13.5 | 74.471 |
| Python DevOps 3.14.8, Node et Go explicites | 84.497 |
| Total des deux exécutions | 158.968 |

Durée totale de session : N/A, absence de mesure globale continue.
Tokens, coût, comptes exhaustifs des messages et des outils : N/A,
absence de télémétrie de pilotage dans cette session SCM.
Lignes modifiées et état Git global : N/A, inspection Git non autorisée.
Agents délégués : 0. Paquets installés : 0. Archivages exécutés : 1.

## 3. Fichiers et contrat

Six fichiers préexistants sont modifiés dans le périmètre :

- `modules/projects/template.sh` : version 0.6 et rendu de la rubrique Prompts ;
- `tests/test_projects_template_devops.py` : attentes de version, rubrique,
  parcours individuel, groupé et final de création, compte DevOps configurable ;
- `TECHNICAL.md` : section Traçabilité du document DevOps ;
- `README.md` : description du format et des emplacements des prompts ;
- `CHANGELOG.md` : entrée Unreleased ;
- `openspec/specs/projects-template-devops/spec.md` : synchronisation officielle
  d'une exigence modifiée et de deux exigences ajoutées.

Quatre fichiers du change sont créés puis déplacés par l'archivage :
`proposal.md`, `design.md`, `tasks.md` et
`specs/projects-template-devops/spec.md`. Ce rapport est le cinquième fichier
de l'archive, soit onze fichiers de livraison distincts au total. Les créations
et déplacements du même fichier ne sont pas additionnés deux fois.

Le rendu réutilise devops_home, construit par la fonction publique avec
`/home/${ENV_DEVOPS_USER:-}` après validation du compte. Les chemins sont
`${devops_home}/datas/prompts` et `${devops_home}/datas/prompts/INDEX.md`.
Ils ne dépendent ni de DEVOPS_PROJECTS_ROOT ni de l'identifiant du projet.
La rubrique suit le gestionnaire de paquets Python et précède les navigateurs.

La comparaison SHA-256 des blocs d'exigences, avant et après archivage,
confirme 36 exigences antérieures inchangées, une modifiée et deux ajoutées :
39 exigences au total. Les trois blocs concernés correspondent exactement
au delta archivé. Les huit tâches du change sont cochées.

## 4. Tests et vérifications

Commande de la suite initiale :

```bash
python3 -m unittest discover -s tests -p 'test_projects_template_devops.py'
```

Commande de la suite finale, avec les outils référencés par DEVOPS.md :

```bash
env DIU_TEST_NODE=/home/devops/node/current/bin/node DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test_projects_template_devops.py'
```

| Suite | Cas comptés | Réussis | Échecs d'assertion | Erreurs | Ignorés |
| --- | ---: | ---: | ---: | ---: | ---: |
| Initiale, Python système | 89 | 78 | 0 | 9 | 2 |
| Finale, Python DevOps | 89 | 89 | 0 | 0 | 0 |
| Total, répétitions incluses | 178 | 167 | 0 | 9 | 2 |

Résultat final : **89 tests distincts réussis, aucun ignoré**.
Les neuf erreurs initiales sont des StopIteration dans la préparation des
fixtures de venv avec le Python système 3.13.5. La relance avec le Python
DevOps 3.14.8 réussit sans changement de ces fixtures ni affaiblissement des
assertions. Les chemins Node et Go explicites permettent aussi l'exécution
des deux scénarios runtime initialement ignorés.

Le nouveau test conserve le calcul réel du domicile et le rendu ; il simule
les identités et les sondes et écrit uniquement dans sa fixture. Il vérifie
les comptes devops et ci-builder avec une racine de projets séparée. Les
tests de rendu contrôlent l'unicité et l'ordre de la section, les deux chemins
et l'absence de création de prompts. Les parcours groupé et de création
contrôlent aussi la nouvelle rubrique. Les fixtures temporaires sont nettoyées.

| Contrôle | État |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi |
| `python3 -m py_compile tests/test_projects_template_devops.py` | Exécuté et réussi |
| Compilation identique avec `/home/devops/python/current/bin/python3` | Exécutée et réussie |
| Validation stricte du change avant code et tests | Exécutée et réussie après découpage d'une exigence trop longue |
| Validation stricte du change avant archivage | Exécutée et réussie |
| Validation standard de la spécification synchronisée | Exécutée et réussie, huit avertissements préexistants |
| Validation stricte de la spécification complète | Exécutée et échouée sur ces huit avertissements |
| Contrôle UTF-8/LF, absence de NUL et LF final | Exécuté et réussi sur les fichiers du périmètre |
| Comparaison des exigences et vérification des tâches | Exécutées et réussies |
| Suite entière du dépôt et installation réelle | Non exécutées, hors de la validation ciblée nécessaire |

Les commandes OpenSpec utilisent le compte devops par sudo et les chemins
explicites `/home/devops/node/current/bin/node` et
`/home/devops/.local/npm/bin/openspec`. Les validations utilisent
`validate add-devops-prompts-section --type change --strict`, puis
`validate projects-template-devops --type spec` avec et sans `--strict`.

## 5. Résultats, cohérence et archivage

Avec ENV_DEVOPS_USER=devops, la nouvelle rubrique est :

```markdown
# Prompts

  * Dossier des prompts : /home/devops/datas/prompts
  * Index des prompts : /home/devops/datas/prompts/INDEX.md
```

Archivage officiel exécuté une seule fois :

```bash
sudo -n -u devops /home/devops/node/current/bin/node /home/devops/.local/npm/bin/openspec archive add-devops-prompts-section --json --yes
```

Résultat : specsUpdated=true, deux exigences ajoutées, une modifiée, aucune
supprimée ni renommée. Le change n'est plus actif ; ses quatre artefacts
sont dans l'archive indiquée, complétés par ce rapport à six sections.

| Élément de la matrice SCM | État et preuve documentaire |
| --- | --- |
| Projet réel | Générateur 0.6, printf Prompts dans projects_template_devops_render et 89 tests ciblés réussis |
| AGENTS.md | Inchangé : sections 6 et 7 appliquées pour OpenSpec et le rapport d'archive ; aucune nouvelle règle d'agent nécessaire |
| PROJECT.md | Inchangé : Architecture fonctionnelle, module projects ; l'ajout reste dans la gestion des projets existante |
| TECHNICAL.md | Mis à jour : Traçabilité du document DevOps, version 0.6 et convention des chemins |
| BUILD.md | Inchangé : Objet et Contenu du paquet ; la construction et son périmètre ne changent pas |
| DEVOPS.md | Inchangé : relevé UTC 2026-10-19T05:35:05Z en version 0.5, conservé comme instantané ; prochain rendu en 0.6, sans régénération du relevé réel dans cette session |
| README.md | Mis à jour : génération de l'inventaire DevOps et rubrique Prompts |
| CHANGELOG.md | Mis à jour : Unreleased, format 0.6 et chemins selon le compte configuré |
| openspec/specs/ | Synchronisé : Structure et version documentaire, Emplacements des prompts communs, Références Prompts passives |
| openspec/config.yaml | Inchangé : schéma spec-driven, aucune configuration supplémentaire |

Le titre, les sondes, leurs diagnostics, les commandes, les permissions et
l'ordre relatif des rubriques existantes sont préservés. Le dernier bloc
reste consacré aux navigateurs. Aucun fichier de cadrage absent n'a dû être
créé. Les autres changes actifs ne sont pas traités.

## 6. Limites et suites

La validation stricte de la spécification complète reste en échec sur huit
avertissements de longueur supérieure à 500 caractères. La comparaison des
empreintes confirme que leurs huit exigences sont intégralement inchangées :
Commande de génération du modèle DevOps ; Distinction entre hôte et
environnement DevOps ; Vérification sûre du serveur PostgreSQL ; Manifeste
Python conditionnel ; Génération finale lors de la création ; Génération
DevOps de tous les projets configurés ; Bilan et poursuite du traitement
groupé ; Navigateurs externes hôte pour le mode headless.

Le change ciblé passe les contrôles stricts et la spécification complète
passe le contrôle standard. Ces avertissements préexistants sont conservés
dans le bilan ; leur réécriture dépasse l'ajout de la section Prompts.

Les chemins indiquent une convention d'emplacement, pas une preuve de présence
ou d'accessibilité des prompts. Aucune nouvelle dépendance, migration ou
sonde n'est introduite. La version installée du DIU et les documents DevOps
déjà générés ne sont pas actualisés par cette session.

Le contrôle de périmètre porte sur les écritures effectuées et les fichiers
explicitement examinés. Il ne constitue pas un inventaire des modifications
antérieures ou concurrentes du dépôt ; aucun état Git ni relevé initial global
du système de fichiers n'est disponible pour établir cet inventaire.

### Correction des chemins — 19 octobre 2026

Les deux chemins utilisent désormais le dossier `prompts` en minuscules :
`/home/${ENV_DEVOPS_USER}/datas/prompts` et
`/home/${ENV_DEVOPS_USER}/datas/prompts/INDEX.md`. La version reste 0.6.
Le générateur, les attentes des tests, les trois documents concernés et les
artefacts OpenSpec existants sont alignés, sans nouvel archivage. Les exemples
et le contrat ci-dessus reflètent cette correction ; les mesures des deux
exécutions initiales sont conservées.

Une exécution supplémentaire avec le Python DevOps 3.14.8 réussit : quatre
tests, zéro échec, zéro erreur, zéro ignoré, en 4.137 secondes. Elle couvre
la structure du document, la génération finale de création, la génération
groupée et les chemins selon le compte configuré avec une racine distincte.
Ces mesures s'ajoutent aux deux exécutions initiales : 182 cas comptés,
171 réussis, neuf erreurs initiales et deux ignorés initiaux, pour 163.105
secondes cumulées de suites.

Bash -n, ShellCheck et la compilation du test avec le Python DevOps sont
exécutés et réussis. La validation standard de la spécification complète
réussit avec les huit avertissements préexistants. Le contrôle ciblé confirme
UTF-8/LF, les trois blocs de spécification synchronisés, les chemins en
minuscules et le nettoyage des fixtures.
