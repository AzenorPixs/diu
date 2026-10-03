## 1. Spécification

- [x] 1.1 Valider strictement le change correspondant au périmètre approuvé.

## 2. Implémentation

- [x] 2.1 Ajouter la fonction et le routage OpenSpec avec contrôles et erreurs.
- [x] 2.2 Intégrer l'appel avant DevOps lors de la création et actualiser les aides.
- [x] 2.3 Documenter le comportement et ajouter les tests isolés nécessaires.

## 3. Validation et clôture

- [x] 3.1 Exécuter les tests ciblés, bash -n et ShellCheck.
- [x] 3.2 Vérifier la cohérence et le périmètre des modifications.
- [x] 3.3 Valider strictement le change final et vérifier son éligibilité à l'archivage.

## Preuves observées

- Validation stricte du change réussie avant implémentation, puis sous devops
  avec `/home/devops/.local/npm/bin/openspec validate add-projects-template-openspec --type change --strict --no-interactive`.
- `bash -n modules/projects/template.sh modules/projects/projects.sh root-install-debian.sh lib/rid-help.sh` : réussi.
- `shellcheck modules/projects/template.sh root-install-debian.sh lib/rid-help.sh` : réussi.
- ShellCheck de la fonction create_project extraite en mémoire : réussi.
- ShellCheck du module projects.sh complet : code 1, uniquement SC2004 de style
  dans project_env_set_variables, à la ligne 374, hors modification. Conservé.
- `python3 -B -m unittest discover -s tests -p 'test_rid_help.py'` : 49 tests réussis.
- `python3 -B -m unittest discover -s tests -p 'test_projects*.py'`, hors sandbox
  sous devops : 71 tests réussis, aucun ignoré.
- Le lancement des tests DevOps dans le sandbox avait échoué sur un chown avec
  mappage UID/GID invalide ; la suite complète sous devops hors sandbox réussit.
- Accès non interactif devops et docker vérifié hors sandbox par `id -un`.
- Validation stricte finale sous devops : réussie. Encodage UTF-8, LF,
  syntaxe Python et nettoyage des fixtures : réussis.

## Cohérence du périmètre

| Élément | Contrôle |
| --- | --- |
| Code | Fonction et routage relus ; tests des trois branches, erreurs et ordre des appels réussis. |
| AGENTS.md | Racine, exclusions et périmètre respectés ; aucune opération Git. |
| PROJECT.md | Responsabilité du module projects préservée. |
| TECHNICAL.md | Commandes, compte, erreurs et ordre documentés. |
| BUILD.md | Aucun changement de construction ; module existant déjà distribué. |
| DEVOPS.md | Chemin OpenSpec explicite utilisé ; fichier conservé. |
| README.md | Présentation générale toujours cohérente ; fichier conservé. |
| OpenSpec | Change validé strictement, archivé et trois capacités synchronisées validées strictement. |

Seuls les neuf fichiers de code, tests et cadrage prévus et les artefacts du
change ciblé ont été édités. Le diagnostic SC2004 ne concerne pas ces ajouts.

## Archivage et état terminal

`openspec archive add-projects-template-openspec --json --yes`, exécuté sous
devops hors sandbox, a réussi. Le change est archivé dans
`openspec/changes/archive/2026-10-02-add-projects-template-openspec` ; trois
exigences ont été ajoutées et une modifiée, sans suppression ni renommage.

Les commandes `openspec validate <capacité> --type spec --strict --no-interactive`
ont réussi sous devops pour projects-template-openspec, projects-template-devops
et rid-help. L'objet provisoire généré par l'archivage pour la nouvelle capacité
a été complété ; sa validation stricte a ensuite réussi. Les informations
OpenSpec sur la longueur des exigences ne sont pas bloquantes.

Le change actif n'existe plus. Les critères du périmètre approuvé sont établis,
avec 120 tests ciblés réussis. Le diagnostic ShellCheck SC2004 dans la fonction
non modifiée reste signalé hors périmètre. Aucun projet réel n'a été initialisé,
aucun commit ni autre change n'a été modifié.
