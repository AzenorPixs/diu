# STATISTIQUES — Correction de la casse GHCR

## 1. Identification et périmètre

Date : 15 octobre 2026, Europe/Paris. Change :
`fix-github-release-image-case`. Archive :
`2026-10-15-fix-github-release-image-case`.

Périmètre SCM validé : normalisation locale des chemins GHCR versionné et
`latest`, résumé CI/CD, tests, documentation, spécification et archivage.
Les valeurs de `project.env`, les identifiants, les remotes Git et la casse
du tag de version sont préservés. Aucune publication réelle, installation,
création de commit ou branche n'est réalisée. Aucun état Git ni fichier
sensible réel n'est inspecté pendant cette session SCM. Les fichiers
`project.env` utilisés par les tests sont exclusivement des fixtures.

## 2. Durées et mesures disponibles

Début du relevé SHA-256 (UTC) : 2026-10-15T15:34:25.647002+00:00.
Rapport préparé le 2026-10-15T17:48:26.696385+02:00, Europe/Paris.
Intervalle observé : 841.048 s ; il ne mesure pas la conversation entière.
Somme des durées unittest : 2,787 s.

Agents délégués : 0. OpenCode/CAB et sondes de pilotage : non utilisés.
Tokens, coût, compte exhaustif des messages/outils : N/A, aucune télémétrie
de pilotage n'est activée pour SCM. Statistiques Git de lignes : N/A, aucune
inspection Git n'est effectuée. La comparaison du module à son empreinte
initiale confirme exactement trois substitutions de références GHCR.

## 3. Fichiers et cohérence documentaire

Quinze fichiers préexistants sont suivis par SHA-256 : six modifiés attendus,
neuf inchangés. Cinq fichiers nouveaux sont conservés dans l'archive :
`proposal.md`, `design.md`, `tasks.md`,
`specs/implement-projects-github-release/spec.md` et ce rapport.
Les quatre premiers ont été créés dans le change puis déplacés par archivage.
Les catégories création et déplacement ne s'additionnent pas.

Fichiers préexistants modifiés :

- `modules/projects/git.sh` : trois expansions Bash en minuscules, dans la
  release GHCR et le résumé CI/CD.
- `tests/test_projects.py` : quatre configurations de casse, conservation
  du fichier et des variables, identité de connexion, version RC1 et résumé.
- `TECHNICAL.md` : section « Variables des fournisseurs distants », règle
  de construction GHCR et invariants de configuration.
- `README.md` : commande de release GHCR et exemple de conversion.
- `CHANGELOG.md` : entrée dans Unreleased.
- `openspec/specs/implement-projects-github-release/spec.md` : exigence
  de publication enrichie et trois scénarios supplémentaires.

| Document de la matrice SCM | État et justification |
|---|---|
| Projet réel | Trois constructions GHCR corrigées ; publication simulée et résumé vérifiés. |
| AGENTS.md | Inchangé, SHA-256 identique ; règles de sécurité et périmètre respectés. |
| PROJECT.md | Inchangé, SHA-256 identique ; architecture et objectifs non modifiés. |
| TECHNICAL.md | Mis à jour dans les variables des fournisseurs distants. |
| BUILD.md | Inchangé, SHA-256 identique ; construction du paquet Debian non concernée. |
| DEVOPS.md | Inchangé par la session, SHA-256 identique ; aucun outil ou environnement ajouté. |
| README.md | Mis à jour avec la commande GHCR, sa conversion et son prérequis d'image construite. |
| CHANGELOG.md | Mis à jour dans Unreleased, sans version ni date de publication inventée. |
| openspec/specs/ | Une exigence modifiée ; deux autres exigences préservées ; validation stricte finale réussie. |

Les neuf références inchangées sont `AGENTS.md`, `PROJECT.md`, `BUILD.md`,
`DEVOPS.md`, `PROMPTS/SCM.md`, `openspec/config.yaml`,
`openspec/specs/projects-cicd/spec.md`, `root-install-debian.sh` et
`lib/github-auth.sh`. Les autres changes actifs restent hors périmètre.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Méthodes sans échec | Méthodes en échec | Constats d'échec, sous-tests inclus | Erreurs | Durée s |
|---|---:|---:|---:|---:|---:|---:|
| Release GHCR ciblée | 1 | 1 | 0 | 0 | 0 | 0,443 |
| Suite projets élargie avec TMPDIR dans le dépôt | 26 | 19 | 7 | 22 | 0 | 1,662 |
| CI/CD et releases applicables | 8 | 8 | 0 | 0 | 0 | 0,682 |
| Total, répétitions incluses | 35 | 28 | 7 | 22 | 0 | 2,787 |

Résultat applicable final : huit méthodes distinctes réussies ; la méthode
GHCR comprend quatre sous-tests de casse. Les tests concernés couvrent
l'ordre du pipeline, les opérations ignorées, les résumés, les releases
GitHub et les reprises de push Docker GitLab.

Commandes unittest exécutées avec
`TMPDIR=/home/devops/datas/diu/openspec/changes/fix-github-release-image-case`
et `PYTHONDONTWRITEBYTECODE=1` :

- `python3 -m unittest discover -s tests -p test_projects.py -k github_release -v` :
  exécutée et réussie.
- `python3 -m unittest discover -s tests -p test_projects.py` :
  exécutée et échouée. Sept méthodes de création/synchronisation fabriquent
  explicitement un faux utilisateur `../tmp/<nom-fixture>` et supposent
  leurs fixtures sous `/tmp`, malgré TMPDIR. Elles ne peuvent pas retrouver
  les modèles placés dans le dépôt. Vingt-deux constats incluent les
  sous-tests de deux méthodes paramétrées. Ces fonctions et cette hypothèse
  de harnais ne sont pas corrigées dans le périmètre GHCR.
- `python3 -m unittest discover -s tests -p test_projects.py -k cicd -k github_release -k gitlab_docker -v` :
  exécutée et réussie.

Autres contrôles :

- `bash -n modules/projects/git.sh` : exécutée et réussie.
- Compilation de `tests/test_projects.py` par `py_compile.compile(...,
  doraise=True)`, dans un répertoire temporaire du change nettoyé :
  exécutée et réussie.
- `shellcheck modules/projects/git.sh` : exécutée et échouée avec SC2034,
  SC2269 et SC2086 dans des fonctions hors correction. Reconstruction en
  mémoire du module initial, vérifiée contre son SHA-256 de départ :
  diagnostics ShellCheck strictement identiques avant/après.
- ShellCheck des deux fonctions extraites sans contexte : exécutée et échouée,
  avec SC2153 dû aux déclarations GitLab absentes de l'extrait.
- ShellCheck des mêmes fonctions, en fournissant seulement les cinq
  déclarations GitLab externes nécessaires : exécutée et réussie, sans
  suppression de diagnostic ni modification du code.
- Contrôles UTF-8/LF et empreintes ciblées : exécutés et réussis.
- Validation stricte du change avant code puis avant archivage :
  exécutée et réussie.
- Validation stricte de la spécification après synchronisation : premier
  contrôle échoué sur la longueur du texte normatif, puis réussi après
  condensation de l'exigence dans le delta archivé et la spécification
  principale, sans perte des scénarios.
- Publication réelle GHCR, build Docker et mise à jour du DIU installé :
  non exécutés, hors périmètre.

Les contrôles des invariants OpenSpec, des six sections de ce rapport, de
l'encodage et des totaux sont vérifiés à la clôture. Aucune assertion de test
n'a été affaiblie pour masquer un échec.

## 5. Résultats et archivage

`AzenorPixs/PKeycloak` produit `ghcr.io/azenorpixs/pkeycloak` pour les
deux tags Docker et le résumé. La version `1.2.3-RC1` conserve ses
majuscules. Le fichier fixture est identique octet pour octet après release ;
les variables GitHub chargées conservent leur casse et Docker reçoit
l'identité de connexion originale.

Archivage officiel exécuté une seule fois sous le compte devops :

`/home/devops/.local/npm/bin/openspec archive fix-github-release-image-case --json --yes`

Code de sortie : 0. Réponse : `specsUpdated=true`, zéro exigence ajoutée,
une modifiée, zéro supprimée, zéro renommée. L'archive contient les sept
tâches d'implémentation/qualification cochées et ce rapport de clôture.

La spécification finale conserve trois exigences, dont deux exigences
antérieures inchangées, et six scénarios. Le corps normatif de l'exigence
modifiée est identique entre le delta archivé et la spécification principale.
La correction rédactionnelle après archivage répond à la limite de longueur
du validateur et ne change ni les scénarios ni l'implémentation.
Aucun second archivage n'est exécuté.

## 6. Limites et suites

La qualification établit les références transmises à Docker sur fixtures ;
elle ne prouve ni les droits GHCR du compte réel ni une publication effective.
Le DIU installé n'est pas mis à jour par cette session.

Les trois diagnostics ShellCheck historiques du module complet et la
dépendance de sept tests de création/synchronisation à `/tmp` restent
signalés hors périmètre. Le résultat de la suite élargie n'est pas présenté
comme une réussite. Les validations applicables à la correction réussissent.

La normalisation ne remplace pas les autres validations de syntaxe de
référence assurées par Docker. Aucun fournisseur autre que GHCR, aucune
configuration de projet réelle et aucun correctif du libellé Docker
d'interruption du résumé CI/CD ne sont inclus dans cette correction.
