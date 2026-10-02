## 1. Spécification

- [x] 1.1 Valider strictement le change avant implémentation.

## 2. Implémentation

- [x] 2.1 Adapter routage, aides, diagnostics et documentation.
- [x] 2.2 Adapter les tests de routage et d'aide avec contrôles de régression.

## 3. Validation

- [x] 3.1 Exécuter syntaxe Bash, ShellCheck et suites ciblées sous devops.
- [x] 3.2 Contrôler le périmètre, la cohérence et la validation stricte finale.

## Preuves observées

- Validation stricte sous devops avant implémentation : réussie. Validation
  après ajustement de cohérence de la clause OpenSpec : réussie.
- `bash -n root-install-debian.sh lib/rid-help.sh modules/projects/template.sh` : réussi.
- `shellcheck root-install-debian.sh lib/rid-help.sh modules/projects/template.sh` : réussi.
- `python3 -B -m unittest discover -s tests -p 'test_projects*.py'`, sous
  devops hors sandbox : 71 tests réussis, aucun ignoré.
- `python3 -B -m unittest discover -s tests -p 'test_rid_help.py'`, sous
  devops hors sandbox : 50 tests réussis, aucun ignoré. Réexécution réussie
  après ajout des cas de projets nommés devops et openspec.
- Aides réelles `projects template help` et `projects template devops all help` :
  nouvelles syntaxes et cinq critères de sélection observés.
- UTF-8, LF, syntaxe Python et nettoyage des fixtures : réussis.
- Recherche des anciens ordres DevOps dans les quatre fichiers d'exécution
  et cadrage ciblés : aucune occurrence.
- Validation stricte finale du change sous devops : réussie.

## Cohérence du périmètre

| Élément | Contrôle |
| --- | --- |
| Code | Routage et aides relus ; génération et sélection groupée inchangées, création et OpenSpec testés. |
| AGENTS.md | Racine, exclusions et périmètre respectés ; aucune opération Git ni modification de PROMPTS. |
| PROJECT.md | Responsabilité du module projects conservée. |
| TECHNICAL.md | Nouvelles syntaxes et exceptions des anciennes commandes documentées. |
| BUILD.md | Construction et contenu du paquet inchangés. |
| DEVOPS.md | Chemin OpenSpec explicite utilisé sous devops ; fichier conservé. |
| README.md | Présentation générale toujours cohérente ; fichier conservé. |
| OpenSpec | Trois capacités cohérentes ; la clause sur l'ancien ordre OpenSpec reconnaît le nouveau DevOps pour le projet openspec. |

Seuls les six fichiers prévus et les artefacts du change ciblé ont été édités.
La clause de compatibilité OpenSpec a été ajustée pour appliquer l'exception
approuvée des anciennes syntaxes correspondant déjà à une commande valide.
Aucun autre change ni projet réel n'a été modifié ; aucune installation,
opération Git ou modification de configuration n'a été exécutée.

## Archivage et état terminal

`openspec archive reorder-projects-template-devops --json --yes`, sous devops
hors sandbox, a réussi. Le change a été archivé dans
`openspec/changes/archive/2026-10-02-reorder-projects-template-devops`.
Cinq exigences ont été synchronisées, sans ajout, suppression ni renommage.

Les validations strictes des capacités projects-template-devops,
projects-template-openspec et rid-help ont réussi sous devops après archivage.
Les informations sur la longueur des exigences ne sont pas bloquantes.
Le change actif n'existe plus, toutes les tâches sont prouvées et aucun
blocage du périmètre ne subsiste. Total : 121 tests ciblés réussis.
