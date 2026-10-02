## 1. Spécification

- [x] 1.1 Valider le change strictement avant implémentation.

## 2. Implémentation

- [x] 2.1 Activer projects_update et distinguer les deux usages CLI.
- [x] 2.2 Répercuter l'échec projects dans rid update sans changer l'ordre.
- [x] 2.3 Actualiser aides, documentation et tests isolés.

## 3. Validation

- [x] 3.1 Exécuter syntaxe Bash, ShellCheck et les suites applicables.
- [x] 3.2 Vérifier cohérence, périmètre et validation OpenSpec finale.

## Autorisation et périmètre

Le développeur a validé la proposition : mise à jour générale par all all,
préservation de la mise à jour ciblée des variables, propagation d'échec
dans rid update, aides, documentation, tests et archivage SCM ciblé.
La synchronisation et les configurations Git/fournisseurs ont été soumises
séparément et ne sont pas intégrées. Le décalage préexistant entre la
description enrichie d'orchestration globale et le code simple a été signalé
avant validation ; sa refonte reste explicitement exclue.

## Validations exécutées et réussies

- `bash -n modules/projects/projects.sh modules/diu/update-all.sh root-install-debian.sh lib/rid-help.sh`.
- `shellcheck modules/diu/update-all.sh root-install-debian.sh lib/rid-help.sh`.
- `shellcheck --severity=warning modules/projects/projects.sh modules/diu/update-all.sh root-install-debian.sh lib/rid-help.sh` : aucun avertissement ou erreur.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects_general_update.py` : 9 tests sur la dernière exécution, incluant répartiteur public réel et absence de poursuite de l'installation.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_rid_help.py` : 56 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects.py` : 25 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects_template_all.py` : 8 tests.
- Sous devops, `/home/devops/.local/npm/bin/openspec validate add-projects-general-update --type change --strict --no-interactive` : avant code puis sur le change final.
- Aides réelles : `bash root-install-debian.sh projects update help` et `bash root-install-debian.sh update '?'`.
- Syntaxe Python, UTF-8/LF et nettoyage des fixtures ciblées : réussis.

Total : 98 tests ciblés réussis. Aucun rid update système ou modèle de vrai
projet n'a été exécuté. Les tests isolent les modules externes et valident
appel unique, routage général/ciblé/all, saisie ciblée conservée via la fonction
existante, arguments refusés, sélection et ordre par projet réutilisés,
échec OpenSpec sans DevOps, bilan, aucun projet éligible, ordre des six modules,
code projects non nul conservé après softwares et code softwares conservé
si projects réussit. Les parcours diu et moteurs explicites restent séparés.

## Échecs observés et limites préexistantes

La commande ShellCheck par défaut sur les quatre fichiers a rendu un code 1
pour le seul diagnostic de style SC2004 sur `keys[${index}]` dans projects.sh,
ligne 378. Cette ligne n'a pas été modifiée. Une comparaison par stdin avec
la fonction projects_update initiale reconstituée en mémoire a retrouvé le
même diagnostic unique SC2004, code 1, niveau style. Le contrôle par défaut
n'est donc pas déclaré réussi sur ce fichier ; le contrôle des niveaux
avertissement et erreur a réussi. Aucun diagnostic n'a été désactivé dans le code.

Cinq tests globaux existants de test_software.py ont été exécutés via
unittest.TestResult, sans modifier leur attente :

- test_universal_order_and_exec_isolation
- test_global_failure_keeps_independent_diu
- test_hermes_installed_but_stopped_is_included
- test_hermes_failure_is_in_global_summary
- test_diu_failure_is_in_global_summary

Ils échouent tous dans le code actuel et tous dans une seconde exécution
avec la fonction update_all précédente reconstituée en mémoire depuis la
lecture initiale. Le premier diagnostic précis est `system_update: command
not found`, code 127 : leurs fixtures attendent une orchestration enrichie
et ne définissent pas les participants du parcours simple. Ces cinq tests
ne sont pas déclarés réussis, ni corrigés ou désactivés. La comparaison prouve
leur présence antérieure à cette évolution ; les nouveaux tests utilisent
les six participants réels du contrat et passent.
La première commande de comparaison n'a pas exécuté de tests à cause d'une
erreur de transmission des retours ligne Python ; elle a été reprise avec
un encodage explicite du script et la comparaison a ensuite réussi.

## Cohérence finale dans le périmètre validé

| Élément | Constat |
| --- | --- |
| Projet réel | projects_update appelle la fonction de modèles existante ; branche ciblée et update_projects inchangées ; répartiteur public et retours vérifiés. |
| AGENTS.md | Spécification avant code, écritures approuvées et tests isolés ; aucune inspection Git ou écriture OpenCode. |
| PROJECT.md | Architecture modulaire préservée. |
| TECHNICAL.md | Deux usages update et propagation projects documentés ; écart d'orchestration enrichie explicitement signalé. |
| BUILD.md | Construction et infrastructure inchangées. |
| DEVOPS.md | OpenSpec via le chemin explicite de l'environnement réel sous devops. |
| README.md | Présentation générale cohérente ; aucune modification nécessaire. |
| OpenSpec | Nouvelle capacité projects-general-update, ajouts universal-update et rid-help validés ; capacités de variables et modèles existantes conservées. |

Fichiers modifiés : modules/projects/projects.sh, modules/diu/update-all.sh,
root-install-debian.sh, lib/rid-help.sh, TECHNICAL.md et tests/test_rid_help.py.
Fichier créé : tests/test_projects_general_update.py. Les autres écritures
concernent uniquement ce change et ses capacités synchronisées. Pas de
migration, dépendance, variable, suppression ou autre opération projects.
Les critères de ce change sont satisfaits par les tests ciblés ; les écarts
préexistants ci-dessus restent signalés, hors du périmètre approuvé de correction.

## Archivage et clôture du périmètre ciblé

Exécuté et réussi sous devops :
`/home/devops/.local/npm/bin/openspec archive add-projects-general-update --json --yes`.
Archive : `2026-10-02-add-projects-general-update`. Synchronisation effective
de quatre exigences ajoutées, sans modification, suppression ou renommage
d'exigence existante. Le Purpose de la nouvelle capacité a été finalisé après
remplacement du texte provisoire généré par l'archivage.

Exécutées et réussies sous devops :

- `/home/devops/.local/npm/bin/openspec validate projects-general-update --type spec --strict --no-interactive`.
- `/home/devops/.local/npm/bin/openspec validate universal-update --type spec --strict --no-interactive`.
- `/home/devops/.local/npm/bin/openspec validate rid-help --type spec --strict --no-interactive`.

Les messages INFO sur la longueur des exigences sont informatifs et les
trois validations strictes ont rendu un code zéro. Le change ciblé n'est
plus actif et ses tâches sont terminées. Les réserves préexistantes
ShellCheck style et tests globaux décrites ci-dessus restent explicitement
signalées ; elles ne constituent pas une livraison de la refonte globale
exclue du périmètre validé.
