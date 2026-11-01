# Statistiques — Accès TPM du conteneur Docker de test

## 1. Statistiques générales et décisions

- Session : SCM directe exécutée par Codex ; aucun pilotage CAB/OpenCode ni agent délégué.
- Date de clôture technique : 2026-11-01 (Europe/Paris).
- Début exact et durée : N/A, horodatage initial non collecté.
- Objectif validé : documenter `Accès TPM OK` dans la rubrique Docker générée après test d'accès.
- Décision de lot : aucun code attribué ; ACL demande un rapport et une validation séparés.
- État : change archivé après validation stricte, tests et génération du document.

## 2. Types de messages et d’outils

| Mesure | Valeur |
|---|---|
| Télémétrie exhaustive des messages et appels d'outils | N/A : non collectée dans cette session SCM directe |
| Modèle, jetons, coût et compactions | N/A : données non disponibles |
| Pilotage CAB/OpenCode ou sous-agents | 0 : aucune délégation ni session pilotée |

## 3. Fichiers modifiés

Fichiers du projet touchés :

- `DEVOPS.md`
- `README.md`
- `TECHNICAL.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `openspec/BATCH_CODES.md`
- `openspec/specs/projects-template-devops/spec.md`
- `modules/projects/template.sh`
- `tests/test_projects_template_devops.py`

Artefacts archivés :

- `proposal.md`, `design.md`, `tasks.md`, `.openspec.yaml` et `README.md`
- `specs/projects-template-devops/spec.md`
- ce rapport `STATISTICS.md`

Nombre total de fichiers du change dans l’archive : 7.

## 4. Commandes et validations

| Vérification | Résultat |
|---|---|
| `tpm2_getcap properties-fixed` depuis le compte de développement | Échec : accès direct au périphérique refusé |
| `docker run --rm --device=/dev/tpmrm0 debian:stable-slim ... tpm2_getcap properties-fixed` | Réussie : TPM 2.0, fabricant INTC, révision 1.38 ; outils installés uniquement dans le conteneur éphémère |
| `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p test_projects_template_devops.py` | Réussie : 152 tests, 2 ignorés |
| `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p test_projects_template_all.py` | Réussie : 8 tests |
| `bash -n modules/projects/template.sh` | Réussie |
| `shellcheck modules/projects/template.sh` | Réussie |
| `/home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py` | Réussie |
| Validation stricte OpenSpec du change et de `projects-template-devops` | Réussie après correction des intitulés de scénarios du delta |
| Génération du `DEVOPS.md` par le rendu commun | Réussie ; six puces Docker et inventaire TPM présents |
| Encodage UTF-8 et fins LF des fichiers contrôlés | Réussie |
| Archivage OpenSpec | Réussi : `2026-11-01-add-devops-docker-tpm-access` |
| Validation groupée des changes archivés | Échec global : 106/118 valides ; 12 anciennes archives ont des tâches incomplètes. Ce change est valide dans le résultat (0 problème). |

## 5. Accès web

Accès web : 0. Aucun outil web n'a été utilisé.

## 6. Synthèse globale

Le périphérique TPM de l'hôte a répondu depuis le conteneur Debian lorsque `/dev/tpmrm0` a été transmis explicitement. Le générateur ajoute la mention documentaire demandée après `debian:stable-slim` ; il n'ajoute aucune sonde TPM ni modification du lancement Docker. Les tests ciblés, les parcours de modèle et les validations OpenSpec requis ont réussi. Le change est archivé et reste sans code de lot. Le rapport `STATISTICS.md` global du projet est absent et n'a pas été créé.
