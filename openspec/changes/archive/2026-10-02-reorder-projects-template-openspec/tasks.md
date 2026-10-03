## 1. Spécification

- [x] 1.1 Valider strictement le change avant toute écriture de code ou test.

## 2. Implémentation

- [x] 2.1 Adapter le routage et le diagnostic à la nouvelle syntaxe.
- [x] 2.2 Actualiser les aides, la documentation et les tests concernés.

## 3. Validation

- [x] 3.1 Exécuter bash -n, ShellCheck et les tests ciblés.
- [x] 3.2 Contrôler la cohérence, le périmètre et la validation stricte finale.

## Preuves observées

- Validation stricte du change sous devops avant implémentation : réussie.
  Le scénario d'aide existant Arguments invalides a été conservé après le
  diagnostic initial de validation sur son renommage.
- `bash -n modules/projects/template.sh root-install-debian.sh lib/rid-help.sh` : réussi.
- `shellcheck modules/projects/template.sh root-install-debian.sh lib/rid-help.sh` : réussi.
- `python3 -B -m unittest discover -s tests -p 'test_rid_help.py'` sous devops,
  hors sandbox : 49 tests réussis, aucun ignoré.
- `python3 -B -m unittest discover -s tests -p 'test_projects*.py'` sous devops,
  hors sandbox : 71 tests réussis, aucun ignoré.
- Aides réelles `projects template help` et
  `projects template openspec application help` : nouvelle syntaxe et libellé
  observés sans chargement de configuration.
- Validation stricte finale du change sous devops : réussie. Encodage UTF-8,
  fins de ligne LF, syntaxe Python et nettoyage des fixtures : réussis.

## Cohérence du périmètre

| Élément | Contrôle |
| --- | --- |
| Code et aide | Routage, diagnostics et aides relus ; nouveau sélecteur et rejet de l'ancienne syntaxe testés. |
| AGENTS.md | Périmètre et exclusions respectés ; aucune opération Git ni modification de PROMPTS. |
| PROJECT.md | Responsabilité du module projects conservée. |
| TECHNICAL.md | Nouvelle syntaxe et priorité du sélecteur documentées. |
| BUILD.md | Construction et contenu du paquet inchangés. |
| DEVOPS.md | Chemin OpenSpec explicite utilisé sous devops ; fichier conservé. |
| README.md | Présentation générale conservée et toujours cohérente. |
| OpenSpec | Deux exigences modifiées dans les seules capacités ciblées ; aucun autre change modifié. |

Les six fichiers prévus ont été édités, avec les seuls artefacts du change
ciblé. La fonction garde son argument, ses trois branches, son compte et son
appel avant DevOps lors de create. Aucune migration de projet, opération Git,
installation ni initialisation d'un projet réel n'a été exécutée.

## Archivage et état terminal

`openspec archive reorder-projects-template-openspec --json --yes`, sous devops
hors sandbox, a réussi. Le change a été archivé dans
`openspec/changes/archive/2026-10-02-reorder-projects-template-openspec` et deux
exigences ont été synchronisées, sans ajout, suppression ni renommage.

Les validations strictes des capacités projects-template-openspec et rid-help
ont réussi sous devops après synchronisation. Les informations de longueur des
exigences ne sont pas bloquantes. Le change actif n'existe plus, toutes les
tâches sont prouvées et aucun blocage du périmètre ne subsiste.
