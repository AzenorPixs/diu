# STATISTIQUES — safe.directory système des projets

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date de session et d'archive : 22 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, `projects-git-safe-directory`.
- Change : `manage-projects-git-safe-directory`.
- Archive : `2026-10-22-manage-projects-git-safe-directory`.
- Objet : exception safe.directory système exacte pour init/update,
  diagnostic sans écriture pour status, aide et documentation associées.
- Sources de preuve : sorties de commandes de cette session, empreintes
  ciblées, tâches, deltas et [review.md](review.md).

Ce rapport consigne les mesures observées. Il ne lance ni télémétrie de
pilotage, ni service CAB, ni session OpenCode, ni agent délégué.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Durée complète de la session | N/A : aucun chronométrage global initialisé |
| Première série dédiée, 22 tests | 1,420 s, durée fournie par unittest |
| Deuxième série dédiée, 24 tests | 1,798 s, durée fournie par unittest |
| Suite finale groupée, 118 tests | 6,757 s, durée fournie par unittest |
| Total des durées unittest observées | 9,975 s = 1,420 + 1,798 + 6,757 ; hors exploration, édition, lint et OpenSpec |
| Tokens, coût et ressources machine | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie de session |
| Statistiques d'approbations CAB | N/A : protocole CAB non utilisé dans cette session SCM |

## 3. Fichiers et contrat

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 2 | modules/projects/git.sh ; lib/rid-help.sh |
| Tests | 2 | test_rid_help.py modifié ; test_projects_git_safe_directory.py créé |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécifications principales synchronisées | 4 | projects-git-init ; implement-projects-git-update ; projects-git-status ; rid-help |
| Documents de l'archive créée | 9 | proposal.md ; design.md ; tasks.md ; quatre deltas spec.md ; review.md ; STATISTIQUES.md |
| **Total final du périmètre** | **20** | **2 + 2 + 3 + 4 + 9** |

Dix fichiers existants sont modifiés : deux scripts, un test, trois documents
et quatre spécifications. Dix fichiers sont créés : un test et neuf
documents d'archive. Les nouveaux artefacts actifs sont déplacés dans
l'archive par OpenSpec ; aucun fichier préexistant n'est supprimé ou renommé.

Les empreintes des quatre cadrages inchangés (AGENTS.md, PROJECT.md, BUILD.md,
DEVOPS.md), d'openspec/config.yaml et des deux fichiers contrôlés du change
voisin ensure-projects-git-commit-init sont conservées : sept fichiers témoins.
Les exigences antérieures des quatre spécifications synchronisées sont aussi
préservées, par comparaison de leurs empreintes initiales avant les ajouts.

Le contrat livré utilise un chemin absolu canonique, aucun joker ajouté et
un ajout système idempotent. Les erreurs sont explicites, les autres règles
et propriétaires sont préservés. status n'écrit pas safe.directory, même via
ses replis. Les signatures publiques, le questionnaire des variables et
l'initialisation silencieuse sont conservés.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Première série dédiée | 22 | 19 | 3 | 0 | 0 |
| Série dédiée après corrections | 24 | 24 | 0 | 0 | 0 |
| Suite finale groupée | 118 | 118 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **164** | **161** | **3** | **0** | **0** |

Les 118 méthodes de la suite finale se répartissent en 26 tests dédiés,
56 tests d'aide/routage/Git, 9 tests de mise à jour générale et 27 tests de
projets. Ce total est distinct des 164 exécutions cumulées ; les sous-tests
unittest ne sont pas comptés comme des méthodes supplémentaires.
Les trois échecs initiaux sont expliqués et corrigés dans review.md.

| Autre contrôle | État final |
| --- | --- |
| bash -n, chacun des deux scripts | Exécuté et réussi |
| ShellCheck des sept fonctions concernées | Exécuté et réussi, zéro diagnostic |
| ShellCheck du fichier d'aide complet | Exécuté et réussi |
| ShellCheck du fichier Git complet | Exécuté et échoué : SC2034, SC2269 et SC2086 antérieurs et hors périmètre, reproduits sur le contenu initial à SHA-256 identique |
| python3 -m py_compile, deux tests | Exécuté et réussi, caches temporaires isolés puis supprimés |
| Validation stricte du change | Exécutée et réussie avant implémentation et avant archivage |
| Validation stricte des spécifications Git init/update/status synchronisées | Trois exécutées et réussies |
| Validation stricte de rid-help complet | Exécutée et échouée : cinq exigences anciennes trop longues, indices 3, 8, 9, 10, 11 ; mêmes avertissements sur le document initial reconstruit et validé en isolation |
| Delta rid-help ajouté | Inclus dans le change validé strictement, aucun avertissement propre |
| UTF-8/LF, six sections, totaux et tâches | Vérifiés sur le périmètre final par contrôle local après écriture de ce rapport |
| Configuration système réelle et publication | Non exécutées : tous les tests Git utilisent des fichiers temporaires isolés |

## 5. Résultats et archivage

La commande exécutée est :

```bash
/home/devops/.local/npm/bin/openspec archive manage-projects-git-safe-directory --yes
```

Elle retourne zéro et annonce les tâches complètes, la synchronisation
réussie de quatre spécifications et l'archive
`2026-10-22-manage-projects-git-safe-directory`.

| Résultat OpenSpec | Nombre |
| --- | ---: |
| Exigences ajoutées | 6 |
| Exigences modifiées | 0 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Tâches d'implémentation et de validation terminées | 8 sur 8 |
| Changes archivés pendant cette session | 1 |

Les six exigences se répartissent en deux pour init, une pour update, deux
pour status et une pour l'aide. Le change actif ciblé n'existe plus ; son
archive contient le présent rapport et review.md. Aucun autre change n'a
été archivé. Le bilan documentaire par fichier, avec les motifs des cadrages
inchangés et les preuves de cohérence, figure dans review.md.

Commits et pushes du dépôt de travail : zéro. Aucune branche, aucun tag,
aucune release et aucune installation système créés par cette session.
Les fixtures Git temporaires des tests ne représentent pas une publication
ou un commit du dépôt de travail. Aucun réarchivage n'est nécessaire pour
produire ou corriger ce rapport.

## 6. Limites et suites

L'évolution est implémentée, testée et archivée. Le dépôt n'est pas déclaré
exempt de tous diagnostics : trois diagnostics ShellCheck et cinq
avertissements stricts du document rid-help préexistaient à cette évolution
et restent hors périmètre. Aucune règle de validation n'a été désactivée.

Une règle globale prioritaire peut neutraliser la confiance système.
Un include système qui neutralise l'entrée exacte bloque la commande,
sans réordonner les règles administrateur. Une première tentative peut
laisser une entrée inactive, sans doublon supplémentaire aux relances.
Les écritures précédentes restent en place en cas d'échec.

L'installation de production du DIU n'a pas été mise à jour et aucune
exception n'a été ajoutée à la configuration réelle de cette machine.
Les dépôts existants adopteront le comportement lors d'un prochain init ou
update avec les sources livrées et les droits système nécessaires.
