# Revue SCM — copie initiale de DEVELOPMENT_MAP.md

## Mandat et réalisation

Le développeur a validé le périmètre autonome puis demandé de poursuivre
jusqu'à la clôture complète. Le change couvre uniquement l'initialisation
de DEVELOPMENT_MAP.md dans sync_project, également appelée par sync all.
Les autres changes restent hors périmètre.

La sélection conditionnelle intervient avant le staging et les copies dans
le projet. Une destination existante, y compris répertoire ou lien pendant,
n'entre pas dans la sélection, les substitutions Markdown ou le chown.
Une source requise absente ou de type incorrect échoue avant copie ; la
commande groupée conserve son parcours après échec. Le second contrôle
avant copie préserve une destination apparue pendant la préparation ; aucune
garantie de verrouillage de synchronisations concurrentes n'est ajoutée.

## Critères et preuves ciblées

Commande : `/home/devops/python/current/bin/python3 -B -m unittest discover
-s tests -p 'test_projects_development_map.py' -v`.

Résultat final : 8 tests réussis, avec sous-cas couvrant les modes Yes, No
et vide, les chemins avec espaces et le caractère & du nom de projet.

| Critère | Test |
| --- | --- |
| Création, personnalisation et propriétaire | test_missing_map_is_personalized_and_owned_in_every_mode |
| Carte existante intacte, source non requise | test_existing_map_preserves_content_and_attributes_without_source |
| Réexécution sans écrasement | test_second_sync_preserves_new_map_after_model_changes |
| Répertoires, liens valides et pendants préservés | test_directory_and_symlinks_are_preserved_even_without_source |
| Source absente ou répertoire : échec avant copie | test_missing_or_directory_source_fails_before_copy |
| Parcours groupé mixte et réexécution | test_grouped_sync_initializes_only_missing_maps_and_is_repeatable |
| Poursuite du parcours groupé après échec | test_grouped_failure_does_not_block_later_project_with_existing_map |
| Erreur de copie explicite sans faux succès | test_copy_failure_is_reported_without_false_success |

Le premier passage du test d'erreur interceptait à tort la copie de staging.
Seul le ciblage de cette simulation a été corrigé ; ses assertions ont été
conservées, et le second passage complet des 8 tests réussit.

`chown` est simulé dans ces tests pour contrôler sa sélection sans modifier
les comptes système. Ils prouvent les arguments transmis ; le propriétaire
réel d'un projet synchronisé en production n'a pas été qualifié ici.

Autres contrôles exécutés et réussis :

- `bash -n modules/projects/projects.sh` ;
- `shellcheck modules/projects/projects.sh` avant et après modification ;
- `py_compile.compile(..., doraise=True)` avec le Python DevOps et une sortie
  temporaire pour les trois fichiers de tests modifiés/créés ;
- vérification UTF-8/LF des 11 fichiers du périmètre avant cette revue ;
- préservation des 6 scénarios existants du bloc MODIFIED ;
- validation stricte du delta OpenSpec ciblé, avant code puis après réalisation.

## Validation globale

Premier passage des tests `test_projects*.py`, Python DevOps, TMPDIR temporaire
sous DIU : 322 tests en 135,152 s, 1 échec et 2 ignorés. L'échec existant de
test_git_local_update_preserves_mode_without_asking provient d'un accès refusé
à /etc/gitconfig ; il ne touche pas le parcours de synchronisation.
La reprise finale isole GIT_CONFIG_SYSTEM dans un fichier temporaire sous DIU,
sans modifier le code ou les assertions de ce test ni la configuration hôte.
Résultat de cette reprise globale (`test_*.py`) : 636 tests exécutés en
157,121 s, 626 réussis, 2 ignorés, 8 échecs hors du périmètre modifié.
Les 322 tests des projets sont inclus et ne signalent plus aucun échec
(320 réussis, 2 ignorés), y compris le test Git précédemment empêché.

Les échecs globaux restants sont :

- test_root_shellcheck : test_generated_contents (/root/.zshrc, empreinte
  différente) et test_literal_zsh_functions (15 blocs au lieu de 14) ;
- test_software : test_diu_failure_is_in_global_summary,
  test_global_failure_keeps_independent_diu,
  test_hermes_failure_is_in_global_summary,
  test_hermes_installed_but_stopped_is_included,
  test_universal_order_and_exec_isolation ;
- test_software_flatpak :
  test_softwares_update_and_universal_update_call_flatpak_once.

Les six échecs logiciels correspondent à un retour 127 au lieu du résultat
attendu ; les diagnostics observés indiquent system_update introuvable dans
modules/diu/update-all.sh. La recherche ciblée des imports dans ces trois
fichiers de tests confirme qu'ils n'exécutent pas sync_project ni le module
projects.sh modifié : les tests Zsh lisent root-install-debian.sh et les tests
logiciels sourcent les modules logiciels et update-all.sh, tous inchangés
par ce mandat. Ces écarts indépendants restent signalés sans extension du
périmètre. Le dépôt global n'est pas déclaré entièrement valide.

OpenSpec global standard avant archivage : 68 valides, 2 échecs préexistants.
OpenSpec global strict avant archivage : 49 valides, 21 échecs préexistants,
contre 48 valides et ces mêmes 21 échecs avant création du change.
Le change ajouté est valide. Les deux erreurs standard concernent les deltas
Forgejo modify-projects-forgejo-push-force-with-lease et
restore-forgejo-push-to-create ; les autres échecs stricts sont des
avertissements préexistants hors périmètre. Ils ne sont pas corrigés ici.

## Bilan documentaire par fichier

| Document | État et preuve |
| --- | --- |
| AGENTS.md | Inchangé : sections 5, 6, 13 et 21 appliquées ; aucune nouvelle règle d'agent requise. |
| PROJECT.md | Inchangé : section Module projects, responsabilité d'administration inchangée. |
| TECHNICAL.md | Mis à jour : paragraphe rid projects sync, copie initiale, préservation, erreurs et parcours groupé. |
| BUILD.md | Inchangé : section Contenu du paquet, les scripts modifiés restent dans modules/ déjà distribué. Aucun changement de construction. |
| DEVOPS.md | Inchangé : rubriques Python et OpenSpec réutilisées, aucune nouvelle dépendance ni sonde. |
| README.md | Mis à jour : paragraphe de synchronisation de DEVELOPMENT_MAP.md et limite des sources requises. |
| CHANGELOG.md | Mis à jour : entrée Unreleased, sans version/date de livraison inventée. |
| openspec/specs/projects-sync/spec.md | Delta synchronisé par l'archivage réussi ; 6 scénarios du bloc remplacé conservés ; validation stricte finale réussie. |
| openspec/specs/projects-sync-all/spec.md | Inchangé : exigence Commande de synchronisation groupée appliquant déjà le comportement unitaire. |

## Périmètre et limites

Fichiers applicatifs/doc : modules/projects/projects.sh ;
tests/test_projects_development_map.py ; tests/test_projects.py ;
tests/test_projects_orchestrated_copy.py ; TECHNICAL.md ; README.md ; CHANGELOG.md.
Les deux tests existants reçoivent uniquement le document dans leurs modèles
synthétiques ; leurs assertions de préservation restent inchangées.
Artefacts OpenSpec : proposal.md, design.md, tasks.md, ce rapport et delta
projects-sync dans ce seul change, puis synchronisation du spec courant et
rapport STATISTICS.md lors de l'archivage.

Aucune synchronisation de projet réel ni modification du modèle externe,
installation, construction de paquet ou activation runtime n'est exécutée.
Ces opérations sont non pertinentes pour ce correctif source ; son adoption
effective dépend de l'utilisation de la version DIU mise à jour.
Les erreurs pendant les copies ou le chown restent sans rollback global,
conformément au comportement existant.

## Archivage et contrôle de la spécification synchronisée

`openspec archive add-projects-sync-development-map-if-missing --yes` a
réussi : 2 exigences ajoutées, 1 modifiée, aucune supprimée ; archive
2026-10-28-add-projects-sync-development-map-if-missing. Le change actif a
disparu au profit de ce dossier d'archive ; aucun second archivage effectué.

Le premier contrôle strict du spec courant a signalé que le texte de
l'exigence modifiée dépassait 500 caractères. La formulation a été condensée
à 444 caractères, sans modification des comportements ni des scénarios, dans
le spec courant et son delta archivé pour conserver leur cohérence.
La validation stricte de projects-sync après cette correction réussit.
Cette correction documentaire n'affecte pas le code ni les preuves des tests.
Le dernier contrôle global strict après correction retrouve exactement
48 éléments valides et les 21 échecs préexistants sur 69 éléments.
