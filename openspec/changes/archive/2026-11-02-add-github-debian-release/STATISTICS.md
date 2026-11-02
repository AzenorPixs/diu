# Statistiques — publication Debian GitHub

## 1. Statistiques générales et décisions

Session directe SCM du 2026-11-02, plan SCM-GITHUB-DEBIAN-20261102-R1 validé en
version 1.0.3. Un agent Codex, sans délégation, CAB, OpenCode ni télémétrie de
pilotage. Le change add-github-debian-release est archivé sous
2026-11-02-add-github-debian-release ; quatre tâches validées, cinq exigences
ajoutées et quatre modifiées dans quatre capacités synchronisées.
Code non attribué ; aucune allocation de code ou de sous-lot définitif hors ACL.
Durée totale, coûts, tokens et quotas : N/A, sans mesure exhaustive disponible.

## 2. Types de messages et d'outils

Exploration, précisions des conditions Forgejo et de la version, proposition,
validation explicite, suivi et restitution. Outils : recherche/lecture locale,
résolution SCM, patches, exécution locale et consultation de documentation
GitHub officielle. Totaux exhaustifs de messages/appels : N/A, sans journal
instrumenté. Aucune compétence réservée à une session pilotée n'est invoquée.
Les vérifications de connexion et publications Git après ce rapport sont
restituées dans le bilan final, sans anticipation de réussite ici.

## 3. Fichiers modifiés

Vingt-sept livrables publics, rapport inclus, et une configuration locale :
28 ressources traitées. L'archivage ne compte pas deux fois les mêmes fichiers.
Les éventuelles modifications extérieures ne sont pas attribuées à ce total.

- `root-install-debian.sh`
- `lib/rid-help.sh`
- `lib/github-auth.sh`
- `modules/projects/git.sh`
- `modules/projects/github-release.sh`
- `tests/test_projects_github_debian_release.py`
- `tests/test_projects_cicd_debian.py`
- `tests/test_project_version.py`
- `PROJECT.md`
- `TECHNICAL.md`
- `BUILD.md`
- `README.md`
- `CHANGELOG.md`
- `DEVELOPMENT_MAP.md`
- `openspec/BATCH_CODES.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/design.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/proposal.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/implement-projects-github-release/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/projects-cicd/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/projects-github-debian-release/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/tasks.md`
- `openspec/specs/projects-github-debian-release/spec.md`
- `openspec/specs/implement-projects-github-release/spec.md`
- `openspec/specs/projects-cicd/spec.md`
- `openspec/specs/rid-help/spec.md`
- `openspec/changes/archive/2026-11-02-add-github-debian-release/STATISTICS.md`

- Configuration locale `project.env` : seule PROJECT_VERSION passe de 1.0.2 à
  1.0.3, un octet modifié ; autres octets, inode, permissions et propriétaire
  préservés. Aucune autre valeur privée n'est exposée ni copiée dans ce rapport.

AGENTS, DEVOPS, lib/project-version.sh, lib/forgejo-auth.sh, les modules de
release Forgejo, packaging historique et Docker, et la recette DIU conservent
leurs empreintes au contrôle de qualification. Forgejo et GitLab ne sont pas
modifiés. Le corps GHCR est conservé dans un helper dédié ; ses anciens tests
restent exécutés, avec contrôle de casse et absence de build.

## 4. Commandes et validations

| Contrôle réellement exécuté | Résultat |
|---|---|
| Publisher Debian et authentification | 30 tests réussis en 18,787 s |
| Sept suites ciblées publication, CI/CD, projets, version, aide, indisponibilité et credentials | 175 tests réussis en 46,446 s |
| Suite complète avec DIU_TEST_GO déclaré | 1 074 tests réussis en 338,324 s ; aucun échec, erreur ou saut |
| Syntaxe Bash des cinq fichiers modifiés | Réussie |
| ShellCheck avec dépendances explicites | Réussi sans diagnostic |
| Compilation des trois fichiers Python modifiés | Réussie |
| OpenSpec du change strict | Réussi, scénarios historiques conservés |
| openspec archive add-github-debian-release --yes | Réussi, cinq ajouts et quatre modifications |
| OpenSpec global standard avant/après archivage | 118/118 valides |
| OpenSpec global strict avant/après archivage | 71 valides, mêmes 47 éléments historiques en échec |
| Quatre canons concernés après synchronisation | Quatre validations strictes réussies |
| Revue documentaire avant archivage | 22 fichiers UTF-8/LF, nouvelles cibles de liens présentes, huit sources surveillées inchangées |

Les 30 et 175 tests ciblés sont des sous-ensembles/répétitions, pas des nombres
à ajouter aux 1 074 tests uniques. Le nouveau fichier contient 24 méthodes et
la suite CI/CD reçoit un cas supplémentaire ; HTTP, assets, erreurs, choix
Docker/Debian, authentification et anciennes publications GHCR sont vérifiés.
Les premières fixtures héritaient du setgid sur DEBIAN : mode exact 0755 appliqué
avant les constructions réelles. Les quotes et les annotations de portée
dynamique signalées par ShellCheck sont corrigées, sans affaiblissement d'attente.

Paquets Debian réels sur fixtures ; Git, API, upload et Docker simulés. Les
contrôles vérifient HTTP/JSON, refus de release existante, tag absent ou erroné,
version, branche et remote, URL d'upload, id/noms/état/taille des assets,
interruption, nettoyage et confidentialité. Aucun artefact n'est réellement
publié ni installé pendant les tests. Les onze premiers paramètres du bilan
restent compatibles et l'activation Docker de la CI/CD reste exactement Yes.

## 5. Accès web

Recherche technique limitée aux sources GitHub officielles et quatre pages :

- [Releases](https://docs.github.com/en/rest/releases/releases).
- [Assets de release](https://docs.github.com/en/rest/releases/assets).
- [Références Git](https://docs.github.com/en/rest/git/refs).
- [Objets de tag](https://docs.github.com/en/rest/git/tags).

Ces lectures précisent création de release, upload binaire, référence et tag
annoté. Aucun secret ou document privé n'est transmis à la recherche web.
Les tests n'appellent pas les API réelles. Les publications Git conditionnelles
SCM suivent le rapport et sont distinguées dans le bilan final.

## 6. Synthèse globale

La commande github release sélectionne Docker, Debian ou les deux avec
Yes/YES/1. Les paquets suivent les conditions de publication Forgejo : paquet
unique et cohérent, version commune, HEAD synchronisé, tag protégé, release
existante refusée et échec partiel explicite sans rollback automatique.
La CI/CD à six étapes publie désormais Debian GitHub à l'étape 5 sans dépendre
de Docker. Le bilan et les aides sont mis à jour. L'upload vérifie son URL et
ses réponses, et protège les credentials dans des fichiers temporaires 0600.

PROJECT, TECHNICAL, BUILD, README et CHANGELOG sont actualisés ; quatre canons,
carte et registre sont synchronisés, avec Purpose GitHub élargi. AGENTS et DEVOPS
ne nécessitent pas d'édition ; les mêmes outils et runtimes sont utilisés.
La matrice complète figure dans tasks.md. Aucune mise à jour du DIU installé :
ridt utilise les sources du dépôt et rid utilise la version installée.

La conformité stricte globale n'est pas revendiquée : 47 éléments historiques
restent en échec, sans nouveau diagnostic dans les quatre canons concernés.
Un ancien lien README vers
openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTIQUES.md
reste absent et hors périmètre ; les nouveaux liens sont vérifiés.
Aucun BLOCKER.md/BLOCKERS.md dans l'archive : aucun nettoyage nécessaire.
STATISTICS.md global absent : mandater SGS.md pour sa génération initiale.
Le code et les sous-lots définitifs restent à attribuer via ACL.
