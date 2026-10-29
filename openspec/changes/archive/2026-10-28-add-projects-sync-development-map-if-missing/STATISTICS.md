# Statistiques — add-projects-sync-development-map-if-missing

## 1. Statistiques générales et décisions

- Projet : Debian Installeur Unifié (`diu`).
- Date de session : 28 octobre 2026, Europe/Paris.
- Mode : SCM direct ; 1 agent Codex, aucun agent délégué ni pilotage OpenCode.
- Mandat : périmètre proposé puis validation explicite du développeur,
  avec demande de poursuivre jusqu'à la clôture complète du change.
- Objectif : initialiser DEVELOPMENT_MAP.md pendant sync uniquement si absent.
- Change archivé : `2026-10-28-add-projects-sync-development-map-if-missing`.
- Archivage exécuté et réussi ; 2 exigences ajoutées, 1 modifiée, 0 supprimée.
- Durée totale, tokens, coûts et quotas : N/A, aucune télémétrie exhaustive
  disponible ; les durées des tests ci-dessous ne sont pas la durée de session.
- Les étapes conditionnelles de commit et publication suivent ce rapport ;
  leur résultat vérifié est restitué dans le bilan final du chat.

## 2. Types de messages et d'outils

- Messages : demande fonctionnelle, proposition de périmètre, validation
  explicite du développeur, suivis de réalisation et restitution finale.
- Outils utilisés : lecture/recherche ciblée, application de patches, scripts
  Python locaux, exécution Bash, unittest, py_compile, ShellCheck et OpenSpec.
- Git est réservé à l'étape SCM après archivage et vérification de ce rapport.
- Nombre exhaustif de messages, appels et lignes de sortie : N/A, absence
  d'un compteur instrumenté ; aucun total estimé présenté comme mesure.
- Aucune compétence de statistiques de session pilotée invoquée.

## 3. Fichiers modifiés

Inventaire du seul change : 14 fichiers, dont 7 nouveaux et 7 modifiés.
Ce total ne décrit pas d'éventuels autres changements déjà présents dans le
projet et inclus par la règle SCM de commit complet.

| Type | Chemin | Nombre |
| --- | --- | ---: |
| Modifié | modules/projects/projects.sh | 1 |
| Modifiés | tests/test_projects.py ; tests/test_projects_orchestrated_copy.py | 2 |
| Nouveau | tests/test_projects_development_map.py | 1 |
| Modifiés | TECHNICAL.md ; README.md ; CHANGELOG.md | 3 |
| Modifié | openspec/specs/projects-sync/spec.md | 1 |
| Nouveaux, dans cette archive | proposal.md ; design.md ; tasks.md ; review.md ; specs/projects-sync/spec.md ; STATISTICS.md | 6 |
| **Total** | **7 nouveaux + 7 modifiés** | **14** |

L'archivage a déplacé le dossier du change actif vers cette archive ; aucun
fichier existant extérieur au périmètre n'a été supprimé par la réalisation.
Les répertoires temporaires dédiés aux tests ont été nettoyés.
AGENTS.md, PROJECT.md, BUILD.md et DEVOPS.md sont inchangés ; justification
document par document dans [review.md](review.md).

## 4. Commandes et validations

Les chemins d'outils sont ceux de DEVOPS.md : Python DevOps
`/home/devops/python/current/bin/python3` et OpenSpec
`/home/devops/.local/npm/bin/openspec`.

| Contrôle exécuté | Résultat observé |
| --- | --- |
| bash -n modules/projects/projects.sh | Réussi |
| shellcheck modules/projects/projects.sh | Réussi avant et après modification |
| py_compile des 3 fichiers de tests concernés | Réussi, sorties temporaires sous DIU |
| unittest test_projects_development_map.py, passage initial | 8 exécutés, 1 échec de simulation du test de copie |
| unittest test_projects_development_map.py, après correction de la simulation | 8 exécutés, 8 réussis |
| unittest test_projects*.py, premier passage | 322 exécutés en 135,152 s : 319 réussis, 1 échec de droits /etc/gitconfig, 2 ignorés |
| unittest test_*.py, TMPDIR et GIT_CONFIG_SYSTEM isolés sous DIU | 636 exécutés en 157,121 s : 626 réussis, 8 échecs hors périmètre, 2 ignorés |
| Sous-ensemble projets inclus dans ce dernier passage | 322 exécutés : 320 réussis, 0 échec, 2 ignorés |
| OpenSpec change ciblé --strict, avant code puis avant archivage | Réussi |
| OpenSpec --all avant archivage | 68 valides, 2 échecs Forgejo préexistants |
| OpenSpec --all --strict, état initial | 48 valides, 21 échecs préexistants |
| OpenSpec --all --strict avec change actif | 49 valides, mêmes 21 échecs préexistants |
| OpenSpec archive du seul change ciblé | Réussi, +2 exigences et 1 modifiée |
| OpenSpec projects-sync --type spec --strict après archivage | Premier contrôle en échec pour longueur de texte ; formulation condensée à 444 caractères, contrôle suivant réussi |
| OpenSpec --all --strict --report findings après archivage et correction documentaire | 48 valides, mêmes 21 échecs préexistants sur 69 éléments ; aucun nouveau défaut |
| Préservation des scénarios MODIFIED | 6 scénarios existants conservés |
| UTF-8/LF des fichiers du périmètre | Réussi avant archivage ; rapport final vérifié séparément |

Les passages successifs des tests et leurs sous-ensembles se recouvrent :
ne pas les additionner comme tests distincts. Détail des 8 échecs hors périmètre
et preuve de leur indépendance : [review.md](review.md). Aucun test n'a été
désactivé ni assertion affaiblie. Le dépôt global n'est pas déclaré valide.

Nombre exhaustif de commandes : N/A, aucun journal de comptage instrumenté.
Construction de paquet, installation et synchronisation réelle : non
pertinentes pour la validation source de ce change, non exécutées.

## 5. Accès web

Aucun accès web applicatif, recherche internet ou appel fournisseur pour la
réalisation de ce change. Les publications Git conditionnelles SCM sont des
étapes distinctes, avec résultats détaillés dans le bilan final du chat.
Mesures de trafic réseau des outils et des tests : N/A, non instrumentées.

## 6. Synthèse globale

La copie initiale et la préservation de toute entrée destination existante sont
couvertes par les tests, en mode unitaire et groupé. La personnalisation et les
arguments de propriété sont vérifiés ; aucun propriétaire de projet réel ni
effet runtime n'est qualifié par ces tests synthétiques.

Le change ciblé est réalisé, documenté et archivé ; sa spécification courante
passe le contrôle strict. Les défauts globaux indépendants sont conservés et
explicitement signalés. Aucun BLOCKER.md ou BLOCKERS.md n'était présent dans
ce change ; aucun nettoyage de bilan n'est nécessaire.

Totaux vérifiés : 14 fichiers = 7 nouveaux + 7 modifiés ; 636 tests finaux =
626 réussis + 8 échecs hors périmètre + 2 ignorés ; sous-ensemble projets
322 = 320 réussis + 0 échec + 2 ignorés ; 8 nouveaux tests inclus dans ce
sous-ensemble. Voir [review.md](review.md) pour les preuves et limites.
