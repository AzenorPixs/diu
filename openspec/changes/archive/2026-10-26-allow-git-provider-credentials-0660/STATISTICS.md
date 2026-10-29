# STATISTIQUES — Identifiants Git en 0600 ou 0660

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, `diu`, /home/devops/datas/diu.
- Session SCM directe ; date utilisateur : 26 octobre 2026, Europe/Paris.
- Change : `allow-git-provider-credentials-0660`.
- Archive : `2026-10-26-allow-git-provider-credentials-0660`.
- Périmètre proposé puis explicitement approuvé par « Je valide ».
- Preuves : commandes de cette session, [proposition](proposal.md),
  [conception](design.md), [tâches](tasks.md), [revue](review.md), cinq deltas
  sous specs/ et cinq spécifications canoniques synchronisées.

Acceptation exacte de 0600 et 0660 pour les six fichiers username/token des
providers Forgejo, GitHub et GitLab. Les fichiers existants gardent leur
contenu et leur mode ; les autres modes restent refusés avant lecture.
Nouveaux identifiants et secrets temporaires restent en 0600. Le groupe peut
lire et modifier un identifiant en 0660 ; aucune permission système ou ACL
n'est modifiée. Aucun push de tools-codex ni déploiement du DIU n'est exécuté.

## 2. Durées et mesures disponibles

| Mesure | Valeur et source |
| --- | --- |
| Première suite projets | 109,340 s, sortie unittest : 283 tests |
| Dernière suite dédiée | 2,709 s, sortie unittest : 14 tests |
| Campagne finale combinée | 111,256 s, sortie unittest : 297 tests |
| Durée totale de conversation ou session | N/A : pas de mesure continue depuis le début |
| Tokens, coût, CPU et mémoire | N/A : pas d'instrumentation dédiée |
| Messages et appels d'outils exhaustifs | N/A : pas d'export de télémétrie |
| Approbations CAB et télémétrie OpenCode | N/A : session SCM directe, sans CAB ni skill de statistiques SCMP |

Les durées sont celles des passages distincts, non une somme de temps total.
Les sous-tests ne sont pas comptés comme méthodes supplémentaires.

## 3. Fichiers et comportement livré

| Catégorie | Nombre | Chemins |
| --- | ---: | --- |
| Code existant modifié | 3 | lib/forgejo-auth.sh ; lib/github-auth.sh ; lib/gitlab-auth.sh |
| Test créé | 1 | tests/test_provider_credential_permissions.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Canon OpenSpec modifié | 5 | forgejo-auth ; forgejo-release ; implement-projects-forgejo-push ; implement-projects-github-push ; implement-projects-gitlab-push |
| Delta actif voisin aligné | 1 | modify-projects-forgejo-push-force-with-lease/specs/forgejo-auth/spec.md, une phrase de permission |
| Fichiers dans la nouvelle archive | 10 | proposal.md ; design.md ; tasks.md ; review.md ; cinq specs/*/spec.md ; STATISTIQUES.md |
| **Total du correctif** | **23** | **3 + 1 + 3 + 5 + 1 + 10** |

Douze fichiers préexistants modifiés et onze nouveaux fichiers à leur
emplacement final. Les neuf fichiers du change ont été déplacés par OpenSpec,
avec conservation de leurs SHA-256 avant/après. Le rapport est créé ensuite.
La modification préexistante de DEVOPS.md est conservée sans édition par la
session ; elle n'est pas comptée dans ces 23 fichiers. Son inclusion au commit
global conditionnel relève du prompt SCM, pas du correctif fonctionnel.

## 4. Tests et vérifications

| Passage | Exécutés | Réussis | Échoués | Ignorés |
| --- | ---: | ---: | ---: | ---: |
| Lecteurs seuls | 5 | 5 | 0 | 0 |
| Dédié final | 14 | 14 | 0 | 0 |
| Première suite projets sans isolation système Git | 283 | 280 | 1 | 2 |
| Test de configuration Git rejoué avec isolation | 1 | 1 | 0 | 0 |
| Campagne finale projets + suite dédiée | 297 | 295 | 0 | 2 |

Ces passages se recouvrent et leurs nombres ne doivent pas être additionnés.
Le passage de construction des fixtures d'intégration (13 méthodes) a échoué
avec 29 échecs de sous-tests et deux erreurs : les répertoires héritaient du
bit setgid du dépôt partagé. Le scratch propre aux tests est maintenant
explicitement isolé en 0700, puis les mêmes assertions exactes ont réussi.
Aucun comportement applicatif ni attente de sécurité n'a été affaibli.

La première suite projets a échoué sur
`test_git_local_update_preserves_mode_without_asking` : écriture refusée dans
/etc/gitconfig. Le test ne charge aucune bibliothèque modifiée. La campagne
finale redirige GIT_CONFIG_SYSTEM vers une fixture temporaire sous le projet,
sans changer les tests ni la configuration Git hôte. Les deux tests Go sont
ignorés faute de binaire dans le PATH de test ou DIU_TEST_GO ; ils sont hors
du comportement corrigé. Leurs identifiants sont :
`test_real_go_version_from_inaccessible_caller_directory` et
`test_runuser_execution_envelope_preserves_arguments_and_changes_child_directory`.

La campagne finale emploie /home/devops/python/current/bin/python3 -B,
unittest.TestLoader.discover sur test_projects*.py et
sur test_provider_credential_permissions.py, regroupés en une TestSuite.

La suite dédiée vérifie les six lecteurs et douze modes refusés, les fichiers
absents/vides et stat en échec, 24 parcours push/fetch avec modes privés,
partagés ou mixtes, les clones GitHub/GitLab existants, leur initialisation,
les API Forgejo/GitHub et le registre GitLab. Les lecteurs et le cœur Git sont
réels ; Git, curl et Docker sont des transports simulés sans réseau.
Les secrets fictifs sont vérifiés hors arguments et sorties ; fichiers privés
Git/curl et DOCKER_CONFIG sont nettoyés après succès et échec.

| Contrôle | Résultat observé |
| --- | --- |
| bash -n des trois bibliothèques et cinq scripts de fixtures | Exécuté et réussi |
| Compilation Python py_compile | Exécutée et réussie avec le Python DevOps |
| ShellCheck des trois bibliothèques | Exécuté, code 1 : Forgejo/GitHub sans diagnostic ; GitLab garde SC2295 ligne 30 et trois SC2034 lignes 44–46 |
| Comparaison ShellCheck avant/après | Réussie : diagnostics et positions intégralement identiques, aucun ajout ni exclusion |
| Change OpenSpec strict avant code et avant archive | Exécuté et réussi sans diagnostic |
| Global OpenSpec strict initial | Exécuté, code 1 : 68 éléments, 46 valides, 22 en échec |
| Global strict avec le change actif | Exécuté, code 1 : 69 éléments, 47 valides, mêmes diagnostics préexistants |
| Global strict après archive | Exécuté, code 1 : 68 éléments, 46 valides, 22 en échec ; aucun diagnostic ajouté, deux avertissements de longueur retirés dans les exigences Forgejo release modifiées |
| Global standard final | Exécuté, code 1 : 68 éléments, 66 valides ; deux changes Forgejo préexistants en échec, 60 canons valides |
| Concordance deltas/canons | Réussie : cinq capacités, sept exigences et 40 scénarios, hors lignes vides normalisées par OpenSpec |
| UTF-8/LF, sans BOM, blancs finaux et fin de fichier | Réussi sur les fichiers du périmètre avant archive ; contrôle étendu à l'archive et au présent rapport |
| Suite complète du dépôt | Non exécutée : suites projets et authentification retenues |
| Publications réelles, Docker/LXC réels, installation | Non exécutés : correctif des sources et fixtures isolées |

## 5. Cohérence documentaire et archivage

| Document | État et preuve |
| --- | --- |
| Projet réel | Six lecteurs corrigés, transports simulés et 295 tests finaux réussis ; pas de déploiement |
| AGENTS.md | Inchangé : règles OpenSpec, secrets et validation appliquées |
| PROJECT.md | Inchangé : architecture modulaire conservée, session directe autorisée par SCM |
| TECHNICAL.md | Fichiers d'identifiants décrit 600/660, partage de groupe et protection temporaire |
| BUILD.md | Inchangé : build et packaging non concernés |
| DEVOPS.md | Non édité, modification préexistante conservée ; chemins Python/OpenSpec utilisés |
| README.md | Ajout des règles publiques 0600/0660 |
| CHANGELOG.md | Entrée Unreleased, sans version ou publication inventée |
| openspec/specs/ | Cinq canons synchronisés, sept exigences et 40 scénarios conformes aux deltas |

Commande d'archivage exécutée et réussie sous devops :

```bash
/home/devops/.local/npm/bin/openspec archive allow-git-provider-credentials-0660 --json --yes
```

Un seul archivage réussi. Résultat OpenSpec : zéro ajout, sept modifications,
zéro suppression ou renommage d'exigence ; specsUpdated=true. Change actif
absent, archive présente, neuf empreintes conservées et cinq tâches cochées.
Aucun BLOCKER.md ou BLOCKERS.md ni lien correspondant : nettoyage non requis.

Totaux vérifiables : 23 = 3 + 1 + 3 + 5 + 1 + 10 ;
297 = 295 + 0 + 2 ; cinq tâches sur cinq ; sept exigences, 40 scénarios ;
un change archivé, dix fichiers dans son archive, six sections dans ce rapport.

## 6. Limites et clôture

Le correctif des sources, ses tests, les cinq spécifications et la
documentation sont cohérents dans le périmètre validé. Les quatre diagnostics
ShellCheck GitLab et les 22 éléments OpenSpec strict en échec sont préexistants.
En mode standard, les deltas des changes
modify-projects-forgejo-push-force-with-lease et restore-forgejo-push-to-create
omettent toujours deux scénarios du canon ; cette correction n'est pas autorisée.
Le premier reçoit uniquement l'alignement de sa phrase de permissions.
Aucune réussite globale du dépôt n'est affirmée.

Aucun fichier d'identifiant réel n'a été ouvert ou modifié ; le correctif n'est
pas installé dans /root/diu. Les commandes rid utilisant cette installation
nécessitent la livraison habituelle du DIU avant de profiter du correctif.
Le commit global et les publications conditionnelles SCM suivent la
vérification de ce rapport ; leurs résultats réels sont restitués dans le
bilan final, sans les présumer ici.
