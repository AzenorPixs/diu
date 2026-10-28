# STATISTIQUES — Source du mot de passe API OpenCode dans DEVOPS.md

## 1. Identification et périmètre

Projet : Debian Installeur Unifié (`diu`). Session SCM directe, le 28 octobre 2026.
Archive : `2026-10-28-document-devops-opencode-password-source`.
Ajout d'une puce statique après le chemin OpenCode ; spécification, test existant,
documentation et clôture associés. Extension : remise en forme de huit exigences
canoniques trop longues, sans changement de leur texte normatif ni suppression
de scénario existant. Aucun pilotage, CAB ou sous-agent.

## 2. Mesures disponibles

| Mesure | Résultat et preuve |
| --- | --- |
| Test ciblé de structure | 1 réussi en 0,408 s, sortie unittest |
| Suite de génération complète | 152 tests en 170,699 s : 150 réussis, 2 ignorés, 0 échec |
| Cas ignorés | Go réel absent ; tests Go et enveloppe runuser nécessitant ce binaire |
| Exigences longues remises en forme | 8 ; répartition avec 10 sous-exigences courtes |
| Delta synchronisé par archivage | 1 exigence ajoutée, 0 modifiée, 0 supprimée, 0 renommée |
| Durée totale, jetons et coût | N/A : pas de télémétrie qualifiée de la session complète |
| Approbations CAB et appels web | Non applicable : session directe, aucun appel web |

Le test ciblé appartient aux 152 tests ; les deux exécutions ne sont pas additionnées.

## 3. Fichiers et comportement livré

Après nettoyage du bilan résolu, dix fichiers constituent le livrable : cinq
sources/documents et cinq fichiers d'archive.

- `modules/projects/template.sh` : helper commun ajoutant exactement la puce demandée après le chemin OpenCode, avant les dépendances éventuelles.
- `tests/test_projects_template_devops.py` : test existant complété pour le bloc exact et l'unicité de la puce.
- `TECHNICAL.md` : rendu, position et limites documentés.
- `CHANGELOG.md` : entrée Unreleased.
- `openspec/specs/projects-template-devops/spec.md` : huit exigences remises en forme et delta OpenCode synchronisé.
- Archive : `proposal.md`, `design.md`, `tasks.md`, `specs/projects-template-devops/spec.md`, présent `STATISTIQUES.md`.

Le bilan historique `BLOCKERS.md`, créé pendant la suspension, est supprimé
après vérification de ce rapport selon SCM. Aucun autre fichier n'est supprimé.
Le DEVOPS.md préexistant est préservé, sans édition ou régénération par cette
session. Le commit complet du projet prévu par SCM peut inclure cet état préexistant.

## 4. Validations et preuves

| Commande ou contrôle | Résultat |
| --- | --- |
| `python3 -B tests/test_projects_template_devops.py ProjectsTemplateDevopsTests.test_generation_structure_versions_and_executable_paths -v` avec Python DevOps | Réussi, 1 test |
| `/home/devops/python/current/bin/python3 -B tests/test_projects_template_devops.py -v` | Réussi, 152 tests dont 2 ignorés |
| `bash -n modules/projects/template.sh` | Réussi |
| `shellcheck modules/projects/template.sh` | Réussi, aucun diagnostic |
| `/home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py` | Réussi |
| `openspec validate document-devops-opencode-password-source --strict --no-interactive` | Réussi avant code et avant archivage |
| `openspec validate projects-template-devops --type spec --strict --no-interactive` | Échec initial sur huit textes de plus de 500 caractères ; réussi après leur remise en forme et après archivage |
| `openspec archive document-devops-opencode-password-source --yes --json` | Réussi, `specsUpdated=true`, 1 exigence ajoutée |
| UTF-8/LF et intégrité documentaire | Vérifiés sur sources et artefacts ; rapport et nettoyage contrôlés avant commit |

OpenSpec est exécuté via `/home/devops/.local/npm/bin/openspec`.
La première transformation préparatoire a été arrêtée par une assertion avant
écriture (nombre de sous-exigences navigateurs) ; le découpage corrigé a ensuite
été appliqué et validé. Aucune validation n'a été contournée.

La remise en forme conserve les textes normatifs mot pour mot hors espaces,
vérifiés par assertions lors de la transformation. SHA-256 canonique avant :
`52feebb389024d5a9eb75dc7d33b7bb4eb7bb59f18670efd44a43f601c027a51` ;
après remise en forme avant ajout du delta :
`8e7b405226c4721126539fc5d5fd08491a4b8bf7fb3dd3cc46a4fb3039e132fc`.
Les preuves des tests sont conservées à la reprise : aucun code ni test n'a
changé depuis leur exécution réussie. La suite complète des autres fonctionnalités
du dépôt n'est pas exécutée, hors périmètre de cet ajout documentaire.

## 5. Cohérence documentaire

| Document | État et justification |
| --- | --- |
| Projet réel | Helper de rubrique OpenCode et test de structure cohérents ; texte statique sans consultation de configuration pour cet ajout |
| AGENTS.md | Inchangé, règles d'agents sans modification |
| PROJECT.md | Inchangé, architecture et rôles de développement préservés |
| TECHNICAL.md | Mis à jour dans « Traçabilité du document DevOps » |
| BUILD.md | Inchangé, construction et packaging Debian sans changement |
| DEVOPS.md | Inchangé par cette session, rubrique OpenCode déjà conforme à la demande |
| README.md | Inchangé, présentation de la génération au format 0.7 toujours exacte ; détail porté par TECHNICAL.md |
| CHANGELOG.md | Mis à jour dans Unreleased |
| openspec/config.yaml | Inchangé, schéma spec-driven conservé |
| openspec/specs/ | Spécification concernée validée strictement après synchronisation ; autres capacités inchangées |
| Change | Archivé avec toutes les tâches cochées, blocage documentaire résolu |

## 6. Limites et clôture

L'ajout ne lit pas OPENCODE_PASSWORD ou project.env ; il indique une source
conventionnelle sans prouver la présence d'un mot de passe ou le fonctionnement
de l'API. Versions sondées, chemins, format 0.7 et autres rubriques conservés.
Aucun secret réel reçu ou reproduit. Aucun déploiement ni test réel de l'API.
Les deux tests Go ignorés restent explicitement signalés.

L'archive et son rapport précèdent les étapes Git conditionnelles SCM.
Le résultat du commit, du tag et de chaque publication est vérifié puis restitué
dans le bilan de session ; leur réussite n'est pas anticipée par ce rapport.
